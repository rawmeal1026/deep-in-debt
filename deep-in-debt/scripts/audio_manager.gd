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

# --- VOLUME CONTROL (0.0 = silent, 1.0 = full) ---
var sfx_volume: float = 1.0
var bgm_volume: float = 1.0
## How much one increase/decrease call moves the volume
var volume_step: float = 0.1

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_base_db: Dictionary = {}
var _bgm_base_db: float = 0.0

func _ready() -> void:
	# Every player except BGM counts as SFX
	_sfx_players = [
		player_footstep,
		carpa_vaggio, leon_octo, mikoi_angelo, mon_whale,
		picass_shark, tuna_tello, van_gold,
		trashbag, bottle, can, milk, bag,
	]
	# Remember each node's editor volume so we never destroy your mix
	for p in _sfx_players:
		_sfx_base_db[p.name] = p.volume_db
	_bgm_base_db = bgm.volume_db


func play_sfx_oneshot(node: String, pitch: float = -1.0):
	var event = get(node)
	if event == null:
		push_warning("audio_manager.gd/play_sfx_oneshot(): WARN! sound event not found ('"+node+"' doesn't exist!)")
		return
	if pitch != -1:
		event.pitch_scale = pitch
	event.play()

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
