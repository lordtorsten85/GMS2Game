// obj_enemy_parent - Create Event
if (!variable_instance_exists(id, "point_owner")) point_owner = "default";
if (!variable_instance_exists(id, "patrol_speed")) patrol_speed = 2;
if (!variable_instance_exists(id, "current_point")) current_point = 0;

patrol_points = [];
target_x = x;
target_y = y;
path = path_add();
grid = noone; // Will be set to global.mp_grid in Room Start
last_player_x = x;
last_player_y = y;

state = "patrol";
search_timer = 0;
search_timer_max = 1200;
search_pause_timer = 0;
detection_range = 150;
detection_angle = 90;
facing_direction = 0;
attack_range = 48;
attack_timer = 0;
attack_cooldown = 60;
is_attacking = false;
hp = 50;

alert_icon_timer = 0;
alert_icon_scale = 1;
alert_icon_alpha = 1;

wait_timer = 0;
pre_wait_timer = 0; // In steps, for rotation phase