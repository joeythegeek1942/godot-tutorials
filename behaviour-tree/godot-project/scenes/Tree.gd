tool
class_name WoodTree
extends StaticBody2D

enum TreeState {
	PLANTED,
	GROWING,
	GROWN,
	CHOPPING
}

export(TreeState) var state = TreeState.GROWN

onready var planted_sprite = $PlantedSprite
onready var grow_sprites = $GrowSprites.get_children()
onready var grown_sprite = $GrownSprite
onready var chop_sprites = $ChopSprites
