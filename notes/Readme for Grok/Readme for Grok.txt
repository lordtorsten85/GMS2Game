Coding standards - We are using Game Maker Studio 2. For each event, script, and function, please include a comment block at the top of the code with the name of the object/script, the specific event (if in an object) and a brief description of what it does, as well as any variable definitions set in the object editor and their purpose.

Project structure - I want to keep everything lean and reusable, I want to be able to expand on functionality of the inventory without breaking several other features.

Version control – Using SourceTree local repo

Testing - We test 1 fix at a time, I don't want to induce errors through testing. When testing using the debug log, any messages that occur during the step or draw events should be removed in the next iteration of the script once the problem is fixed as to not flood the debug log.

Documentation - Covered in the coding standards

Communication - Speak to me as a designer, not a programmer. I have solid coding knowledge, but I am mostly a designer. More complicated code blocks will require a deeper explanation.

Constraints - Not really too much of a worry for performance. This is a 2D retro-style adventure game, akin to the original metal gear games.

Project Scope - This is a 2D adventure game where the volumetric inventory is a core mechanic of the game. The player is limited by what they can carry, and their inventory expands over time. The player interacts with containers and consoles, which have their own inventories. Containers can be preloaded with items that the player can drag items from and into their inventory and vice versa. Consoles are similar to containers, except filling them with certain items will trigger events on other objects, such as opening a door, turning on a light, or combining items in the console to make a new item. Equipment slots are special cases of inventories. The player will have 2 equipment slots always displayed in their HUD, a utility and weapon slot. These special slots always reduce the size of the sprite being equipped to fit in a 1x1 grid cell (for better UI design). Items removed from equipment slots return to their original size upon being removed.

Experience Level - I'm comfortable with programming, but not an expert. I have a BS degree in Game Design. I'm getting more comfortable with Game Maker Studio 2 but I grew up on Unreal Engine (UDK, UE4, UE5).

1 more thing. Don't use things like @param or @function or @description in comment blocks, it messes with Game Maker. Also, when utilizing variable definitions dont use code checks like argument(0) or arg(0), they're not necessary, instance_create_layer() (refer to the room creation code)  is sufficient to spawn in an instance with the variables set to what we want.

I’d like to note that when I’m talking about variable definitions, I’m talking about the definitions created in the object editor in game maker, not defining them in the create even. So if you see variable definitions in a comment but they’re not defined in create, confirm with me if you’re unsure about their utilization before making assumptions.

obj_intentory has children: obj_container, obj_equipment_slots, and obj_mod_inventory

They have variable definitions set in the object editor of game maker 2. 

for obj_inventory:

// inventory_type - string
// grid_width - real
// grid_height - real
// slot_size - real
// inv_gui_x - real
// inv_gui_y - real
// dragging - real
// drag_offset_x - real
// drag_offset_y - real
// original_grid - real
// original_mx - real
// original_my - real
// is_open - boolean
// inventory - asset (ds_grid)
// just_split_timer - real
// parent_inventory - asset


for obj_equipment_slots:

// slot_types - expression - default to [ITEM_TYPE.UTILITY, ITEM_TYPE.WEAPON]
// spacing - real - defaults to 64

obj_context_menu has them too, but is not a child of obj_inventory

// inventory - asset
// item_id - real
// slot_x - real
// slot_y - real
// menu_x - real
// menu_y - real

We protect variable definitions defined in the object editor like this in the create event of the object:

if (!variable_instance_exists(id, "inventory_type")) inventory_type = "generic"; // e.g., "backpack", "container"
if (!variable_instance_exists(id, "grid_width")) grid_width = 4;              // Number of slots wide
if (!variable_instance_exists(id, "grid_height")) grid_height = 4;            // Number of slots tall

But we do not redelcare them, this overwrites the values we want to be set in instance_create_layer

We call instance create layer when spawning instances with their variable definitions by using the optional 4th argument (array) in instance_create_layer()

There are two GUI layers we are currently using:

GUI - drawn first - depth 12500
GUI_Menu - drawn next - depth 12600
 
I need whole functions, scripts, and events, not snippets. This keeps us on the same page by me copy/pasting what you output

Make no assumptions! If you need to clarify something, ask!