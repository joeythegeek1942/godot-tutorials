tool
class_name Villager
extends KinematicBody2D

signal action_performed()

enum AnimationState {
	RUN = 0,
	IDLE = 1,
	CARRY = 2,
	CHOPPING = 3,
	WATERING = 4,
	DOING = 5,
	DIGGING = 6
}

export(float) var ACCELERATION = 340
export(float) var FRICTION = 670
export(float) var MAX_SPEED = 75

onready var animation_tree:BlendPositionAnimationTree = $AnimationTree

var velocity = Vector2.ZERO
var state = AnimationState.IDLE
var move_direction = Vector2.ZERO
var last_move_velocity = Vector2.ZERO

func _ready():
	animation_tree.active = true
	
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
