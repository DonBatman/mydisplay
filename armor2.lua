local function get_armor_texture2(item_name)
    if armor and armor.registered_armor and armor.registered_armor[item_name] then
        return armor.registered_armor[item_name].texture
    end
    local def = minetest.registered_items[item_name]
    if def and def.groups and def.groups.armor_use then
        return def.texture or (item_name:gsub(":", "_") .. ".png")
    end
    return nil
end

minetest.register_entity("mydisplay:visual_armor2", {
    initial_properties = {
        visual = "mesh",
        mesh = "mydisplay_entity.obj",
        visual_size = {x=1, y=1, z=1},
        physical = false,
        pointable = false,
        static_save = false,
        use_texture_alpha = true,
        textures = {"mydisplay_trans.png"},
    },
    on_activate = function(self)
        self.object:set_armor_groups({immortal = 1})
        self.object:set_animation({x=0, y=0}, 0, 0)
    end,
})

local function update_rack_visuals2(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    
    local objects = minetest.get_objects_inside_radius(pos, 0.5)
    for _, obj in ipairs(objects) do
        local ent = obj:get_luaentity()
        if ent and ent.name == "mydisplay:visual_armor2" then
            obj:remove()
        end
    end

    if inv:is_empty("armor_slots") then return end
    
    local node = minetest.get_node(pos)
    local dir = minetest.facedir_to_dir(node.param2)
    
    local offset = vector.multiply(dir, 0.23)
    local spawn_pos = vector.add(pos, offset)
    
    local ent_obj = minetest.add_entity(spawn_pos, "mydisplay:visual_armor2")
    
    if ent_obj then
        ent_obj:set_yaw(minetest.dir_to_yaw(dir))
    
        local textures = {}
        for i=1, 4 do
            local stack = inv:get_stack("armor_slots", i)
            if not stack:is_empty() then
                local tex = get_armor_texture2(stack:get_name())
                if tex then 
                    table.insert(textures, tex) 
                end
            end
        end
        
        local final_tex = "mydisplay_trans.png"
        if #textures > 0 then
            final_tex = table.concat(textures, "^")
        end
        
        ent_obj:set_properties({
            textures = {final_tex},
        })
    end
end

minetest.register_node("mydisplay:armor_rack2", {
    description = "Locked 3D Armor Display Rack 2",
    drawtype = "mesh",
    mesh = "mydisplay_rack3.obj", 
    tiles = {"mydisplay_rack2.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {choppy = 2, oddly_breakable_by_hand = 2},
    selection_box = {
    	type = "fixed",
    	fixed = {-0.5, -0.5, 0.4, 0.5, 1.5, 0.5}},
    collision_box = {
    	type = "fixed",
    	fixed = {-0.5, -0.5, 0.4, 0.5, 1.5, 0.5}},
    
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("armor_slots", 4)
    end,
    can_dig = function(pos, player)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local name = player:get_player_name()
        local owner = meta:get_string("owner")

        if not inv:is_empty("armor_slots") then
            minetest.chat_send_player(name, "You cannot dig the rack while it contains armor!")
            return false
        end

        if owner ~= "" and name ~= owner and not minetest.check_player_privs(name, "protection_bypass") then
            minetest.chat_send_player(name, "This armor rack belongs to " .. owner)
            return false
        end

        return true
    end,

    after_place_node = function(pos, placer)
        local meta = minetest.get_meta(pos)
        local name = placer:get_player_name() or ""
        meta:set_string("owner", name)
        meta:set_string("infotext", "Armor Rack (Owned by " .. name .. ")")
        update_rack_visuals2(pos)
    end,

    on_rightclick = function(pos, node, clicker, itemstack)
        local name = clicker:get_player_name()
        local meta = minetest.get_meta(pos)
        local owner = meta:get_string("owner")

        if owner ~= "" and name ~= owner and not minetest.check_player_privs(name, "protection_bypass") then
            minetest.chat_send_player(name, "This armor rack belongs to " .. owner)
            return itemstack
        end

        local pos_str = pos.x .. "," .. pos.y .. "," .. pos.z
        local formspec = "size[8,6.5]" ..
        	"background[0,0;8,8.5;mydisplay_bg.png;true]" ..
            "list[nodemeta:" .. pos_str .. ";armor_slots;2,0.5;4,1;]" ..
            "list[current_player;main;0,2.5;8,4;]" ..
            "listring[nodemeta:" .. pos_str .. ";armor_slots]" ..
            "listring[current_player;main]"
        
        minetest.show_formspec(name, "mydisplay:rack_inv2", formspec)
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if player:get_player_name() ~= minetest.get_meta(pos):get_string("owner") then return 0 end
        return stack:get_count()
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if player:get_player_name() ~= minetest.get_meta(pos):get_string("owner") then return 0 end
        return stack:get_count()
    end,

    on_metadata_inventory_put = function(pos) update_rack_visuals2(pos) end,
    on_metadata_inventory_take = function(pos) update_rack_visuals2(pos) end,
    on_metadata_inventory_move = function(pos) update_rack_visuals2(pos) end,

    on_destruct = function(pos)
        local objects = minetest.get_objects_inside_radius(pos, 0.1)
        for _, obj in ipairs(objects) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "mydisplay:visual_armor2" then
                obj:remove()
            end
        end
    end,
})

minetest.register_lbm({
    name = "mydisplay:restore_visuals2",
    nodenames = {"mydisplay:armor_rack2"},
    run_at_every_load = true,
    action = function(pos)
        update_rack_visuals2(pos)
    end,
})

minetest.register_craft({
    output = "mydisplay:armor_rack2",
    recipe = {
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
        {"", "default:wood", ""},
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
    }
})
