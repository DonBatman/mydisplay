core.register_node("mydisplay:magic_display", {
    description = "Magic Machine",
    drawtype = "mesh",
    mesh = "mydisplay_magic.obj",
    tiles = {"mydisplay_magic.png"},
    light_source = 5,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 1, level = 3, explosion_proof = 1},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5},
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
                core.chat_send_player(player_name, core.colorize("#FF0000", "Only " .. owner .. " can take this!"))
                return itemstack
            end

            local inv = clicker:get_inventory()
            local stack = ItemStack(current_string)
            stack:set_count(1)
            
            if clicker:get_wielded_item():is_empty() then
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
            
            local spawn_pos = mydisplay_get_magic_offset(pos)
            mydisplay_clear_display_entities(pos)
            
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
        for _, obj in ipairs(core.get_objects_inside_radius(pos, 1.0)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "mydisplay:display_item" then found = true break end
        end
        
        if not found then
            local stack = ItemStack(item_string)
            local spawn_pos = mydisplay_get_magic_offset(pos)
            local obj = core.add_entity(spawn_pos, "mydisplay:display_item")
            if obj then obj:get_luaentity().itemstring = stack:get_name() end
        end
        return true
    end,

    after_dig_node = function(pos, oldnode, oldmetadata)
        local item = oldmetadata.fields.item
        mydisplay_clear_display_entities(pos)
        if item then mydisplay_drop_item(pos, item) end
    end,
})
