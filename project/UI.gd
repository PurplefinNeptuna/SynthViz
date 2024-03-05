# This file is part of SyntViz.
#
# SyntViz
# Copyright (c) 2024 Ilham AJ (purplefin)
#
# SyntViz is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SyntViz is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SyntViz. If not, see <https://www.gnu.org/licenses/>.

extends Control

@onready var recipeJson := FileAccess.open("res://clean_data.json", FileAccess.READ).get_as_text()
@onready var itemJson := FileAccess.open("res://items.json", FileAccess.READ).get_as_text()
var recipes: Dictionary = {}
var allMaterials: Dictionary = {}
var items: Dictionary = {}
var categories: Dictionary = {}
static var failItems: Array = ["Pollutant", "Broken Item", "Ashes of Failure", "Stinky Trash"]
static var failItemMatch: Array = [
	"Pollutant*", "Broken Item*", "Ashes of Failure*", "Stinky Trash*"
]
var failRecipes: Dictionary = {
	"Pollutant": [], "Broken Item": [], "Ashes of Failure": [], "Stinky Trash": []
}

static var plusCategoryMatch: String = "Add (*"


# Reads and parses JSON data for recipes and items.
func readJson() -> void:
	# Read item and repair keys
	var json := JSON.new()
	var error := json.parse(itemJson)
	if error != OK:
		print("Error parsing JSON")
	else:
		print("Item JSON parsed successfully")
		items = json.data as Dictionary

	for item in items.keys():
		var itemData := items.get(item) as Dictionary
		var cat_col: Array = []
		for key: String in itemData.keys():
			if key.match("Cat*"):
				var category := itemData[key] as String
				cat_col.append(category)

				# old way of adding category
				if categories.has(category):
					categories[category].append(item)
				else:
					categories[category] = [item]
		itemData["Categories"] = cat_col

	for cat_key in categories.keys():
		categories[cat_key].sort_custom(
		func(a, b):
			if items.has(a) and items.has(b):
				return items[a]["Level"].to_int() < items[b]["Level"].to_int()
			else:
				return a < b
		)

	# Read recipe and repair keys
	json = JSON.new()
	error = json.parse(recipeJson)
	if error != OK:
		print("Error parsing JSON")
	else:
		print("Recipe JSON parsed successfully")
		recipes = json.data as Dictionary

	for recipeKey: String in recipes.keys():
		if recipes.has(recipeKey) and items.has(recipeKey):
			var recipeData := recipes.get(recipeKey) as Dictionary
			var itemData := items.get(recipeKey) as Dictionary
			recipeData["Level"] = itemData["Level"]
			recipeData["Categories"] = itemData["Categories"]


# list all materials used in all recipes
func materialScan() -> void:
	for recipeKey: String in recipes.keys():
		var recipeData := recipes.get(recipeKey) as Dictionary
		var materialData := recipeData.get("Mats") as Array
		for mat: Dictionary in materialData:
			var matName := mat.get("Name") as String
			if matName in allMaterials.keys():
				allMaterials[matName] += 1
			else:
				allMaterials[matName] = 1
	print("Material scan completed")


# check if item or it's category is in allMaterial
func isCraftable(item: String) -> bool:
	if item in allMaterials.keys():
		return true
	for key: String in categories.keys():
		if item in categories[key] and key in allMaterials.keys():
			return true
	return false


func failCollection() -> void:
	var orderedRecipeKeys := recipes.keys()
	orderedRecipeKeys.sort_custom(
		func(a, b):
			if items.has(a) and items.has(b):
				return items[a]["Level"].to_int() < items[b]["Level"].to_int()
			else:
				return a < b
	)

	for recipeKey: String in orderedRecipeKeys:
		var recipeData := recipes.get(recipeKey) as Dictionary
		var effects := recipeData.get("Effects") as Array
		if effects == null:
			continue

		#print("Checking recipes %s" % recipeKey)
		#print("Effects: %s" % effects)
		var fail_items: Array = []
		for effect: Dictionary in effects:
			for subEffect: String in effect:
				for failIndex: int in failItems.size():
					if effect[subEffect].match(failItemMatch[failIndex]):
						#print("Matched %s" % failItems[failIndex])
						failRecipes[failItems[failIndex]].append(recipeKey)
						fail_items.append(
							failItems[failIndex].substr(0, failItems[failIndex].length() - 2)
						)
		recipeData["FailItems"] = fail_items
	print("Fail recipes collected")


func plusCategoryFinder() -> void:
	var regex := RegEx.new()
	regex.compile("(?<=\\()[\\w\\s\\d]*(?=\\))")

	var orderedRecipeKeys := recipes.keys()
	orderedRecipeKeys.sort_custom(
		func(a, b):
			if items.has(a) and items.has(b):
				return items[a]["Level"].to_int() < items[b]["Level"].to_int()
			else:
				return a < b
	)

	for recipeKey: String in orderedRecipeKeys:
		var recipeData := recipes.get(recipeKey) as Dictionary
		var effects := recipeData.get("Effects") as Array
		if effects == null:
			continue

		#print("Checking recipes %s" % recipeKey)
		#print("Effects: %s" % effects)
		var add_category: Array = []
		for effect: Dictionary in effects:
			for subEffect: String in effect:
				var subEffectStr := effect[subEffect] as String
				if subEffectStr.match(plusCategoryMatch):
					var category := regex.search(subEffectStr).get_string()
					category = "(" + category + ")"
					add_category.append(category)

		recipeData["AddCategory"] = add_category
	print("Plus category recipes collected")


@onready var startItem := get_node("%StartingSelect") as OptionButton
@onready var targetItem := get_node("%TargetSelect") as OptionButton
@onready var failureCheck := get_node("%FailCheck") as CheckBox
@onready var effectCheck := get_node("%EffectCheck") as CheckBox
@onready var startSearch := get_node("%Start") as Button
@onready var resultbox := get_node("%Item") as HBoxContainer
@onready var result_container := get_node("%ItemContainer") as VBoxContainer
#get_node("%Item2") as HBoxContainer,
#get_node("%Item3") as HBoxContainer,
#get_node("%Item4") as HBoxContainer,
#get_node("%Item5") as HBoxContainer,
#get_node("%Item6") as HBoxContainer,
#get_node("%Item7") as HBoxContainer,
#get_node("%Item8") as HBoxContainer
#]
@onready var lvSlider := get_node("%LvSlider") as Slider
@onready var lvLabel := get_node("%LvText") as Label
@onready var resultText := get_node("%ResultText") as Label
var recipe_book: AtelierRecipeBook = null
var resultbox_copy: HBoxContainer = null


func _ready():
	readJson()
	materialScan()
	failCollection()
	plusCategoryFinder()

	resultbox_copy = resultbox.duplicate()
	recipe_book = AtelierRecipeBook.new(recipes, items, failItems, failRecipes)

	var orderedItemKeys := items.keys()
	orderedItemKeys += categories.keys()
	#filter out items that are not craftable
	orderedItemKeys = orderedItemKeys.filter(isCraftable)
	orderedItemKeys.sort()
	for item: String in orderedItemKeys:
		startItem.add_item(item)

	var orderedRecipeKeys := recipes.keys()
	orderedRecipeKeys.sort()
	for recipe: String in orderedRecipeKeys:
		targetItem.add_item(recipe)

	startSearch.pressed.connect(onStartSearchPressed)
	lvSlider.value_changed.connect(onLvSliderChanged)
	targetItem.item_selected.connect(onTargetSelected)


func onTargetSelected(id: int):
	var target := targetItem.get_item_text(id)
	if recipes.has(target) and items.has(target):
		var level := items[target]["Level"] as String
		lvSlider.min_value = level.to_int()


func onLvSliderChanged(value: float):
	lvLabel.text = "Alchemy Level: %d" % value


func onStartSearchPressed():
	for child in result_container.get_children():
		result_container.remove_child(child)

	if startItem.get_selected_id() == -1 or targetItem.get_selected_id() == -1:
		return

	var start := startItem.get_item_text(startItem.get_selected_id())
	var target := targetItem.get_item_text(targetItem.get_selected_id())
	var depth := 5
	#var useFailure := failureCheck.is_pressed()
	#var useAddCategory := effectCheck.is_pressed()
	#var lv: int = round(lvSlider.value)

	var search_test := recipe_book.find_recipe_graph(start, target, depth)
	var total_path: int = 0
	var paths := []
	print("Search test:")
	for recipe: AtelierRecipe in search_test:
		var chain := recipe.extract_chains()
		print("\t%s has %d path(s)" % [recipe.material.name, chain.size()])
		total_path += chain.size()
		paths += chain
	print("Total path: %d" % total_path)
	paths.sort_custom(func(a, b): return a.size() < b.size())
	#var paths := findAllPaths(target, start, depth, useFailure, useAddCategory, lv)
	if paths.size() == 0:
		resultText.text = "No recipe found!"
		return

	resultText.text = "Found: %d" % paths.size()

	for path: int in paths.size():
		var pathbox := resultbox_copy.duplicate()
		var currentPath = paths[path]
		#print("Path %d: %s" % [path + 1, currentPath])
		for i: int in currentPath.size():
			var item = currentPath[i]
			var itemLabel := Label.new()
			itemLabel.text = item if i % 2 == 0 else "(Fail) ->" if item.match("Fail*") else "->"
			pathbox.add_child(itemLabel)
		result_container.add_child(pathbox)
