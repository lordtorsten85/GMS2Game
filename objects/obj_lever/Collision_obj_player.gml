/// @DnDAction : YoYo Games.Mouse & Keyboard.If_Key_Pressed
/// @DnDVersion : 1
/// @DnDHash : 2AA07E8B
/// @DnDArgument : "key" "ord("E")"
var l2AA07E8B_0;l2AA07E8B_0 = keyboard_check_pressed(ord("E"));if (l2AA07E8B_0){	/// @DnDAction : YoYo Games.Common.If_Variable
	/// @DnDVersion : 1
	/// @DnDHash : 3CC95925
	/// @DnDParent : 2AA07E8B
	/// @DnDArgument : "var" "image_index"
	if(image_index == 0){	/// @DnDAction : YoYo Games.Common.Variable
		/// @DnDVersion : 1
		/// @DnDHash : 5B728872
		/// @DnDParent : 3CC95925
		/// @DnDArgument : "expr" "1"
		/// @DnDArgument : "var" "image_index"
		image_index = 1;
	
		/// @DnDAction : YoYo Games.Common.Apply_To
		/// @DnDVersion : 1
		/// @DnDHash : 335F07D8
		/// @DnDApplyTo : gate_to_open
		/// @DnDParent : 3CC95925
		with(gate_to_open) {
			/// @DnDAction : YoYo Games.Instances.Sprite_Animation_Speed
			/// @DnDVersion : 1
			/// @DnDHash : 512AD73F
			/// @DnDParent : 335F07D8
			image_speed = 1;
		
			/// @DnDAction : YoYo Games.Audio.Play_Audio
			/// @DnDVersion : 1.1
			/// @DnDHash : 2BB37D96
			/// @DnDParent : 335F07D8
			/// @DnDArgument : "soundid" "snd_lever_pull"
			/// @DnDSaveInfo : "soundid" "snd_lever_pull"
			audio_play_sound(snd_lever_pull, 0, 0, 1.0, undefined, 1.0);
		}}}