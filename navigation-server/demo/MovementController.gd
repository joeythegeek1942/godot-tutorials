class_name MovementController
extends Node2D

export(NodePath) var npc_path

onready var ClickEffect = preload("res://util/ClickEffect.tscn")
onready var npc:Villager = get_node(npc_path)

func _input(event):
   if event is InputEventMouseButton and event.pressed:
	   var target_location = get_global_mouse_position()
	   npc.set_target_location(target_location)
	   var clickEffect = ClickEffect.instance()
	   clickEffect.position = target_location
	   add_child(clickEffect)
	   npc.make_sound()
