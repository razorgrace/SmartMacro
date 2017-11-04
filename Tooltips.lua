local addonName, addonNamespace = ...

addonNamespace.Tooltips = function (Frames)
    local lastMacro = nil
    
    local function setCurrentMacro(desc)
        if lastMacro ~= desc then
            if lastMacro and (lastMacro ~= desc) and (type(lastMacro.env.OnReleaseTooltip) == 'function') then
                lastMacro.env.OnReleaseTooltip(self)
            end

            if desc and (type(desc.env.OnAcquireTooltip) == 'function') then
                desc.env.OnAcquireTooltip(self, GameTooltip)
            end

            lastMacro = desc
        end

        if desc and (type(desc.env.OnUpdateTooltip) == 'function') then
            desc.env.OnUpdateTooltip(self, GameTooltip)
            GameTooltip:Show()
        end
    end

    return {
        SetTooltipCallback = function (frame)
            setCurrentMacro(Frames.FindMacroByFrame(frame))
        end,

        HideTooltipCallback = function ()
            setCurrentMacro(nil)
        end,
    }
end