local addonName, addonNamespace = ...

if not addonNamespace.Integration then
    addonNamespace.Integration = {}
end

addonNamespace.Integration.BlizzardUI = function (Tooltips)
    hooksecurefunc("ActionButton_SetTooltip", function (self)
        Tooltips.SetTooltipCallback(self)
    end)
    
    hooksecurefunc("GameTooltip_OnHide", function (self)
        Tooltips.HideTooltipCallback(self)
    end)        
end