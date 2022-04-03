tool
class_name Villager
extends KinematicBody2D

enum {
	RUN,
	IDLE,
	CARRY,
	CHOPPING,
	WATERING,
	DOING,
	DIGGING
}

onready var animation_tree:BlendPositionAnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	
func _process(delta):
	animation_tree.position = Vector2(-10, 0)
	animation_tree.transition = DIGGING
