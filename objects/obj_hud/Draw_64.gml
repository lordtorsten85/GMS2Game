// obj_hud - Draw GUI Event
// Description: Renders health and ammo on the HUD with a black background (equipment slots drawn by obj_manager)
// Variable Definitions (set in Create event):
// - health_current - real - Current player health
// - health_max - real - Maximum player health
// - ammo_current - real - Current ammo for equipped weapon
// - ammo_max - real - Maximum ammo for equipped weapon

// Get GUI dimensions (set by obj_camera_controller to 1280x720)
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

// Calculate equipment slots dimensions (including spr_inventory_frame border)
var slots_width = global.equipment_slots.grid_width * global.equipment_slots.slot_size + (global.equipment_slots.grid_width - 1) * global.equipment_slots.spacing; // 2 * 64 + 1 * 64 = 192px
var slots_height = global.equipment_slots.grid_height * global.equipment_slots.slot_size; // 1 * 64 = 64px
var padding = 24; // From obj_manager Draw GUI (spr_inventory_frame padding)
var slots_total_width = slots_width + 2 * padding; // 192 + 48 = 240px
var slots_total_height = slots_height + 2 * padding; // 64 + 48 = 112px
var slots_y = global.equipment_slots.inv_gui_y; // Top of the slots (bottom-aligned)

// Black background under HUD (starting from bottom)
var hud_height = slots_total_height + 20; // 112px + 20px padding = 132px
var background_x = 0;
var background_y = gui_height - hud_height; // Anchor to bottom
var background_width = gui_width;
var background_height = hud_height;
draw_set_color(c_black);
draw_rectangle(background_x, background_y, background_x + background_width, background_y + background_height, false);

// Dash-style health bar (bottom-left, horizontal, tighter spacing)
var health_x = 10;
var health_y = background_y + 20; // Closer to top of background (20px from top)
var dash_sprite_width = 32; // spr_HUD_health_bar is 32x32px
var dash_actual_width = 5; // Actual dash width, overlapping for tighter look
var max_dashes = floor(health_max / 10); // Each dash represents 10 HP
var current_dashes = floor(health_current / 10); // Number of dashes to draw
for (var i = 0; i < max_dashes; i++) {
    var dash_x = health_x + (i * dash_actual_width); // 5px spacing to overlap
    draw_set_color(i < current_dashes ? c_green : c_red); // Green for full, red for empty
    draw_sprite(spr_HUD_health_bar, 0, dash_x, health_y); // Draw each dash horizontally
}
draw_set_color(c_white);
draw_text(health_x, health_y - 20, "HP: " + string(health_current) + "/" + string(health_max));

// Ammo counter (bottom-right, adjusted for visibility)
var ammo_x = gui_width - 200; // Adjusted to 1080 (within 1280px GUI)
var ammo_y = background_y + (hud_height - 20); // Align with bottom of background
if (ammo_current > 0) {
    draw_text(ammo_x, ammo_y, "Ammo: " + string(ammo_current) + "/" + string(ammo_max));
}

// Reset color
draw_set_color(c_white);