// obj_minimap - Draw GUI Event
// Draws the minimap with room layout, object positions, and cones, respecting revealed areas and utility state
// Variable Definitions (assumed set in Create):
// - map_surface - surface - Rendering surface
// - map_width - real - Surface width
// - map_height - real - Surface height
// - map_gui_x - real - GUI X position
// - map_gui_y - real - GUI Y position
// - scale_x - real - X scaling factor
// - scale_y - real - Y scaling factor
// - obj_minimap_id - real - Reference to self (for with statements)

// Check if surface exists, recreate if needed
if (!surface_exists(map_surface)) {
    map_surface = surface_create(map_width, map_height);
}

// Draw to surface
surface_set_target(map_surface);
draw_clear_alpha(c_black, 1); // Solid black background for unrevealed areas

// Draw revealed room areas (techy gray for walkable, black for walls)
with (obj_room_mask) {
    if (ds_map_exists(global.revealed_rooms, linked_room_tag)) {
        var mask_left = bbox_left * other.scale_x;
        var mask_top = bbox_top * other.scale_y;
        var mask_right = bbox_right * other.scale_x;
        var mask_bottom = bbox_bottom * other.scale_y;
        
        draw_set_color(c_black);
        draw_rectangle(mask_left, mask_top, mask_right, mask_bottom, false);
        
        for (var i = bbox_left; i < bbox_right; i += 32) {
            for (var j = bbox_top; j < bbox_bottom; j += 32) {
                if (!collision_point(i, j, obj_collision_parent, true, true)) {
                    var map_x = i * other.scale_x;
                    var map_y = j * other.scale_y;
                    draw_set_color($3C3C3C); // Techy gray
                    draw_rectangle(map_x, map_y, map_x + 32 * other.scale_x, map_y + 32 * other.scale_y, false);
                }
            }
        }
    }
}

// Get player’s current room tag
var player_room_tag = "";
if (instance_exists(obj_player)) {
    with (obj_room_mask) {
        if (point_in_rectangle(obj_player.x, obj_player.y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
            player_room_tag = linked_room_tag;
            break;
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

// Draw enemies
with (obj_enemy_parent) {
    var minimap = other.obj_minimap_id;
    var draw_enemy = false;
    var draw_cone = false;
    var enemy_room_tag = "";
    with (obj_room_mask) {
        if (point_in_rectangle(other.x, other.y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
            enemy_room_tag = linked_room_tag;
            var in_player_area = (linked_room_tag == player_room_tag);
            // Only draw position in player’s room
            if (in_player_area) {
                draw_enemy = true;
                draw_cone = global.optics_enabled; // Cones require OPTICS
            }
            break;
        }
    }
    if (draw_enemy) {
        var enemy_x = x * minimap.scale_x;
        var enemy_y = y * minimap.scale_y;
        draw_set_color(state == "alert" ? c_red : c_white);
        draw_circle(enemy_x, enemy_y, 2, false);
        show_debug_message("Enemy at " + string(enemy_x) + "," + string(enemy_y) + " - Room: " + enemy_room_tag + ", DrawCone: " + string(draw_cone) + ", Optics: " + string(global.optics_enabled));
        if (draw_cone) {
            draw_set_alpha(0.5);
            var cone_color;
            switch (state) {
                case "patrol": cone_color = merge_color($3C3C3C, c_green, 0.5); break;
                case "alert": cone_color = merge_color($3C3C3C, c_red, 0.5); break;
                case "search": cone_color = merge_color($3C3C3C, c_yellow, 0.5); break;
                default: cone_color = merge_color($3C3C3C, c_green, 0.5);
            }
            draw_set_color(cone_color);
            var cone_length = 20;
            var cone_angle_half = 22.5;
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(enemy_x, enemy_y);
            for (var i = -cone_angle_half; i <= cone_angle_half; i += 5) {
                var dir = facing_direction + i;
                var draw_x = enemy_x + lengthdir_x(cone_length, dir);
                var draw_y = enemy_y + lengthdir_y(cone_length, dir);
                draw_vertex(draw_x, draw_y);
            }
            draw_primitive_end();
            draw_set_alpha(1);
        }
    }
}

// Draw cameras
with (obj_enemy_camera) {
    var minimap = other.obj_minimap_id;
    var draw_cam = false;
    var draw_cone = false;
    var cam_room_tag = "";
    with (obj_room_mask) {
        if (point_in_rectangle(other.x, other.y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
            cam_room_tag = linked_room_tag;
            var in_player_area = (linked_room_tag == player_room_tag);
            // Only draw position in player’s room
            if (in_player_area) {
                draw_cam = true;
                draw_cone = global.optics_enabled; // Cones require OPTICS
            }
            break;
        }
    }
    if (draw_cam) {
        var cam_x = x * minimap.scale_x;
        var cam_y = y * minimap.scale_y;
        draw_set_color(state == "detected" ? c_red : c_white);
        draw_circle(cam_x, cam_y, 2, false);
        show_debug_message("Camera at " + string(cam_x) + "," + string(cam_y) + " - Room: " + cam_room_tag + ", DrawCone: " + string(draw_cone) + ", Optics: " + string(global.optics_enabled));
        if (draw_cone) {
            draw_set_alpha(0.5);
            var cone_color;
            switch (state) {
                case "patrol": cone_color = merge_color($3C3C3C, c_green, 0.5); break;
                case "detected": cone_color = merge_color($3C3C3C, c_red, 0.5); break;
                case "search": cone_color = merge_color($3C3C3C, c_yellow, 0.5); break;
                default: cone_color = merge_color($3C3C3C, c_green, 0.5);
            }
            draw_set_color(cone_color);
            var cone_length = 20;
            var cone_angle_half = 22.5;
            draw_primitive_begin(pr_trianglefan);
            draw_vertex(cam_x, cam_y);
            for (var i = -cone_angle_half; i <= cone_angle_half; i += 5) {
                var dir = facing_direction + i;
                var draw_x = cam_x + lengthdir_x(cone_length, dir);
                var draw_y = cam_y + lengthdir_y(cone_length, dir);
                draw_vertex(draw_x, draw_y);
            }
            draw_primitive_end();
            draw_set_alpha(1);
        }
    }
}

// Reset surface target
surface_reset_target();

// Draw surface to GUI
draw_surface(map_surface, map_gui_x, map_gui_y);

// Draw border
draw_set_color($FFAA00);
draw_rectangle(map_gui_x, map_gui_y, map_gui_x + map_width, map_gui_y + map_height, true);