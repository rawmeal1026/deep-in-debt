extends Node

@onready var player_footstep: AudioStreamPlayer = %player_footstep
@onready var bgm: AudioStreamPlayer = %BGM
@onready var npc_voices: Node = $npc_voices
@onready var carpa_vaggio: AudioStreamPlayer = %carpa_vaggio
@onready var leon_octo: AudioStreamPlayer = %leon_octo
@onready var mikoi_angelo: AudioStreamPlayer = %mikoi_angelo
@onready var mon_whale: AudioStreamPlayer = %mon_whale
@onready var picass_shark: AudioStreamPlayer = %picass_shark
@onready var tuna_tello: AudioStreamPlayer = %tuna_tello
@onready var van_gold: AudioStreamPlayer = %van_gold
@onready var pickup_sfx: Node = $pickup_sfx
@onready var trashbag: AudioStreamPlayer = %trashbag
@onready var bottle: AudioStreamPlayer = %bottle
@onready var can: AudioStreamPlayer = %can
@onready var milk: AudioStreamPlayer = %milk
@onready var bag: AudioStreamPlayer = %bag


func play_sfx_oneshot(node: String, pitch: float = -1.0):
	var event = get(node)
	if event == null:
		push_warning("audio_manager.gd/play_sfx_oneshot(): WARN! sound event not found ('"+node+"' doesn't exist!)")
		return
	if pitch != -1:
		event.pitch_scale = pitch
	event.play()
	print("played sfx " + node + " with pitch " + str(event.pitch_scale))

func play_or_update_loop(node_name: String, clip_id: int = 0) -> void:
	var event = get(node_name)
	if event == null:
		push_warning("audio_manager.gd/play_or_update_loop(): WARN! loop event not found ('" + node_name + "')")
		return
	
	if event is AudioStreamPlayer:
		if not event.playing:
			event.play()
		
		var playback = event.get_stream_playback()
		if playback is AudioStreamPlaybackInteractive:
			if playback.get_current_clip_index() != clip_id:
				playback.switch_to_clip(clip_id)
