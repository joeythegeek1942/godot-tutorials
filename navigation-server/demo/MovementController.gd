class_name MovementController
extends Node2D

export(NodePath) var npc_path

onready var ClickEffect = preload("res://util/ClickEffect.tscn")
onready var npc:Villager = get_node(npc_path)

var target_location = Vector2()

func _ready():
	target_location = npc.global_position

func _input(event):
   if event is InputEventMouseButton and event.pressed:
	   target_location = get_global_mouse_position()
	   var clickEffect = ClickEffect.instance()
	   clickEffect.position = target_location
	   add_child(clickEffect)
	
func _process(delta):
	var direction = target_location - npc.global_position
	if direction.length() > 4:
		npc.move(direction)
	else:
		npc.move(Vector2.ZERO)
