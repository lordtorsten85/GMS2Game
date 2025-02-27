/// @DnDAction : YoYo Games.Instances.Destroy_Instance
/// @DnDVersion : 1
/// @DnDHash : 589E68C7
instance_destroy();

/// @DnDAction : YoYo Games.Particles.Effect
/// @DnDVersion : 1
/// @DnDHash : 37EFFD4D
/// @DnDArgument : "x_relative" "1"
/// @DnDArgument : "y_relative" "1"
/// @DnDArgument : "type" "5"
/// @DnDArgument : "where" "1"
/// @DnDArgument : "size" "1"
/// @DnDArgument : "color" "$FF7626C1"
effect_create_above(5, x + 0, y + 0, 1, $FF7626C1 & $ffffff);

/// @DnDAction : YoYo Games.Audio.Play_Audio
/// @DnDVersion : 1.1
/// @DnDHash : 7D5F2074
/// @DnDArgument : "soundid" "snd_bat_defeat"
/// @DnDSaveInfo : "soundid" "snd_bat_defeat"
audio_play_sound(snd_bat_defeat, 0, 0, 1.0, undefined, 1.0);