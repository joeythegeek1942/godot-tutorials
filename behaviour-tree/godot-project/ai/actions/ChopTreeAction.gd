extends ActionLeaf

var action_performed = false
var action_queued = false
var tree

func tick(actor, blackboard):
	if not actor.is_connected("action_performed", self, "_action_performed"):
		actor.connect("action_performed", self, "_action_performed")
	
	tree = blackboard.get("closest-tree")
	
	if tree == null:
		action_performed = false
		action_queued = false
		actor.disconnect("action_performed", self, "_action_performed")
		return FAILURE
		
	if action_performed and tree.is_completely_chopped():
		tree = null
		action_performed = false
		action_queued = false
		actor.disconnect("action_performed", self, "_action_performed")
		actor.carry()
		return SUCCESS
		
	if not action_queued:
		action_queued = true
		actor.chop()
		
	return RUNNING

func _action_performed() -> void:
	action_performed = true
	action_queued = false
	tree.chop()
