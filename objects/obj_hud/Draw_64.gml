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

var ammo_x = gui_width - 200;
var ammo_y = background_y + (hud_height - 20);
if (ammo_current > 0) {
    draw_text(ammo_x, ammo_y, "Ammo: " + string(ammo_current) + "/" + string(ammo_max));
}

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

draw_set_color(c_white);
draw_set_alpha(1.0);