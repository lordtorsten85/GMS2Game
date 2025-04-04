/// obj_trigger_gate - Create
event_inherited();
state = "closed";
image_speed = 0;
image_index = 0;

collision_active = true; // Blocks player and grid when closed
locked = true; // Set to true in room editor for locked gates

// Only locked gates block the grid initially
if (locked) {
    mp_grid_add_rectangle(global.mp_grid, 
        x - sprite_width/2, y - sprite_height/2, 
        x + sprite_width/2, y + sprite_height/2);
} else {
    mp_grid_clear_rectangle(global.mp_grid, 
        x - sprite_width/2, y - sprite_height/2, 
        x + sprite_width/2, y + sprite_height/2);
}

function Activate() {
    if (state == "closed" || state == "closing") {
        image_speed = 1;
        state = "opening";
    }
}

function Deactivate() {
    if (state == "open" || state == "opening") {
        image_speed = -1;
        state = "closing";
    }
}