class_name Villager
extends KinematicBody2D

signal action_performed
signal animation_finished
signal target_reached

enum AnimationState {
	IDLE = 0,
	SWIM = 1,
}

var AnimationNames = {
	AnimationState.SWIM:"Swim",
	AnimationState.IDLE:"Idle",
}

export(float) var ACCELERATION = 540
export(float) var FRICTION = 770
export(float) var MAX_SPEED = 75

onready var animation_player = $AnimationPlayer
onready var voice_sounds = $VoiceSounds

var velocity = Vector2.ZERO
var state = AnimationState.IDLE
var move_direction = Vector2.ZERO
var last_move_velocity = Vector2.ZERO
var current_animation = null

func make_sound():
	voice_sounds.play()

func _ready():
	randomize()
	
func reset():
	state = AnimationState.IDLE
	
func swim():
	state = AnimationState.SWIM
	
func idle():
	state = AnimationState.IDLE
	velocity = Vector2.ZERO
	
func move(direction:Vector2) -> void:
	move_direction = direction
	
func do_state(delta, animation):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	_play_animation(animation)
	velocity = move_and_slide(velocity)
	
func move_state(delta, idle_animation, run_animation, max_speed, acceleration):
	if move_direction != Vector2.ZERO:
		last_move_velocity = move_direction
		look_at_direction(move_direction)
		_play_animation(run_animation)
		velocity = velocity.move_toward(move_direction * max_speed, acceleration * delta)
	else:
		_play_animation(idle_animation)
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	velocity = move_and_slide(velocity)
	
func _physics_process(delta):
	if not visible:
		return
	
	match state:
		AnimationState.IDLE:
			move_state(delta, AnimationState.IDLE, AnimationState.IDLE, MAX_SPEED, ACCELERATION)
		AnimationState.SWIM:
			move_state(delta, AnimationState.SWIM, AnimationState.SWIM, MAX_SPEED, ACCELERATION)
		_:
			do_state(delta, state)
		
func look_at_direction(direction:Vector2) -> void:
	direction = direction.normalized()
	move_direction = direction
	if current_animation != null:
		_play_animation(current_animation)
	
func _action_performed() -> void:
	emit_signal("action_performed")
	
func _on_NavigationAgent2D_target_reached():
	emit_signal("target_reached")

func _play_walk_sound():
	if not visible:
		return
	
func _animation_finished():
	emit_signal("animation_finished")
	
func _play_animation(animation_type:int) -> void:
	var animation_type_string = AnimationNames[animation_type]
	var animation_name = animation_type_string + "_" + _get_direction_string(move_direction.angle())
	if animation_name != animation_player.current_animation:
		animation_player.stop(true)
	animation_player.play(animation_name)
	current_animation = animation_type
			
func _get_direction_string(angle:float) -> String:
	var angle_deg = round(rad2deg(angle))
	if angle_deg > -90.0 and angle_deg < 90.0:
		return "Right"
	return "Left"

func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	velocity = move_and_slide(safe_velocity)
