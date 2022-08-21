class_name Villager
extends KinematicBody2D

signal action_performed
signal animation_finished
signal target_reached
signal path_changed(path)

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
onready var navigation_agent:NavigationAgent2D = $NavigationAgent2D

var velocity = Vector2.ZERO
var safe_velocity = Vector2.ZERO
var state = AnimationState.IDLE
var last_move_velocity = Vector2.ZERO
var current_animation = null
var move_direction = Vector2.ZERO

func _ready():
	# ensure villagers are initially set to their origin
	set_target_location(position)

func make_sound():
	voice_sounds.play()
	
func reset():
	state = AnimationState.IDLE
	
func swim():
	state = AnimationState.SWIM
	
func idle():
	state = AnimationState.IDLE
	velocity = Vector2.ZERO
	
func set_target_location(target:Vector2) -> void:
	navigation_agent.set_target_location(target)
	make_sound()
	
func move_state(delta, idle_animation, run_animation, max_speed, acceleration):
	
	var next_location = navigation_agent.get_next_location()

	if not navigation_agent.is_navigation_finished():
		var move_direction = position.direction_to(next_location)
		velocity = move_direction * MAX_SPEED
		look_at_direction(move_direction)
		_play_animation(run_animation)
	else:
		_play_animation(idle_animation)
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	navigation_agent.set_velocity(velocity)
	
func _physics_process(delta):
	if not visible:
		return
	
	match state:
		AnimationState.IDLE:
			move_state(delta, AnimationState.IDLE, AnimationState.IDLE, MAX_SPEED, ACCELERATION)
		AnimationState.SWIM:
			move_state(delta, AnimationState.SWIM, AnimationState.SWIM, MAX_SPEED, ACCELERATION)
	
	if not navigation_agent.is_navigation_finished():
		velocity = move_and_slide(safe_velocity)
	
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
	self.safe_velocity = safe_velocity

func _on_NavigationAgent2D_path_changed():
	emit_signal("path_changed", navigation_agent.get_nav_path())


func _on_NavigationAgent2D_navigation_finished():
	emit_signal("path_changed", [])
	emit_signal("target_reached")
