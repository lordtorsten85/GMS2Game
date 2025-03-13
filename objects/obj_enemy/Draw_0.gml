// obj_enemy - Draw Event
// Description: Draws the enemy sprite and scan cone visualization
// Variable Definitions (set in Create event):
// - facing - real - Current facing direction for sprite and detection
// - facing_target - real - Target facing direction for smooth cone rotation
// - cone_facing - real - Current facing direction for the scan cone

// Update sprite facing based on direction
if (facing >= 90 && facing <= 270) {
    image_xscale = -1; // Face left
} else {
    image_xscale = 1; // Face right
}

// Draw enemy sprite
draw_self(); // Draws the idle animation with image_speed

// Smoothly rotate the scan cone toward facing_target
var angle_diff = angle_difference(facing_target, cone_facing);
cone_facing += sign(angle_diff) * min(abs(angle_diff), 5); // Rotate at 5 degrees per step

// Draw scan cone if in patrol or chase state
if (state == "patrol" || state == "chase") {
    draw_sprite_ext(spr_enemy_bot_scan_cone, 0, x, y, 1, 1, cone_facing, c_white, 0.5);
    
    // Scale the cone to match scan_range (150px)
    var cone_width = 128; // Original width
    var cone_height = 64; // Original height
    var scale_x = (scan_range + 16) / cone_width; // Scale to 150px + 16px padding
    var scale_y = (scan_range + 16) / cone_height; // Maintain aspect ratio
    draw_sprite_ext(spr_enemy_bot_scan_cone, 0, x, y, scale_x, scale_y, cone_facing, c_white, 0.5);
}