class_name GameData
extends RefCounted
## Static game data: plant species and item definitions.
## Edit numbers here - everything else reads from these tables.

const CAT_STABLE := "stable"
const CAT_FRESH := "fresh"
const CAT_LEAFY := "leafy"
const CAT_HERB := "herb"

const CATEGORY_LABEL := {
	CAT_STABLE: "Stable crop",
	CAT_FRESH: "Fresh produce",
	CAT_LEAFY: "Leafy green",
	CAT_HERB: "Herb",
}

# grow_time: seconds to mature with full water/light
# water_need: water consumed to finish a full grow cycle (bed holds 100)
# oxygen: O2 per second produced when mature
const PLANTS := {
	"potato": {
		"name": "Potato", "category": CAT_STABLE,
		"grow_time": 180.0, "water_need": 40.0,
		"yield": 4, "food": 28.0, "hp": 4.0, "oxygen": 0.55,
		"seed_cost": 20, "sell": 11,
		"sprite": "res://assets/plants/plant_potato.png",
		"icon": "res://assets/items/crop_potato.png",
	},
	"dwarf_wheat": {
		"name": "Dwarf wheat", "category": CAT_STABLE,
		"grow_time": 200.0, "water_need": 35.0,
		"yield": 5, "food": 22.0, "hp": 3.0, "oxygen": 0.6,
		"seed_cost": 18, "sell": 8,
		"sprite": "res://assets/plants/plant_dwarf_wheat.png",
		"icon": "res://assets/items/crop_dwarf_wheat.png",
	},
	"soybean": {
		"name": "Soybean", "category": CAT_STABLE,
		"grow_time": 170.0, "water_need": 35.0,
		"yield": 4, "food": 24.0, "hp": 5.0, "oxygen": 0.8,
		"seed_cost": 18, "sell": 10,
		"sprite": "res://assets/plants/plant_soybean.png",
		"icon": "res://assets/items/crop_soybean.png",
	},
	"cherry_tomato": {
		"name": "Cherry tomato", "category": CAT_FRESH,
		"grow_time": 130.0, "water_need": 30.0,
		"yield": 6, "food": 14.0, "hp": 4.0, "oxygen": 0.45,
		"seed_cost": 12, "sell": 5,
		"sprite": "res://assets/plants/plant_cherry_tomato.png",
		"icon": "res://assets/items/crop_cherry_tomato.png",
	},
	"chile_pepper": {
		"name": "Chile pepper", "category": CAT_FRESH,
		"grow_time": 140.0, "water_need": 28.0,
		"yield": 5, "food": 12.0, "hp": 6.0, "oxygen": 0.35,
		"seed_cost": 14, "sell": 6,
		"sprite": "res://assets/plants/plant_chile_pepper.png",
		"icon": "res://assets/items/crop_chile_pepper.png",
	},
	"strawberry": {
		"name": "Strawberry", "category": CAT_FRESH,
		"grow_time": 120.0, "water_need": 30.0,
		"yield": 5, "food": 16.0, "hp": 5.0, "oxygen": 0.4,
		"seed_cost": 14, "sell": 6,
		"sprite": "res://assets/plants/plant_strawberry.png",
		"icon": "res://assets/items/crop_strawberry.png",
	},
	"mizuna_mustard": {
		"name": "Mizuna mustard", "category": CAT_LEAFY,
		"grow_time": 90.0, "water_need": 25.0,
		"yield": 4, "food": 12.0, "hp": 3.0, "oxygen": 0.7,
		"seed_cost": 8, "sell": 4,
		"sprite": "res://assets/plants/plant_mizuna_mustard.png",
		"icon": "res://assets/items/crop_mizuna_mustard.png",
	},
	"red_romaine": {
		"name": "Red romaine", "category": CAT_LEAFY,
		"grow_time": 95.0, "water_need": 25.0,
		"yield": 4, "food": 13.0, "hp": 3.0, "oxygen": 0.7,
		"seed_cost": 8, "sell": 4,
		"sprite": "res://assets/plants/plant_red_romaine.png",
		"icon": "res://assets/items/crop_red_romaine.png",
	},
	"basil": {
		"name": "Basil", "category": CAT_HERB,
		"grow_time": 80.0, "water_need": 20.0,
		"yield": 3, "food": 8.0, "hp": 4.0, "oxygen": 0.5,
		"seed_cost": 6, "sell": 3,
		"sprite": "res://assets/plants/plant_basil.png",
		"icon": "res://assets/items/crop_basil.png",
	},
	"dill": {
		"name": "Dill", "category": CAT_HERB,
		"grow_time": 85.0, "water_need": 20.0,
		"yield": 3, "food": 9.0, "hp": 4.0, "oxygen": 0.5,
		"seed_cost": 6, "sell": 3,
		"sprite": "res://assets/plants/plant_dill.png",
		"icon": "res://assets/items/crop_dill.png",
	},
}

const SPROUT_TEXTURE := "res://assets/plants/plant_sprout.png"

# Textures used in the world / UI.
const TEX_BG := "res://assets/bg/greenhouse.png"
const TEX_COMPUTER := "res://assets/objects/obj_computer.png"
const TEX_OXYGEN := "res://assets/objects/obj_oxygen.png"
const TEX_FUEL := "res://assets/objects/obj_fuel.png"
const TEX_BAG := "res://assets/objects/obj_bag.png"


static func plant(id: String) -> Dictionary:
	return PLANTS.get(id, {})


static func plant_ids() -> Array:
	return PLANTS.keys()


static func seed_id(plant_id: String) -> String:
	return "seed_" + plant_id


static func crop_id(plant_id: String) -> String:
	return "crop_" + plant_id


static func seed_plant(item_id: String) -> String:
	if item_id.begins_with("seed_"):
		var id := item_id.substr(5)
		if PLANTS.has(id):
			return id
	return ""


static func crop_plant(item_id: String) -> String:
	if item_id.begins_with("crop_"):
		var id := item_id.substr(5)
		if PLANTS.has(id):
			return id
	return ""


static func item_name(item_id: String) -> String:
	var p := seed_plant(item_id)
	if p != "":
		return "Seed: " + str(PLANTS[p]["name"])
	p = crop_plant(item_id)
	if p != "":
		return str(PLANTS[p]["name"])
	return item_id


static func item_icon(item_id: String) -> Texture2D:
	var p := seed_plant(item_id)
	if p == "":
		p = crop_plant(item_id)
	if p == "":
		return null
	return load(str(PLANTS[p]["icon"])) as Texture2D


static func item_sell_price(item_id: String) -> int:
	var p := crop_plant(item_id)
	if p == "":
		return 0
	return int(PLANTS[p]["sell"])
