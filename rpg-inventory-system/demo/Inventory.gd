class_name Inventory
extends Node

class InventorySlot:
	var item:Item
	var previous:InventorySlot
	var next:InventorySlot
	var amount:int

# is emitted when an item gets removed from this inventory
signal item_removed(Item, count, index)
# is emitted when an item is added to this inventory
signal item_added(Item, count, index)
# is emitted when an item has been picked up onto this inventory
signal item_collected(Item, count)
# is emitted when an item is 
signal item_count_updated(Item, count, index)

export var number_of_slots = 4 setget _set_slots

var slots:Array = []
var initialised:bool = true
var used_slots:int = 0

func _ready():
	_set_slots(number_of_slots)

func clear():
	for slot in slots:
		slot.item = null
		slot.amount = 0
	
func get_item_add_index(item:Item) -> int:
	var index = -1
	# only find items that can be stacked
	if item.stackable:
		index = _find(item)
	if index != -1:
		# item found, let's return the index
		return index
	# no stackable item found, let's see if we can add it
	for slot_index in range(0, slots.size()):
		var slot = slots[slot_index]
		if slot.item == null:
			# empty slot found
			return slot_index
	# all slots occupied!
	return -1
	
func set_item(item:Item, count:int, index:int) -> void:
	if count > 0:
		var old_item = slots[index].item
		var old_amount = slots[index].amount
		slots[index].item = item
		slots[index].amount = count
		if old_item != null:
			emit_signal("item_removed", old_item, old_amount, index, forging_attributes)
		else:
			used_slots += 1
		if initialised:
			emit_signal("item_collected", item, count, forging_attributes)
		emit_signal("item_added", item, count, count, forging_attributes)
		emit_signal("item_count_updated", item, count, index, forging_attributes)
	else:
		var old_item = slots[index].item
		var old_amount = slots[index].amount
		slots[index].item = null
		slots[index].amount = 0
		slots[index].forging_attributes = null
		if old_item != null:	
			used_slots -= 1
			emit_signal("item_removed", old_item, old_amount, index)
		emit_signal("item_count_updated", item, count, index)

func add_item(item:Item, count:int) -> int:
	if count_item(item) > 0 && item.stackable:
		var slot_index = _find(item)
		slots[slot_index].amount = slots[slot_index].amount + count
		if initialised:
			emit_signal("item_collected", item, count)
		emit_signal("item_added", item, count, slot_index)
		emit_signal("item_count_updated", item, slots[slot_index].amount, slot_index)
		return slot_index
	else:
		var new_index = get_item_add_index(item)
		if new_index != -1:
			slots[new_index].item = item
			slots[new_index].amount = count
			used_slots += 1
			if initialised:
				emit_signal("item_collected", item, count)
			emit_signal("item_added", item, count, new_index)
			emit_signal("item_count_updated", item, slots[new_index].amount, new_index)
			return new_index
	return -1
	
func remove_item(item:Item, count:int, index:int = -1) -> int:
	if has_item(item, count):
		var slot_index = index
		if slot_index == -1:
			slot_index = _find(item)
		slots[slot_index].amount = slots[slot_index].amount - count
		if slots[slot_index].amount == 0:
			used_slots -= 1
			slots[slot_index].item = null
			emit_signal("item_count_updated", item, 0, slot_index)
		else:
			emit_signal("item_count_updated", item, slots[slot_index].amount, slot_index)
		emit_signal("item_removed", item, count, slot_index)
		return slot_index
	else:
		return -1
		
func swap_item(from_index:int,to_index:int) -> void:
	var from_slot_item = slots[from_index].item
	var from_slot_amount = slots[from_index].amount
	var to_slot_item = slots[to_index].item
	var to_slot_amount = slots[to_index].amount
	slots[to_index].forging_attributes = from_slot_attributes
	slots[from_index].forging_attributes = to_slot_attributes
	slots[to_index].amount = from_slot_amount
	slots[from_index].amount = to_slot_amount
	slots[to_index].item = from_slot_item
	slots[from_index].item = to_slot_item
	emit_signal("item_count_updated", slots[to_index].item, slots[to_index].amount, to_index)
	emit_signal("item_count_updated", slots[from_index].item, slots[from_index].amount, from_index)

func can_pick_up(item:Item,count:int) -> bool:
	var available_slots = slots.size()  - used_slots
	if available_slots > 0:
		return true
	return item.stackable && has_item(item, 1)

func _find(item:Item) -> int:
	for i in range(0, slots.size()):
		var slot = slots[i]
		if slot.item != null && slot.item.item_name == item.item_name:
			return i
	return -1

func _set_slots(number:int):
	number_of_slots = number
	slots.clear()
	# create slots
	for _i in range(0, number_of_slots):
		var slot = InventorySlot.new()
		slots.append(slot)
	# link siblings
	for i in range(0, number_of_slots):
		var slot = slots[i]
		if i > 0:
			slot.previous = slots[i - 1]
		else:
			slot.previous = slots[number_of_slots - 1]
		if i < number_of_slots - 1:
			slot.next = slots[i + 1]
		else:
			slot.next = slots[0]

func _get_items():
	var items = []
	for slot in slots:
		if slot.item != null:
			items.append(slot.item.get_path())
		else:
			items.append(null)
	return items
	
func _get_amounts():
	var amounts = []
	for slot in slots:
		amounts.append(slot.amount)
	return amounts
