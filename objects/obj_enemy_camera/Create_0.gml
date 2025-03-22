// Object: obj_enemy_camera
// Event: Create
// Description: Initializes a stationary camera enemy that scans and alerts patrolling guards
// Variable Definitions (set in object editor):
// - face_left - boolean - If true, flips the sprite to face left (default: false)
// - detection_range - real - Range of the detection cone (default: 200)
// - detection_angle - real - Total angle of the detection cone (default: 90)
// - scan_speed - real - Scanning speed in degrees per step (default: 0.5)
// - scan_angle - real - Starting angle offset for scanning (default: 0)
// - pause_duration_seconds - real - Pause duration at each end of the scan in seconds (default: 1)

// Sprite setup
image_xscale = face_left ? -1 : 1; // Flip sprite if facing left
image_speed = 0.4;

// Detection variables (set in editor, no redefinition here)
base_direction = face_left ? 180 : 0; // Base direction (0 = right, 180 = left)
facing_direction = base_direction; // Current direction (will oscillate)
scan_direction = 1; // 1 for increasing, -1 for decreasing
pause_timer = 0; // Timer for pausing at ends
pause_duration = pause_duration_seconds * game_get_speed(gamespeed_fps); // Convert seconds to steps

// State
state = "patrol"; // Start in patrol state
alert_cooldown = 0; // Prevent spamming alerts (in steps)
alert_cooldown_duration = game_get_speed(gamespeed_fps) * 2; // 2 seconds
search_timer = 0; // Timer for search state after losing player
search_duration = 10 * game_get_speed(gamespeed_fps); // 10 seconds, same as patrolling enemies