extends Node3D


@onready var animation_player = $Room/AnimationPlayer
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $Room/Node3D/AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("pet"): 
		animation_player.play("maxwell_dance")
		if not audio_stream_player_3d.playing and not audio_stream_player_3d.stream_paused: audio_stream_player_3d.play()
		if audio_stream_player_3d.stream_paused: audio_stream_player_3d.stream_paused = false
		
	else:
		animation_player.pause()
		audio_stream_player_3d.stream_paused = true
