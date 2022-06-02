extends ConditionLeaf

func tick(actor, blackboard):
	var trees = get_tree().get_nodes_in_group("Trees")
	for tree in trees:
		if tree.is_completely_chopped():
			return SUCCESS
	return FAILURE
