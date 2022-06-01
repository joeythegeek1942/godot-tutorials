class_name Villager
extends KinematicBody2D

signal action_performed()
signal target_reached

enum AnimationState {
	RUN = 0,
	IDLE = 1,
	CARRY = 2,
	CHOPPING = 3,
	WATERING = 4,
	DOING = 5,
	DIGGING = 6
}

export(String) var villager_name
export(String) var villager_profession
export(float) var ACCELERATION = 340
export(float) var FRICTION = 670
export(float) var MAX_SPEED = 75
export(Vector2) var target_location setget _set_target_location
export(NodePath) var house_path

onready var animation_tree:BlendPositionAnimationTree = $AnimationTree
onready var navigation_agent = $NavigationAgent2D
onready var house:House = get_node(house_path)
onready var voice_sounds = $VoiceSounds
onready var voice_timer = $VoiceTimer

var velocity = Vector2.ZERO
var state = AnimationState.IDLE
var move_direction = Vector2.ZERO
var last_move_velocity = Vector2.ZERO

func _ready():
	randomize()
	animation_tree.active = true
	target_location = global_position
	navigation_agent.set_target_location(target_location)
	voice_timer.start(rand_range(8.0, 20.0))
	
func get_house() -> House:
	return house
	
func water():
	state = AnimationState.WATERING

func chop():
	state = AnimationState.CHOPPING
	
func do():
	state = AnimationState.DOING
	
func dig():
	state = AnimationState.DIGGING
	
func carry():
	state = AnimationState.CARRY
	
func is_carrying():
	return state == AnimationState.CARRY
	
func reset():
	state = AnimationState.RUN
	
func move(direction:Vector2) -> void:
	move_direction = direction
	
func move_state(delta, idle_animation, run_animation, max_speed, acceleration):
	if move_direction != Vector2.ZERO:
		last_move_velocity = move_direction
		look_at_direction(move_direction)
		animation_tree.transition = run_animation
		velocity = velocity.move_toward(move_direction * max_speed, acceleration * delta)
	else:
		animation_tree.transition = idle_animation
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	velocity = move_and_slide(velocity)
	
func _physics_process(delta):
	if not visible:
		return
	var next_location = navigation_agent.get_next_location()
	var direction = (next_location - global_transform.origin).normalized()
	move(direction)
	
	match state:
		AnimationState.RUN:
			move_state(delta, AnimationState.IDLE, AnimationState.RUN, MAX_SPEED, ACCELERATION)
		_:
			move_state(delta, state, state, MAX_SPEED, ACCELERATION)
		
func look_at_direction(direction:Vector2) -> void:
	direction = direction.normalized()
	animation_tree.position = direction
	
func _action_performed() -> void:
	emit_signal("action_performed")
	
func _set_target_location(tl):
	target_location = tl
	if navigation_agent != null:
		navigation_agent.set_target_location(target_location)

func _on_VoiceTimer_timeout():
	voice_sounds.play()
	voice_timer.start(rand_range(8.0, 20.0))

func _on_NavigationAgent2D_target_reached():
	emit_signal("target_reached")
