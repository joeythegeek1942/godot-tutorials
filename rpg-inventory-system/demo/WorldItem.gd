class_name WorldItem
extends Node2D

export(Resource) var item

onready var sprite = $Sprite

func _ready():
	if item != null:
		sprite.texture = item.item_texture
