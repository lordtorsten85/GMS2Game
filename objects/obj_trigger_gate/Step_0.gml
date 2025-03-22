/// obj_trigger_gate - Step

// If we’re opening:
if (state == "opening") {
    if (image_index >= 6) {
        // Door fully open
        image_index = 6;   // clamp to last frame
        image_speed = 0;   // stop anim
        visible = false;   // door is gone
        solid   = false;   // no collision
        state   = "open";  // done
		collision_active = false;
    }
}
// If we’re closing:
else if (state == "closing") {
	visible = true; 
    solid   = true;
	collision_active = true;
    if (image_index <= 1) {
        // Door fully closed
        image_index = 0;
        image_speed = 0;
        state   = "closed";
    }
}
