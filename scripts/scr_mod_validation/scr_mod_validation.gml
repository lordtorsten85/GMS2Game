// Script: scr_mod_validation
function can_accept_mod(parent_item_id, mod_item_id) {
    var parent_data = global.item_data[parent_item_id];
    var valid_mod_items = parent_data[11]; // valid_mod_items array
    
    for (var i = 0; i < array_length(valid_mod_items); i++) {
        if (mod_item_id == valid_mod_items[i]) { // Check exact item ID
            return true;
        }
    }
    return false;
}