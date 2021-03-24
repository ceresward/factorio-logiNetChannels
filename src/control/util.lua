local util = {}

function util.table_appendArray(tbl, arr)
    for _, item in pairs(arr) do
        table.insert(tbl, item)
    end
end

function util.table_appendArrayFiltered(tbl, arr, fn)
    for _, item in pairs(arr) do
        if fn(item) then
            table.insert(tbl, item)
        end
    end
end

return util