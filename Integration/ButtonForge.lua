local addonName, addonNamespace = ...

if not addonNamespace.Integration then
    addonNamespace.Integration = {}
end

addonNamespace.Integration.ButtonForge = function (ButtonForge, Tooltips)
    if ButtonForge and BFButton then
        for k, _ in pairs(BFButton) do
            if k:match('^UpdateTooltip.+$') then
                _G['BFButton_' .. k] = BFButton[k]
                BFButton[k] = function (...)
                    return _G['BFButton_' .. k](...)
                end
                hooksecurefunc('BFButton_' .. k, function (self)
                    Tooltips.SetTooltipCallback(self.Widget or self)
                end)
            end
        end
    end        
end