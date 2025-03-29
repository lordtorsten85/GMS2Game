// obj_hud - Draw GUI Event
draw_set_color(c_white);
draw_set_alpha(1.0);

var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

var slots_width = global.equipment_slots.grid_width * global.equipment_slots.slot_size + (global.equipment_slots.grid_width - 1) * global.equipment_slots.spacing;
var slots_height = global.equipment_slots.grid_height * global.equipment_slots.slot_size;
var padding = 24;
var slots_total_width = slots_width + 2 * padding;
var slots_total_height = slots_height + 2 * padding;
var slots_y = global.equipment_slots.inv_gui_y;

var hud_height = slots_total_height + 20;
var background_x = 0;
var background_y = gui_height - hud_height;
var background_width = gui_width;
var background_height = hud_height;
draw_set_color(c_black);
draw_rectangle(background_x, background_y, background_x + background_width, background_y + background_height, false);

var health_x = 10;
var health_y = background_y + 20;
var dash_sprite_width = 32;
var dash_actual_width = 5;
var max_dashes = floor(health_max / 10);
var current_dashes = floor(health_current / 10);
for (var i = 0; i < max_dashes; i++) {
    var dash_x = health_x + (i * dash_actual_width);
    draw_set_color(i < current_dashes ? c_green : c_red);
    draw_sprite(spr_HUD_health_bar, 0, dash_x, health_y);
}
draw_set_color(c_white);
draw_text(health_x, health_y - 20, "HP: " + string(health_current) + "/" + string(health_max));

var alert_x = health_x;
var alert_y = health_y + 40;
if (instance_exists(obj_manager)) {
    if (obj_manager.enemies_alerted && global.alert_timer > 0) {
        var alert_seconds = ceil(global.alert_timer / game_get_speed(gamespeed_fps));
        draw_text(alert_x, alert_y, "ALERT! " + string(alert_seconds) + "s");
    } else if (global.search_timer > 0) {
        var search_seconds = ceil(global.search_timer / game_get_speed(gamespeed_fps));
        draw_text(alert_x, alert_y, "SEARCH: " + string(search_seconds) + "s");
    }
}

// Draw minimap between health/alert and equipment slots
var minimap_x = alert_x + 150;
var minimap_y = background_y + (hud_height - minimap_height) / 2;

// Check if surface exists, recreate if needed
if (!surface_exists(minimap_surface)) {
    minimap_surface = surface_create(minimap_width, minimap_height);
}

// Draw to surface
surface_set_target(minimap_surface);
draw_clear_alpha(c_black, 1);

// Draw revealed room areas
with (obj_room_mask) {
    if (ds_map_exists(global.revealed_rooms, linked_room_tag)) {
        var mask_left = bbox_left * other.minimap_scale_x;
        var mask_top = bbox_top * other.minimap_scale_y;
        var mask_right = bbox_right * other.minimap_scale_x;
        var mask_bottom = bbox_bottom * other.minimap_scale_y;
        
        draw_set_color(c_black);
        draw_rectangle(mask_left, mask_top, mask_right, mask_bottom, false);
        
        for (var i = bbox_left; i < bbox_right; i += 32) {
            for (var j = bbox_top; j < bbox_bottom; j += 32) {
                if (!collision_point(i, j, obj_collision_parent, true, true)) {
                    var map_x = i * other.minimap_scale_x;
                    var map_y = j * other.minimap_scale_y;
                    draw_set_color($5A5A5A);
                    draw_rectangle(map_x, map_y, map_x + 32 * other.minimap_scale_x, map_y + 32 * other.minimap_scale_y, false);
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
            show_debug_message("Player in room: " + player_room_tag);
            break;
        }
    }
}

// Draw player
if (instance_exists(obj_player)) {
    var player_x = obj_player.x * minimap_scale_x;
    var player_y = obj_player.y * minimap_scale_y;
    draw_set_color(c_lime);
    draw_circle(player_x, player_y, 3, false);
}

// Draw enemies with conditional logic
with (obj_enemy_parent) {
    var draw_enemy = false;
    var draw_cone = false;
    var enemy_room_tag = "";
    with (obj_room_mask) {
        if (point_in_rectangle(other.x, other.y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
            enemy_room_tag = linked_room_tag;
            var in_player_area = (linked_room_tag == player_room_tag);
            var in_revealed = ds_map_exists(global.revealed_rooms, linked_room_tag);
            if (in_player_area) {
                draw_enemy = true; // Always show positions in current room
                draw_cone = global.optics_enabled; // Cones in current room with OPTICS
            } else if (global.optics_ir_enabled && in_revealed) {
                draw_enemy = true; // Positions in other revealed rooms with IR
                draw_cone = false;
            }
            break;
        }
    }
    if (draw_enemy) {
        var enemy_x = x * other.minimap_scale_x;
        var enemy_y = y * other.minimap_scale_y;
        draw_set_color(state == "alert" ? c_red : c_white);
        draw_circle(enemy_x, enemy_y, 2, false);
        show_debug_message("Enemy at " + string(enemy_x) + "," + string(enemy_y) + " - Room: " + enemy_room_tag + ", DrawCone: " + string(draw_cone) + ", Optics: " + string(global.optics_enabled) + ", IR: " + string(global.optics_ir_enabled));
        if (draw_cone) {
            draw_set_alpha(0.7);
            var cone_color;
            switch (state) {
                case "patrol": cone_color = c_green; break;
                case "alert": cone_color = c_red; break;
                case "search": cone_color = c_yellow; break;
                default: cone_color = c_green;
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

// Draw cameras with conditional logic
with (obj_enemy_camera) {
    var draw_cam = false;
    var draw_cone = false;
    var cam_room_tag = "";
    with (obj_room_mask) {
        if (point_in_rectangle(other.x, other.y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
            cam_room_tag = linked_room_tag;
            var in_player_area = (linked_room_tag == player_room_tag);
            var in_revealed = ds_map_exists(global.revealed_rooms, linked_room_tag);
            if (in_player_area) {
                draw_cam = true; // Always show positions in current room
                draw_cone = global.optics_enabled; // Cones in current room with OPTICS
            } else if (global.optics_ir_enabled && in_revealed) {
                draw_cam = true; // Positions in other revealed rooms with IR
                draw_cone = false;
            }
            break;
        }
    }
    if (draw_cam) {
        var cam_x = x * other.minimap_scale_x;
        var cam_y = y * other.minimap_scale_y;
        draw_set_color(state == "detected" ? c_red : c_white);
        draw_circle(cam_x, cam_y, 2, false);
        show_debug_message("Camera at " + string(cam_x) + "," + string(cam_y) + " - Room: " + cam_room_tag + ", DrawCone: " + string(draw_cone) + ", Optics: " + string(global.optics_enabled) + ", IR: " + string(global.optics_ir_enabled));
        if (draw_cone) {
            draw_set_alpha(0.7);
            var cone_color;
            switch (state) {
                case "patrol": cone_color = c_green; break;
                case "detected": cone_color = c_red; break;
                case "search": cone_color = c_yellow; break;
                default: cone_color = c_green;
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
draw_surface(minimap_surface, minimap_x, minimap_y);

// Draw border around minimap
draw_set_color($FFAA00);
draw_rectangle(minimap_x, minimap_y, minimap_x + minimap_width, minimap_y + minimap_height, true);

var ammo_x = minimap_x + minimap_width + 20;
var ammo_y = background_y + (hud_height - 20);
if (ammo_current >= 0) {
    draw_text(ammo_x, ammo_y, "Ammo: " + string(ammo_current));
}

draw_set_color(c_white);
draw_set_alpha(1.0);