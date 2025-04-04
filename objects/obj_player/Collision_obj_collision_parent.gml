// obj_player Collision with obj_collision_parent
var x_move = x - xprevious;
var y_move = y - yprevious;

if (x_move != 0) {
    if (place_meeting(x + x_move, yprevious, obj_collision_parent)) {
        var list = ds_list_create();
        instance_place_list(x + x_move, yprevious, obj_collision_parent, list, false);
        var blocked = false;
        for (var i = 0; i < ds_list_size(list); i++) {
            var inst = list[| i];
            if (inst.collision_active) {
                blocked = true;
                break;
            }
        }
        ds_list_destroy(list);
        if (blocked) {
            x = xprevious;
        }
    }
}

if (y_move != 0) {
    if (place_meeting(x, y + y_move, obj_collision_parent)) {
        var list = ds_list_create();
        instance_place_list(x, y + y_move, obj_collision_parent, list, false);
        var blocked = false;
        for (var i = 0; i < ds_list_size(list); i++) {
            var inst = list[| i];
            if (inst.collision_active) {
                blocked = true;
                break;
            }
        }
        ds_list_destroy(list);
        if (blocked) {
            y = yprevious;
        }
    }
}