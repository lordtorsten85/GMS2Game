// obj_enemy_parent - Collision Event with obj_bullet
// Description: Applies damage from bullet, triggers stun, and plays feedback.

if (other.id != -1 && instance_exists(other)) {
    // Apply damage
    hp -= other.damage;
    show_debug_message("Enemy hit at [" + string(x) + "," + string(y) + "], HP: " + string(hp));
    
    // Trigger stun
    state = "stunned";
    stunned = true;
    stun_timer = 120; // 2 seconds at 60 FPS
    stun_flash_timer = 10; // Start flashing (10 steps per cycle)
    
    // Play stun sound
    audio_play_sound(snd_chest_open, 0, 0, 1.0, undefined, 1.0);
    
    // Destroy bullet
    instance_destroy(other);
}

// Check for death
if (hp <= 0) {
    instance_destroy(); // Destroy the enemy
}