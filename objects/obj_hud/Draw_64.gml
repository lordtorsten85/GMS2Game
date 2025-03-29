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
var minimap_x = alert_x + 150; // Adjust based on alert text width
var minimap_y = background_y + (hud_height - minimap_height) / 2; // Center vertically in HUD bar

// Check if surface exists, recreate if needed
if (!surface_exists(minimap_surface)) {
    minimap_surface = surface_create(minimap_width, minimap_height);
}

// Draw to surface
surface_set_target(minimap_surface);
draw_clear_alpha(c_black, 1); // Solid black background for unrevealed areas

// Draw revealed room areas (brighter gray for walkable, black for walls)
with (obj_room_mask) {
    if (ds_map_exists(global.revealed_rooms, linked_room_tag)) {
        var mask_left = bbox_left * other.minimap_scale_x;
        var mask_top = bbox_top * other.minimap_scale_y;
        var mask_right = bbox_right * other.minimap_scale_x;
        var mask_bottom = bbox_bottom * other.minimap_scale_y;
        
        // Draw mask area exactly (black base for walls)
        draw_set_color(c_black);
        draw_rectangle(mask_left, mask_top, mask_right, mask_bottom, false);
        
        // Overlay walkable areas within exact mask bounds
        for (var i = bbox_left; i < bbox_right; i += 32) {
            for (var j = bbox_top; j < bbox_bottom; j += 32) {
                if (!collision_point(i, j, obj_collision_parent, true, true)) {
                    var map_x = i * other.minimap_scale_x;
                    var map_y = j * other.minimap_scale_y;
                    draw_set_color($5A5A5A); // Brighter gray for contrast
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
            break;
        }
    }
}

// Draw player
if (instance_exists(obj_player)) {
    var player_x = obj_player.x * minimap_scale_x;
    var player_y = obj_player.y * minimap_scale_y;
    draw_set_color(c_lime); // Your tweak: lime player dot
    draw_circle(player_x, player_y, 3, false);
}

// Draw enemies and cones in player’s area or all revealed if toggled
with (obj_enemy_parent) {
    var draw_enemy = false;
    with (obj_room_mask) {
        var in_player_area = (linked_room_tag == player_room_tag && point_in_rectangle(other.x, other.y, bbox_left, bbox_top, bbox_right, bbox_bottom));
        var in_revealed = ds_map_exists(global.revealed_rooms, linked_room_tag) && point_in_rectangle(other.x, other.y, bbox_left, bbox_top, bbox_right, bbox_bottom);
        if (in_player_area || (global.show_all_enemies && in_revealed)) {
            draw_enemy = true;
            break;
        }
    }
    if (draw_enemy) {
        var enemy_x = x * other.minimap_scale_x;
        var enemy_y = y * other.minimap_scale_y;
        // Draw dot
        draw_set_color(state == "alert" ? c_red : c_white);
        draw_circle(enemy_x, enemy_y, 2, false);
        // Draw cone approximation
        draw_set_alpha(0.7); // Higher alpha for vibrancy
        var cone_color;
        switch (state) {
            case "patrol": cone_color = c_green; break; // Pure green
            case "alert": cone_color = c_red; break;   // Pure red
            case "search": cone_color = c_yellow; break; // Pure yellow
            default: cone_color = c_green;
        }
        draw_set_color(cone_color);
        var cone_length = 20;
        var cone_angle_half = 22.5; // 45° total
        draw_primitive_begin(pr_trianglefan);
        draw_vertex(enemy_x, enemy_y); // Center
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

// Draw cameras and cones in player’s area or all revealed if toggled
with (obj_enemy_camera) {
    var draw_cam = false;
    with (obj_room_mask) {
        var in_player_area = (linked_room_tag == player_room_tag && point_in_rectangle(other.x, other.y, bbox_left, bbox_top, bbox_right, bbox_bottom));
        var in_revealed = ds_map_exists(global.revealed_rooms, linked_room_tag) && point_in_rectangle(other.x, other.y, bbox_left, bbox_top, bbox_right, bbox_bottom);
        if (in_player_area || (global.show_all_enemies && in_revealed)) {
            draw_cam = true;
            break;
        }
    }
    if (draw_cam) {
        var cam_x = x * other.minimap_scale_x;
        var cam_y = y * other.minimap_scale_y;
        // Draw dot
        draw_set_color(state == "detected" ? c_red : c_white);
        draw_circle(cam_x, cam_y, 2, false);
        // Draw cone approximation
        draw_set_alpha(0.7); // Higher alpha for vibrancy
        var cone_color;
        switch (state) {
            case "patrol": cone_color = c_green; break; // Pure green
            case "detected": cone_color = c_red; break;   // Pure red
            case "search": cone_color = c_yellow; break; // Pure yellow
            default: cone_color = c_green;
        }
        draw_set_color(cone_color);
        var cone_length = 20;
        var cone_angle_half = 22.5; // 45° total
        draw_primitive_begin(pr_trianglefan);
        draw_vertex(cam_x, cam_y); // Center
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

// Reset surface target
surface_reset_target();

// Draw surface to GUI
draw_surface(minimap_surface, minimap_x, minimap_y);

// Draw border around minimap
draw_set_color($FFAA00); // Techy blue border
draw_rectangle(minimap_x, minimap_y, minimap_x + minimap_width, minimap_y + minimap_height, true);

var ammo_x = minimap_x + minimap_width + 20;
var ammo_y = background_y + (hud_height - 20);
if (ammo_current >= 0) { // Show even at 0
    draw_text(ammo_x, ammo_y, "Ammo: " + string(ammo_current)); // Just total rounds
}

draw_set_color(c_white);
draw_set_alpha(1.0);