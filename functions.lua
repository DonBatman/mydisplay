function mydisplay_clear_display_entities(pos)
    for _, obj in ipairs(core.get_objects_inside_radius(pos, 1.0)) do
        local ent = obj:get_luaentity()
        if ent and ent.name == "mydisplay:display_item" then
            obj:remove()
        end
    end
end

function mydisplay_drop_item(pos, item)
    if item and item ~= "" then
        local obj = core.add_item({x=pos.x, y=pos.y+0.5, z=pos.z}, item)
        if obj then
            obj:set_velocity({
                x = math.random(-1, 1),
                y = 2, 
                z = math.random(-1, 1)
            })
        end
    end
end

function mydisplay_get_shelf_offset(pos)
    local fdir = core.get_node(pos).param2
    local offset = {x = 0, y = 0.03, z = 0} 
    if fdir == 0 then offset.z = 0.38
    elseif fdir == 1 then offset.x = 0.38
    elseif fdir == 2 then offset.z = -0.38
    elseif fdir == 3 then offset.x = -0.38
    end
    return {x = pos.x + offset.x, y = pos.y + offset.y, z = pos.z + offset.z}
end

function mydisplay_get_frame_offset(pos)
    local fdir = core.get_node(pos).param2
    local offset = {x = 0, y = 0, z = 0}
    if fdir == 0 then offset.z = 0.35
    elseif fdir == 1 then offset.x = 0.35
    elseif fdir == 2 then offset.z = -0.35
    elseif fdir == 3 then offset.x = -0.35
    end
    return {x = pos.x + offset.x, y = pos.y + offset.y, z = pos.z + offset.z}
end

function mydisplay_get_rack_offset(pos)
    return {x = pos.x, y = pos.y + 0.3, z = pos.z}
end

function mydisplay_get_magic_offset(pos)
    return {x = pos.x, y = pos.y + 0.4, z = pos.z}
end

local function update_display(pos)
    mydisplay_clear_display_entities(pos) 
    
    local meta = core.get_meta(pos)
    local itemstring = meta:get_string("itemstring")
    
    if itemstring ~= "" then
        local obj = core.add_entity(pos, "mydisplay:display_item")
        if obj then
            obj:get_luaentity().itemstring = itemstring
            obj:set_pos(mydisplay_get_magic_offset(pos))
        end
    end
end

local function refresh_magic_display(pos)
    for _, obj in ipairs(core.get_objects_inside_radius(pos, 0.5)) do
        local ent = obj:get_luaentity()
        if ent and ent.name == "mydisplay:display_item" then
            obj:remove()
        end
    end

    local meta = core.get_meta(pos)
    local item = meta:get_string("itemstring")
    if item ~= "" then
        local obj = core.add_entity(mydisplay_get_magic_offset(pos), "mydisplay:display_item")
    end
end

function mydisplay_admin_cleanup(pos, user)
    local radius = 10
    local count = 0
    local objects = core.get_objects_inside_radius(pos, radius)
    
    for _, obj in ipairs(objects) do
        local ent = obj:get_luaentity()
        if ent and ent.name == "mydisplay:display_item" then
            obj:remove()
            count = count + 1
        end
    end
    
    core.chat_send_player(user:get_player_name(), 
        "Cleanup complete! Removed " .. count .. " display entities.")
end
