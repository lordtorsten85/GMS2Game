// Clean up particle system and particle type
if (part_type_exists(part_type)) {
    part_type_destroy(part_type);
}
if (part_system_exists(part_system)) {
    part_system_destroy(part_system);
}