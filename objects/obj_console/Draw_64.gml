// obj_console - Draw GUI Event
// Description: Draws the inventory GUI and interaction prompt

if (is_open) {
    event_inherited(); // Draw inventory from obj_inventory
}

// Debug to check can_interact state and position
show_debug_message("can_interact: " + string(can_interact) + ", is_open: " + string(is_open));

if (can_interact && !is_open) {
    var text = "Press 'E' to Interact";
    var scale = 0.7;
    
    // Convert world position to GUI coordinates
    var cam_x = camera_get_view_x(view_camera[0]);
    var cam_y = camera_get_view_y(view_camera[0]);
    var cam_width = camera_get_view_width(view_camera[0]);
    var cam_height = camera_get_view_height(view_camera[0]);
    var gui_width = display_get_gui_width();
    var gui_height = display_get_gui_height();
    var scale_x = gui_width / cam_width;
    var scale_y = gui_height / cam_height;
    
    // Calculate the top center of the sprite in world space (top-left origin)
    var sprite_center_x = x + sprite_width / 2; // Center x from top-left origin
    var sprite_top_y = y; // Top of sprite with top-left origin
    var prompt_world_x = sprite_center_x; // Center horizontally
    var prompt_world_y = sprite_top_y + 24; // 25% of 64 (64 * 0.25 = 16 pixels above top)
    
    // Convert to GUI coordinates
    var gui_x = (prompt_world_x - cam_x) * scale_x;
    var gui_y = (prompt_world_y - cam_y) * scale_y;
    
    // Calculate text size
    draw_set_font(fnt_small); // Replace with your font if different
    var text_width = string_width(text) * scale * scale_x;
    var text_height = string_height(text) * scale * scale_y;
    var text_x = gui_x - (text_width / 2); // Center text horizontally
    var text_y = gui_y; // Bottom of text
    
    // Debug prompt position
    show_debug_message("Prompt world position: (" + string(prompt_world_x) + ", " + string(prompt_world_y) + ")");
    show_debug_message("Prompt GUI position: (" + string(text_x) + ", " + string(text_y - text_height) + ")");
    
    // Draw black box background
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    var padding = 4;
    draw_rectangle(text_x - padding, text_y - text_height - padding, text_x + text_width + padding, text_y + padding, false);
    
    // Draw text with shadow
    draw_set_alpha(1.0);
    draw_set_color(c_black);
    draw_text_transformed(text_x + 1, text_y - text_height + 1, text, scale * scale_x, scale * scale_y, 0); // Shadow
    draw_set_color(c_white);
    draw_text_transformed(text_x, text_y - text_height, text, scale * scale_x, scale * scale_y, 0); // Main text
}