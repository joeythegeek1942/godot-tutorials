class_name StashSlot
extends Sprite

onready var stash_box = $StashBox

func place_box() -> bool:
	if not stash_box.visible:
		stash_box.visible = true
		return true
	return false
	
func take_box() -> bool:
	if stash_box.visible:
		stash_box.visible = false
		return true
	return false

func has_space() -> bool:
	return not stash_box.visible 
