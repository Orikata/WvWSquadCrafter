extends GridContainer

@onready var palette: Palette = preload("res://scripts/palette.tres")
@onready var squad: Squad = preload("res://scripts/squad.tres")

@onready var palette_slots: Array = get_children()

func _ready():
	update()

func update():
	pass
	'for i in range(0, palette_slots.size()):
		#palette_slots[i].update(palette.units[i])
		print(i, " ",palette.units[i].name)'
