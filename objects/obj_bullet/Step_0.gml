// obj_bullet - Step Event
// Description: Moves the bullet in its direction and destroys it if outside the room

// Move bullet
x += lengthdir_x(speed, direction);
y += lengthdir_y(speed, direction);

// Destroy if outside room
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
}