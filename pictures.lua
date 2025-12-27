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
        local stack = ItemStack(item)
        local obj = core.add_item({x=pos.x, y=pos.y+0.5, z=pos.z}, stack)
        if obj then
            obj:set_velocity({
                x = math.random(-1, 1),
                y = 2, 
                z = math.random(-1, 1)
            })
        end
    end
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

core.register_node("mydisplay:item_frame", {
    description = "Picture Frame",
    drawtype = "mesh",
    mesh = "mydisplay_frame.obj",
    tiles = {"mydisplay_frame.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 2},
    selection_box = {
        type = "fixed",
        fixed = {-0.45, -0.45, 0.4, 0.45, 0.45, 0.5}, 
    },

    on_rightclick = function(pos, node, clicker, itemstack)
        local meta = core.get_meta(pos)
        local current_string = meta:get_string("item")
        local owner = meta:get_string("owner")
        local player_name = clicker:get_player_name()

        -- Check area protection first
        if core.is_protected(pos, player_name) then return itemstack end

        -- OWNER CHECK: If an item is inside, only the owner can take it
        if current_string ~= "" then
            if owner ~= "" and owner ~= player_name then
                core.chat_send_player(player_name, core.colorize("#FF0000", "This item belongs to " .. owner .. "!"))
                return itemstack
            end

            local inv = clicker:get_inventory()
            local stack = ItemStack(current_string)
            stack:set_count(1)
            
            if clicker:get_wielded_item():get_count() == 0 then
                clicker:set_wielded_item(stack)
            else
                local leftover = inv:add_item("main", stack)
                if not leftover:is_empty() then core.add_item(pos, leftover) end
            end
            
            meta:set_string("item", "")
            meta:set_string("owner", "") -- Clear owner when empty
            mydisplay_clear_display_entities(pos)
            return clicker:get_wielded_item()
        end

        -- Placing an item
        local name = itemstack:get_name()
        if name ~= "" then
            local temp_stack = ItemStack(itemstack)
            temp_stack:set_count(1)
            
            meta:set_string("item", temp_stack:to_string())
            meta:set_string("owner", player_name) -- SET OWNER ON PLACEMENT
            
            local obj = core.add_entity(mydisplay_get_frame_offset(pos), "mydisplay:display_item", name)
            if obj then 
                local ent = obj:get_luaentity()
                ent.itemstring = name
                local rot = core.facedir_to_dir(node.param2)
                obj:set_yaw(core.dir_to_yaw(rot))
            end
            
            if not core.settings:get_bool("creative_mode") then 
                itemstack:take_item(1) 
            end
            
            core.get_node_timer(pos):start(5)
            return itemstack
        end
    end,

    on_timer = function(pos)
        local node = core.get_node(pos)
        local meta = core.get_meta(pos)
        local item_string = meta:get_string("item")
        if item_string == "" then return false end
        
        local found = false
        for _, obj in ipairs(core.get_objects_inside_radius(pos, 0.8)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "mydisplay:display_item" then 
                found = true 
                break 
            end
        end
        
        if not found then
            local stack = ItemStack(item_string)
            local item_name = stack:get_name()
            local obj = core.add_entity(mydisplay_get_frame_offset(pos), "mydisplay:display_item", item_name)
            if obj then 
                obj:get_luaentity().itemstring = item_name
                local rot = core.facedir_to_dir(node.param2)
                obj:set_yaw(core.dir_to_yaw(rot))
            end
        end
        return true
    end,

    after_dig_node = function(pos, oldnode, oldmetadata)
        local item = oldmetadata.fields.item
        mydisplay_clear_display_entities(pos)
        mydisplay_drop_item(pos, item)
    end,
})

core.register_craft({
    output = "mydisplay:item_frame",
    recipe = {
        {"default:stick", "default:stick", "default:stick"},
        {"default:stick", "default:paper", "default:stick"},
        {"default:stick", "default:stick", "default:stick"},
    }
})
