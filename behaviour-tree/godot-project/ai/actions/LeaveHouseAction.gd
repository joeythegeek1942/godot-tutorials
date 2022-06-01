extends ActionLeaf

func tick(actor, blackboard):
	if not actor.visible:
		actor.get_house().leave_house()
		actor.visible = true
	return SUCCESS
