
core.register_tool("mydisplay:cleaner_tool", {
    description = "Display Cleanup Wand (Right-click to clear 10m radius)",
    inventory_image = "default_stick.png^[multiply:#ff0000",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        local pos = user:get_pos()
        mydisplay_admin_cleanup(pos, user)
        return itemstack
    end,
    on_place = function(itemstack, user, pointed_thing)
        local pos = user:get_pos()
        mydisplay_admin_cleanup(pos, user)
        return itemstack
    end,
})
