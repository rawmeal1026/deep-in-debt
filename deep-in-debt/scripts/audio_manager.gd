extends Node

@onready var player_footstep: AudioStreamPlayer = $player_footstep
@onready var bgm: AudioStreamPlayer = $BGM
#@onready var npc_voices: Node = $npc_voices
@onready var carpa_vaggio: AudioStreamPlayer = $npc_voices/carpa_vaggio
@onready var leon_octo: AudioStreamPlayer = $npc_voices/leon_octo
@onready var mikoi_angelo: AudioStreamPlayer = $npc_voices/mikoi_angelo
@onready var mon_whale: AudioStreamPlayer = $npc_voices/mon_whale
@onready var picass_shark: AudioStreamPlayer = $npc_voices/picass_shark
@onready var tuna_tello: AudioStreamPlayer = $npc_voices/tuna_tello
@onready var van_gold: AudioStreamPlayer = $npc_voices/van_gold
#@onready var pickup_sfx: Node = $pickup_sfx
@onready var trashbag: AudioStreamPlayer = $pickup_sfx/trashbag
@onready var bottle: AudioStreamPlayer = $pickup_sfx/bottle
@onready var can: AudioStreamPlayer = $pickup_sfx/can
@onready var milk: AudioStreamPlayer = $pickup_sfx/milk
@onready var bag: AudioStreamPlayer = $pickup_sfx/bag


func play_sfx_oneshot(node: String, pitch: float = -1.0):
	var event = get(node)
	if event == null:
		push_warning("audio_manager.gd/play_sfx_oneshot(): WARN! sound event not found ('"+node+"' doesn't exist)")
		return
	if pitch != -1:
		event.pitch_scale = pitch
	event.play()
	print("played sfx " + node + " with pitch " + str(event.pitch_scale))
