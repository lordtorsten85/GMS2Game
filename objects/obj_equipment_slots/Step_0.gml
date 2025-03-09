// obj_equipment_slots - Step Event
// Description: Extends obj_inventory drag-and-drop with equipment slot-specific click detection.
// Variable Definitions (set in object editor):
// - Inherited from obj_inventory
// - slot_types - array: Type requirements per slot (default: [ITEM_TYPE.UTILITY, ITEM_TYPE.WEAPON])
// - spacing - real: Pixel gap between slots (default: 64)

event_inherited();

// Override context menu spawning for equipment slots to account for spacing
if (mouse_check_button_pressed(mb_right) && is_open && dragging == -1 && global.dragging_inventory == -1 && !instance_exists(obj_context_menu) && !instance_exists(obj_mod_inventory)) {
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);
    var mx = floor((gui_mouse_x - inv_gui_x) / (slot_size + spacing));
    var my = floor((gui_mouse_y - inv_gui_y) / slot_size);
    if (mx >= 0 && mx < grid_width && my == 0) { // Height is always 1, so my must be 0
        var slot = inventory[# mx, my];
        if (slot != -1 && is_array(slot)) {
            var item_id = slot[0];
            instance_create_layer(0, 0, "GUI_Menu", obj_context_menu, {
                menu_x: gui_mouse_x,
                menu_y: gui_mouse_y,
                slot_x: mx,
                slot_y: my,
                inventory: id,
                item_id: item_id
            });
            show_debug_message("Spawned context menu for equipment slot item at [" + string(mx) + ",0]");
        }
    }
}