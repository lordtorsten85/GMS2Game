// obj_camera_controller - Step Event
// Centers the camera on the player, clamping to room boundaries to prevent viewing outside.

// Follow the player and center the camera on them
if (instance_exists(obj_player)) {
    var px = obj_player.x;
    var py = obj_player.y;

    // Calculate camera position to center on player
    var cam_x = px - global.cam_width / 2;
    var cam_y = py - global.cam_height / 2;

    // Clamp camera to room boundaries
    cam_x = clamp(cam_x, 0, room_width - global.cam_width);
    cam_y = clamp(cam_y, 0, room_height - global.cam_height);

    // Update camera position
    camera_set_view_pos(global.cam, cam_x, cam_y);
}