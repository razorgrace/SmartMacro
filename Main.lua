local addonName, addonNamespace = ...

addonNamespace.Main = function (Database, Frames, MyMacros)
    local persistentStorageVariableName = 'SmartMacroSaved'
    local persistentStorage
    local transientStorage = {}
    local privateTransientStorage = {}
    local DEFAULT_ICON = nil
    
    local function toCamelCase(str)
        return str:gsub('[^%w%s]', ''):gsub('(%w)(%w*)', function (a, b) return a:upper() .. b end):gsub('%s+', '')
    end
        
    local function initStorage(bucket)
        if bucket.localStorage == nil then
            bucket.localStorage = {}
        end
    
        if bucket.privateLocalStorage == nil then
            bucket.privateLocalStorage = {}
        end
    
        if bucket.globalStorage == nil then
            bucket.globalStorage = {}
        end
    end
    
    local function getLocalStorage(bucket, id)
        if bucket.localStorage[id] == nil then
            bucket.localStorage[id] = {}
        end
    
        return bucket.localStorage[id]
    end
    
    local function getPrivateLocalStorage(bucket, id)
        if bucket.privateLocalStorage[id] == nil then
            bucket.privateLocalStorage[id] = {}
        end
    
        return bucket.privateLocalStorage[id]
    end
    
    local function getGlobalStorage(bucket)
        return bucket.globalStorage
    end
    
    local function cache(storage, key, func)
        if storage[key] == nil then
            (function (...)
                storage[key] = { ... }
            end)(func())
        end
    
        return unpack(storage[key])
    end
    
    local function extractIdFromTaggedMacroName(name)
        return type(name) == 'string' and tonumber(name:match('<SM(%d+)>'))
    end
    
    addonNamespace.extractIdFromTaggedMacroName = extractIdFromTaggedMacroName
    
    local function splitIntoLines(text)
        local result = {}
        for str in string.gmatch(text, "[^\n\r]+") do
            table.insert(result, str)
        end
        return result
    end
    
    local function convertSmartMacroToLuaCode(env, lines)
        local result = ''
        local args = {}
    
        if table.getn(lines) == 0 then
            result = result .. 'return \'\''
        else
            local vars = ''
    
            for k, v in pairs(env) do
                table.insert(args, v)
    
                if vars ~= '' then
                    vars = vars .. ', '
                end
    
                vars = vars .. k
            end
    
            if vars ~= '' then
                result = result .. 'local ' .. vars .. ' = ...\n'
            end
    
            result = result .. 'local __result = \'\'\n'
    
            for k, line in pairs(lines) do
                if not string.match(line, '^%s*[/#]') then
                    result = result .. line .. '\n'
                else
                    result = result .. '__result = __result .. \'' ..  tostring(line):gsub('{{(.-)}}', function (expr)
                        return '\' .. tostring(' .. (expr) .. ') .. \''
                    end) .. '\\n\'\n'
                end
            end
    
            result = result .. 'return __result\n'
        end
    
        return result, args
    end
    
    local function shortenMacro(text)
        local lines = splitIntoLines(text)
        local result = ''
    
        for i, line in pairs(lines) do
            line = string.match(line, '^%s*(.*)$')
            if line ~= '' then
                if result == '' then
                    result = line
                else
                    result = result .. '\n' .. line
                end
            end
        end
    
        return result
    end
    
    local function flattenSmartMacro(desc)
        local lines = splitIntoLines(desc.text)
        local code, args = convertSmartMacroToLuaCode(desc.env, lines)
        local func, err = loadstring(code)
        if err then
            error(err)
        end
        return shortenMacro(func(unpack(args)))
    end
    
    local function formatMacroTag(id)
        return string.format('<SM%d>', id)
    end
    
    local function formatMacroName(id, name)
        local maxLength = 16
        local ellipsis = '...'
        local tag = formatMacroTag(id)
    
        if string.len(name) < maxLength - string.len(tag) then
            return name .. tag
        else
            return string.sub(name, 1, maxLength - string.len(tag) - string.len(ellipsis)) .. ellipsis .. tag
        end
    end
    
    local function isMacroTagged(macroID, tag)
        local name, texture, body = GetMacroInfo(macroID)
        return name ~= nil and name:find(tag) ~= nil
    end
    
    local function findMacro(desc, global)
        -- local macroID = GetMacroIndexByName(formatMacroName(desc.id, desc.name))
    
        -- if macroID and macroID ~= 0 then
        --     return macroID
        -- end
    
        local tag = formatMacroTag(desc.id)
        local minMacroID = global and 1 or (MAX_ACCOUNT_MACROS + 1)
        local maxMacroID = global and MAX_ACCOUNT_MACROS or (MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS)
        
        for macroID = minMacroID, maxMacroID do
            if isMacroTagged(macroID, tag) then
                return macroID
            end
        end
    
        -- for macroID = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        --     if isMacroTagged(macroID, tag) then
        --         return macroID
        --     end
        -- end
    
        return nil
    end
    
    local function initMacro(desc)
        if desc.initialized then
            return
        end
    
        desc.initialized = true
    
        if not desc.env then
            desc.env = {}
        end
    
        desc.env.api = {
            getLocalStorage = function () return getLocalStorage(transientStorage, desc.id) end,
            getGlobalStorage = function () return getGlobalStorage(transientStorage) end,
            getPersistentLocalStorage = function () return getLocalStorage(persistentStorage, desc.id) end,
            getPersistentGlobalStorage = function () return getLocalStorage(persistentStorage) end,
    
            getFrames = function ()
                local storage = getGlobalStorage(privateTransientStorage)
                -- print(storage.frames[desc.id])
    
                if storage.currentFrames and storage.currentFrames[desc.id] then
                    return {unpack(storage.currentFrames[desc.id])}
                else
                    return {}
                end
            end,
    
            cache = function (key, func) return cache(getPrivateLocalStorage(transientStorage, desc.id), key, func) end,
    
            setName = function (value) desc.name = value end,
            setIcon = function (value) desc.icon = value or DEFAULT_ICON end,
    
            spell = Database.GetSpellMetaObject(),
            player = Database.GetPlayerMetaObject(),
            mount = Database.GetMountMetaObject(),
        }

        if type(desc.init) == 'function' then
            for k, v in pairs(desc.init(desc.env.api) or {}) do
                desc.env[k] = v
            end
        end
    end
    
    local function updateMacro(desc)
        initMacro(desc)
    
        if desc.hasErrors or (desc.env and desc.env.IsMacroEnabled and not desc.env.IsMacroEnabled()) then
            return
        end
    
        local status, error = pcall(function ()
            local storage = getPrivateLocalStorage(transientStorage, desc.id)
    
            if desc.trigger and (desc.trigger ~= '') then
                local trigger = SecureCmdOptionParse(desc.trigger) or '<nil>'
                if storage.trigger ~= trigger then
                    storage.trigger = trigger
                else
                    return
                end
            end
    
            local text = flattenSmartMacro(desc)
            local name = formatMacroName(desc.id, desc.name)
            local icon = desc.icon or 'INV_MISC_QUESTIONMARK'
    
            local macroID = findMacro(desc, desc.global)
    
            if macroID then
                local newName = name ~= storage.name and name or nil
                local newTexture = icon ~= storage.icon and icon or nil
                local newBody = text ~= storage.text and text or nil
    
                if newName or newTexture or newBody then
                    -- print("Editing macro:")
                    -- print("name = ", name)
                    -- print("icon = ", icon)
                    -- print("text = ", text)
                    EditMacro(macroID, newName, newTexture, newBody)
                -- else
                    -- print("Not going to change macro:")
                    -- print("name = ", name)
                    -- print("icon = ", icon)
                    -- print("text = ", text)
                end
            else
                -- print("Creating macro:")
                -- print("name = ", name)
                -- print("icon = ", icon)
                -- print("text = ", text)
                CreateMacro(name, icon, text, not desc.global)
            end
    
            storage.name = name
            storage.icon = icon
            storage.text = text
    
            local previousFrames = {}
            local currentFrames = {}
            local allFrames = {}
    
            local function getPreviousFrames(storage, id)
                local tmp = getGlobalStorage(storage).previousFrames
                if tmp and tmp[id] then
                    return tmp[id]
                else
                    return {}
                end
            end
            
            local function getCurrentFrames(storage, id)
                local tmp = getGlobalStorage(storage).currentFrames
                if tmp and tmp[id] then
                    return tmp[id]
                else
                    return {}
                end
            end
            
            for _, frame in pairs(getPreviousFrames(privateTransientStorage, desc.id)) do
                allFrames[tostring(frame)] = frame
                previousFrames[tostring(frame)] = frame
            end
    
            for _, frame in pairs(getCurrentFrames(privateTransientStorage, desc.id)) do
                allFrames[tostring(frame)] = frame
                currentFrames[tostring(frame)] = frame
            end
    
            local detachedFrames = {}
            local attachedFrames = {}
    
            for key, frame in pairs(allFrames) do
                if currentFrames[key] and not previousFrames[key] then
                    table.insert(attachedFrames, frame)
                elseif previousFrames[key] and not currentFrames[key] then
                    table.insert(detachedFrames, frame)
                end
            end
    
            if #detachedFrames > 0 then
                if desc.env.OnDetachFrames then
                    desc.env.OnDetachFrames(detachedFrames)
                end
    
                if desc.env.OnDetachFrame then
                    for _, frame in pairs(detachedFrames) do
                        desc.env.OnDetachFrame(frame)
                    end
                end
            end
    
            if #attachedFrames > 0 then
                if desc.env.OnAttachFrames then
                    desc.env.OnAttachFrames(attachedFrames)
                end
    
                if desc.env.OnAttachFrame then
                    for _, frame in pairs(attachedFrames) do
                        desc.env.OnAttachFrame(frame)
                    end
                end
            end
        end)
    
        if not status then
            desc.hasErrors = true
            print(
                string.format("Failed updating macro #%s %s: %s",
                    desc.id,
                    desc.name,
                    error
                )
            )
        end
    end
    
    -- local c = CreateMacro
    -- CreateMacro = function (...)
    --     print('CreateMacro', ...)
    --     return c(...)
    -- end
    
    -- local e = EditMacro
    -- EditMacro = function (...)
    --     print('EditMacro', ...)
    --     return e(...)
    -- end
    
    local frame = CreateFrame('FRAME', nil, UIParent)
    
    if type(_G[persistentStorageVariableName]) ~= 'table' then
        _G[persistentStorageVariableName] = {}
    end

    persistentStorage = _G[persistentStorageVariableName]

    initStorage(persistentStorage)
    initStorage(transientStorage)
    initStorage(privateTransientStorage)

    local previous = GetTime()
    local interval = 1

    frame:SetScript('OnUpdate', function ()
        local current = GetTime()
        if current - previous >= interval then
            previous = current
        end
    
        if not InCombatLockdown() then
            -- local current = GetTime()
            -- if previous == nil or current - previous >= interval then
                -- previous = current
    
                Frames.ScanFrames()

                for k, v in pairs(MyMacros.List) do
                    if Frames.MacroHasFrames(v.id) then
                        updateMacro(v)
                    end
                end
            -- end
        end
    end)

    persistentStorage.dump = nil
    -- persistentStorage.dump = (function ()
    --     local result = {}

    --     local function isBig(v)
    --         local size = 0
    --         local maxSize = 1000

    --         local function walk(v)
    --             if size > maxSize then
    --                 return
    --             end

    --             size = size + 1

    --             if type(v) == 'table' then
    --                 for k, sv in pairs(v) do
    --                     walk(sv)
    --                 end
    --             end
    --         end

    --         walk(v)

    --         return size > maxSize
    --     end

    --     for k, v in pairs(_G) do
    --         if k ~= persistentStorageVariableName then
    --             if isBig(v) then
    --                 result[k] = 'big'
    --             else
    --                 result[k] = v
    --             end
    --         end
    --     end

    --     return result
    -- end)()

    return {}
end