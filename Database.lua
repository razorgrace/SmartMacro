local addonName, addonNamespace = ...

addonNamespace.Database =function (SugarBase)
	local spellMetaObject = SugarBase.GetSpellMetaObject()
	local playerMetaObject = SugarBase.GetPlayerMetaObject()
	local mountMetaObject = SugarBase.GetMountMetaObject()
	
	return {
		GetSpellMetaObject = function () return spellMetaObject end,
		GetPlayerMetaObject = function () return playerMetaObject end,						
		GetMountMetaObject = function () return mountMetaObject end,
	}
end