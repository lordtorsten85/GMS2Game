// Object: obj_enemy_parent
// Event: Draw
draw_self();

var cone_color = c_green;
switch (state) {
    case "patrol": cone_color = c_green; break;
    case "detected": cone_color = c_red; break;
    case "search": cone_color = c_yellow; break;
}

var active_range = (state == "patrol") ? detection_range : chase_range;
var active_angle = (state == "patrol") ? detection_angle : chase_angle;

draw_set_alpha(0.3);
draw_set_color(cone_color);
var cone_length = active_range;
var cone_angle_half = active_angle / 2;
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
    var icon_y = y - sprite_height - 10; // Above the enemy (adjust 10px offset as needed)
    draw_sprite_ext(spr_enemy_alert, 0, icon_x, icon_y, alert_icon_scale, alert_icon_scale, 0, c_white, alert_icon_alpha);
}

draw_set_color(c_white);