local addonName, addonNamespace = ...

addonNamespace.MyMacros = {
    [1] = {
        id = 1,
        trigger = '[mod]',
        name = 'Travel',
        icon = 'achievement_guildperk_mountup',
        env = {
            env = 'env',
        },
        init = function (api)
            -- LoadAddOn("Blizzard_MountCollection")

            local function findMountJournalIdBySpellId(id)
                return api.cache('findMountJournalIdBySpellId/' .. id, function ()
                    for mountID = 1, C_MountJournal.GetNumMounts() do
                        local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountID)
                        if spellID == id and isUsable then
                            return mountID
                        end
                    end
                end)
            end

            return {
                class = function () return select(2, UnitClass('player')) end,

                specialMount = function ()
                    return findMountJournalIdBySpellId(122708) or -- Grand Expedition Yak
                        findMountJournalIdBySpellId(61425) or -- Traveler's Tundra Mammoth
                        0 -- random favorite mount
                end,

                ShamanGhostWolf = function () return (GetSpellInfo(2645)) end,
                DruidTravelForm = function () return (GetSpellInfo(783)) end,

                hasMagicBroom = function () return GetItemCount(37011) > 0 end,
                MagicBroom = function () return (GetItemInfo(37011)) end,
            }
        end,
        text = [[
            #showtooltip
            /stopmacro [flying]

            if class() == 'DRUID' then
                -- /click MountJournalSummonRandomFavoriteButton
                /run C_MountJournal.SummonByID(SecureCmdOptionParse("[mod]") and {{specialMount()}} or 0)
                /run UIErrorsFrame:Clear()
                /use {{DruidTravelForm()}}
            else
                /run C_MountJournal.SummonByID(SecureCmdOptionParse("[mod]") and {{specialMount()}} or 0)
                /run UIErrorsFrame:Clear()
    
                if hasMagicBroom() then
                    /cancelaura {{MagicBroom()}}
                    /use [nocombat,noindoors] {{MagicBroom()}}
                end
    
                if hasMagicBroom() then
                    /cancelaura {{MagicBroom()}}
                    /use [nocombat,noindoors] {{MagicBroom()}}
                end

                if class() == 'SHAMAN' then
                    /use {{ShamanGhostWolf()}}
                end
            end

            -- local flag = api.getLocalStorage().flag
        
            -- for k, button in pairs(api.getFrames()) do
            --     if flag then
            --         ActionButton_ShowOverlayGlow(button)
            --     else
            --         ActionButton_HideOverlayGlow(button)
            --     end
            -- end

            -- api.getLocalStorage().flag = not flag

            -- api.setIcon(SecureCmdOptionParse("[mod]") and 132243 or 134400)
        ]],
    },
    [2] = {
        id = 2,
        name = 'Racial',
        text = [[
            #showtooltip

            if api.player.isDraenei then
                /cast {{api.spell.GiftOfTheNaaru}}
            elseif api.player.isHuman then
                /cast {{api.spell.EveryManForHimself()}}
            end
        ]],
    },
    [3] = {
        id = 3,
        name = 'Dispel',
        text = [[
            #showtooltip
            -- /cast [mod,@player][@mouseover] {{GetSpellName()}}

            if api.player.isPriest then
                /cast [harm,mod,@target][harm,@mouseover] {{api.spell.DispelMagic}}
                if api.player.isShadow then
                    /cast [mod,@player][@mouseover] {{api.spell.PurifyDisease}}
                else
                    /cast [mod,@player][@mouseover] {{api.spell.Purify}}
                end
            elseif api.player.isPaladin then
                if api.player.isHoly then
                    /cast [mod,@player][@mouseover] {{api.spell.Cleanse}}
                else
                    /cast [mod,@player][@mouseover] {{api.spell.CleanseToxins}}
                end
            elseif api.player.isShaman then
                /cast [harm,mod,@target][harm,@mouseover] {{api.spell.Purge}}
                if api.player.isRestoration then
                    /cast [mod,@player][@mouseover] {{api.spell.PurifySpirit}}
                else
                    /cast [mod,@player][@mouseover] {{api.spell.CleanseSpirit}}
                end
            elseif api.player.isRestorationDruid then
                /cast [mod,@player][@mouseover] {{api.spell.NaturesCure}}
            end
        ]],
    },
    [4] = {
        id = 4,
        name = 'Resurrect',
        text = [[
            #showtooltip

            if api.player.isPaladin then
                if api.player.isHoly then
                    /cast [mod] {{api.spell.Absolution}}; {{api.spell.Redemption}}
                else
                    /cast {{api.spell.Redemption}}
                end
            elseif api.player.isPriest then
                if api.player.isShadow then
                    /cast {{api.spell.Resurrection}}
                else
                    /cast [mod] {{api.spell.MassResurrection}}; {{api.spell.Resurrection}}
                end
            end
        ]],
    },
    [5] = {
        id = 5,
        name = 'Sprint',
        trigger = '',
        text = [[
            #showtooltip

            if api.player.isPriest then
                if (api.player.isHoly or api.player.isDiscipline) and api.player.usesAngelicFeather then
                    /cast [@player] {{api.spell.AngelicFeather}}
                elseif (api.player.isShadow or api.player.isDiscipline) and api.player.usesBodyAndSoul then
                    /cast [@player] {{api.spell.PowerWordShield}}
                elseif api.player.isHoly and api.player.usesBodyAndMind then
                    /cast [@player] {{api.spell.BodyAndMind}}
                end
            elseif api.player.isPaladin then
                /cast {{api.spell.DivineSteed}}
            elseif api.player.isShaman then
                /cast {{api.spell.GhostWolf}}
            elseif api.player.isDruid then
                /cast {{api.spell.Dash}}
            elseif api.player.isDeathKnight then
                /cast {{api.spell.WraithWalk}}
            end
        ]],
    },
    [6] = {
        id = 6,
        name = 'Flask',
        init = function (api)
            local FlaskOfTenWhisperedPact = 127847
            local FlaskOfTenSeventhDemon = 127848
            local FlaskOfTenCountlessArmies = 127849
            local FlaskOfTenThousandScars = 127850
            local SpiritFlask = 127858
            
            local function getOptions()
                local options = {}
                
                -- if api.player.usesIntellect then
                    table.insert(options, FlaskOfTenWhisperedPact)
                -- end

                -- if api.player.usesAgility then
                    table.insert(options, FlaskOfTenSeventhDemon)
                -- end

                -- if api.player.usesStrength then
                    table.insert(options, FlaskOfTenCountlessArmies)
                -- end

                -- if api.player.isTank then
                    table.insert(options, FlaskOfTenThousandScars)
                -- end

                -- if GetItemCount(127858) > 0 then
                    table.insert(options, SpiritFlask)
                -- end

                return options
            end
            
            local function getValue()
                local specializationId = (GetSpecializationInfo(GetSpecialization()))
                local storage = api.getPersistentLocalStorage()

                if type(storage.value) ~= 'table' then
                    storage.value = {}
                end

                if not storage.value[specializationId] then
                    storage.value[specializationId] = 0
                end

                return storage.value[specializationId]
            end

            local function setValue(value)
                local specializationId = (GetSpecializationInfo(GetSpecialization()))
                local storage = api.getPersistentLocalStorage()

                if type(storage.value) ~= 'table' then
                    storage.value = {}
                end

                storage.value[specializationId] = value
            end

            local function getSelectedOption()
                local options = getOptions()
                local value = getValue()
                if value < 1 or value > #options then
                    value = 1
                end
                if value > #options then
                    value = #options
                end
                return options[value]
            end

            local function selectPreviousOption()
                local options = getOptions()
                local value = getValue() - 1
                if value < 1 then
                    value = #options
                end
                setValue(value)
            end
            
            local function selectNextOption()
                local options = getOptions()
                local value = getValue() + 1
                if value > #options then
                    value = 0
                end
                setValue(value)
            end

            return {
                updateHandlers = updateHandlers,
                getSelectedOption = getSelectedOption,

                OnDetachFrame = function (frame)
                    frame:EnableMouseWheel(false)
                    frame:SetScript("OnMouseWheel", nil)
                end,

                OnAttachFrame = function (frame)
                    frame:EnableMouseWheel(true)
                    frame:SetScript("OnMouseWheel", function(self, delta)
                        if delta < 0 then
                            selectNextOption()
                        else
                            selectPreviousOption()
                        end
                    end)
                end,

                OnUpdateTooltip = function (frame, tooltip)
                    tooltip:AddLine(' ')
                    tooltip:AddLine('Available flasks')
                    for i, option in ipairs(getOptions()) do
                        local name, _, _, _, _, _, _, _, _, texture, _ = GetItemInfo(option)

                         -- In case we're lagging, provide some decent defaults:
                        if not name then
                            name = 'Item #' .. option
                            texture = 134400 -- Question mark icon
                        end

                        -- Using texture escape sequence instead of AddTexture because:
                        -- 1. To avoid hitting 10 textures limitation
                        -- 2. To avoid resolving texture ID (returned by GetItemInfo) to filename (required by AddTexture)
                        if option == getSelectedOption() then
                            tooltip:AddDoubleLine("|T" .. texture .. ":0|t " .. name, '>>> ' .. GetItemCount(option), 0.5, 1.0, 0.5, 0.5, 1.0, 0.5)
                        else
                            tooltip:AddDoubleLine("|T" .. texture .. ":0|t " .. name, GetItemCount(option), 1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
                        end
                    end
                end,
            }
        end,
        text = [[
            #showtooltip

            /use item:{{getSelectedOption()}}
        ]],
    },
    [7] = {
        id = 7,
        name = 'AP',
        global = true,
        init = function (api)
            local getAmount = (function ()
                local tooltipScanner = (function ()
                    local id = 0

                    local function findLine(tooltip, pattern)
                        local loaded = false
                        
                        for i = 1, tooltip:NumLines() do
                            local fontString = _G[tooltip:GetName() .. 'TextLeft' ..i]
                            if fontString then
                                local text = fontString:GetText()
    
                                if (type(text) == 'string') then
                                    if text:match(pattern) then
                                        return text
                                    end
    
                                    loaded = true
                                end
                            end
                        end
    
                        if loaded then
                            return false
                        else
                            return nil
                        end
                    end
    
                    return function (pattern)
                        id = id + 1

                        local tooltip = CreateFrame("GameTooltip", addonName .. 'ScannerTooltip' .. id, nil, "GameTooltipTemplate")
                        tooltip:SetOwner(UIParent, "ANCHOR_NONE")

                        local cache = setmetatable({}, { __index = function (self, link)
                            tooltip:SetHyperlink(link)
                            local text = findLine(tooltip, pattern)
                            self[link] = text
                            return text
                        end })

                        return function (link)
                            return cache[link]
                        end
                    end
                end)()

                local isApToken = tooltipScanner('\124cFFE6CC80' .. ARTIFACT_POWER .. '\124r')
                local getUseLine = tooltipScanner( '^' .. USE)                
                
                local function getArtifactPowerAmount(link)
                    local itemString = link:match('\124H(item:%d+:.-)\124h')

                    if not itemString then
                        return 0
                    end

                    local pieces = { strsplit(':', itemString) }

                    if not pieces[15] then
                        return 0
                    end

                    -- Numbers might be a bit off due to several unrelated sources:
                    local multipliers = {
                        [0] = 0.0,
                        [1] = 0.25,
                        [2] = 0.50,
                        [3] = 0.90,
                        [4] = 1.40,
                        [5] = 2.00,
                        [6] = 2.75,
                        [7] = 3.75,
                        [8] = 5.00,
                        [9] = 6.50,
                        [10] = 8.50,
                        [11] = 11.00,
                        [12] = 14.00,
                        [13] = 17.75,
                        [14] = 22.50,
                        [15] = 28.50,
                        [16] = 36.00,
                        [17] = 45.50,
                        [18] = 57.00,
                        [19] = 72.00,
                        [20] = 90.00,
                        [21] = 113.00,
                        [22] = 142.00,
                        [23] = 178.00,
                        [24] = 223.00,
                        [25] = 249.00,
                        [26] = 1001.00,
                        [27] = 1301.00,
                        [28] = 1701.00,
                        [29] = 2201.00,
                        [30] = 2901.00,
                        [31] = 3801.00,
                        [32] = 4901.00,
                        [33] = 6401.00,
                        [34] = 8301.00,
                        [35] = 10801.00,
                        [36] = 14001.00,
                        [37] = 18201.00,
                        [38] = 23701.00,
                        [39] = 30801.00,
                        [40] = 40001.00,
                        [41] = 160001.00,
                        [42] = 208001.00,
                        [43] = 270401.00,
                        [44] = 351501.00,
                        [45] = 457001.00,
                        [46] = 594001.00,
                        [47] = 772501.00,
                        [48] = 1004001.00,
                        [49] = 1305001.00,
                        [50] = 1696501.00,
                        [51] = 2205501.00,
                        [52] = 2867501.00,
                        [53] = 3727501.00,
                        [54] = 4846001.00,
                        [55] = 6300001.00,
                    }

                    local multiplier = multipliers[tonumber(pieces[15]) - 1]

                    if not multiplier then
                        return 0
                    end

                    pieces[15] = 1
                    
                    local text = getUseLine(table.concat(pieces, ':'))

                    if text == nil then
                        return nil
                    end

                    if text == false then
                        return 0
                    end

                    local baseAmount = tonumber((text:gsub('[^%d]', '')))

                    if not baseAmount then
                        return 0
                    end

                    return math.floor(baseAmount * multiplier)
                end
                
                local cache = setmetatable({}, { __index = function (self, link)                
                    local amount = nil

                    local flag = isApToken(link)

                    if flag == false then
                        amount = 0
                    elseif flag ~= nil then
                        amount = getArtifactPowerAmount(link)
                    end
    
                    self[link] = amount
    
                    return amount
                end })

                return function (link)
                    return cache[link]
                end
            end)()

            local scanBags = (function ()
                local cache = nil

                local frame = CreateFrame('FRAME', nil, UIParent)
                frame:RegisterEvent('BAG_UPDATE')
                frame:SetScript('OnEvent', function ()
                    cache = nil
                end)

                local function scan()
                    local total = 0
                    local list = {}

                    for bagIndex = 0, NUM_BAG_SLOTS do
                        for bagSlotIndex = 1, GetContainerNumSlots(bagIndex) do
                            local link = GetContainerItemLink(bagIndex, bagSlotIndex)
                            if type(link) == 'string' and link:match("item:%d+") then
                                local amount = getAmount(link)

                                if amount == nil then
                                    return nil
                                end

                                if amount > 0 then
                                    total = total + amount

                                    table.insert(list, {
                                        link = link,
                                        amount = amount,
                                        bag = bagIndex,
                                        slot = bagSlotIndex,
                                    })
                                end
                            end
                        end
                    end

                    return total, list
                end
    
                return function ()
                    if not cache then
                        local total, list = scan()

                        if not total then
                            return 0, {}
                        end

                        cache = { total, list }
                    end

                    return unpack(cache)
                end
            end)()
            
            return {
                scanBags = scanBags,

                OnUpdateTooltip = function (frame, tooltip)
                    local total, list = scanBags()

                    if #list > 0 then
                        tooltip:AddLine(' ')
                        tooltip:AddLine('Artifact power tokens in your bags:')
                        tooltip:AddLine(' ')
    
                        local maxItems = 10
                        local displayedItems = (#list <= maxItems) and #list or (maxItems - 1)
                        local subtotal = 0
                        for i = 1, displayedItems do
                            local item = list[i]
                            local name, _, quality, _, _, _, _, _, _, texture, _ = GetItemInfo(item.link)

                            --  -- In case we're lagging, provide some decent defaults:
                            if not name then
                                name = item.link
                                quality = 1
                                texture = 134400 -- Question mark icon
                            end

                            local r, g, b = GetItemQualityColor(quality)                        

                            -- Using texture escape sequence instead of AddTexture because:
                            -- 1. To avoid hitting 10 textures limitation
                            -- 2. To avoid resolving texture ID (returned by GetItemInfo) to filename (required by AddTexture)
                            tooltip:AddDoubleLine("|T" .. texture .. ":0|t " .. name, BreakUpLargeNumbers(item.amount, true), r, g, b)
                            subtotal = subtotal + item.amount
                        end

                        if #list > displayedItems then
                            local name = '...and ' .. (#list - displayedItems) .. ' more'
                            tooltip:AddDoubleLine(name, BreakUpLargeNumbers(total - subtotal, true))
                        end

                        tooltip:AddLine(' ')
                        tooltip:AddDoubleLine('Total', BreakUpLargeNumbers(total, true))
                    else
                        tooltip:ClearLines()
                        tooltip:AddLine('|T130775:0|t Can\'t find any artifact\npower tokens in your bags.')
                    end
                end,
            }
        end,
        text = [[
            #showtooltip

            local total, list = scanBags()

            if list[1] then
                /use {{list[1].bag}} {{list[1].slot}}
                api.setIcon('INV_MISC_QUESTIONMARK')
            else
                api.setIcon(130775)
                for _, frame in ipairs(api.getFrames()) do
                    _G[frame:GetName() .. 'Name']:Hide()
                end
            end
        ]],
    },
}