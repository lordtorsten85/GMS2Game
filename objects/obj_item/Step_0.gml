// obj_item - Step Event

if (place_meeting(x, y, obj_player) && keyboard_check_pressed(ord("E"))) {
    var my_item_id = item_id; // Set in Create Event, e.g., ITEM.SYRINGE
    show_debug_message("Item ID: " + string(my_item_id));
    var success = (my_item_id != ITEM.NONE && inventory_add(global.backpack, my_item_id, 1));
    if (success) {
        instance_destroy();
    }
}