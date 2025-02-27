// obj_inventory - Draw GUI Event
// Renders the inventory UI with a stretched frame, translucent gray grid slots, white borders, and items.

if (is_open) {
    // Safety check: Ensure the inventory grid exists
    if (!ds_exists(inventory, ds_type_grid)) {
        show_debug_message("Error: Inventory grid does not exist for " + inventory_type);
        return; // Exit early to prevent crashes
    }
    
    // Define padding for the frame (24 pixels on all sides)
    var padding = 24;
    
    // Calculate frame dimensions, including padding
    var frame_width = (grid_width * slot_size) + (2 * padding);
    var frame_height = (grid_height * slot_size) + (2 * padding);
    var frame_x = inv_gui_x - padding;
    var frame_y = inv_gui_y - padding;
    
    // Draw the stretched frame sprite as the background
    draw_sprite_stretched(spr_inventory_frame, 0, frame_x, frame_y, frame_width, frame_height);
    
    // Set alpha for translucent gray cells (hologram effect)
    draw_set_alpha(0.3); // Adjust this between 0.2 and 0.5 for desired transparency
    draw_set_color(c_gray);
    
    // Draw translucent gray backgrounds for each slot
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var slot_x = inv_gui_x + i * slot_size;
            var slot_y = inv_gui_y + j * slot_size;
            draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, false);
        }
    }
    
    // Reset alpha to fully opaque for borders and items
    draw_set_alpha(1.0);
    
    // Draw white borders around each slot
    draw_set_color(c_white);
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var slot_x = inv_gui_x + i * slot_size;
            var slot_y = inv_gui_y + j * slot_size;
            draw_rectangle(slot_x, slot_y, slot_x + slot_size - 1, slot_y + slot_size - 1, true);
        }
    }
    
    // Draw items, scaling multicell items appropriately
    for (var i = 0; i < grid_width; i++) {
        for (var j = 0; j < grid_height; j++) {
            var slot = inventory[# i, j];
            if (slot != -1 && is_array(slot)) {
                var item_id = slot[0];
                var placement_id = slot[1];
                var qty = slot[2];
                
                // Only draw from the top-left cell of multicell items
                if (i == 0 || !is_array(inventory[# i-1, j]) || inventory[# i-1, j][1] != placement_id) {
                    if (j == 0 || !is_array(inventory[# i, j-1]) || inventory[# i, j-1][1] != placement_id) {
                        // Get item dimensions and sprite
                        var item_width = global.item_data[item_id][1];  // Width in grid cells
                        var item_height = global.item_data[item_id][2]; // Height in grid cells
                        var sprite = global.item_data[item_id][5];      // Item sprite
                        
                        // Calculate pixel dimensions for the item
                        var total_width = item_width * slot_size;
                        var total_height = item_height * slot_size;
                        
                        // Calculate scaling factors based on sprite size
                        var scale_x = total_width / sprite_get_width(sprite);
                        var scale_y = total_height / sprite_get_height(sprite);
                        
                        // Draw the scaled item sprite
                        var slot_x = inv_gui_x + i * slot_size;
                        var slot_y = inv_gui_y + j * slot_size;
                        draw_sprite_ext(sprite, 0, slot_x, slot_y, scale_x, scale_y, 0, c_white, 1);
                    }
                }
            }
        }
    }
}