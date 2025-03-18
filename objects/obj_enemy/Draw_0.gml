// obj_enemy - Draw Event
// Description: Draws the enemy sprite and vision cone

draw_self();

// Update sprite facing
if (facing >= 90 && facing <= 270) image_xscale = -1; // Left
else image_xscale = 1; // Right

// Draw vision cone with state-based colors
var cone_color;
switch (state) {
    case "patrol":
    case "return":
        cone_color = c_green;
        break;
    case "chase":
        cone_color = c_orange;
        break;
    case "scan": // Kept from your original, but we don’t use it now
        cone_color = c_yellow;
        break;
    default:
        cone_color = c_white; // Fallback
}
draw_set_alpha(0.3);
draw_set_color(cone_color);
draw_triangle(x, y, 
              x + lengthdir_x(vision_range, facing - vision_angle), y + lengthdir_y(vision_range, facing - vision_angle),
              x + lengthdir_x(vision_range, facing + vision_angle), y + lengthdir_y(vision_range, facing + vision_angle), false);
draw_set_alpha(1.0);
draw_set_color(c_white);