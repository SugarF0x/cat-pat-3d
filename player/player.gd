class_name Player
extends CharacterBody3D


@export_range(1.0, 5.0) var fall_multiplier := 2.5
@export var speed := 2.0


@onready var camera_3d = $Camera3D
@onready var camera_3d_position = camera_3d.position
@onready var camera_3d_fov = camera_3d.fov
@onready var video_stream_player = $CanvasLayer/VideoStreamPlayer
@onready var video_stream_player_position = video_stream_player.position
@onready var video_stream_player_scale = video_stream_player.scale


const MOUSE_SENSITIVITY := .002
const ZOOM_MULTIPLIER := .7


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_motion := Vector2.ZERO


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	video_stream_player.paused = !Input.is_action_pressed("pet")


func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	handle_fall(delta)
	handle_movement()
	handle_crouch(delta)
	handle_zoom(delta)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
	
	if event is InputEventMouseMotion: mouse_motion = -event.relative * get_mouse_sensitivity_multiplier()
	video_stream_player.paused = !Input.is_action_pressed("pet")


func get_mouse_sensitivity_multiplier() -> float:
	var width = get_viewport().size.x
	var project_width = ProjectSettings.get_setting_with_override("display/window/size/viewport_width")
	return MOUSE_SENSITIVITY * width / project_width

func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	
	camera_3d.rotate_x(mouse_motion.y)
	camera_3d.rotation_degrees.x = clampf(camera_3d.rotation_degrees.x, -90, 90)
	
	mouse_motion = Vector2.ZERO

func handle_fall(delta: float) -> void: 
	if is_on_floor(): return
	
	if velocity.y >= 0: velocity.y -= gravity * delta
	else: velocity.y -= gravity * delta * fall_multiplier

func handle_movement() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

func handle_zoom(delta: float) -> void:
	camera_3d.fov = lerp(camera_3d.fov, camera_3d_fov * ZOOM_MULTIPLIER if Input.is_action_pressed("pet") else camera_3d_fov, delta * 20)
	video_stream_player.position = lerp(video_stream_player.position, video_stream_player_position * ZOOM_MULTIPLIER if Input.is_action_pressed("pet") else video_stream_player_position, delta * 20)
	video_stream_player.scale = lerp(video_stream_player.scale, video_stream_player_scale * ZOOM_MULTIPLIER if Input.is_action_pressed("pet") else video_stream_player_scale, delta * 20)

func handle_crouch(delta: float) -> void:
	camera_3d.position.y = lerp(camera_3d.position.y, camera_3d_position.y * .1 if Input.is_action_pressed("crouch") else camera_3d_position.y, delta * 20)
