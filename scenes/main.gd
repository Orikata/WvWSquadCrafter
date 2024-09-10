extends Node2D


@onready var squad: Squad =  preload("res://scripts/squad.tres")
@onready var palette: Palette = preload("res://scripts/palette.tres")

@onready var PaletteStackGuiClass = preload("res://scenes/palettestackgui.tscn")

@onready var squad_slots: Array = $CanvasLayer/Control/NinePatchRect/squadgui.get_children()
@onready var palette_slots: Array = $CanvasLayer/Control/NinePatchRect/palette.get_children()
@onready var syncbuttons = $CanvasLayer/Control/NinePatchRect/rowsync.get_children()

@onready var nine_patch_rect = $CanvasLayer/Control/NinePatchRect

var unitInHand: PaletteStackGui

func _ready():
	squad.updated.connect(update)
	connectSquadSlots()
	connectPaletteSlots()
	connectSyncButtons()
	update()

func update():
	for i in range(min(palette.units.size(), palette_slots.size())):
		#squad_slots[i].update(squad.units[i])
		var paletteSlot:Unit = palette.units[i]
		if !paletteSlot:continue
		var palettestackgui: PaletteStackGui = palette_slots[i].paletteStackGui
		if !palettestackgui:
			palettestackgui = PaletteStackGuiClass.instantiate()
			palette_slots[i].insert(palettestackgui)
		palettestackgui.unit = palette.units[i]
		palettestackgui.update()
	
	for i in range(min(squad.units.size(), squad_slots.size())):
		#squad_slots[i].update(squad.units[i])
		var squadSlot:Unit = squad.units[i]
		if !squadSlot:continue
		var palettestackgui: PaletteStackGui = squad_slots[i].paletteStackGui
		if !palettestackgui:
			palettestackgui = PaletteStackGuiClass.instantiate()
			squad_slots[i].insert(palettestackgui)
		palettestackgui.unit = squad.units[i]
		palettestackgui.update()

func connectSquadSlots():
	for i in range(squad_slots.size()):
		var slot = squad_slots[i]
		slot.index = i
		var callable = Callable(onSquadSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)
	
func connectSyncButtons():
	for i in range(syncbuttons.size()):
		var but = syncbuttons[i]
		but.index = i
		var callable = Callable(onSyncButClicked)
		callable = callable.bind(but)
		but.pressed.connect(callable)

func onSyncButClicked(button):
	if !unitInHand: return
	var column_index = button.index
	if column_index == null:return
	
	var duplicates = []
	for slot in squad_slots:
		if slot.index % 5 == column_index:
			var unit_duplicate = unitInHand.duplicate()
			if unit_duplicate.get_parent():
				unit_duplicate.get_parent().remove_child(unit_duplicate)
			slot.insert(unit_duplicate)
			duplicates.append(unit_duplicate)
	unitInHand.queue_free()
	unitInHand = null
	

func removeFromHand():
	unitInHand.queue_free()
	unitInHand = null

func onSquadSlotClicked(slot):
	if unitInHand:
		insertUnitInSlot(slot)
		return
	if !unitInHand:
		takeUnitFromSlot(slot)
	updateUnitInHand()

func connectPaletteSlots():
	for slot in palette_slots:
		var callable = Callable(onPaletteSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func onPaletteSlotClicked(slot):
	if unitInHand:
		nine_patch_rect.remove_child(unitInHand)
	unitInHand = slot.takeItem()
	nine_patch_rect.add_child(unitInHand)
	updateUnitInHand()

func takeUnitFromSlot(slot):
	unitInHand = slot.takeItem()
	if !unitInHand: return
	nine_patch_rect.add_child(unitInHand)
	updateUnitInHand()
	
func clearSlotClicked(slot):
	unitInHand = slot.takeItem()
	unitInHand.queue_free()
	unitInHand = null
	updateUnitInHand()

func insertUnitInSlot(slot):
	if unitInHand:
		if unitInHand.get_parent():
			unitInHand.get_parent().remove_child(unitInHand)
		slot.insert(unitInHand)
		unitInHand = null

func updateUnitInHand():
	if !unitInHand: return
	unitInHand.global_position = get_global_mouse_position()

func _input(_event):
	if unitInHand && Input.is_action_just_pressed("rightClick"):
		removeFromHand()
	
	updateUnitInHand()
	
