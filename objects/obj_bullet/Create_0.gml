// obj_bullet - Create Event
// Description: Represents a bullet fired by the player
// Variable Definitions (set in object editor or creation):
// - speed - real - Speed of the bullet (e.g., 10 pixels per step)
// - direction - real - Direction of the bullet (set by player facing)
// - damage - real - Damage dealt by the bullet (e.g., 10)

speed = 10; // Bullet speed
direction = 0; // Will be set by obj_player
damage = 10; // Damage value
image_angle = direction; // Rotate sprite to match direction