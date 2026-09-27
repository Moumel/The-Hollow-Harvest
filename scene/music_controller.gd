extends Node

var player: AudioStreamPlayer

func _ready():
   
	player = AudioStreamPlayer.new()
	player.name = "AudioStreamPlayer"
	add_child(player)
	player.bus = &"Master"

func play_music(stream: AudioStream, fade_in_duration: float = 1.0):
	
	if player.stream == stream and player.playing:
		return
	
	
	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamOggVorbis:
		stream.loop = true    
	
   
	if player.playing:
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(player, "volume_db", -80.0, 0.5)
		await fade_out_tween.finished
		player.stop()

 
	player.stream = stream
	player.volume_db = -80 
	player.play()
	
 
	var tween = create_tween()
	tween.tween_property(player, "volume_db", 0.0, fade_in_duration).set_trans(Tween.TRANS_SINE)

func play_music_from_path(track_path: String):
	var new_track = load(track_path)
	if new_track:
		play_music(new_track)

func fade_out_and_stop(duration: float = 1.0):
	if not player.playing:
		return
		
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration).set_trans(Tween.TRANS_SINE)
	await tween.finished
	player.stop()
	player.volume_db = 0.0 
