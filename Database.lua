local addonName, addonNamespace = ...

LoadAddOn('SugarBase')

local SugarBase = LibStub:GetLibrary('SugarBase-0.0.0', 0)

local spellMetaObject = SugarBase.GetSpellMetaObject()
local playerMetaObject = SugarBase.GetPlayerMetaObject()

addonNamespace.GetSpellMetaObject = function () return spellMetaObject end
addonNamespace.GetPlayerMetaObject = function () return playerMetaObject end