// obj_enemy_parent - Draw Event
// Draws the enemy sprite and detection cone based on state.

// Draw sprite
draw_self();

// Set cone color based on state
var cone_color;
switch (state) {
    case "patrol": cone_color = c_green; break;
    case "alert": cone_color = c_red; break;
    case "search": cone_color = c_yellow; break;
    default: cone_color = c_green;
}

// Draw detection cone
draw_set_alpha(0.3);
draw_set_color(cone_color);
var cone_length = detection_range;
var cone_angle_half = detection_angle / 2;
draw_primitive_begin(pr_trianglefan);
draw_vertex(x, y);
for (var i = -cone_angle_half; i <= cone_angle_half; i += 5) {
    var dir = facing_direction + i;
    var xx = x + lengthdir_x(cone_length, dir);
    var yy = y + lengthdir_y(cone_length, dir);
    draw_vertex(xx, yy);
}
draw_primitive_end();
draw_set_alpha(1);
draw_set_color(c_white);

// Draw alert icon if active
if (alert_icon_timer > 0) {
    var icon_x = x;
    var icon_y = y - sprite_height - 10;
    draw_sprite_ext(spr_enemy_alert, 0, icon_x, icon_y, alert_icon_scale, alert_icon_scale, 0, c_white, alert_icon_alpha);
}