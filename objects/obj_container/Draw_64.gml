// obj_container - Draw GUI
// Renders the container UI with feedback, inheriting obj_inventory drawing
// Removes proximity prompt, now handled in world Draw event

event_inherited(); // Pull in all obj_inventory drawing (hover, drag highlights, items)