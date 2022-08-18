extends Node2D

onready var villager = $"%Villager"
onready var ship = $"%Ship"

func _ready():
	villager.swim()

func _on_Ship_arrive():
	ship.get_stash_area().place(0)
	ship.get_stash_area().place(1)
	ship.get_stash_area().place(2)
	ship.get_stash_area().place(3)
