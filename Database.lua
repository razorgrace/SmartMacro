local addonName, addonNamespace = ...

addonNamespace.Database =function (SugarBase)
	local spellMetaObject = SugarBase.GetSpellMetaObject()
	local playerMetaObject = SugarBase.GetPlayerMetaObject()
	
	return {
		GetSpellMetaObject = function () return spellMetaObject end,
		GetPlayerMetaObject = function () return playerMetaObject end,						
	}
end