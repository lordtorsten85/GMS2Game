// obj_minimap - Draw GUI Event
// Draws the minimap with room layout and object positions, respecting revealed areas.

// Check if surface exists, recreate if needed
if (!surface_exists(map_surface)) {
    map_surface = surface_create(map_width, map_height);
}

// Draw to surface
surface_set_target(map_surface);
draw_clear_alpha(c_black, 1); // Solid black background for unrevealed areas

// Draw revealed room areas (gray for walkable, black for walls)
with (obj_room_mask) {
    if (ds_map_exists(global.revealed_rooms, linked_room_tag)) {
        var mask_left = bbox_left * other.scale_x;
        var mask_top = bbox_top * other.scale_y;
        var mask_right = bbox_right * other.scale_x;
        var mask_bottom = bbox_bottom * other.scale_y;
        
        // Draw mask area exactly (black base for walls)
        draw_set_color(c_black);
        draw_rectangle(mask_left, mask_top, mask_right, mask_bottom, false);
        
        // Overlay walkable areas within exact mask bounds
        for (var i = bbox_left; i < bbox_right; i += 32) {
            for (var j = bbox_top; j < bbox_bottom; j += 32) {
                if (!collision_point(i, j, obj_collision_parent, true, true)) {
                    var map_x = i * other.scale_x;
                    var map_y = j * other.scale_y;
                    draw_set_color(c_gray);
                    draw_rectangle(map_x, map_y, map_x + 32 * other.scale_x, map_y + 32 * other.scale_y, false);
                }
            }
        }
    }
}

// Draw player
if (instance_exists(obj_player)) {
    var player_x = obj_player.x * obj_minimap_id.scale_x;
    var player_y = obj_player.y * obj_minimap_id.scale_y;
    draw_set_color(c_blue);
    draw_circle(player_x, player_y, 3, false);
}

// Draw enemies in revealed areas
with (obj_enemy_parent) {
    var minimap = other.obj_minimap_id;
    with (obj_room_mask) {
        if (ds_map_exists(global.revealed_rooms, linked_room_tag) && point_in_rectangle(other.x, other.y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
            var enemy_x = other.x * minimap.scale_x;
            var enemy_y = other.y * minimap.scale_y;
            draw_set_color(other.state == "alert" ? c_red : c_white);
            draw_circle(enemy_x, enemy_y, 2, false);
        }
    }
}

// Draw cameras in revealed areas
with (obj_enemy_camera) {
    var minimap = other.obj_minimap_id;
    with (obj_room_mask) {
        if (ds_map_exists(global.revealed_rooms, linked_room_tag) && point_in_rectangle(other.x, other.y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
            var cam_x = other.x * minimap.scale_x;
            var cam_y = other.y * minimap.scale_y;
            draw_set_color(other.state == "detected" ? c_red : c_white);
            draw_circle(cam_x, cam_y, 2, false);
        }
    }
}

// Reset surface target
surface_reset_target();

// Draw surface to GUI
draw_surface(map_surface, map_gui_x, map_gui_y);

// Draw border
draw_set_color(c_white);
draw_rectangle(map_gui_x, map_gui_y, map_gui_x + map_width, map_gui_y + map_height, true);