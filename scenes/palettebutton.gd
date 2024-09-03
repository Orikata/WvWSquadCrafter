extends Button

@onready var center_container = $CenterContainer
var paletteStackGui: PaletteStackGui

func insert(psg:PaletteStackGui):
	paletteStackGui = psg
	center_container.add_child(paletteStackGui)

func takeItem():
	if !paletteStackGui: return
	var unit = paletteStackGui.duplicate()
	return unit

func isPalette():
	return true
