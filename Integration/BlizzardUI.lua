local addonName, addonNamespace = ...

hooksecurefunc("ActionButton_SetTooltip", function (self)
    if addonNamespace.SetTooltipCallback then
        addonNamespace.SetTooltipCallback(self)
    end
end)

hooksecurefunc("GameTooltip_OnHide", function (self)
    if addonNamespace.HideTooltipCallback then
        addonNamespace.HideTooltipCallback(self)
    end
end)