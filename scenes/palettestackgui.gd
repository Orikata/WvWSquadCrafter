extends Panel

class_name PaletteStackGui
@onready var iconSprite:Sprite2D = $icon


var unit: Unit

func update():
	#if !unit || unit.item:return
	
	iconSprite.visible = true
	iconSprite.texture = unit.texture
	
