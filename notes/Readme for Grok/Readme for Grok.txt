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


Make no assumptions! If you need to clarify something, ask!