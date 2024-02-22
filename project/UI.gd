# FILEPATH: /E:/Gamedev/Godot4Project/SynthViz/UI.gd
# Here's the plan:
# 1. Read recipes and items from JSON files
# 2. Create a dictionary of list of items per category
# 3. Add new recipes by failing
# 4. Read starting items and desired result item
# 5. Find all unique recipes paths without common subpaths
# 6. Display the paths in a tree view

# TODO:
# 1. Consider a recipe that add category to the item by awakening effects

extends Control

@onready var recipeJson := FileAccess.open("res://recipe.json", FileAccess.READ).get_as_text()
@onready var itemJson := FileAccess.open("res://items.json", FileAccess.READ).get_as_text()
var recipes: Dictionary = {}
var allMaterials: Dictionary = {}
var items: Dictionary = {}
var categories: Dictionary = {}
static var failItems: Array[String] = [
	"Pollutant", "Broken Item", "Ashes of Failure", "Stinky Trash"
]
static var failItemMatch: Array[String] = [
	"Pollutant*", "Broken Item*", "Ashes of Failure*", "Stinky Trash*"
]
var failRecipes: Dictionary = {
	"Pollutant": [], "Broken Item": [], "Ashes of Failure": [], "Stinky Trash": []
}

var plusCategoryRecipes: Dictionary = {}
static var plusCategoryMatch: String = "Add (*"
var plusCategories: Dictionary = {}


# Reads and parses JSON data for recipes and items.
func readJson() -> void:
	var json := JSON.new()
	var error := json.parse(recipeJson)
	if error != OK:
		print("Error parsing JSON")
	else:
		print("Recipe JSON parsed successfully")
		recipes = json.data as Dictionary

	json = JSON.new()
	error = json.parse(itemJson)
	if error != OK:
		print("Error parsing JSON")
	else:
		print("Item JSON parsed successfully")
		items = json.data as Dictionary

	for recipeKey: String in recipes.keys():
		var recipeData := recipes.get(recipeKey) as Dictionary
		var itemData := items.get(recipeKey) as Dictionary
		if itemData != null:
			recipeData["Level"] = itemData["Level"]
			recipes[recipeKey] = recipeData


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


func categorize() -> void:
	var orderedItemKeys := items.keys()
	orderedItemKeys.sort_custom(
		func(a, b): return items[a]["Level"].to_int() < items[b]["Level"].to_int()
	)

	for item in orderedItemKeys:
		var itemData := items.get(item) as Dictionary
		for key: String in itemData.keys():
			if key.match("Cat*"):
				var category := itemData[key] as String
				if categories.has(category):
					categories[category].append(item)
				else:
					categories[category] = [item]
	print("Categories dict created")


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
		func(a, b): return items[a]["Level"].to_int() < items[b]["Level"].to_int()
	)

	for recipeKey: String in orderedRecipeKeys:
		var recipeData := recipes.get(recipeKey) as Dictionary
		var effects := recipeData.get("Effects") as Array
		if effects == null:
			continue

		#print("Checking recipes %s" % recipeKey)
		#print("Effects: %s" % effects)
		for effect: Dictionary in effects:
			for subEffect: String in effect:
				for failIndex: int in failItems.size():
					if effect[subEffect].match(failItemMatch[failIndex]):
						#print("Matched %s" % failItems[failIndex])
						failRecipes[failItems[failIndex]].append(recipeKey)

	print("Fail recipes collected")


func plusCategoryFinder() -> void:
	var regex := RegEx.new()
	regex.compile("(?<=\\()\\w*(?=\\))")

	var orderedRecipeKeys := recipes.keys()
	orderedRecipeKeys.sort_custom(
		func(a, b): return items[a]["Level"].to_int() < items[b]["Level"].to_int()
	)

	for recipeKey: String in orderedRecipeKeys:
		var recipeData := recipes.get(recipeKey) as Dictionary
		var effects := recipeData.get("Effects") as Array
		if effects == null:
			continue

		#print("Checking recipes %s" % recipeKey)
		#print("Effects: %s" % effects)
		for effect: Dictionary in effects:
			for subEffect: String in effect:
				var subEffectStr := effect[subEffect] as String
				if subEffectStr.match(plusCategoryMatch):
					var category := regex.search(subEffectStr).get_string()
					var recipeName := recipeKey + " (Add " + category + ")"
					category = "(" + category + ")"
					#print("Matched %s" % recipeName)
					if plusCategories.has(category):
						plusCategories[category].append(recipeName)
					else:
						plusCategories[category] = [recipeName]
					plusCategoryRecipes[recipeName] = recipeKey

	print("Plus category recipes collected")


# Check item if it's not in recipe or it's level is less than maxLv)
func checkItem(item: String, maxLv: int) -> bool:
	if item not in items.keys():
		return false
	if item in recipes.keys():
		if items[item]["Level"].to_int() <= maxLv:
			return true
		else:
			return false
	else:
		return true


# Returns the materials needed to craft the given item.
func getMaterials(
	item: Array[String],
	target: String,
	result: Array[Array],
	memo: Dictionary,
	useFailure: bool,
	useAddCategory: bool,
	maxLv: int
) -> bool:
	var recipeData = null
	if item[0] in failItems:
		recipeData = recipes.get(item[1])
	else:
		recipeData = recipes.get(item[0])
	if recipeData == null:
		return false
	var materialData := recipeData.get("Mats") as Array
	var materials: Array[Array] = []
	for mat: Dictionary in materialData:
		var matName := mat.get("Name") as String
		if matName in items.keys():
			if matName in memo.keys():
				continue
			if matName in failItems and useFailure and matName != target:
				for failRecipe: String in failRecipes[matName]:
					if checkItem(failRecipe, maxLv) and failRecipe != target:
						materials.append([matName, failRecipe])
			elif checkItem(matName, maxLv):
				materials.append([matName, matName])
		else:
			if matName in categories.keys():
				for itemCat: String in categories[matName]:
					if itemCat in memo.keys():
						continue
					if itemCat in failItems and useFailure and itemCat != target:
						for failRecipe: String in failRecipes[itemCat]:
							if checkItem(failRecipe, maxLv) and failRecipe != target:
								materials.append([itemCat, failRecipe])
					elif checkItem(itemCat, maxLv):
						materials.append([itemCat, itemCat])
			if matName in plusCategories.keys() and useAddCategory:
				for plusRecipe: String in plusCategories[matName]:
					if (
						plusCategoryRecipes[plusRecipe] in memo.keys()
						or plusCategoryRecipes[plusRecipe] == target
					):
						continue
					elif checkItem(plusCategoryRecipes[plusRecipe], maxLv):
						materials.append([plusCategoryRecipes[plusRecipe], plusRecipe])

	result.append_array(materials)
	return true


func findAllPaths(
	start: String,
	target: String,
	depth_limit: int,
	useFailure: bool,
	useAddCategory: bool,
	maxLv: int
) -> Array[Array]:
	var visited: Array[String] = []
	var memo: Dictionary = {}
	var result := dfs(
		start, start, target, depth_limit, 0, visited, memo, useFailure, useAddCategory, maxLv
	)
	result.sort_custom(func(a, b): return a.size() < b.size())
	for path in result:
		path.reverse()
	return result


func dfs(
	start: String,
	source: String,
	target: String,
	depth_limit: int,
	current_depth: int,
	visited: Array[String],
	memo: Dictionary,
	useFailure: bool,
	useAddCategory: bool,
	maxLv: int
) -> Array[Array]:
	# debug print
	# print("DFS: %s -> %s, Memo: " % [start, target], memo)
	if start == target and current_depth > 0:
		return [[[start, source]]]
	if current_depth >= depth_limit:
		return []
	if visited.has(start):
		return []
	if memo.has(start):
		return memo[start]

	visited.append(start)
	var allPaths: Array[Array] = []

	var nextMats: Array[Array] = []
	if getMaterials([start, source], target, nextMats, memo, useFailure, useAddCategory, maxLv):
		for neighbor in nextMats:
			#print("Neighbor: ", neighbor)
			var subPath: Array = dfs(
				neighbor[0],
				neighbor[1],
				target,
				depth_limit,
				current_depth + 1,
				visited,
				memo,
				useFailure,
				useAddCategory,
				maxLv
			)
			for path: Array in subPath:
				var subRes: Array = [[start, source]] + path
				if subRes not in allPaths:
					allPaths.append(subRes)

	visited.erase(start)
	if allPaths.size() > 0:
		memo[start] = allPaths
	#memo[start] = allPaths
	return allPaths


@onready var startItem := get_node("%StartingSelect") as OptionButton
@onready var targetItem := get_node("%TargetSelect") as OptionButton
@onready var failureCheck := get_node("%FailCheck") as CheckBox
@onready var effectCheck := get_node("%EffectCheck") as CheckBox
@onready var startSearch := get_node("%Start") as Button
@onready var resultbox: Array[HBoxContainer] = [
	get_node("%Item1") as HBoxContainer,
	get_node("%Item2") as HBoxContainer,
	get_node("%Item3") as HBoxContainer,
	get_node("%Item4") as HBoxContainer,
	get_node("%Item5") as HBoxContainer,
	get_node("%Item6") as HBoxContainer,
	get_node("%Item7") as HBoxContainer,
	get_node("%Item8") as HBoxContainer
]
@onready var lvSlider := get_node("%LvSlider") as Slider
@onready var lvLabel := get_node("%LvText") as Label
@onready var resultText := get_node("%ResultText") as Label


func _ready():
	readJson()
	categorize()
	materialScan()
	failCollection()
	plusCategoryFinder()

	var orderedItemKeys := items.keys()
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
	if recipes.has(target):
		var level := items[target]["Level"] as String
		lvSlider.min_value = level.to_int()


func onLvSliderChanged(value: float):
	lvLabel.text = "Alchemy Level: %d" % value


func onStartSearchPressed():
	for box: HBoxContainer in resultbox:
		for child in box.get_children():
			box.remove_child(child)

	if startItem.get_selected_id() == -1 or targetItem.get_selected_id() == -1:
		return

	var start := startItem.get_item_text(startItem.get_selected_id())
	var target := targetItem.get_item_text(targetItem.get_selected_id())
	var depth := 5
	var useFailure := failureCheck.is_pressed()
	var useAddCategory := effectCheck.is_pressed()
	var lv: int = round(lvSlider.value)
	var paths := findAllPaths(target, start, depth, useFailure, useAddCategory, lv)
	print("Paths: %d" % paths.size())
	if paths.size() == 0:
		resultText.text = "No recipe found!"
		return
	else:
		resultText.text = "Found: %d" % paths.size()

	for path: int in min(paths.size(), 8):
		var currentPath := paths[path]
		for subPath: int in currentPath.size():
			#add new label node to the resultbox
			var label := Label.new()
			if currentPath[subPath][0] == currentPath[subPath][1]:
				label.text = currentPath[subPath][0]
			else:
				if failItems.has(currentPath[subPath][0]):
					label.text = currentPath[subPath][1] + " (Fail)"
				else:
					label.text = currentPath[subPath][1]
			resultbox[path].add_child(label)
			if subPath < currentPath.size() - 1:
				var arrow := Label.new()
				arrow.text = " -> "
				resultbox[path].add_child(arrow)
