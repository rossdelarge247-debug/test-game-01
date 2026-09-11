extends Node
## Original synthesized mono PCM cues. No external recordings or copyrighted music.
static var muted := false
var voices: Array[AudioStreamPlayer] = []
var clips := {}
var last_cue := ""
var cue_count := 0

func _ready() -> void:
	for i in range(4):
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -14.0
		add_child(voice)
		voices.append(voice)
	for entry in [["sword", 660.0, 0.16], ["passage", 330.0, 0.22], ["memory", 880.0, 0.3],
		["finish", 990.0, 0.4], ["hurt", 150.0, 0.12], ["defeat", 220.0, 0.2], ["room", 440.0, 0.1]]:
		clips[entry[0]] = _tone(entry[1], entry[2])

func _tone(frequency: float, duration: float) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var count := int(duration * stream.mix_rate)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t := float(i) / stream.mix_rate
		var envelope := minf(t / 0.012, 1.0) * (1.0 - float(i) / count)
		data.encode_s16(i * 2, int(sin(TAU * frequency * t) * envelope * 12000))
	stream.data = data
	return stream

func cue(kind: String) -> void:
	if muted or not clips.has(kind):
		return
	last_cue = kind
	cue_count += 1
	for voice in voices:
		if not voice.playing:
			voice.stream = clips[kind]
			voice.play()
			print("SOUND_CUE " + kind)
			return

func toggle() -> void:
	muted = not muted
	if muted:
		stop_all()
	print("SOUND_MUTED=%s" % muted)

func stop_all() -> void:
	for voice in voices:
		voice.stop()
