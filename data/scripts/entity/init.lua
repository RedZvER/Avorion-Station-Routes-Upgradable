local entity = Entity()
local debugReset = true
if debugReset and entity.playerOwned and entity:getValue("max_routes") > 3 then
    entity:setValue("max_routes", 3)
end