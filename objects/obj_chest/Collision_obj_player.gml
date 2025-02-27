/// @DnDAction : YoYo Games.Common.If_Variable
/// @DnDVersion : 1
/// @DnDHash : 56AA351F
/// @DnDArgument : "var" "locked"
/// @DnDArgument : "value" "true"
if(locked == true){	/// @DnDAction : YoYo Games.Mouse & Keyboard.If_Key_Pressed
	/// @DnDVersion : 1
	/// @DnDHash : 17EFB02D
	/// @DnDParent : 56AA351F
	/// @DnDArgument : "key" "ord("E")"
	var l17EFB02D_0;l17EFB02D_0 = keyboard_check_pressed(ord("E"));if (l17EFB02D_0){	/// @DnDAction : YoYo Games.Audio.Play_Audio
		/// @DnDVersion : 1.1
		/// @DnDHash : 0B049E5F
		/// @DnDParent : 17EFB02D
		/// @DnDArgument : "soundid" "snd_chest_locked"
		/// @DnDSaveInfo : "soundid" "snd_chest_locked"
		audio_play_sound(snd_chest_locked, 0, 0, 1.0, undefined, 1.0);}

	/// @DnDAction : YoYo Games.Common.Exit_Event
	/// @DnDVersion : 1
	/// @DnDHash : 4DD7760A
	/// @DnDParent : 56AA351F
	exit;}

/// @DnDAction : YoYo Games.Mouse & Keyboard.If_Key_Pressed
/// @DnDVersion : 1
/// @DnDHash : 723DE982
/// @DnDArgument : "key" "ord("E")"
var l723DE982_0;l723DE982_0 = keyboard_check_pressed(ord("E"));if (l723DE982_0){	/// @DnDAction : YoYo Games.Particles.Effect
	/// @DnDVersion : 1
	/// @DnDHash : 1D68A546
	/// @DnDParent : 723DE982
	/// @DnDArgument : "x_relative" "1"
	/// @DnDArgument : "y" "-20"
	/// @DnDArgument : "y_relative" "1"
	/// @DnDArgument : "type" "7"
	/// @DnDArgument : "where" "1"
	/// @DnDArgument : "size" "1"
	/// @DnDArgument : "color" "$FF1EDDFF"
	effect_create_above(7, x + 0, y + -20, 1, $FF1EDDFF & $ffffff);

	/// @DnDAction : YoYo Games.Common.Variable
	/// @DnDVersion : 1
	/// @DnDHash : 38A45121
	/// @DnDParent : 723DE982
	/// @DnDArgument : "expr" "coins_to_give"
	/// @DnDArgument : "expr_relative" "1"
	/// @DnDArgument : "var" "obj_player.coins"
	obj_player.coins += coins_to_give;

	/// @DnDAction : YoYo Games.Audio.Play_Audio
	/// @DnDVersion : 1.1
	/// @DnDHash : 058722EF
	/// @DnDParent : 723DE982
	/// @DnDArgument : "soundid" "snd_chest_open"
	/// @DnDSaveInfo : "soundid" "snd_chest_open"
	audio_play_sound(snd_chest_open, 0, 0, 1.0, undefined, 1.0);

	/// @DnDAction : YoYo Games.Instances.Change_Instance
	/// @DnDVersion : 1
	/// @DnDHash : 50D891BF
	/// @DnDParent : 723DE982
	/// @DnDArgument : "objind" "obj_chest_open"
	/// @DnDSaveInfo : "objind" "obj_chest_open"
	instance_change(obj_chest_open, true);}