extends Node2D

onready var villager = $"%Villager"

func _ready():
	villager.swim()
