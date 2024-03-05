# This file contains code derived from Atelier Recipe Finder.
#
# Atelier Recipe Finder is licensed under the GNU General Public License v3.0 (GPL v3).
# See https://www.gnu.org/licenses/gpl-3.0.html for more details.
#
# Original authors: Sean Cusack (eruciform)
# Copyright 2020 Sean Cusack (eruciform)
#
# This file has been modified as part of the SyntViz project.
# SyntViz is licensed under the GNU General Public License v3.0 (GPL v3).
# Copyright 2024 Ilham AJ (purplefin)

class_name AtelierRecipeBook
extends Resource

var by_name := {}
var by_category := {}
var by_optional := {}
var by_required := {}
var by_antecedent := {}
var by_precedent := {}
var dead_end := {}
var already_found := {}


func _init(
	recipes: Dictionary, items: Dictionary, fail_items: Array, fail_recipes: Dictionary
) -> void:
	# Add all recipes
	for recipe in recipes.keys():
		var recipe_data := recipes[recipe] as Dictionary

		var recipe_required: Array = []
		for required in recipe_data["Mats"]:
			recipe_required.append(required["Name"])

		add_material(
			recipe,
			"Synth",
			recipe_data["Categories"] if "Categories" in recipe_data else [],
			recipe_data["AddCategory"] if "AddCategory" in recipe_data else [],
			recipe_required
		)

	# Add all items
	for item in items.keys():
		if recipes.has(item):  # skip items that are also recipes
			continue
		var item_data := items[item] as Dictionary

		add_material(item, "Materials", item_data["Categories"])

	# Add all failed items from recipes
	for fail_item in fail_items:
		if not by_name.has(fail_item):
			continue
		var fail_material: AtelierMaterial = by_name[fail_item] as AtelierMaterial

		var from_materials: Array[AtelierMaterial] = []
		for fitem in fail_recipes[fail_item]:
			if by_name.has(fitem):
				from_materials.append(by_name[fitem] as AtelierMaterial)

		fail_material.add_failures({"Fail": true}, from_materials)

		for fitem in fail_recipes[fail_item]:
			if not by_precedent.has(fitem):
				by_precedent[fitem] = {}
			by_precedent[fitem][fail_item] = fail_material
			if not by_antecedent.has(fail_item):
				by_antecedent[fail_item] = {}
			by_antecedent[fail_item][fitem] = fail_material


func add_material(
	name: String,
	type: String,
	category: Array,
	optional: Array = [],
	required: Array = [],
	p_from: Array = [],
	ftype: Array = []
) -> void:
	var material: AtelierMaterial = AtelierMaterial.new(
		name, type, category, optional, required, p_from, ftype
	)
	by_name[name] = material
	for cat in category:
		if not by_category.has(cat):
			by_category[cat] = {}
		by_category[cat][name] = material
	for opt in optional:
		if not by_optional.has(opt):
			by_optional[opt] = {}
		by_optional[opt][name] = material
	for req in required:
		if not by_required.has(req):
			by_required[req] = {}
		by_required[req][name] = material
	for from_recipe in material.from.keys():
		if not by_antecedent.has(name):
			by_antecedent[name] = {}
		by_antecedent[name][from_recipe] = material
		if not by_precedent.has(from_recipe):
			by_precedent[from_recipe] = {}
		by_precedent[from_recipe][name] = material


func clear_cache():
	dead_end = {}
	already_found = {}


func get_dead_end(label: String) -> int:
	return dead_end[label] if dead_end.has(label) else -1


func set_dead_end(label: String, depth: int):
	dead_end[label] = depth


func get_already_found(label: String) -> Array[AtelierRecipe]:
	var result: Array[AtelierRecipe] = []
	if already_found.has(label):
		result.assign(already_found[label])
	return result


func set_already_found(label: String, recipes: Array[AtelierRecipe]):
	already_found[label] = recipes.duplicate(true)


func get_by_name(search: String) -> AtelierMaterial:
	return by_name[search] if by_name.has(search) else null


func get_by_category(search: String) -> Array:
	var result: Array = []
	if by_category.has(search):
		result += by_category[search].keys()
	return result


func get_by_optional(search: String) -> Array:
	var result: Array = []
	if by_optional.has(search):
		result += by_optional[search].keys()
	return result


func get_by_required(search: String) -> Array:
	var result: Array = []
	if by_required.has(search):
		result += by_required[search].keys()
	return result


func get_by_antecedent(search: String) -> Array:
	var result: Array = []
	if by_antecedent.has(search):
		result += by_antecedent[search].keys()
	return result


func get_by_precedent(search: String) -> Array:
	var result: Array = []
	if by_precedent.has(search):
		result += by_precedent[search].keys()
	return result


func by_precedent_types(precedent: String, antecedent: String) -> Array:
	var result: Array = []
	if by_precedent.has(precedent) and by_precedent[precedent].has(antecedent):
		var found: AtelierMaterial = by_precedent[precedent][antecedent]
		result += found.from_types(precedent)
	return result


func many_category(search: Array) -> Array:
	var result: Array = []
	for category: String in search:
		if by_category.has(category):
			result += by_category[category].keys()
	return result


func many_optional(search: Array) -> Array:
	var result: Array = []
	for optional: String in search:
		if by_optional.has(optional):
			result += by_optional[optional].keys()
	return result


func many_required(search: Array) -> Array:
	var result: Array = []
	for required: String in search:
		if by_required.has(required):
			result += by_required[required].keys()
	return result


func many_antecedent(search: Array) -> Array:
	var result: Array = []
	for antecedent: String in search:
		if by_antecedent.has(antecedent):
			result += by_antecedent[antecedent].keys()
	return result


func many_precedent(search: Array) -> Array:
	var result: Array = []
	for precedent: String in search:
		if by_precedent.has(precedent):
			result += by_precedent[precedent].keys()
	return result


func all_name() -> Array:
	return by_name.keys()


func all_category() -> Array:
	return by_category.keys()


func all_optional() -> Array:
	return by_optional.keys()


func all_required() -> Array:
	return by_required.keys()


func all_antecedent() -> Array:
	return by_antecedent.keys()


func all_precedent() -> Array:
	return by_precedent.keys()


func check_already_found(name: String, depth: int) -> Array[AtelierRecipe]:
	var result := get_already_found(name)
	if result.size() > 0:
		var min_found := -1
		var max_found := -1
		for af in result:
			if min_found == -1 or af.depth < min_found:
				min_found = af.depth
			if max_found == -1 or af.depth > max_found:
				max_found = af.depth

		var already_min: Array[AtelierRecipe] = []
		for af: AtelierRecipe in result:
			if af.depth == min_found and min_found != -1:
				already_min.append(af)

		if min_found > depth and min_found != -1:
			for af: AtelierRecipe in already_min:
				af.re_depth(depth)
			return []
		if min_found < depth and min_found != -1:
			return []

		var non_blank: Array[AtelierRecipe] = []
		var seen: Array[AtelierRecipe] = []
		for af: AtelierRecipe in already_min:
			if af not in seen:
				seen.append(af)
				if af.into.size() > 0:
					non_blank.append(af)
		return non_blank
	return []


func find_recursive_graph(
	item: AtelierMaterial,
	finish: AtelierMaterial,
	cache: Dictionary,
	depth: int,
	max_dep: int = 999
) -> Array[AtelierRecipe]:
	if depth > max_dep:
		return []

	if item.name == finish.name or item.is_category(finish.name):
		return [AtelierRecipe.new(item, depth, [], [], true)]
	if item.is_optional(finish.name):
		return [AtelierRecipe.new(item.add(finish.name), depth, [], [], true)]

	if cache.has(item.name):
		return []

	var dead_end_pos := get_dead_end(item.label)
	if dead_end_pos != -1 and dead_end_pos <= depth:
		return []

	var already_found_item := check_already_found(item.label, depth)
	if already_found_item.size() > 0:
		return already_found_item

	# this should be duplicated, but how??
	var cache2 := cache.duplicate(true)
	cache2[item.name] = true

	var layer: Dictionary = cache.duplicate(true)
	layer[item.name] = true
	for category: String in item.category:
		layer[category] = true
	for optional: String in item.optional:
		layer[optional] = true

	var optional_recipes: Array[AtelierRecipe] = []
	var main_recipe := AtelierRecipe.new(item, depth)
	for next: String in get_by_required(item.name):
		var found_recipes := find_recursive_graph(
			get_by_name(next), finish, cache2, depth + 1, max_dep
		)
		if found_recipes.size() > 0:
			var seen: Array[AtelierRecipe] = []
			for af: AtelierRecipe in found_recipes:
				if af not in seen:
					seen.append(af)
					# I still dont know if this is correct
					AtelierSynthesis.new("Synth", main_recipe, af)

	for category: String in item.category:
		if not cache.has(category):
			var dead_end_cat := get_dead_end(category)
			if dead_end_cat != -1 and dead_end_cat <= depth:
				continue

			var all_found: Array[AtelierRecipe] = []
			var found := false

			for required: String in get_by_required(category):
				var next_cache := cache.duplicate(true)
				next_cache[category] = true
				var found_recipes := find_recursive_graph(
					get_by_name(required), finish, next_cache, depth + 1, max_dep
				)
				if found_recipes.size() > 0:
					found = true
					all_found += found_recipes

			if not found:
				set_dead_end(category, depth + 1)
				continue
			if all_found.size() == 0:
				continue
			var seen: Array[AtelierRecipe] = []
			for af: AtelierRecipe in all_found:
				if af not in seen:
					seen.append(af)
					# another one I dont know if it's correct
					AtelierSynthesis.new("Synth", main_recipe, af)

	for optional: String in item.optional:
		if not cache.has(optional):
			var dead_end_opt := get_dead_end(optional)
			if dead_end_opt != -1 and dead_end_opt <= depth:
				continue

			var all_found: Array[AtelierRecipe] = []
			var found := false

			for required: String in get_by_required(optional):
				var next_cache := cache.duplicate(true)
				next_cache[optional] = true
				var found_recipes := find_recursive_graph(
					get_by_name(required), finish, next_cache, depth + 1, max_dep
				)
				if found_recipes.size() > 0:
					found = true
					all_found += found_recipes

			if not found:
				set_dead_end(optional, depth + 1)
				continue
			if all_found.size() == 0:
				continue
			var add_recipe := AtelierRecipe.new(item.add(optional), depth)
			var seen: Array[AtelierRecipe] = []
			for af: AtelierRecipe in all_found:
				if af not in seen:
					seen.append(af)
					# another one I dont know if it's correct
					AtelierSynthesis.new("Synth", add_recipe, af)
			optional_recipes.append(add_recipe)

	for next: String in get_by_precedent(item.name):
		var found_recipes := find_recursive_graph(
			get_by_name(next), finish, cache, depth + 1, max_dep
		)
		if found_recipes.size() > 0:
			var seen: Array[AtelierRecipe] = []
			for af: AtelierRecipe in found_recipes:
				if af not in seen:
					seen.append(af)
					var from_types := by_precedent_types(item.name, next)
					for from_type: String in from_types:
						# another one I dont know if it's correct
						AtelierSynthesis.new(from_type, main_recipe, af)

	var recipes: Array[AtelierRecipe] = optional_recipes.duplicate(true)
	if main_recipe.into.size() > 0:
		recipes.append(main_recipe)

	var unique_recipes: Array[AtelierRecipe] = []
	for af: AtelierRecipe in recipes:
		if af not in unique_recipes:
			unique_recipes.append(af)

	if unique_recipes.size() > 0:
		set_already_found(item.label, unique_recipes)
	else:
		set_dead_end(item.label, depth)

	return unique_recipes


func find_recipe_graph(start, finish, max_dep: int = 999) -> Array[AtelierRecipe]:
	clear_cache()

	var start_item: AtelierMaterial = null
	if start is AtelierMaterial:
		start_item = start
	elif start is String:
		if by_name.has(start):
			start_item = by_name[start]
		elif by_category.has(start):
			start_item = AtelierMaterial.new(start, "Type", [start])

	var finish_item: AtelierMaterial = null
	if finish is AtelierMaterial:
		finish_item = finish
	elif finish is String:
		if by_name.has(finish):
			finish_item = by_name[finish]
		elif by_category.has(finish):
			finish_item = AtelierMaterial.new(finish, "Type", [finish])
		elif by_optional.has(finish):
			finish_item = AtelierMaterial.new(finish, "Type", [finish])

	if start_item == null or finish_item == null:
		return []

	var include: Array = get_by_category(start_item.name).duplicate(true)
	include += get_by_optional(start_item.name).duplicate(true)

	var unique: Array = []
	for inc: String in include:
		if not unique.has(inc):
			unique.append(inc)

	var start_categories: Array = []
	for cat: String in start_item.category.keys():
		start_categories.append(cat)

	var start_optionals: Array = []
	for opt: String in start_item.optional.keys():
		start_optionals.append(opt)

	var start_required: Array = [start_item.name]
	var start_precedent: Array = [start_item.name]

	if (
		many_required(start_categories).size() == 0
		and many_required(start_optionals).size() == 0
		and many_required(start_required).size() == 0
		and many_precedent(start_precedent).size() == 0
		and include.size() == 0
	):
		return []

	var result: Array[AtelierRecipe] = find_recursive_graph(start_item, finish_item, {}, 1, max_dep)
	for s: String in unique:
		var found := find_recursive_graph(get_by_name(s), finish_item, {}, 1, max_dep)
		if found.size() > 0:
			result += found
	return result
