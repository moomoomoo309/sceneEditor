local object = require "object"

local properties = {}

--- "Walks" through a table, I.E. Iterates through an N-deep table as if it were a flat table. Returns key(s) and value.
--- Use it like pairs() or ipairs() in a for loop. The key(s) will always be in a table.
local function walk(tbl)
    local indices = {}
    local indicesLen = 1
    local function appendKey(indices, indicesLen, key)
        --Always return copies of the table, since it will be modified within the coroutine.
        local newIndices = {}
        for i = 1, indicesLen - 1 do
            newIndices[i] = indices[i]
        end
        --Append key, but since no more values will be appended to this copy, indicesLen does not need to be incremented.
        newIndices[indicesLen] = key
        return newIndices
    end

    local searchTblWrapper

    local function searchTbl(tbl, indices, indicesLen)
        --Make a copy of indices, so each reference frame of this function has its own copy of indices.
        local indicesCopy = {}
        for i = 1, indicesLen - 1 do
            indicesCopy[i] = indices[i]
        end
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                indicesCopy[indicesLen] = k --Add the current key into the indices.
                for _ in searchTblWrapper(v, indicesCopy, indicesLen + 1), v, nil do
                    doNothing() --IntelliJ doesn't like empty for loops, even though it makes shorter code in this case.
                end
            else
                coroutine.yield(appendKey(indicesCopy, indicesLen, k), v)
            end
        end
    end

    searchTblWrapper = function(tbl, indices, indicesLen)
        return function()
            searchTbl(tbl, indices, indicesLen)
        end
    end

    return coroutine.wrap(searchTblWrapper(tbl, indices, indicesLen)), tbl, nil
end

--- This is what you would give the results from table.indexOf() to.
--- The first argument should be the table being accessed, the following arguments should be the indices in order.
--- Example use: To access tbl.bacon[a][5].c, use "getTblVal(tbl,unpack{"bacon",a,5,"c"})" or "getTblVal(tbl,"bacon",a,5,"c")"
local function getTblVal(...)
    return select("#", ...) >= 3 and tablex.get((...)[select(2, ...)], select(3, ...)) or (...)[select(2, ...)]
end

function properties.new(_, args)
    local obj = object {
        x = args.x or 0,
        y = args.y or 0,
        w = args.w or 0,
        h = args.h or 0,
        sprites = args.sprites or {},
        open = {}
    }
    assert(type(obj.x) == "number", ("Number expected, got %s."):format(type(obj.x)))
    assert(type(obj.y) == "number", ("Number expected, got %s."):format(type(obj.y)))
    assert(type(obj.w) == "number", ("Number expected, got %s."):format(type(obj.w)))
    assert(type(obj.h) == "number", ("Number expected, got %s."):format(type(obj.h)))
    assert(type(obj.sprites) == "table", ("Table expected, got %s."):format(type(obj.sprites)))
    obj.class = properties
end

return setmetatable(properties, { __index = object, __call = properties.new })


