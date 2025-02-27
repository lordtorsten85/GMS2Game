/// @DnDAction : YoYo Games.Common.Variable
/// @DnDVersion : 1
/// @DnDHash : 1821851E
/// @DnDArgument : "expr" "default_move_speed"
/// @DnDArgument : "var" "move_speed"
move_speed = default_move_speed;

/// @DnDAction : YoYo Games.Common.Variable
/// @DnDVersion : 1
/// @DnDHash : 0A75EB96
/// @DnDArgument : "expr" "false"
/// @DnDArgument : "var" "powerup_active"
powerup_active = false;

/// @DnDAction : YoYo Games.Common.Variable
/// @DnDVersion : 1
/// @DnDHash : 787E8BCD
/// @DnDArgument : "expr" "false"
/// @DnDArgument : "var" "star_powerup_active"
star_powerup_active = false;

/// @DnDAction : YoYo Games.Instances.Sprite_Animation_Speed
/// @DnDVersion : 1
/// @DnDHash : 793C8E47
image_speed = 1;

/// @DnDAction : YoYo Games.Instances.Color_Sprite
/// @DnDVersion : 1
/// @DnDHash : 4E26759C
image_blend = $FFFFFFFF & $ffffff;
image_alpha = ($FFFFFFFF >> 24) / $ff;

/// @DnDAction : YoYo Games.Audio.If_Audio_Playing
/// @DnDVersion : 1
/// @DnDHash : 306EDEF0
/// @DnDArgument : "soundid" "snd_music_rampage"
/// @DnDSaveInfo : "soundid" "snd_music_rampage"
var l306EDEF0_0 = snd_music_rampage;if (audio_is_playing(l306EDEF0_0)){	/// @DnDAction : YoYo Games.Audio.Stop_Audio
	/// @DnDVersion : 1
	/// @DnDHash : 35FBF940
	/// @DnDParent : 306EDEF0
	/// @DnDArgument : "soundid" "snd_music_rampage"
	/// @DnDSaveInfo : "soundid" "snd_music_rampage"
	audio_stop_sound(snd_music_rampage);}

/// @DnDAction : YoYo Games.Audio.If_Audio_Paused
/// @DnDVersion : 1
/// @DnDHash : 5D27753D
/// @DnDArgument : "soundid" "snd_music_game"
/// @DnDSaveInfo : "soundid" "snd_music_game"
var l5D27753D_0 = snd_music_game;if (audio_is_paused(l5D27753D_0)){	/// @DnDAction : YoYo Games.Audio.Resume_Audio
	/// @DnDVersion : 1
	/// @DnDHash : 590BF123
	/// @DnDParent : 5D27753D
	/// @DnDArgument : "sound" "snd_music_game"
	/// @DnDSaveInfo : "sound" "snd_music_game"
	audio_resume_sound(snd_music_game);}