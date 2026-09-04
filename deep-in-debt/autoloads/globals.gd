extends Node

var bag_slow_interval = 10
#First increase threshold = bag_slow_interval * 2
#Second increase threshold = bag_slow_interval * 3
#Max_bag_content = bag_slow_interval * 4


## path        = the FMOD event path, e.g. "event:/SFX/BagPickup"
## param_name  = name of the FMOD parameter to set ("" = no parameter)
## param_value = value for that parameter
func play_fmod_sfx(path: String, param_name := "", param_value := 0.0) -> void:
	if path.is_empty():
		push_warning(name + ": FMOD event path is empty.")
		return

	if param_name.is_empty():
		FmodServer.play_one_shot(path)
	else:
		FmodServer.play_one_shot_with_params(path, {param_name: float(param_value)})

#if playing sfx with no parameter: Globals.play_fmod_sfx(path)
#if playing sfx with ONE parameter: Globals.play_fmod_sfx(path, parameter_name, parameter_value)
