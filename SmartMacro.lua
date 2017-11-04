local addonName, addonNamespace = ...

local function EntryPoint()
    LoadAddOn('SugarBase')
    LoadAddOn('ButtonForge')
    
    local SugarBase = LibStub:GetLibrary('SugarBase-0.0.0', 0)
	local Database = addonNamespace.Database(SugarBase)
    local MyMacros = addonNamespace.MyMacros()
    local Frames = addonNamespace.Frames(MyMacros)
    local Tooltips = addonNamespace.Tooltips(Frames)
    
    addonNamespace.Integration.BlizzardUI(Tooltips)
    addonNamespace.Integration.ButtonForge(true, Tooltips)

    local Main = addonNamespace.Main(Database, Frames, MyMacros)
end

local frame = CreateFrame('FRAME', nil, UIParent)

frame:RegisterEvent('ADDON_LOADED')

frame:SetScript('OnEvent', function (self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        EntryPoint()
    end
end)