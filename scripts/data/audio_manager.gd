extends Node
## AudioManager (TV5) — phát hiệu ứng âm thanh cơ bản + bật/tắt âm thanh.
## Không phải Autoload: scene tự tạo bằng AudioManager.new() rồi add_child().
## Không tự lưu trạng thái: nơi khác đọc SaveManager rồi gọi set_sound_enabled().

## Số player phát song song, để hiệu ứng này không cắt hiệu ứng kia.
const POOL_SIZE: int = 4

var sound_enabled: bool = true

var _players: Array[AudioStreamPlayer] = []
var _next_player: int = 0


func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)

	_apply_mute()


## Bật/tắt âm thanh.
func set_sound_enabled(enabled: bool) -> void:
	sound_enabled = enabled
	_apply_mute()

	if not enabled:
		stop_sound()


func is_sound_enabled() -> bool:
	return sound_enabled


## Phát một hiệu ứng. Khi đang tắt âm thanh hoặc stream null thì không phát.
func play_sound(sound: AudioStream) -> void:
	if not sound_enabled or sound == null or _players.is_empty():
		return

	var player: AudioStreamPlayer = _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = sound
	player.play()


## Dừng mọi âm thanh đang phát.
func stop_sound() -> void:
	for player in _players:
		player.stop()


func _apply_mute() -> void:
	var master_bus: int = AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_mute(master_bus, not sound_enabled)
