// obj_context_menu - Step Event
var gui_mouse_x = device_mouse_x_to_gui(0);
var gui_mouse_y = device_mouse_y_to_gui(0);

// Constrain menu position to stay within GUI bounds
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
menu_x = clamp(menu_x, 0, gui_width - menu_width);
menu_y = clamp(menu_y, 0, gui_height - menu_height);

// Set options based on inventory type and item properties
options = ["Drop"]; // Default for non-containers
if (instance_exists(inventory) && ds_exists(inventory.inventory, ds_type_grid) && item_id >= 0) {
    var item_type = global.item_data[item_id][6];
    var is_stackable = global.item_data[item_id][3];
    var is_moddable = global.item_data[item_id][8];
    var qty = 0;
    var slot = inventory.inventory[# slot_x, slot_y];
    if (is_array(slot)) qty = slot[2];

    switch (inventory.inventory_type) {
        case "backpack":
            if (is_stackable && qty > 1) array_push(options, "Split Stack");
            switch (item_type) {
                case ITEM_TYPE.UTILITY:
                case ITEM_TYPE.WEAPON:
                    array_push(options, "Equip");
                    break;
            }
            if (is_moddable) array_push(options, "Mod");
            break;
        case "equipment_slots":
            array_push(options, "Unequip");
            if (is_moddable) array_push(options, "Mod");
            break;
        case "container":
            options = ["Take"]; // Only "Take" for containers
            break;
    }
    menu_height = max(30, array_length(options) * 30);
}

// Close menu on left-click outside or on selection, enforcing delay
if (mouse_check_button_pressed(mb_left)) {
    if (!point_in_rectangle(gui_mouse_x, gui_mouse_y, menu_x, menu_y, menu_x + menu_width, menu_y + menu_height)) {
        var inv_type = instance_exists(inventory) ? inventory.inventory_type : "unknown";
        instance_destroy();
        global.mouse_input_delay = 15; // Enforce delay on closure
        show_debug_message("Closed context menu for " + inv_type + " with no action, set delay to 15");
    }
}

// Handle option selection
if (mouse_check_button_pressed(mb_left) && point_in_rectangle(gui_mouse_x, gui_mouse_y, menu_x, menu_y, menu_x + menu_width, menu_y + menu_height)) {
    var option_height = 30;
    var option_index = floor((gui_mouse_y - menu_y) / option_height);
    if (option_index >= 0 && option_index < array_length(options)) {
        var option = options[option_index];
        var qty = 0;
        var top_left_x = slot_x;
        var top_left_y = slot_y;
        var item_width = 1;
        var item_height = 1;
        var slot = -1;

        if (instance_exists(inventory) && ds_exists(inventory.inventory, ds_type_grid)) {
            slot = inventory.inventory[# slot_x, slot_y];
            if (is_array(slot)) {
                var placement_id = slot[1];
                qty = slot[2];
                while (top_left_x > 0 && is_array(inventory.inventory[# top_left_x - 1, slot_y]) && inventory.inventory[# top_left_x - 1, slot_y][1] == placement_id) top_left_x -= 1;
                while (top_left_y > 0 && is_array(inventory.inventory[# slot_x, top_left_y - 1]) && inventory.inventory[# slot_x, top_left_y - 1][1] == placement_id) top_left_y -= 1;
                item_width = global.item_data[item_id][1];
                item_height = global.item_data[item_id][2];
                slot = inventory.inventory[# top_left_x, top_left_y];
            }
        }

        if (option == "Drop" && (inventory.inventory_type == "backpack" || inventory.inventory_type == "equipment_slots") && item_id >= 0) {
            var contained_items = (is_array(slot) && array_length(slot) > 3 && slot[3] != undefined) ? slot[3] : [];
            instance_create_layer(obj_player.x + irandom_range(-8, 8), obj_player.y + irandom_range(-8, 8), "Instances", obj_item, {
                item_id: item_id,
                stack_quantity: qty,
                placement_id: slot[1],
                contained_items: contained_items
            });
            if (inventory.inventory_type == "backpack") {
                inventory_remove(top_left_x, top_left_y, inventory.inventory);
            } else if (inventory.inventory_type == "equipment_slots") {
                inventory.inventory[# slot_x, 0] = -1;
            }
        } else if (option == "Split Stack" && inventory.inventory_type == "backpack" && item_id >= 0) {
            if (qty > 1) {
                var keep_qty = floor(qty / 2);
                var drag_qty = qty - keep_qty;

                if (is_array(slot)) {
                    var contained_items = (array_length(slot) > 3 && slot[3] != undefined) ? slot[3] : [];
                    // Remove the item from the slot before setting up the drag
                    inventory_remove(top_left_x, top_left_y, inventory.inventory);
                    // Add back the kept quantity
                    inventory_add_at(top_left_x, top_left_y, item_id, keep_qty, inventory.inventory, contained_items);

                    if (inventory.dragging == -1 && global.dragging_inventory == -1) {
                        inventory.dragging = [item_id, slot[1], drag_qty, contained_items];
                        global.dragging_inventory = inventory;
                        inventory.original_mx = top_left_x;
                        inventory.original_my = top_left_y;
                        inventory.drag_offset_x = -((item_width * inventory.slot_size * 0.8) / 2);
                        inventory.drag_offset_y = -((item_height * inventory.slot_size * 0.8) / 2);
                        inventory.just_split_timer = 0; // Reset to allow immediate context menu
                        global.mouse_input_delay = 15; // Restore delay to prevent immediate drop
                        show_debug_message("Split stack: " + string(keep_qty) + " kept, " + string(drag_qty) + " dragged");
                    }
                }
            }
        } else if (option == "Take" && inventory.inventory_type == "container" && item_id >= 0) {
            if (instance_exists(global.backpack)) {
                var contained_items = (is_array(slot) && array_length(slot) > 3 && slot[3] != undefined) ? slot[3] : [];
                var success = inventory_add_item(global.backpack, item_id, qty, true, contained_items);
                if (success) {
                    inventory_remove(top_left_x, top_left_y, inventory.inventory);
                    show_debug_message("Took " + global.item_data[item_id][0] + " from container to backpack");
                } else {
                    show_debug_message("Failed to take " + global.item_data[item_id][0] + " - backpack full");
                }
            }
        } else if (option == "Equip" && inventory.inventory_type == "backpack" && item_id >= 0) {
            var item_type = global.item_data[item_id][6];
            var target_slot = (item_type == ITEM_TYPE.UTILITY) ? 0 : 1;
            var equip_inv = global.equipment_slots;

            if (instance_exists(equip_inv) && ds_exists(equip_inv.inventory, ds_type_grid)) {
                var current_slot = equip_inv.inventory[# target_slot, 0];
                if (is_array(current_slot)) {
                    var current_id = current_slot[0];
                    var current_qty = current_slot[2];
                    var current_width = global.item_data[current_id][1];
                    var current_height = global.item_data[current_id][2];
                    var current_contained = (array_length(current_slot) > 3 && current_slot[3] != undefined) ? current_slot[3] : [];
                    var backpack = global.backpack;

                    if (instance_exists(backpack) && ds_exists(backpack.inventory, ds_type_grid)) {
                        // Simulate removal of the current equipped item to check space
                        var can_swap = false;
                        var swap_x = -1;
                        var swap_y = -1;

                        // Check space as if the equipped item is removed
                        for (var i = 0; i <= backpack.grid_width - current_width; i++) {
                            for (var j = 0; j <= backpack.grid_height - current_height; j++) {
                                if (inventory_can_fit(i, j, current_width, current_height, backpack.inventory)) {
                                    can_swap = true;
                                    swap_x = i;
                                    swap_y = j;
                                    break;
                                }
                            }
                            if (can_swap) break;
                        }

                        if (can_swap) {
                            var contained_items = (is_array(slot) && array_length(slot) > 3 && slot[3] != undefined) ? slot[3] : [];
                            // Perform the swap
                            equip_inv.inventory[# target_slot, 0] = [item_id, slot[1], qty, contained_items];
                            inventory_remove(top_left_x, top_left_y, inventory.inventory); // Remove new item from backpack
                            inventory_add_at(swap_x, swap_y, current_id, current_qty, backpack.inventory, current_contained); // Add old item back
                            show_debug_message("Swapped " + global.item_data[item_id][0] + " into equipment slot [" + string(target_slot) + ",0], moved " + global.item_data[current_id][0] + " to backpack at [" + string(swap_x) + "," + string(swap_y) + "]");
                        } else {
                            // Revert if no space (should not crash)
                            show_debug_message("No space in backpack for " + global.item_data[current_id][0] + " during swap with " + global.item_data[item_id][0]);
                        }
                    } else {
                        show_debug_message("Error: Backpack instance or inventory grid not found");
                    }
                } else {
                    // No item equipped, just equip the new one
                    var contained_items = (is_array(slot) && array_length(slot) > 3 && slot[3] != undefined) ? slot[3] : [];
                    equip_inv.inventory[# target_slot, 0] = [item_id, slot[1], qty, contained_items];
                    inventory_remove(top_left_x, top_left_y, inventory.inventory);
                    show_debug_message("Equipped " + global.item_data[item_id][0] + " into slot [" + string(target_slot) + ",0]");
                }
            } else {
                show_debug_message("Error: Equipment slots instance or inventory grid not found");
            }
        } else if (option == "Unequip" && inventory.inventory_type == "equipment_slots" && item_id >= 0) {
            var contained_items = (is_array(slot) && array_length(slot) > 3 && slot[3] != undefined) ? slot[3] : [];
            var success = inventory_add_item(global.backpack, item_id, qty, true, contained_items);
            if (success) {
                inventory.inventory[# slot_x, 0] = -1;
            }
        } else if (option == "Mod" && item_id >= 0) {
            if (global.item_data[item_id][8]) {
                var mod_width = global.item_data[item_id][9];
                var mod_height = global.item_data[item_id][10];
                var contained_items = (is_array(slot) && array_length(slot) > 3 && slot[3] != undefined) ? slot[3] : [];

                // Calculate mod inventory dimensions
                var slot_size = 32;
                var frame_w = (mod_width * slot_size) + (8 * 2);
                var total_w = frame_w + 8 + sprite_get_width(spr_help_close);
                var frame_h = (mod_height * slot_size) + 64;

                // Calculate spawn position (X)
                var backpack_right = global.backpack.inv_gui_x + (global.backpack.grid_width * global.backpack.slot_size);
                var desired_x = backpack_right + 64;
                var max_screen_width = display_get_gui_width();
                var spawn_x = min(desired_x, max_screen_width - total_w);

                var mod_inv = instance_create_layer(0, 0, "GUI", obj_mod_inventory, {
                    inventory_type: "mod_" + global.item_data[item_id][0],
                    grid_width: mod_width,
                    grid_height: mod_height,
                    slot_size: 32,
                    inv_gui_x: spawn_x,
                    inv_gui_y: 0, // Set initially, adjusted in Create Event
                    is_open: true,
                    inventory: ds_grid_create(mod_width, mod_height),
                    item_id: item_id,
                    parent_inventory: inventory,
                    parent_slot_x: top_left_x,
                    parent_slot_y: (inventory.inventory_type == "equipment_slots" ? 0 : top_left_y)
                });
                ds_grid_clear(mod_inv.inventory, -1);

                if (array_length(contained_items) > 0) {
                    for (var i = 0; i < array_length(contained_items); i++) {
                        var mod_slot = contained_items[i];
                        inventory_add_at(mod_slot[1], mod_slot[2], mod_slot[0], mod_slot[3], mod_inv.inventory);
                    }
                }
            }
        }
        instance_destroy();
        global.mouse_input_delay = 15; // Enforce delay on action completion
        show_debug_message("Closed context menu after action " + option + ", set delay to 15");
    }
}