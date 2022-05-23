class_name House
extends Node2D

onready var enter_leave_position = $EnterLeavePosition

func get_enter_leave_position() -> Vector2:
	return enter_leave_position.position
