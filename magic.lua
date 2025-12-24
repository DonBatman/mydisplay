core.register_node("mydisplay:magic_display", {
    description = "Magic Altar",
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
    	local current = meta:get_string("item")
	
    	if current ~= "" then
        	local stack = ItemStack(current)
        	if clicker:get_wielded_item():is_empty() then
            	clicker:set_wielded_item(stack)
        	else
            	clicker:get_inventory():add_item("main", stack)
        	end
        	meta:set_string("item", "")
        	mydisplay_clear_display_entities(pos)
        	return clicker:get_wielded_item()
    	end
	
    	local name = itemstack:get_name()
    	if name ~= "" then
        	meta:set_string("item", name)
        	local spawn_pos = mydisplay_get_magic_offset(pos)
        	mydisplay_clear_display_entities(pos)
        	
        	local obj = core.add_entity(spawn_pos, "mydisplay:display_item", name)
        	
        	if obj then
            	local ent = obj:get_luaentity()
            	ent.itemstring = name
            	obj:set_properties({wield_item = name})
        	end
	
        	if not core.settings:get_bool("creative_mode") then
            	itemstack:take_item(1)
        	end
    	end
	end,
    
    on_timer = function(pos)
        local meta = core.get_meta(pos)
        local item_str = meta:get_string("item")
        if item_str == "" then return false end
        
        local found = false
        local objs = core.get_objects_inside_radius(pos, 1.0)
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "mydisplay:display_item" then 
                found = true 
                break 
            end
        end
        
        if not found then
            local stack = ItemStack(item_str)
            local spawn_pos = mydisplay_get_magic_offset(pos)
            local obj = core.add_entity(spawn_pos, "mydisplay:display_item")
            if obj then 
                obj:get_luaentity().itemstring = stack:get_name() 
            end
        end
        return true
    end,

    after_dig_node = function(pos, oldnode, oldmetadata)
        local item = oldmetadata.fields.item
        mydisplay_clear_display_entities(pos)
        if item then mydisplay_drop_item(pos, item) end
    end,
})
