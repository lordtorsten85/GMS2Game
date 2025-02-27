// obj_player - draw event

draw_self();

if(move_speed > default_move_speed)
{
	draw_sprite_ext(sprite_index, image_index, xprevious, yprevious, image_xscale * 1.1, image_yscale * 1.1, 0, $FFFFFF & $ffffff, 0.2);
}