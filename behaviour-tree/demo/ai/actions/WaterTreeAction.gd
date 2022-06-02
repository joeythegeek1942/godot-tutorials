extends TreeAction

func _start_action(actor):
	actor.water()
	
func _change_tree(tree):
	tree.water()
