// Object: obj_enemy_camera
// Event: Draw
draw_self();

// Draw detection cone
var cone_color = c_green;
switch (state) {
    case "patrol": cone_color = c_green; break;
    case "detected": cone_color = c_red; break;
    case "search": cone_color = c_yellow; break;
}

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