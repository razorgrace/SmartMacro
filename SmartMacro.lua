local addonName, addonNamespace = ...

local function EntryPoint()
    LoadAddOn('SugarBase')
    LoadAddOn('ButtonForge')
    
    local SugarBase = LibStub:GetLibrary('SugarBase-0.0.0', 0)
	local Database = addonNamespace.Database(SugarBase)
    local MyMacros = addonNamespace.MyMacros()
    local Frames = addonNamespace.Frames(MyMacros)
    local Tooltips = addonNamespace.Tooltips(Frames)

    return {
        OnStart = function ()
            addonNamespace.Integration.BlizzardUI(Tooltips)
            addonNamespace.Integration.ButtonForge(true, Tooltips)

            local Main = addonNamespace.Main(Database, Frames, MyMacros)
        end,

        RegisterExternalItem = function (uniqueId, item)
            local var = 'SmartMacroSaved'

            if not _G[var].externals then
                _G[var].externals = {}
            end

            if not _G[var].externals[uniqueId] then
                _G[var].externals[uniqueId] = MyMacros.GetNextId()
            end

            item.id = _G[var].externals[uniqueId]

            MyMacros.Add(item)
        end
    }
end

local frame = CreateFrame('FRAME', nil, UIParent)

frame:RegisterEvent('ADDON_LOADED')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')

frame:SetScript('OnEvent', function (self, event, arg1)
    if event == 'ADDON_LOADED' and arg1 == addonName then
        _G[addonName] = EntryPoint()
    end

    if event == 'PLAYER_ENTERING_WORLD' then
        self:SetScript('OnEvent', nil)
        _G[addonName].OnStart()
    end
end)