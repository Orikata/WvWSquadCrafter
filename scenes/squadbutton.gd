extends Button

@onready var center_container = $CenterContainer
var paletteStackGui: PaletteStackGui
var index:int
@onready var squad = preload("res://scripts/squad.tres")

func insert(psg:PaletteStackGui):
	if psg.get_parent():
		psg.get_parent().remove_child(psg)
	remove_all_children()
	paletteStackGui = psg
	center_container.add_child(paletteStackGui)
	
	#if !paletteStackGui.unit || squad.units[index]==paletteStackGui.unit:
	#	return
		
	squad.insertSlots(index, paletteStackGui.unit)
	
func takeItem():
	if !paletteStackGui: return
	var unit = paletteStackGui
	center_container.remove_child(paletteStackGui) #only do this for squad buttons
	paletteStackGui= null
	return unit

func isPalette():
	return false	

func remove_all_children():
	for child in center_container.get_children():
		center_container.remove_child(child)
		child.queue_free()
