extends CanvasLayer
## Overlay panels: shop (computer), inventory (bag) and seed picker (bed).

signal closed

var greenhouse: Node
var dim: ColorRect
var panel: PanelContainer
var title_label: Label
var content: VBoxContainer
var scroll: ScrollContainer

func _ready() -> void:
	layer = 20
	visible = false

	dim = ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	panel = PanelContainer.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -370
	panel.offset_top = -270
	panel.offset_right = 370
	panel.offset_bottom = 270
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.09, 0.12, 0.97)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.65, 0.8, 0.9)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.6, 0.9, 1.0))
	title_label.text = "PANEL"
	vbox.add_child(title_label)

	var line := HSeparator.new()
	vbox.add_child(line)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 6)
	scroll.add_child(content)

	var close_btn := Button.new()
	close_btn.text = "Close  [ESC]"
	close_btn.custom_minimum_size = Vector2(0, 38)
	close_btn.add_theme_font_size_override("font_size", 17)
	close_btn.pressed.connect(close)
	vbox.add_child(close_btn)

func is_open() -> bool:
	return visible

func open_panel(title: String) -> void:
	title_label.text = title
	visible = true
	Global.ui_open = true

func close() -> void:
	visible = false
	Global.ui_open = false
	emit_signal("closed")

func _clear() -> void:
	for child in content.get_children():
		child.queue_free()

func _section(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.4))
	content.add_child(label)

func _hint(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.65, 0.72, 0.8))
	content.add_child(label)

func _row_button(text: String, icon: Texture2D, cb: Callable, tint: Color = Color(1, 1, 1)) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 38)
	btn.add_theme_font_size_override("font_size", 16)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.modulate = tint
	if icon:
		btn.icon = icon
		btn.expand_icon = true
		btn.add_theme_constant_override("icon_max_width", 28)
	btn.pressed.connect(cb)
	content.add_child(btn)
	return btn

# --- Shop --------------------------------------------------------------------
func show_shop() -> void:
	_open_shop()

func _open_shop() -> void:
	_clear()
	open_panel("SHIP COMPUTER")

	_section("SEEDS")
	for pid in GameData.plant_ids():
		var data := GameData.plant(pid)
		var cost := int(data.get("seed_cost", 10))
		var label := "Buy %s seed  -  %d cr   (have %d)" % [
			str(data.get("name", pid)), cost, Global.count_item(GameData.seed_id(pid))]
		_row_button(label, GameData.item_icon(GameData.seed_id(pid)),
			func(): _buy_seed(pid, cost))

	_section("SELL HARVEST")
	var any := false
	for pid in GameData.plant_ids():
		var cid := GameData.crop_id(pid)
		var count := Global.count_item(cid)
		if count <= 0:
			continue
		any = true
		var data := GameData.plant(pid)
		var price := int(data.get("sell", 1))
		var label := "Sell %s  x%d   +%d cr" % [str(data.get("name", pid)), count, price * count]
		_row_button(label, GameData.item_icon(cid), func(): _sell_crop(pid, price))
	if not any:
		_hint("Nothing to sell yet - go harvest something.")

	_section("SUPPLIES")
	_row_button("Buy water +20   -  10 cr   (have %d)" % roundi(Global.water),
		null, func(): _buy_water())
	_row_button("Convert 5 harvest -> 10 fuel   (fuel %d)" % roundi(Global.fuel),
		null, func(): _convert_fuel())
	_hint("Fuel powers the ship. Rescue mission target: 100 fuel.")

func _buy_seed(pid: String, cost: int) -> void:
	if Global.credits < cost:
		greenhouse.toast("Not enough credits.")
		return
	Global.add_credits(-cost)
	Global.add_item(GameData.seed_id(pid), 1)
	greenhouse.toast("Bought %s seed." % GameData.plant(pid).get("name", pid))
	_open_shop()

func _sell_crop(pid: String, price: int) -> void:
	var cid := GameData.crop_id(pid)
	var count := Global.count_item(cid)
	if count <= 0:
		return
	Global.take_item(cid, count)
	Global.add_credits(price * count)
	greenhouse.toast("Sold %d for %d credits." % [count, price * count])
	_open_shop()

func _buy_water() -> void:
	if Global.credits < 10:
		greenhouse.toast("Not enough credits.")
		return
	if Global.water >= Global.MAX_WATER - 0.1:
		greenhouse.toast("Water tank is full.")
		return
	Global.add_credits(-10)
	Global.water = min(Global.MAX_WATER, Global.water + 20.0)
	greenhouse.toast("Water +20")
	_open_shop()

func _convert_fuel() -> void:
	var total := 0
	var ids := []
	for pid in GameData.plant_ids():
		var cid := GameData.crop_id(pid)
		total += Global.count_item(cid)
		ids.append(cid)
	if total < 5:
		greenhouse.toast("Need 5 harvest to convert.")
		return
	var need := 5
	for cid in ids:
		while need > 0 and Global.count_item(cid) > 0:
			Global.take_item(cid, 1)
			need -= 1
		if need == 0:
			break
	Global.fuel = min(Global.MAX_FUEL, Global.fuel + 10.0)
	greenhouse.toast("Fuel +10")
	_open_shop()

# --- Inventory ---------------------------------------------------------------
func show_inventory() -> void:
	_clear()
	open_panel("BACKPACK")
	if Global.inventory.is_empty():
		_hint("Empty. Harvest some plants first.")
		return

	var keys := Global.inventory.keys()
	keys.sort()
	for item_id in keys:
		var count := int(Global.inventory[item_id])
		var name := GameData.item_name(str(item_id))
		if GameData.crop_plant(str(item_id)) != "":
			_row_button("%s  x%d   -   Eat" % [name, count],
				GameData.item_icon(str(item_id)), func(): _eat(str(item_id)))
		else:
			_row_button("%s  x%d" % [name, count], GameData.item_icon(str(item_id)),
				func(): pass)
	_hint("Press Q to eat the best crop instantly. TAB toggles this panel.")

func _eat(item_id: String) -> void:
	if greenhouse:
		greenhouse.eat_item(item_id)

# --- Seed picker -------------------------------------------------------------
func show_seed_picker(bed_index: int) -> void:
	_clear()
	open_panel("PLANT A SEED")
	var any := false
	for pid in GameData.plant_ids():
		var sid := GameData.seed_id(pid)
		var count := Global.count_item(sid)
		if count <= 0:
			continue
		any = true
		var data := GameData.plant(pid)
		var label := "%s  x%d   (%ds)" % [str(data.get("name", pid)), count,
			int(data.get("grow_time", 120))]
		_row_button(label, GameData.item_icon(sid), func(): _plant(bed_index, pid))
	if not any:
		_hint("No seeds. Buy some at the computer.")
	_hint("The bed is auto-watered when you plant.")

func _plant(bed_index: int, pid: String) -> void:
	if Global.plant(bed_index, pid):
		greenhouse.toast("Planted %s." % GameData.plant(pid).get("name", pid))
		greenhouse.refresh_beds()
		close()
	else:
		greenhouse.toast("Cannot plant there.")

# --- Info --------------------------------------------------------------------
func show_info(title: String, text: String) -> void:
	_clear()
	open_panel(title)
	_hint(text)
