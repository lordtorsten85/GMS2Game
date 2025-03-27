// Object: obj_enemy_camera
// Event: Create
// Description: Initializes the camera’s detection, alert, and scanning variables.

// Detection cone variables
detection_range = 150;       // Range for detection (pixels)
detection_angle = 90;        // Angle of detection cone (degrees)
facing_direction = 0;        // Current direction camera is facing (degrees)

// Alert variables
alert_cooldown = 0;          // Cooldown before next alert trigger (steps)
alert_cooldown_duration = 120; // Cooldown duration (2 sec at 60 FPS)

// State machine
state = "patrol";            // States: "patrol", "detected", "search"
search_timer = 0;            // Timer for search state (steps)
search_duration = 600;       // 10 sec at 60 FPS for search phase

// Scanning variables
base_direction = 0;          // Base direction for patrol/search sweep (set in editor or here)
scan_angle = 0;              // Current offset from base_direction
scan_speed = 1;              // Degrees per step for scanning
scan_direction = 1;          // 1 = right, -1 = left
pause_timer = 0;             // Pause timer for scan direction changes
pause_duration = 60;         // Pause for 1 sec at scan edges

