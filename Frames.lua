local addonName, addonNamespace = ...

local storage = {
    previousFrames = {},
    currentFrames = {},
}

local function findFrames()
    local result = {}

    local frame = EnumerateFrames()
    while frame do
        if frame:IsVisible() then
            if type(frame.GetObjectType) == 'function' and frame:GetObjectType() == 'CheckButton' and type(frame.GetAttribute) == 'function' then
                local ourKey = '$$SmartMacroFlag'
                if not frame[ourKey] then
                    frame[ourKey] = true
                    frame:HookScript("OnClick", function (self, button, down)
                        -- print(...)
                    end)
                end

                local type = frame:GetAttribute('type')
                local macroId = nil

                if type == 'action' then
                    local actionType, id, _, _ = GetActionInfo(frame:GetAttribute('action'))
                    if actionType == 'macro' then
                        macroId = id
                    end
                elseif type == 'macro' then
                    macroId = frame:GetAttribute('macro')
                end

                if macroId then
                    local name, texture, body = GetMacroInfo(macroId)
                    if name ~= nil then
                        local id = addonNamespace.extractIdFromTaggedMacroName(name)
                        if id ~= nil then
                            if result[id] == nil then
                                result[id] = {}
                            end
                            table.insert(result[id], frame)
                        end
                    end
                end
            end
       end
       frame = EnumerateFrames(frame)
    end

    return result
end

addonNamespace.ScanFrames = function ()
    storage.previousFrames = storage.currentFrames
    storage.currentFrames = findFrames()
end

addonNamespace.GetFrames = function ()
    return storage.currentFrames
end

addonNamespace.FindMacroByFrame = function (ref)
    for id, frames in pairs(storage.currentFrames) do
        for _, frame in pairs(frames) do
            if ref == frame then
                return addonNamespace.MyMacros[id]
            end
        end
    end
end

addonNamespace.MacroHasFrames = function (id)
    return storage.currentFrames[id] ~= nil
end