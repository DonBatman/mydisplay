core.register_node("mydisplay:shelf", {
    description = "Display Shelf",
    drawtype = "mesh",
    mesh = "mydisplay_shelf.obj",
    tiles = {"mydisplay_shelf.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 2},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, 0.5, 0.5, -0.15, 0},
    },

    on_rightclick = function(pos, node, clicker, itemstack)
        local meta = core.get_meta(pos)
        local current = meta:get_string("item")
        if core.is_protected(pos, clicker:get_player_name()) then return itemstack end

        if current ~= "" then
            local inv = clicker:get_inventory()
            local stack = ItemStack(current)
            if clicker:get_wielded_item():get_count() == 0 then
                clicker:set_wielded_item(stack)
            else
                local leftover = inv:add_item("main", stack)
                if not leftover:is_empty() then core.add_item(pos, leftover) end
            end
            meta:set_string("item", "")
            mydisplay_clear_display_entities(pos)
            return clicker:get_wielded_item()
        end

        local name = itemstack:get_name()
        if name ~= "" then
            meta:set_string("item", itemstack:to_string())
            local obj = core.add_entity(mydisplay_get_shelf_offset(pos), "mydisplay:display_item", name)
            if obj then obj:get_luaentity().itemstring = name end
            if not core.settings:get_bool("creative_mode") then itemstack:take_item(1) end
            core.get_node_timer(pos):start(5)
            return itemstack
        end
    end,

    on_timer = function(pos)
        local meta = core.get_meta(pos)
        local item_str = meta:get_string("item")
        if item_str == "" then return false end
        local found = false
        for _, obj in ipairs(core.get_objects_inside_radius(pos, 0.8)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "mydisplay:display_item" then found = true break end
        end
        if not found then
            local stack = ItemStack(item_str)
            local obj = core.add_entity(mydisplay_get_shelf_offset(pos), "mydisplay:display_item", stack:get_name())
            if obj then obj:get_luaentity().itemstring = stack:get_name() end
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
    output = "mydisplay:shelf 2",
    recipe = {
        {"group:wood", "group:wood", "group:wood"},
        {"", "group:wood", ""},
    }
})
