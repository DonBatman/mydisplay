dofile(core.get_modpath("mydisplay") .. "/functions.lua")
dofile(core.get_modpath("mydisplay") .. "/pictures.lua")
dofile(core.get_modpath("mydisplay") .. "/rack.lua")
dofile(core.get_modpath("mydisplay") .. "/case.lua")
dofile(core.get_modpath("mydisplay") .. "/shelf.lua")
dofile(core.get_modpath("mydisplay") .. "/pedestal.lua")
dofile(core.get_modpath("mydisplay") .. "/magic.lua")
dofile(core.get_modpath("mydisplay") .. "/tool.lua")
dofile(core.get_modpath("mydisplay") .. "/armor.lua")
dofile(core.get_modpath("mydisplay") .. "/armor2.lua")


core.register_lbm({
    name = "mydisplay:timer_fix",
    nodenames = {"mydisplay:weapon_rack", "mydisplay:display_case", "mydisplay:shelf", "mydisplay:pedestal", "mydisplay:item_frame", "mydisplay:magic_display"},
    run_at_every_load = true,
    action = function(pos, node)
        core.get_node_timer(pos):start(5)
    end,
})

core.register_entity("mydisplay:display_item", {
    visual = "wielditem",
    visual_size = {x = 0.25, y = 0.25, z = 0.25},
    collisionbox = {0, 0, 0, 0, 0, 0},
    physical = false,
    static_save = true,
    itemstring = "",

    on_activate = function(self, staticdata)
        if staticdata and staticdata ~= "" then
            self.itemstring = staticdata
        end
        if self.itemstring and self.itemstring ~= "" then
            self.object:set_properties({wield_item = self.itemstring, glow = 14})
        end
    end,

    get_staticdata = function(self)
        return self.itemstring
    end,

on_step = function(self, dtime)
        self.timer = (self.timer or 0) + dtime
        local pos = self.object:get_pos()
        if not pos then return end

        local node = core.get_node(pos)
        local name = node.name
        if name == "air" or name == "ignore" then
            local node_below = core.get_node({x=pos.x, y=pos.y-1, z=pos.z})
            name = node_below.name
        end

        local is_static = string.find(name, "shelf") or string.find(name, "frame")
        
        if not is_static then
            local rot = self.object:get_rotation()
            self.object:set_rotation({x = rot.x, y = rot.y + dtime * 1.5, z = rot.z})
        end

        if string.find(name, "magic") then
            local bob = math.sin(self.timer * 2.5) * 0.12
            self.object:set_velocity({x = 0, y = bob, z = 0})
        else
            self.object:set_velocity({x = 0, y = 0, z = 0})
        end
    end,
})
