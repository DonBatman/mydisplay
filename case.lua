core.register_node("mydisplay:display_case", {
    description = "Glass Display Case",
    drawtype = "mesh",
    mesh = "mydisplay_case.obj",
    tiles = {"mydisplay_case.png", "default_glass.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    groups = {snappy = 2, cracky = 3},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },

    on_rightclick = function(pos, node, clicker, itemstack)
        local meta = core.get_meta(pos)
        local current_string = meta:get_string("item")
        local owner = meta:get_string("owner")
        local player_name = clicker:get_player_name()

        if core.is_protected(pos, player_name) then return itemstack end

        if current_string ~= "" then
            -- OWNER LOCK
            if owner ~= "" and owner ~= player_name then
                core.chat_send_player(player_name, core.colorize("#FF0000", "Owner only: " .. owner))
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
            meta:set_string("owner", "")
            mydisplay_clear_display_entities(pos)
            return clicker:get_wielded_item()
        end

        local name = itemstack:get_name()
        if name ~= "" then
            local temp_stack = ItemStack(itemstack)
            temp_stack:set_count(1)
            meta:set_string("item", temp_stack:to_string())
            meta:set_string("owner", player_name)
            
            local spawn_pos = {x=pos.x, y=pos.y-0.2, z=pos.z}
            local obj = core.add_entity(spawn_pos, "mydisplay:display_item", name)
            if obj then 
                local ent = obj:get_luaentity()
                ent.itemstring = name
            end
            if not core.settings:get_bool("creative_mode") then itemstack:take_item(1) end
            core.get_node_timer(pos):start(5)
            return itemstack
        end
    end,

    on_timer = function(pos)
        local meta = core.get_meta(pos)
        local item_string = meta:get_string("item")
        if item_string == "" then return false end
        
        local found = false
        for _, obj in ipairs(core.get_objects_inside_radius(pos, 0.8)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "mydisplay:display_item" then found = true break end
        end
        
        if not found then
            local stack = ItemStack(item_string)
            local item_name = stack:get_name()
            local spawn_pos = {x=pos.x, y=pos.y-0.2, z=pos.z}
            local obj = core.add_entity(spawn_pos, "mydisplay:display_item", item_name)
            if obj then obj:get_luaentity().itemstring = item_name end
        end
        return true
    end,

    after_dig_node = function(pos, oldnode, oldmetadata)
        local item = oldmetadata.fields.item
        mydisplay_clear_display_entities(pos)
        mydisplay_drop_item(pos, item)
    end,
})
