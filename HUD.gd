extends CanvasLayer
## In-game HUD: HP / Food / Oxygen bars, credits, prompt and toasts.

var hp_bar: ProgressBar
var food_bar: ProgressBar
var o2_bar: ProgressBar
var hp_label: Label
var food_label: Label
var o2_label: Label
var credits_label: Label
var resource_label: Label
var prompt_label: Label
var toast_label: Label

var _toast_time := 0.0

const COL_HP := Color(0.9, 0.15, 0.15)
const COL_FOOD := Color(0.95, 0.6, 0.1)
const COL_O2 := Color(0.2, 0.75, 0.95)

func _ready() -> void:
	layer = 10
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	hp_bar = _make_bar(root, 16, "HPBar", "HP", COL_HP, Color(0.4, 0.1, 0.1))
	food_bar = _make_bar(root, 52, "FoodBar", "FOOD", COL_FOOD, Color(0.35, 0.22, 0.05))
	o2_bar = _make_bar(root, 88, "O2Bar", "O2", COL_O2, Color(0.08, 0.25, 0.38))
	hp_label = hp_bar.get_node("Label")
	food_label = food_bar.get_node("Label")
	o2_label = o2_bar.get_node("Label")

	credits_label = Label.new()
	credits_label.name = "Credits"
	credits_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	credits_label.offset_left = -220
	credits_label.offset_top = 14
	credits_label.offset_right = -16
	credits_label.offset_bottom = 44
	credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	credits_label.add_theme_font_size_override("font_size", 20)
	credits_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.45))
	credits_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	credits_label.add_theme_constant_override("outline_size", 4)
	root.add_child(credits_label)

	resource_label = Label.new()
	resource_label.name = "Resources"
	resource_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	resource_label.offset_left = -340
	resource_label.offset_top = 46
	resource_label.offset_right = -16
	resource_label.offset_bottom = 74
	resource_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	resource_label.add_theme_font_size_override("font_size", 15)
	resource_label.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95))
	resource_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	resource_label.add_theme_constant_override("outline_size", 3)
	root.add_child(resource_label)

	prompt_label = Label.new()
	prompt_label.name = "Prompt"
	prompt_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	prompt_label.offset_left = -300
	prompt_label.offset_top = 14
	prompt_label.offset_right = 300
	prompt_label.offset_bottom = 46
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 18)
	prompt_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	prompt_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	prompt_label.add_theme_constant_override("outline_size", 5)
	root.add_child(prompt_label)

	toast_label = Label.new()
	toast_label.name = "Toast"
	toast_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast_label.offset_left = -340
	toast_label.offset_top = 52
	toast_label.offset_right = 340
	toast_label.offset_bottom = 86
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 17)
	toast_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	toast_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	toast_label.add_theme_constant_override("outline_size", 5)
	toast_label.modulate.a = 0.0
	root.add_child(toast_label)

	var hints := Label.new()
	hints.name = "Hints"
	hints.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	hints.offset_left = 16
	hints.offset_top = -34
	hints.offset_right = 460
	hints.offset_bottom = -12
	hints.text = "WASD move    E interact    TAB bag    Q eat"
	hints.add_theme_font_size_override("font_size", 13)
	hints.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 0.95))
	hints.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	hints.add_theme_constant_override("outline_size", 4)
	root.add_child(hints)

	update_from_global()

func _make_bar(parent: Control, y: float, node_name: String, text: String, fill: Color, bg: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.name = node_name
	bar.offset_left = 16
	bar.offset_top = y
	bar.offset_right = 236
	bar.offset_bottom = y + 28
	bar.max_value = 100
	bar.value = 100
	bar.show_percentage = false

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(bg.r, bg.g, bg.b, 0.85)
	bg_style.corner_radius_top_left = 6
	bg_style.corner_radius_top_right = 6
	bg_style.corner_radius_bottom_left = 6
	bg_style.corner_radius_bottom_right = 6
	bg_style.border_width_left = 1
	bg_style.border_width_top = 1
	bg_style.border_width_right = 1
	bg_style.border_width_bottom = 1
	bg_style.border_color = fill.darkened(0.4)
	bar.add_theme_stylebox_override("background", bg_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill
	fill_style.corner_radius_top_left = 5
	fill_style.corner_radius_top_right = 5
	fill_style.corner_radius_bottom_left = 5
	fill_style.corner_radius_bottom_right = 5
	bar.add_theme_stylebox_override("fill", fill_style)

	var label := Label.new()
	label.name = "Label"
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("outline_size", 3)
	label.text = text
	bar.add_child(label)

	parent.add_child(bar)
	return bar

func update_from_global() -> void:
	if hp_bar == null:
		return
	hp_bar.value = Global.player_hp
	food_bar.value = Global.player_food
	o2_bar.value = Global.oxygen
	hp_label.text = "HP  %d" % roundi(Global.player_hp)
	food_label.text = "FOOD  %d" % roundi(Global.player_food)
	o2_label.text = "O2  %d" % roundi(Global.oxygen)
	credits_label.text = "%d cr" % Global.credits
	resource_label.text = "Water %d   Power %d   Fuel %d" % [
		roundi(Global.water), roundi(Global.power), roundi(Global.fuel)]

func set_prompt(text: String) -> void:
	if prompt_label:
		prompt_label.text = text

func toast(text: String) -> void:
	if toast_label == null:
		return
	toast_label.text = text
	toast_label.modulate.a = 1.0
	_toast_time = 2.4

func _process(delta: float) -> void:
	if _toast_time > 0.0:
		_toast_time -= delta
		if _toast_time < 0.6:
			toast_label.modulate.a = maxf(0.0, _toast_time / 0.6)
	update_from_global()
