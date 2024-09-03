extends Resource

class_name Squad

signal updated
@export var units: Array[Unit]

func insert(unit:Unit):
	for i in range(units.size()):
		if !units[i]:
			units[i] = unit
			return
	updated.emit()
	

func removeUnitAtIndex(index: int):
	units[index] = Unit.new()
	

func insertSlots(index:int, unit:Unit):
	var oldIndex: int = units.find(unit)
	removeUnitAtIndex(oldIndex)
	units[index] = unit
