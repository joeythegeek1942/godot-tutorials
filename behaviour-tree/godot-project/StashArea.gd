tool
class_name StashArea
extends Node2D

const STASH_DIMENSION = 16

export(int) var stash_size = 12
export(int) var stash_per_row = 4

onready var StashSlot = preload("res://world_objects/stashbox/StashSlot.tscn")
onready var slots = $Slots
var pointer = Vector2.ZERO

func _ready():
	for i in range(0, stash_size):
		if i % stash_per_row == 0:
			pointer.x = 0
			pointer.y += STASH_DIMENSION
		else:
			pointer.x += STASH_DIMENSION
		
		var slot = StashSlot.instance()
		slot.position = pointer
		slots.add_child(slot)

func get_next_available_slot() -> int:
	for i in range(0, stash_size):
		if get_slot(i).has_space():
			return i
	return -1
	
func get_slot_position(slot:int) -> Vector2:
	return get_slot(slot).position
	
func place(slot:int) -> bool:
	return get_slot(slot).place_box()
	
func get_slot(slot:int) -> StashSlot:
	return slots.get_child(slot)
