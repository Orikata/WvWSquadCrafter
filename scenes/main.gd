extends Node2D


@onready var squad: Squad =  preload("res://scripts/squad.tres")
@onready var palette: Palette = preload("res://scripts/palette.tres")

@onready var PaletteStackGuiClass = preload("res://scenes/palettestackgui.tscn")

@onready var squad_slots: Array = $CanvasLayer/Control/NinePatchRect/squadgui.get_children()
@onready var palette_slots: Array = $CanvasLayer/Control/NinePatchRect/palette.get_children()
@onready var syncbuttons = $CanvasLayer/Control/NinePatchRect/rowsync.get_children()
@onready var delbutton = $CanvasLayer/Control/NinePatchRect/delbutton
@onready var nine_patch_rect = $CanvasLayer/Control/NinePatchRect

#gui references
@onready var squadgui = $CanvasLayer/Control/NinePatchRect/squadgui
@onready var labelgui = $CanvasLayer/Control/labelcontainer
@onready var reference_rect = $CanvasLayer/ReferenceRect

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
		#update palette stack with current palette
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

func _on_delbutton_pressed():
	clearSquad()

func clearSquad():
	for slot in squad_slots:
		slot.takeItem() # returns the unit but we're clearing it so we dont care about the return.
	
	
func connectSquadSlots():
	for i in range(squad_slots.size()):
		if squad_slots[i]:
			var slot = squad_slots[i]
			slot.index = i
			var callable = Callable(onSquadSlotClicked)
			callable = callable.bind(slot)
			slot.pressed.connect(callable)

func connectSyncButtons():
	for i in range(syncbuttons.size()):
		if syncbuttons[i]:
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
	

func _on_camerabutton_pressed():
	await get_tree().process_frame  # UI should finish rendering first
	var reference_rect_global: Rect2 = reference_rect.get_global_rect()
	var top_left: Vector2 = reference_rect_global.position
	var bottom_right_y: float = reference_rect_global.position.y + reference_rect_global.size.y
	var max_width: float = reference_rect_global.size.x  # width of the reference_rect

	var capture_rect: Rect2 = Rect2(top_left, Vector2(max_width, bottom_right_y - top_left.y))
	var padding: float = 5.0
	capture_rect.position -= Vector2(padding, padding)
	capture_rect.size += Vector2(padding * 2, padding * 2)
	print("cappin area ong frfr: ", capture_rect)
	
	var screen_image: Image = get_viewport().get_texture().get_image()
	screen_image = screen_image.get_region(capture_rect)
	
	var current_time = Time.get_datetime_dict_from_system()
	print(current_time)
	var date_str = "%04d-%02d-%02d_%02d-%02d-%02d" % [
		current_time["year"], current_time["month"], current_time["day"],
		current_time["hour"], current_time["minute"], current_time["second"]
	]
	var file_path = "user://squad_" + date_str + ".png"
	print(file_path)
	screen_image.save_png(file_path)
	
	# open the folder where it's saved
	OS.shell_open(ProjectSettings.globalize_path("user://"))
