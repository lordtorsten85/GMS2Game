// Object: obj_enemy_parent
// Event: Collision with obj_bullet
hp -= other.damage; // Reduce health by bullet damage (assumes obj_bullet has 'damage' variable)
instance_destroy(other); // Destroy the bullet

// Check for death
if (hp <= 0) {
    instance_destroy(); // Destroy the enemy
}