// obj_inventory
// Event: Alarm 0
// Description: Forces a redraw of the inventory UI to show stack quantities after pickup.
if (is_open) {
    show_debug_message("Redrawing " + inventory_type + " UI after pickup");
    alarm[0] = -1; // Reset alarm
}