// obj_camera_controller - Step Event
// Description: Smoothly follows the player with interpolated camera movement, clamped to room boundaries

if (instance_exists(obj_player)) {
    var px = obj_player.x;
    var py = obj_player.y;

    // Calculate target camera position to center on player
    var target_cam_x = px - global.cam_width / 2;
    var target_cam_y = py - global.cam_height / 2;

    // Interpolate current camera position towards target
    var current_cam_x = camera_get_view_x(global.cam);
    var current_cam_y = camera_get_view_y(global.cam);
    var lerp_factor = 0.1; // Smoothing factor (0.1 = 10% per step)
    var cam_x = lerp(current_cam_x, target_cam_x, lerp_factor);
    var cam_y = lerp(current_cam_y, target_cam_y, lerp_factor);

    // Clamp camera to room boundaries
    cam_x = clamp(cam_x, 0, room_width - global.cam_width);
    cam_y = clamp(cam_y, 0, room_height - global.cam_height);

    // Update camera position
    camera_set_view_pos(global.cam, cam_x, cam_y);
}