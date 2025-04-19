// obj_player - Step Event
// Description: Handles player movement, crouch toggle, collision push, punching, shooting, item pickup, and sprite animation

var pickup_range = 48;

// Initialize state if not exists
if (!variable_instance_exists(id, "is_punching")) is_punching = false;
if (!variable_instance_exists(id, "last_xscale")) last_xscale = 1;
if (!variable_instance_exists(id, "last_direction")) last_direction = 0;
if (!variable_instance_exists(id, "has_hit")) has_hit = false;
if (!variable_instance_exists(id, "is_crouching")) is_crouching = false;

// Toggle crouch mode with Ctrl (only if not punching)
if (keyboard_check_pressed(vk_control) && !is_punching) {
    var was_crouching = is_crouching;
    is_crouching = !is_crouching;
    
    // If switching to prone, check for collisions and push player away
    if (is_crouching && !was_crouching) {
        // Temporarily set sprite to prone for collision check
        var temp_sprite = sprite_index;
        if (last_direction == 90) {
            sprite_index = spr_rattler_prone_up_idle;
        } else if (last_direction == 270) {
            sprite_index = spr_rattler_prone_down_idle;
        } else {
            sprite_index = spr_rattler_prone_side_idle;
        }
        
        // Check for collision with obj_collision_parent
        var col = instance_place(x, y, obj_collision_parent);
        if (col != noone && col.solid) {
            var push_speed = 2; // Pixels per step to push
            var max_attempts = 13; // Enough to cover 26 pixels (26/2 = 13)
            var attempts = 0;
            var start_x = x;
            var start_y = y;
            
            // Prioritize downward push when facing up (last_direction = 90)
            if (last_direction == 90) {
                // Push downward (180 degrees) to clear 26-pixel mask extension
                while (instance_place(x, y, obj_collision_parent) != noone && attempts < max_attempts) {
                    y += push_speed; // Move downward
                    attempts++;
                }
            } else {
                // For other directions, push away from collision center
                var push_dir = point_direction(col.x, col.y, x, y);
                while (instance_place(x, y, obj_collision_parent) != noone && attempts < max_attempts) {
                    x += lengthdir_x(push_speed, push_dir);
                    y += lengthdir_y(push_speed, push_dir);
                    attempts++;
                }
            }
            
            // If still stuck, try alternative directions (0, 90, 180, 270)
            if (instance_place(x, y, obj_collision_parent) != noone) {
                var directions = [0, 90, 180, 270];
                var i = 0;
                attempts = 0;
                x = start_x;
                y = start_y;
                while (i < array_length(directions) && instance_place(x, y, obj_collision_parent) != noone && attempts < max_attempts) {
                    var push_dir = directions[i];
                    x = start_x + lengthdir_x(push_speed, push_dir);
                    y = start_y + lengthdir_y(push_speed, push_dir);
                    attempts++;
                    if (instance_place(x, y, obj_collision_parent) == noone) {
                        break;
                    }
                    i++;
                }
            }
            
            // If still stuck after all attempts, revert to walking
            if (instance_place(x, y, obj_collision_parent) != noone) {
                is_crouching = false;
                x = start_x;
                y = start_y;
            }
        }
        
        // Restore sprite (animation logic below will set it correctly)
        sprite_index = temp_sprite;
    }
}

// Declare input variables
var h_input = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
var v_input = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));
var moving = (h_input != 0 || v_input != 0);

// Movement with arrow keys and WASD, only if not punching
if (!is_punching) {
    var current_speed = is_crouching ? crouch_speed : move_speed;
    if (h_input != 0 || v_input != 0) {
        var dir = point_direction(0, 0, h_input, v_input);
        input_direction = dir;
        
        // Separate horizontal and vertical movement for sliding
        var h_speed = h_input * current_speed;
        var v_speed = v_input * current_speed;
        
        // Apply horizontal movement
        var prev_x = x;
        x += h_speed;
        var inst = instance_place(x, y, obj_collision_parent);
        if (inst != noone && inst.solid) {
            x = prev_x;
        }
        
        // Apply vertical movement
        var prev_y = y;
        y += v_speed;
        inst = instance_place(x, y, obj_collision_parent);
        if (inst != noone && inst.solid) {
            y = prev_y;
        }
        
        // Update last_direction based on primary input
        if (abs(v_input) > abs(h_input)) {
            last_direction = (v_input < 0) ? 90 : 270; // Up or Down
        } else {
            last_direction = (h_input > 0) ? 0 : 180; // Right or Left
        }
    }
}

// Update movement sprites if not punching
if (!is_punching) {
    var prev_sprite = sprite_index; // Track sprite for collision check
    if (is_crouching) {
        if (moving) {
            if (v_input < 0) { // Prioritize up
                sprite_index = spr_rattler_prone_up_crawl;
                image_xscale = 1;
                image_yscale = 1;
            } else if (v_input > 0) { // Prioritize down
                sprite_index = spr_rattler_prone_down_crawl;
                image_xscale = 1;
                image_yscale = 1;
            } else if (h_input != 0) { // Side only if no vertical input
                sprite_index = spr_rattler_prone_side_crawl;
                image_xscale = (h_input > 0) ? 1 : -1;
                last_xscale = image_xscale;
                image_yscale = 1;
            }
        } else {
            if (last_direction == 90) {
                sprite_index = spr_rattler_prone_up_idle;
                image_xscale = 1;
                image_yscale = 1;
            } else if (last_direction == 270) {
                sprite_index = spr_rattler_prone_down_idle;
                image_xscale = 1;
                image_yscale = 1;
            } else {
                sprite_index = spr_rattler_prone_side_idle;
                image_xscale = (last_direction == 0) ? 1 : -1;
                last_xscale = image_xscale;
                image_yscale = 1;
            }
        }
        image_speed = moving ? 0.6 : 0.3; // 0.3 for crawling, 0.15 for prone idle
        
        // Check for collisions after sprite change in prone mode
        if (sprite_index != prev_sprite && moving) {
            var col = instance_place(x, y, obj_collision_parent);
            if (col != noone && col.solid) {
                var push_speed = 2; // Pixels per step to push
                var max_attempts = 13; // Enough to cover 26 pixels (26/2 = 13)
                var attempts = 0;
                var start_x = x;
                var start_y = y;
                
                // Prioritize downward push when switching to spr_rattler_prone_up_crawl
                if (sprite_index == spr_rattler_prone_up_crawl) {
                    // Push downward (180 degrees) to clear 26-pixel mask extension
                    while (instance_place(x, y, obj_collision_parent) != noone && attempts < max_attempts) {
                        y += push_speed; // Move downward
                        attempts++;
                    }
                } else {
                    // For other sprite changes, push away from collision center
                    var push_dir = point_direction(col.x, col.y, x, y);
                    while (instance_place(x, y, obj_collision_parent) != noone && attempts < max_attempts) {
                        x += lengthdir_x(push_speed, push_dir);
                        y += lengthdir_y(push_speed, push_dir);
                        attempts++;
                    }
                }
                
                // If still stuck, revert position and sprite
                if (instance_place(x, y, obj_collision_parent) != noone) {
                    x = start_x;
                    y = start_y;
                    sprite_index = prev_sprite;
                }
            }
        }
    } else {
        if (h_input != 0 || v_input != 0) {
            if (v_input < 0) {
                sprite_index = spr_rattler_run_up;
                image_xscale = 1;
                image_yscale = 1;
            } else if (v_input > 0) {
                sprite_index = spr_rattler_run_down;
                image_xscale = 1;
                image_yscale = 1;
            } else if (h_input != 0) {
                sprite_index = spr_rattler_walk;
                image_xscale = (h_input > 0) ? 1 : -1;
                last_xscale = image_xscale;
                image_yscale = 1;
            }
        } else {
            if (last_direction == 90) {
                sprite_index = spr_rattler_idle_up;
                image_xscale = 1;
                image_yscale = 1;
            } else if (last_direction == 270) {
                sprite_index = spr_rattler_idle_down;
                image_xscale = 1;
                image_yscale = 1;
            } else {
                sprite_index = spr_rattler_idle;
                image_xscale = last_xscale;
                image_yscale = 1;
            }
        }
        image_speed = moving ? 1.0 : 1.0; // 0.4 for walking, 0.2 for walking idle
    }
}

// Punching collision check
if (is_punching && (sprite_index == spr_rattler_punch || sprite_index == spr_rattler_punch_up || sprite_index == spr_rattler_punch_down)) {
    var punch_range = 32;
    var punch_x = x;
    var punch_y = y;
    
    if (sprite_index == spr_rattler_punch) {
        punch_x += image_xscale * 16;
    } else if (sprite_index == spr_rattler_punch_up) {
        punch_y -= 16;
    } else if (sprite_index == spr_rattler_punch_down) {
        punch_y += 16;
    }
    
    punch_hitbox = { x: punch_x, y: punch_y, size: 8 };
    
    if (image_index == 5 && !has_hit) {
        var enemy_hit = instance_place(punch_x, punch_y, obj_enemy_parent);
        if (enemy_hit != noone) {
            enemy_hit.hp -= melee_damage;
            enemy_hit.state = "stunned";
            enemy_hit.stunned = true;
            enemy_hit.stun_timer = 30;
            enemy_hit.stun_flash_timer = 10;
            audio_play_sound(snd_chest_open, 0, 0, 1.0, undefined, 1.0);
            has_hit = true;
            part_particles_create(part_system, punch_hitbox.x, punch_hitbox.y, part_type, 8);
            with (obj_manager) {
                enemies_alerted = true;
                global.alert_timer = 10 * game_get_speed(gamespeed_fps);
            }
        }
    }
}

// Fire weapon or punch on space bar press (only if not crouching)
if (keyboard_check_pressed(vk_space) && !is_punching && !is_crouching) {
    if (instance_exists(global.equipment_slots)) {
        var weapon_slot = global.equipment_slots.inventory[# 1, 0];
        if (is_array(weapon_slot) && weapon_slot[0] != -1 && obj_manager.ammo_current > 0) {
            var weapon_id = weapon_slot[0];
            var ammo_item_id = -1;
            var ammo_key = ds_map_find_first(global.ammo_to_weapon);
            while (!is_undefined(ammo_key)) {
                var ammo_data = global.ammo_to_weapon[? ammo_key];
                if (ammo_data[1] == weapon_id) {
                    ammo_item_id = ammo_key;
                    break;
                }
                ammo_key = ds_map_find_next(global.ammo_to_weapon, ammo_key);
            }

            if (ammo_item_id != -1) {
                var ammo_type = global.ammo_to_weapon[? ammo_item_id][0];
                
                if (obj_manager.ammo_current > 0) {
                    obj_manager.ammo_current -= 1;
                    ds_map_replace(obj_manager.ammo_counts, ammo_type, obj_manager.ammo_current);

                    var smallest_stack = -1;
                    var smallest_rounds = 9999;
                    var smallest_i = -1;
                    var smallest_j = -1;
                    for (var i = 0; i < ds_grid_width(global.backpack.inventory); i++) {
                        for (var j = 0; j < ds_grid_height(global.backpack.inventory); j++) {
                            var slot = global.backpack.inventory[# i, j];
                            if (is_array(slot) && slot[0] == ammo_item_id && slot[2] > 0 && slot[2] < smallest_rounds) {
                                smallest_stack = slot;
                                smallest_rounds = slot[2];
                                smallest_i = i;
                                smallest_j = j;
                            }
                        }
                    }

                    if (smallest_stack != -1) {
                        smallest_stack[2] -= 1;
                        if (smallest_stack[2] <= 0) {
                            inventory_remove(smallest_i, smallest_j, global.backpack.inventory);
                        } else {
                            global.backpack.inventory[# smallest_i, smallest_j] = smallest_stack;
                        }
                    }

                    var bullet = instance_create_layer(x, y, "Instances", obj_bullet);
                    bullet.direction = input_direction;
                    bullet.image_angle = input_direction;
                    bullet.creator = id;
                }
            }
        } else {
            is_punching = true;
            has_hit = false;
            image_index = 0;
            if (input_direction >= 45 && input_direction <= 135) {
                sprite_index = spr_rattler_punch_up;
                image_xscale = 1;
                image_yscale = 1;
            } else if (input_direction >= 225 && input_direction <= 315) {
                sprite_index = spr_rattler_punch_down;
                image_xscale = 1;
                image_yscale = 1;
            } else {
                sprite_index = spr_rattler_punch;
                image_xscale = (input_direction > 135 && input_direction < 225) ? -1 : 1;
                last_xscale = image_xscale;
                image_yscale = 1;
            }
        }
    }
}

// Inventory and pickup logic
if (pickup_cooldown > 0) pickup_cooldown--;

nearest_item_to_pickup = noone;
var min_dist = pickup_range;
with (obj_item) {
    var dist = point_distance(x, y, other.x, other.y);
    if (dist <= min_dist) {
        other.nearest_item_to_pickup = id;
        min_dist = dist;
    }
}

if (keyboard_check_pressed(vk_tab)) {
    if (instance_exists(global.backpack)) {
        global.backpack.is_open = !global.backpack.is_open;
    }
}

if (keyboard_check_pressed(ord("E")) && pickup_cooldown == 0 && nearest_item_to_pickup != noone) {
    with (nearest_item_to_pickup) {
        var my_item_id = item_id;
        if (my_item_id != ITEM.NONE) {
            var rounds_per_magazine = ds_map_exists(global.ammo_to_weapon, my_item_id) ? global.ammo_to_weapon[? my_item_id][2] : 1;
            var rounds_to_add = stack_quantity * rounds_per_magazine;
            var success = inventory_add_item(global.backpack, my_item_id, rounds_to_add, true, contained_items);
            if (success) {
                is_in_world = false;
                var placement_id = -1;
                for (var i = 0; i < ds_grid_width(global.backpack.inventory); i++) {
                    for (var j = 0; j < ds_grid_height(global.backpack.inventory); j++) {
                        var slot = global.backpack.inventory[# i, j];
                        if (is_array(slot) && slot[0] == my_item_id && slot[2] == rounds_to_add) {
                            placement_id = slot[1];
                            break;
                        }
                    }
                    if (placement_id != -1) break;
                }
                if (global.item_data[my_item_id][8] && placement_id != -1) {
                    var mod_width = global.item_data[my_item_id][9];
                    var mod_height = global.item_data[my_item_id][10];
                    var mod_grid = ds_grid_create(mod_width, mod_height);
                    if (array_length(contained_items) > 0) {
                        array_to_ds_grid(contained_items, mod_grid);
                    } else {
                        ds_grid_clear(mod_grid, -1);
                    }
                    global.mod_inventories[? placement_id] = mod_grid;
                }
                instance_destroy();
                other.pickup_cooldown = 15;
            }
        }
    }
    nearest_item_to_pickup = noone;
}

if (keyboard_check_pressed(ord("I"))) {
    with (obj_proximity_door) {
        if (locked) {
            unlock();
        }
    }
}