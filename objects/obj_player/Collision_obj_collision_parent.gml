// If there wasn't a collision
// in the previous X position
var wallx = instance_place(xprevious, y, [obj_collision_parent]);
if (!(wallx > 0))
{
	// Then move back to that
	// point on the X axis
	x = xprevious;
y = y;
}

else
{
	// If there wasn't a collision
	// in the previous y position
	var wally = instance_place(x, yprevious, [obj_collision_parent]);
if (!(wally > 0))
{
	// Then move back to that
		// point on the Y axis
		x = x;
y = yprevious;
}

	else
{
	// Otherwise just move back
		// on both X and Y axes
		x = xprevious;
y = yprevious;
}
}