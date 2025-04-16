// obj_player Step Event

var pickup_range = 48;

// Initialize state if not exists
if (!variable_instance_exists(id, "is_punching")) is_punching = false;
if (!variable_instance_exists(id, "last_xscale")) last_xscale = 1; // Track last facing direction for left/right
if (!variable_instance_exists(id, "last_direction")) last_direction = 0; // Track last movement direction (0:right, 90:up, 180:left, 270:down)
if (!variable_instance_exists(id, "has_hit")) has_hit = false; // Track if punch has applied damage

// Declare input variables
var h_input = (keyboard_check(vk_right) || keyboard_check(ord("D"))) - (keyboard_check(vk_left) || keyboard_check(ord("A")));
var v_input = (keyboard_check(vk_down) || keyboard_check(ord("S"))) - (keyboard_check(vk_up) || keyboard_check(ord("W")));

// Movement with arrow keys and WASD, only if not punching
if (!is_punching) {
    if (h_input != 0 || v_input != 0) {
        var dir = point_direction(0, 0, h_input, v_input);
        input_direction = dir;
        x += lengthdir_x(move_speed, dir);
        y += lengthdir_y(move_speed, dir);
        
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
    if (h_input != 0 || v_input != 0) {
        // Prioritize vertical movement for sprite (including diagonals)
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
            last_xscale = image_xscale; // Update facing direction for left/right
            image_yscale = 1;
        }
    } else {
        // Select idle sprite based on last_direction
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
            image_xscale = last_xscale; // Use last facing direction for left/right
            image_yscale = 1;
        }
    }
}

// Punching collision check
if (is_punching && (sprite_index == spr_rattler_punch || sprite_index == spr_rattler_punch_up || sprite_index == spr_rattler_punch_down)) {
    var punch_range = 32; // Adjust based on sprite size
    var punch_x = x;
    var punch_y = y;
    
    // Adjust hitbox based on punch direction
    if (sprite_index == spr_rattler_punch) {
        punch_x += image_xscale * 16; // Offset hitbox left/right
    } else if (sprite_index == spr_rattler_punch_up) {
        punch_y -= 16; // Offset hitbox up
    } else if (sprite_index == spr_rattler_punch_down) {
        punch_y += 16; // Offset hitbox down
    }
    
    // Store hitbox for debug drawing
    punch_hitbox = { x: punch_x, y: punch_y, size: 8 }; // Size is half-width of hitbox
    
    // Check for full-extension frame (frame 3, adjust as needed)
    if (image_index == 5 && !has_hit) {
        var enemy_hit = instance_place(punch_x, punch_y, obj_enemy_parent);
        if (enemy_hit != noone) {
            enemy_hit.hp -= melee_damage;
            has_hit = true; // Prevent multiple hits
            show_debug_message("Hit enemy for " + string(melee_damage) + " damage, enemy HP: " + string(enemy_hit.hp));
            // Spawn particle effect at hit location
            part_particles_create(part_system, punch_hitbox.x, punch_hitbox.y, part_type, 8); // Emit 8 particles
            // Trigger enemy alert
            with (obj_manager) {
                enemies_alerted = true;
                global.alert_timer = 10 * game_get_speed(gamespeed_fps);
                show_debug_message("Player punched enemy - all enemies alerted!");
            }
        }
    }
}

// Fire weapon or punch on space bar press
if (keyboard_check_pressed(vk_space) && !is_punching) {
    if (instance_exists(global.equipment_slots)) {
        var weapon_slot = global.equipment_slots.inventory[# 1, 0];
        if (is_array(weapon_slot) && weapon_slot[0] != -1 && obj_manager.ammo_current > 0) {
            // Existing shooting logic
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
                            show_debug_message("Removed empty " + global.item_data[ammo_item_id][0] + " stack at [" + string(smallest_i) + "," + string(smallest_j) + "]");
                        } else {
                            global.backpack.inventory[# smallest_i, smallest_j] = smallest_stack;
                        }
                    }

                    var bullet = instance_create_layer(x, y, "Instances", obj_bullet);
                    bullet.direction = input_direction;
                    bullet.image_angle = input_direction;
                    bullet.creator = id;
                    show_debug_message("Fired " + global.item_data[weapon_id][0] + ", rounds left: " + string(obj_manager.ammo_current));
                } else {
                    show_debug_message("No ammo left for " + global.item_data[weapon_id][0]);
                }
            }
        } else {
            // Punch logic
            is_punching = true;
            has_hit = false; // Reset has_hit for new punch
            image_index = 0;
            // Select punch sprite based on input_direction
            if (input_direction >= 45 && input_direction <= 135) { // Up
                sprite_index = spr_rattler_punch_up;
                image_xscale = 1;
                image_yscale = 1;
            } else if (input_direction >= 225 && input_direction <= 315) { // Down
                sprite_index = spr_rattler_punch_down;
                image_xscale = 1;
                image_yscale = 1;
            } else { // Left or Right
                sprite_index = spr_rattler_punch;
                image_xscale = (input_direction > 135 && input_direction < 225) ? -1 : 1;
                last_xscale = image_xscale; // Store facing direction
                image_yscale = 1;
            }
            show_debug_message("Punching with " + sprite_get_name(sprite_index) + ", direction: " + string(input_direction));
        }
    } else {
        show_debug_message("global.equipment_slots does not exist");
    }
}

// Inventory and pickup logic
if (!variable_instance_exists(id, "pickup_cooldown")) pickup_cooldown = 0;
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
        show_debug_message((global.backpack.is_open ? "Opened" : "Closed") + " backpack at GUI position [64,256]");
    }
}

if (keyboard_check_pressed(ord("E")) && pickup_cooldown == 0 && nearest_item_to_pickup != noone) {
    with (nearest_item_to_pickup) {
        var my_item_id = item_id;
        if (my_item_id != ITEM.NONE) {
            var rounds_per_magazine = ds_map_exists(global.ammo_to_weapon, my_item_id) ? global.ammo_to_weapon[? my_item_id][2] : 1;
            var rounds_to_add = stack_quantity * rounds_per_magazine;
            show_debug_message("Picking up " + global.item_data[my_item_id][0] + ": stack_quantity=" + string(stack_quantity) + ", rounds_to_add=" + string(rounds_to_add));
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
                        show_debug_message("Restored mod inventory for " + global.item_data[my_item_id][0] + " with placement_id " + string(placement_id) + " and contained_items: " + string(contained_items));
                    } else {
                        ds_grid_clear(mod_grid, -1);
                    }
                    global.mod_inventories[? placement_id] = mod_grid;
                }
                show_debug_message("Picked up " + global.item_data[my_item_id][0] + " with " + string(rounds_to_add) + " rounds");
                instance_destroy();
                other.pickup_cooldown = 15;
            } else {
                show_debug_message("Failed to pick up " + global.item_data[my_item_id][0] + " - backpack full or placement error");
            }
        }
    }
    nearest_item_to_pickup = noone;
}