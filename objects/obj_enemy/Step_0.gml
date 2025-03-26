// obj_enemy - Step Event
// Updates sprite direction and handles damage.

// Variable Definitions:
// - hp (real): Health points for this enemy.

// Inherit parent event
event_inherited();

// Update sprite direction based on facing_direction
image_xscale = (facing_direction > 90 && facing_direction < 270) ? -1 : 1;

// Adjust animation speed based on movement
if (state == "alert") {
    image_speed = 0.6; // Slightly faster in chase, but not too quick
} else {
    image_speed = 0.4; // Slower for patrol/search
}

// Example damage check
if (hp <= 0) {
    instance_destroy();
}