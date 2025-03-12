// obj_hud - Step Event
// Description: Updates health and ammo values from obj_manager
// Variable Definitions (set in Create event):
// - health_current - real - Current player health
// - health_max - real - Maximum player health
// - ammo_current - real - Current ammo for equipped weapon
// - ammo_max - real - Maximum ammo for equipped weapon

if (instance_exists(obj_manager)) {
    // Sync health
    health_current = obj_manager.health_current;
    health_max = obj_manager.health_max;
    
    // Sync ammo
    ammo_current = obj_manager.ammo_current;
    ammo_max = obj_manager.ammo_max;
}