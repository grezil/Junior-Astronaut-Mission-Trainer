extends Node2D
## A single grow bed: planter, plant sprite, water gauge and status label.

const BED_W := 88.0
const BODY_TOP := -34.0
const BODY_BOTTOM := 10.0
const SOIL_TOP := -30.0

var index: int = -1
var sprite: Sprite2D
var label: Label
var _last_stage := -1
var _ready_glow := 0.0
var _plant_h := 0.0

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.name = "PlantSprite"
	sprite.centered = true
	sprite.z_index = 1
	add_child(sprite)

	label = Label.new()
	label.name = "Status"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 3)
	label.size = Vector2(150, 18)
	label.position = Vector2(-75, BODY_TOP - 20)
	add_child(label)

	_build_collision()
	refresh(true)
	set_process(true)

func _build_collision() -> void:
	# The planter is solid: the player can not walk through the beds.
	var body := StaticBody2D.new()
	body.name = "Body"
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(BED_W, BODY_BOTTOM - BODY_TOP)
	cs.shape = rs
	cs.position = Vector2(0, (BODY_TOP + BODY_BOTTOM) * 0.5)
	body.add_child(cs)
	add_child(body)

func setup(bed_index: int) -> void:
	index = bed_index
	refresh(true)

func bed_data() -> Dictionary:
	return Global.bed(index)

func plant_id() -> String:
	var b := bed_data()
	return str(b.get("plant", ""))

func progress_ratio() -> float:
	var b := bed_data()
	if b.is_empty() or str(b.get("plant", "")) == "":
		return 0.0
	var data := GameData.plant(str(b["plant"]))
	var grow_time := float(data.get("grow_time", 120.0))
	return clampf(float(b.get("progress", 0.0)) / maxf(grow_time, 0.001), 0.0, 1.0)

func is_mature() -> bool:
	var b := bed_data()
	if b.is_empty() or str(b.get("plant", "")) == "":
		return false
	return progress_ratio() >= 0.999 and not bool(b.get("withered", false))

func is_withered() -> bool:
	return bool(bed_data().get("withered", false))

func is_empty() -> bool:
	return str(bed_data().get("plant", "")) == ""

# --- Interaction -------------------------------------------------------------
func prompt() -> String:
	if index < 0:
		return ""
	if is_empty():
		return "[E] Plant a seed"
	if is_withered():
		return "[E] Clear the dead plant"
	if is_mature():
		return "[E] Harvest"
	var b := bed_data()
	if float(b.get("water", 0.0)) < 95.0:
		return "[E] Water the bed"
	return "[E] Water (still wet)"

# --- Visuals -----------------------------------------------------------------
func _stage_height(stage: int) -> float:
	match stage:
		0: return 44.0
		1: return 62.0
		2: return 78.0
	return 92.0

func refresh(force: bool = false) -> void:
	if sprite == null:
		return
	var b := bed_data()
	var pid := str(b.get("plant", ""))
	if b.is_empty() or pid == "":
		sprite.texture = null
		label.text = ""
		_plant_h = 0.0
		_last_stage = -1
		queue_redraw()
		return

	var data := GameData.plant(pid)
	var ratio := progress_ratio()
	var stage := 0
	if ratio >= 0.999:
		stage = 3
	elif ratio >= 0.7:
		stage = 2
	elif ratio >= 0.3:
		stage = 1

	if force or stage != _last_stage:
		_last_stage = stage
		var tex_path := str(data.get("sprite", ""))
		var target_h := _stage_height(stage)
		if stage == 0:
			tex_path = GameData.SPROUT_TEXTURE
		var tex := load(tex_path) as Texture2D
		sprite.texture = tex
		if tex and tex.get_height() > 0:
			var s := target_h / float(tex.get_height())
			sprite.scale = Vector2(s, s)
		_plant_h = target_h
		sprite.position = Vector2(0, SOIL_TOP - target_h * 0.5 + 4.0)

	if is_withered():
		sprite.modulate = Color(0.5, 0.42, 0.33, 0.95)
		label.text = "DEAD"
		label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	elif is_mature():
		sprite.modulate = Color(1, 1, 1, 1)
		label.text = "%s  READY" % str(data.get("name", pid))
		label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	else:
		sprite.modulate = Color(1, 1, 1, 1)
		label.text = "%s  %d%%" % [str(data.get("name", pid)), int(ratio * 100.0)]
		label.add_theme_color_override("font_color", Color(0.8, 0.92, 1.0))
	label.position = Vector2(-75, SOIL_TOP - _plant_h - 14)
	queue_redraw()

func _process(delta: float) -> void:
	if sprite == null or sprite.texture == null:
		return
	var t := Time.get_ticks_msec() / 1000.0
	if is_mature():
		_ready_glow = 0.5 + 0.5 * sin(t * 4.0)
		rotation = 0.0
	else:
		_ready_glow = 0.0
		rotation = sin(t * 1.6 + index * 1.7) * 0.012
	queue_redraw()

func _draw() -> void:
	var b := bed_data()
	var has_plant: bool = not b.is_empty() and str(b.get("plant", "")) != ""

	# Floor shadow.
	draw_rect(Rect2(-BED_W * 0.5 - 4, BODY_BOTTOM - 2, BED_W + 8, 7),
		Color(0, 0, 0, 0.35), true)

	# Planter box.
	var body := Rect2(-BED_W * 0.5, BODY_TOP, BED_W, BODY_BOTTOM - BODY_TOP)
	draw_rect(body, Color(0.26, 0.34, 0.31, 1.0), true)
	draw_rect(body, Color(0.10, 0.14, 0.14, 1.0), false, 2.0)
	# Front panel highlight.
	draw_rect(Rect2(-BED_W * 0.5 + 3, BODY_TOP + 20, BED_W - 6, 2),
		Color(0.45, 0.55, 0.48, 0.55), true)

	# Top rim.
	draw_rect(Rect2(-BED_W * 0.5 - 3, BODY_TOP - 5, BED_W + 6, 8),
		Color(0.50, 0.56, 0.52, 1.0), true)
	draw_rect(Rect2(-BED_W * 0.5 - 3, BODY_TOP - 5, BED_W + 6, 8),
		Color(0.10, 0.12, 0.12, 1.0), false, 1.0)

	# Soil.
	draw_rect(Rect2(-BED_W * 0.5 + 6, SOIL_TOP, BED_W - 12, 16),
		Color(0.32, 0.22, 0.15, 1.0), true)
	draw_rect(Rect2(-BED_W * 0.5 + 6, SOIL_TOP, BED_W - 12, 3),
		Color(0.18, 0.12, 0.08, 1.0), true)
	# Watered-soil tint.
	if has_plant and float(b.get("water", 0.0)) > 20.0:
		draw_rect(Rect2(-BED_W * 0.5 + 6, SOIL_TOP + 3, BED_W - 12, 13),
			Color(0.10, 0.20, 0.24, 0.35), true)

	# Water gauge on the front face.
	if has_plant:
		var w := clampf(float(b.get("water", 0.0)) / 100.0, 0.0, 1.0)
		var bar := Rect2(-30, BODY_BOTTOM - 8, 60, 5)
		draw_rect(bar, Color(0.05, 0.08, 0.12, 0.9), true)
		var col := Color(0.25, 0.7, 1.0, 0.95)
		if w < 0.05:
			col = Color(1.0, 0.4, 0.3, 0.95)
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * w, bar.size.y)), col, true)

	# Soft glow under a mature plant.
	if is_mature():
		draw_rect(Rect2(-BED_W * 0.5 + 6, SOIL_TOP + 2, BED_W - 12, 14),
			Color(1.0, 0.9, 0.35, 0.12 + 0.18 * _ready_glow), true)
