// obj_enemy - Collision Event with obj_bullet
// Description: Takes damage from bullets and destroys the bullet
if (other.creator != id) { // Avoid self-damage
    hp -= other.damage; // Reduce health by bullet damage (10)
    instance_destroy(other); // Destroy the bullet on hit
}