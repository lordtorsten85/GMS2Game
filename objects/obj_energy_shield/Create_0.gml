/// @DnDAction : YoYo Games.Audio.Play_Audio
/// @DnDVersion : 1.1
/// @DnDHash : 4AA685AA
/// @DnDArgument : "target" "shield_sound"
/// @DnDArgument : "target_temp" "1"
/// @DnDArgument : "soundid" "snd_shield_loop"
/// @DnDArgument : "loop" "1"
/// @DnDSaveInfo : "soundid" "snd_shield_loop"
var shield_sound = audio_play_sound(snd_shield_loop, 0, 1, 1.0, undefined, 1.0);

/// @DnDAction : YoYo Games.Audio.Audio_Set_Volume
/// @DnDVersion : 1.1
/// @DnDHash : 728EC217
/// @DnDArgument : "sound" "snd_shield_loop"
/// @DnDArgument : "volume" "2"
/// @DnDSaveInfo : "sound" "snd_shield_loop"
audio_sound_gain(snd_shield_loop, 2, 0);