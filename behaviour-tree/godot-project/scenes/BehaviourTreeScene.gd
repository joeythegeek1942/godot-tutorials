extends Node2D

onready var stash_area = $Objects/Buildings/StashArea

func _ready():
	stash_area.place(0)
	stash_area.place(1)
	stash_area.place(2)
	stash_area.place(3)
	stash_area.place(4)
	stash_area.place(5)
	stash_area.place(6)
	stash_area.place(7)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
