// obj_enemy_camera - Draw Event
// Draws the camera and segmented detection cones based on state.

// Flip sprite horizontally if face_left
image_xscale = face_left ? -1 : 1;
draw_self();

// Set cone color based on state
var cone_color;
switch (state) {
    case "patrol": cone_color = c_green; break;
    case "detected": cone_color = c_red; break;
    case "search": cone_color = c_yellow; break;
    default: cone_color = c_green;
}

// Draw detection cone as segmented mini-cones, stopping at walls
draw_set_alpha(0.3);
draw_set_color(cone_color);
var cone_length = detection_range; // 150px
var cone_angle_half = detection_angle / 2; // 45°
var step = 5; // Degrees per segment

for (var i = -cone_angle_half; i < cone_angle_half; i += step) {
    var dir_center = facing_direction + i + step / 2; // Center of this segment
    var dir_left = facing_direction + i;
    var dir_right = facing_direction + i + step;
    
    // Start raycast just outside sprite to avoid self-collision
    var ray_start_x = x + lengthdir_x(1, dir_center); // 1px offset forward
    var ray_start_y = y + lengthdir_y(1, dir_center);
    var ray_x = ray_start_x;
    var ray_y = ray_start_y;
    var ray_dist = 0;
    var ray_step = 2; // Step size for precision
    var hit = false;
    while (ray_dist < cone_length && !hit) {
        ray_x = ray_start_x + lengthdir_x(ray_dist, dir_center);
        ray_y = ray_start_y + lengthdir_y(ray_dist, dir_center);
        if (collision_point(ray_x, ray_y, obj_collision_parent, true, true)) {
            hit = true;
            ray_dist -= ray_step; // Step back to before the hit
            break;
        }
        ray_dist += ray_step;
    }
    var seg_length = min(ray_dist, cone_length); // Cap at detection_range
    if (seg_length <= 0) seg_length = cone_length; // Fallback to full length if no hit

    // Debug segment length
    // show_debug_message(point_owner + " seg_length for dir " + string(dir_center) + ": " + string(seg_length));

    // Draw mini-cone for this segment
    draw_primitive_begin(pr_trianglefan);
    draw_vertex(x, y); // Center point
    for (var j = 0; j <= step; j += 1) { // Subdivide segment for smoothness
        var sub_dir = dir_left + (j / step) * (dir_right - dir_left);
        var draw_x = x + lengthdir_x(seg_length, sub_dir);
        var draw_y = y + lengthdir_y(seg_length, sub_dir);
        draw_vertex(draw_x, draw_y);
    }
    draw_primitive_end();
}
draw_set_alpha(1);
draw_set_color(c_white);