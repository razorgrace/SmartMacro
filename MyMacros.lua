local addonName, addonNamespace = ...

addonNamespace.MyMacros = function ()
    local list = {}

    return {
        Add = function (item)
            list[item.id] = item
        end,

        GetNextId = function ()
            local max = 0

            for _, v in ipairs(list) do
                max = math.max(max, v.id)
            end

            return max + 1
        end,

        List = list,
    }
end