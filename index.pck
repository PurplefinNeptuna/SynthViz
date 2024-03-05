GDPC                                                                                          P   res://.godot/exported/133200997/export-c3b50503a0477dc727cd659891fdb3c7-UI.scn  p�     �      eA.(#B��
/c�@�    ,   res://.godot/global_script_class_cache.cfg  ��     _      �6(�g̠F>�Z�}��    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex      �      �Yz=������������       res://.godot/uid_cache.bin  �     7       ����d�t�A��;$�'       res://UI.gd ��     �#      �؆ԃg�#(Vc�       res://UI.tscn.remap P�     _       }`�O�e8���bt�       res://Unused.gd `�     �      �҇���d�)��p��j%    ,   res://atelier_resources/AtelierMaterial.gd          �	      �(��%_:�/�Q�U�j�    (   res://atelier_resources/AtelierRecipe.gd�	      =      �^7`l�Ce�i��C�    ,   res://atelier_resources/AtelierRecipeBook.gd      4      E7�&������6��Z    ,   res://atelier_resources/AtelierSynthesis.gd  F      �      ��珛a�0�&i�#4�       res://clean_data.json   �I      ,�     2eܡ��\s��g�G\�d       res://icon.svg        �      C��=U���^Qu��U3       res://icon.svg.import         �       ��Cx�k�$��9�       res://items.json�     ��     u�p�H�gAߴW��M�       res://project.binary     T      Pvjc(�Z�n�!*@�    # This file contains code derived from Atelier Recipe Finder.
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

class_name AtelierMaterial
extends Resource

var name: String
var type: String
var label: String
var category: Dictionary
var optional: Dictionary
var required: Dictionary
var from: Dictionary


func _init(
	p_name: String,
	p_type: String,
	cat: Array,
	opt: Array = [],
	req: Array = [],
	p_from: Array = [],
	ftype: Array = [],
) -> void:
	name = p_name
	type = p_type
	label = p_name
	category = {}
	for c: String in cat:
		category[c] = true
	optional = {}
	for o: String in opt:
		optional[o] = true
	required = {}
	for r: String in req:
		required[r] = true
	from = {}
	for i: int in range(p_from.size()):
		var f_type: String
		var from_item: String
		if i < ftype.size():
			f_type = ftype[i]
		else:
			f_type = "Convert"
		from_item = p_from[i]
		if from_item not in from.keys():
			from[from_item] = {}
		from[from_item][f_type] = true


func clone() -> AtelierMaterial:
	var cloned = AtelierMaterial.new(
		name, type, category.keys(), optional.keys(), required.keys(), from.keys(), []
	)
	cloned.label = label
	for f in from.keys():
		for ftype in from[f].keys():
			cloned.from[f][ftype] = true
	return cloned


func replace_from(cat: String, types: Dictionary, with: Array[AtelierMaterial]) -> void:
	if not is_from(cat):
		return
	from.erase(cat)
	for w: AtelierMaterial in with:
		from[w.name] = types


func add_failures(types: Dictionary, with: Array[AtelierMaterial]) -> void:
	for w: AtelierMaterial in with:
		if w.name not in from.keys():
			from[w.name] = types


func add(additional: String) -> AtelierMaterial:
	var new = clone()
	new.label = name + " " + additional
	return new


func is_category(cat: String) -> bool:
	return cat in category.keys()


func is_optional(opt: String) -> bool:
	return opt in optional.keys()


func is_required(req: String) -> bool:
	return req in required.keys()


func is_from(p_from: String) -> bool:
	return p_from in from.keys()


func from_types(from_name: String) -> Array:
	if from_name not in from.keys():
		return []
	return from[from_name].keys()
              # This file contains code derived from Atelier Recipe Finder.
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

class_name AtelierRecipe
extends Resource

var material: AtelierMaterial
var from: Array[AtelierSynthesis]
var into: Array[AtelierSynthesis]
var depth: int
var found: bool


func _init(
	p_material: AtelierMaterial,
	p_depth: int = 0,
	p_from: Array[AtelierSynthesis] = [],
	p_into: Array[AtelierSynthesis] = [],
	p_found: bool = false
):
	material = p_material
	depth = p_depth
	from = p_from
	into = p_into
	found = p_found


func set_depth(p_depth: int) -> void:
	depth = p_depth


func set_found(p_found: bool) -> void:
	found = p_found


func re_depth(p_depth: int):
	for synth: AtelierSynthesis in into:
		synth.into.re_depth(p_depth + 1)
	set_depth(p_depth)
	del_into()


func add_into(new_into: AtelierSynthesis):
	into.append(new_into)


func add_from(new_from: AtelierSynthesis):
	from.append(new_from)


func del_into():
	into = []


func del_from():
	from = []


func extract_chains() -> Array:
	var chain_list := {}
	var current_chain: Array = []
	_extract_chains(chain_list, current_chain, 1)
	var chains := []
	for chain in chain_list.values():
		chains.append(chain)

	chains.sort_custom(func(a, b) -> bool: return a.size() < b.size())
	return chains


func _extract_chains(chain_list: Dictionary, current_chain: Array, p_depth: int) -> void:
	current_chain.append(material.label)
	if into.size() > 0:
		for synth: AtelierSynthesis in into:
			if synth.into.found or synth.into.depth == self.depth + 1:
				synth._extract_chains(chain_list, current_chain, p_depth + 1)
	elif self.found:
		var chain_key = ",".join(current_chain)
		chain_list[chain_key] = current_chain.duplicate(true)
	current_chain.pop_back()
   # This file contains code derived from Atelier Recipe Finder.
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
        # This file contains code derived from Atelier Recipe Finder.
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

class_name AtelierSynthesis
extends Resource

var type: String
var from: AtelierRecipe
var into: AtelierRecipe


func _init(p_type: String, p_from: AtelierRecipe, p_into: AtelierRecipe) -> void:
	type = p_type
	from = p_from
	into = p_into
	p_from.add_into(self)
	p_into.add_from(self)


func _extract_chains(chain_list: Dictionary, current_chain: Array, depth: int) -> void:
	current_chain.append(type)
	into._extract_chains(chain_list, current_chain, depth)
	current_chain.pop_back()
        {
	"Abyss Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Absolute Truth: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Pendelook",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Hidden Spell Page",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Bugs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Poisons)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Adventurer's Clothing": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ATK +3: 3",
				"Effect 3": "ATK +5: 6",
				"Effect 4": "ATK +8: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "ACC +8%: -3",
				"Effect 2": "ACC +5%: -1",
				"Effect 3": "None: 0",
				"Effect 4": "DEF +3: 3",
				"Effect 5": "DEF +5: 5",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Muffcot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Armor Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Aerven Staff of Light": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Shining Destiny Light S: 7",
				"Effect 3": "Shining Destiny Light M: 12",
				"Effect 4": "Shining Destiny Light L: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Enhance Skills +15%: -10",
				"Effect 2": "Enhance Skills +12%: -7",
				"Effect 3": "Enhance Skills +8%: -3",
				"Effect 4": "Enhance Items +8%: 0",
				"Effect 5": "Enhance Items +12%: 5",
				"Effect 6": "Enhance Items +15%: 10",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Creation Tree's Twig",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Alchemy Activator": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "ITEM_EFF_AROUSAL_EQUIP_UNIQUE_1: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Clear Grass",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Puniballs)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Alchemy Candy": {
		"Effects": [
			{
				"Effect 1": "Ice Resistance Up+: -8",
				"Effect 2": "Ice Resistance Up: -1",
				"Effect 3": "Pollutant: 0",
				"Effect 4": "Fire Resistance Up: 1",
				"Effect 5": "Fire Resistance Up+: 7",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Earth Resistance Up+: -7",
				"Effect 2": "Earth Resistance Up: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Lightning Resistance Up: 1",
				"Effect 5": "Lightning Resistance Up+: 7",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Puni Fluid",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Honey",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Medicinal)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "3"
			}
		],
		"Uses": "2"
	},
	"Alchemy Cane": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Dexterous Technique S: 2",
				"Effect 3": "Dexterous Technique M: 4",
				"Effect 4": "Dexterous Technique L: 6",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Weaken Items +8%: -4",
				"Effect 2": "Weaken Items +5%: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Enhance Items +5%: 2",
				"Effect 5": "Enhance Items +8%: 4",
				"Effect 6": "Enhance Items +12%: 6",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Alchemy Coal": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Ore): 10",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Eiche",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Fuel Dirt",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Alchemy Coat": {
		"Effects": [
			{
				"Effect 1": "Mastery (Medicines): -10",
				"Effect 2": "Mastery (Food): -5",
				"Effect 3": "None: 0",
				"Effect 4": "Mastery (Bombs): 5",
				"Effect 5": "Mastery (Magic Tools): 10",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Weaken Items +12%: -10",
				"Effect 2": "Weaken Items +8%: -7",
				"Effect 3": "None: 0",
				"Effect 4": "Add Magic Resistance: 6",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Himmel Linen",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rainbow Supplement",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Armor Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Medicines)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Alchemy Yeast": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Puniballs): 15",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "4",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Dizzy Cap Spore",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Mushrooms)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Medicinal)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Ancient Memory": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Ancestral Recall S: 4",
				"Effect 3": "Ancestral Recall M: 7",
				"Effect 4": "Ancestral Recall L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "ACC +12%: -5",
				"Effect 2": "ACC +8%: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Enhance Stun +5%: 4",
				"Effect 5": "Enhance Stun +8%: 6",
				"Effect 6": "Enhance Stun +12%: 8",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Star Piece",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Angel Charm": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Angel's Protection S: 0",
				"Effect 3": "Angel's Protection M: 13",
				"Effect 4": "Angel's Protection L: 16",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Pendelook",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Blessed Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Apprentice Alchemist's Staff": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Training Staff S: 2",
				"Effect 3": "Training Staff M: 4",
				"Effect 4": "Training Staff L: 6",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "DEF +5: -3",
				"Effect 2": "DEF +3: -1",
				"Effect 3": "None: 0",
				"Effect 4": "ATK +3: 1",
				"Effect 5": "ATK +5: 3",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Arland Crystal": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Metals): 14",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Komet",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Artisan's Key": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Opens Locks: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Original Gem",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Barrel": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Empty Barrel: 0",
				"Effect 3": "Water Barrel: 13",
				"Effect 4": "Liquor Barrel: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Critical+ M: -6",
				"Effect 2": "Critical+ S: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Restricts Movement S: 5",
				"Effect 5": "Restricts Movement M: 7",
				"Effect 6": "Restricts Movement L: 9",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Eiche",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "4"
	},
	"Barrel Bomb": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Gunpowder Barrel: 0",
				"Effect 3": "Exploding Barrel: 9",
				"Effect 4": "Blastpowder Barrel: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Critical+ L: -4",
				"Effect 2": "Critical+ M: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Engulfing Flames S: 2",
				"Effect 5": "Engulfing Flames M: 4",
				"Effect 6": "Engulfing Flames L: 6",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Bomb",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Pure Oil",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "1"
			}
		],
		"Uses": "3"
	},
	"Battle Scarf": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Zealous Soul S: 10",
				"Effect 3": "Zealous Soul M: 14",
				"Effect 4": "Zealous Soul L: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Beast Fur",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Magic Paint",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Cloth)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Beast Armor": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Stun Resistance +20: 7",
				"Effect 3": "Stun Resistance +30: 10",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Evasion +5%: -4",
				"Effect 2": "Evasion +3%: -2",
				"Effect 3": "None: 0",
				"Effect 4": "SPD +3: 2",
				"Effect 5": "SPD +5: 4",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Beast Fur",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Armor Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Black Mist Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Abyssal Aura: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Black Runestone",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Poisons)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Black Steel": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "First Blade S: 2",
				"Effect 3": "First Blade M: 4",
				"Effect 4": "First Blade L: 6",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "ATK +5: -5",
				"Effect 2": "ATK +3: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Max HP +5: 2",
				"Effect 5": "Max HP +10: 5",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Blinding Radiance": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Scintillating Insight S: 3",
				"Effect 3": "Scintillating Insight M: 6",
				"Effect 4": "Scintillating Insight L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "ACC +16%: -4",
				"Effect 2": "ACC +12%: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Evasion +5%: 5",
				"Effect 5": "Evasion +8%: 8",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Blitzstrom": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Thunder King's Ambition S: 5",
				"Effect 3": "Thunder King's Ambition M: 8",
				"Effect 4": "Thunder King's Ambition L: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "DEF +12: -10",
				"Effect 2": "DEF +8: -8",
				"Effect 3": "None: 0",
				"Effect 4": "Critical Rate Up +8%: 1",
				"Effect 5": "Critical Rate Up +12%: 5",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sylph Breath",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Blue Beam Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Water Spirit Glow: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Crystal Piece",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Bomb": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Fire DMG XS: 0",
				"Effect 3": "Fire DMG S: 6",
				"Effect 4": "Fire DMG M: 10",
				"Effect 5": "Fire DMG L: 16",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Undying Flame L: -5",
				"Effect 2": "Undying Flame S: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Defenses Down S: 3",
				"Effect 5": "Defenses Down M: 6",
				"Effect 6": "Defenses Down L: 8",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Phlogiston",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Gunpowder)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "4"
	},
	"Bomb Curry": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "Mild Spice: 0",
				"Effect 3": "Spicy: 7",
				"Effect 4": "Extra Spicy: 10",
				"Effect 5": "Flaming Hot: 15",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "MP Healing M: -4",
				"Effect 2": "MP Healing S: -1",
				"Effect 3": "None: 0",
				"Effect 4": "HP Healing XS: 4",
				"Effect 5": "HP Healing S: 6",
				"Effect 6": "HP Healing M: 8",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Nostalgic Spice",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Spices)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Meat)",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Vegetables)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Brave Sigil": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Mark of the Hero S: 10",
				"Effect 3": "Mark of the Hero M: 13",
				"Effect 4": "Mark of the Hero L: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Archfiend Claw",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Wicked Fang",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Bugs)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Bug Catcher Net": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Catches Bugs: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Chainweb",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Threads)",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Lumber)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Captain's Long Sword": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Guardian Stance S: 2",
				"Effect 3": "Guardian Stance M: 4",
				"Effect 4": "Guardian Stance L: 6",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "DEF +12: -4",
				"Effect 2": "DEF +8: -1",
				"Effect 3": "None: 0",
				"Effect 4": "ATK +8: 4",
				"Effect 5": "ATK +12: 7",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Chain of Karma": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Bind Fate S: 0",
				"Effect 3": "Bind Fate M: 9",
				"Effect 4": "Bind Fate L: 13",
				"Effect 5": "Bind Fate XL: 17",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Physical Resistance Down+: -8",
				"Effect 2": "Physical Resistance Down: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Magical Resistance Down: 6",
				"Effect 5": "Magical Resistance Down+: 10",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Rota Fortunae",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "2"
	},
	"Clavaal's Halo": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Lightblade Locus S: 7",
				"Effect 3": "Lightblade Locus M: 11",
				"Effect 4": "Lightblade Locus L: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Max MP +25: -10",
				"Effect 2": "Max MP +20: -8",
				"Effect 3": "Max MP +15: -5",
				"Effect 4": "None: 0",
				"Effect 5": "Evasion +10%: 1",
				"Effect 6": "Evasion +12%: 5",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Gold Puniball",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Elixirs)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Cloth": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: DEF +1: 6",
				"Effect 4": "Equipment Creation: DEF +3: 8",
				"Effect 5": "Equipment Creation: DEF +5: 10",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "(Threads)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Supplements)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Craft": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Physical DMG XS: 0",
				"Effect 3": "Physical DMG S: 4",
				"Effect 4": "Physical DMG M: 6",
				"Effect 5": "Physical DMG L: 8",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Drowsiness M: -4",
				"Effect 2": "Drowsiness S: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Strength Down S: 3",
				"Effect 5": "Strength Down M: 5",
				"Effect 6": "Strength Down L: 7",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Nuse",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Gunpowder)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Ore)",
				"Qty": "1"
			}
		],
		"Uses": "6"
	},
	"Crossment Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Force of Conflict: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Phlogiston",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Snow Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Crystal Ball": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Ore): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "2",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Crystal Piece",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Danish": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "HP Part. Recovery XS: 0",
				"Effect 3": "HP Part. Recovery S: 10",
				"Effect 4": "HP Part. Recovery M: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Cures Seal: -6",
				"Effect 2": "Cures Burns: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Cures Blindness: 2",
				"Effect 5": "Cures Sleep: 4",
				"Effect 6": "Cures Slowness: 6",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Flour",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Alchemy Yeast",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Dark Water": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "Inflicts Impurity L: 0",
				"Effect 3": "Inflicts Despair S: 4",
				"Effect 4": "Inflicts Despair M: 8",
				"Effect 5": "Inflicts Despair L: 11",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Invitation to the Hell L: -4",
				"Effect 2": "Invitation to the Hell S: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Cell Erosion S: 3",
				"Effect 5": "Cell Erosion M: 5",
				"Effect 6": "Cell Erosion L: 7",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Pure Poison",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Night Lady",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Bugs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mushrooms)",
				"Qty": "1"
			}
		],
		"Uses": "3"
	},
	"Death Tarot": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Arcana of the Reaper: 18",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Convert Damage 10%: -8",
				"Effect 2": "Convert Damage 7%: -4",
				"Effect 3": "Convert Damage 5%: -2",
				"Effect 4": "None: 0",
				"Effect 5": "Critical Power Up +12%: 4",
				"Effect 6": "Critical Power Up +15%: 6",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Hidden Spell Page",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Poisons)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Delicious Fishing Bait": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Food): 8",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Hard Potato",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Bugs)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Vegetables)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Demon Canon": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Magic DMG XS: 0",
				"Effect 3": "Magic DMG S: 7",
				"Effect 4": "Magic DMG M: 11",
				"Effect 5": "Magic DMG L: 15",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Consume HP S: -5",
				"Effect 2": "Consume HP M: -3",
				"Effect 3": "Consume HP L: -1",
				"Effect 4": "Consume MP L: 0",
				"Effect 5": "Consume MP M: 5",
				"Effect 6": "Consume MP S: 8",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Crystal Piece",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "Alchemy Coal",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Magic Tool)",
				"Qty": "1"
			}
		],
		"Uses": "3"
	},
	"Direct Illusion": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Silent Blade S: 3",
				"Effect 3": "Silent Blade M: 6",
				"Effect 4": "Silent Blade L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "SPD +15: -5",
				"Effect 2": "SPD +12: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Critical Rate Up +8%: 7",
				"Effect 5": "Critical Rate Up +12%: 10",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Black Runestone",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Distilled Water": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Medicinal): 11",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Clean Water",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "Cotton Flower",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Divine Auric Plate Armor": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Knightly Vow S: 9",
				"Effect 3": "Knightly Vow M: 13",
				"Effect 4": "Knightly Vow L: 18",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Ailments Resistance +15%: -5",
				"Effect 2": "Ailments Resistance +10%: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Avoid KO 15%: 5",
				"Effect 5": "Avoid KO 20%: 7",
				"Effect 6": "Avoid KO 25%: 10",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Himmel Linen",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rainbow Supplement",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Armor Materials)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Divinity's Edge": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Meteoric Speed S: 5",
				"Effect 3": "Meteoric Speed M: 8",
				"Effect 4": "Meteoric Speed L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "DEF +5: -5",
				"Effect 2": "DEF +3: -2",
				"Effect 3": "None: 0",
				"Effect 4": "SPD +3: 5",
				"Effect 5": "SPD +5: 8",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Drachen Elixir": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "Physical Reinforcement S: 0",
				"Effect 3": "Physical Reinforcement M: 6",
				"Effect 4": "Physical Reinforcement L: 10",
				"Effect 5": "Physical Reinforcement XL: 14",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Blocks Strong Strikes L: -5",
				"Effect 2": "Blocks Strong Strikes S: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Level Up S: 6",
				"Effect 5": "Level Up M: 8",
				"Effect 6": "Level Up L: 10",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Medicine Base",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Mandrake Elixir",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Dragon)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Elixirs)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Dragon Gun Gargantua": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Dragon King's Awakening S: 10",
				"Effect 3": "Dragon King's Awakening M: 15",
				"Effect 4": "Dragon King's Awakening L: 20",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Enhance Skills +15%: -10",
				"Effect 2": "Enhance Skills +12%: -7",
				"Effect 3": "Enhance Skills +8%: -3",
				"Effect 4": "Max HP +15: 0",
				"Effect 5": "Max HP +20: 5",
				"Effect 6": "Max HP +25: 10",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Dragon Piece",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Dragon Plate Armor": {
		"Effects": [
			{
				"Effect 1": "Earth Dragon Scale: -6",
				"Effect 2": "None: 0",
				"Effect 3": "Fire Dragon Scale: 4",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Lightning Dragon Scale: -5",
				"Effect 2": "None: 0",
				"Effect 3": "Ice Dragon Scale: 9",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Scale Cloth",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Dragon Scale",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Armor Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Dragoon Coat": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Dragon's Vitality S: 3",
				"Effect 3": "Dragon's Vitality M: 6",
				"Effect 4": "Dragon's Vitality L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Enhance Skills +12%: -6",
				"Effect 2": "Enhance Skills +8%: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Damage Cut 5%: 2",
				"Effect 5": "Damage Cut 8%: 5",
				"Effect 6": "Damage Cut 10%: 8",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Scale Cloth",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Dragon Horn",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Armor Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Dragoon Lore": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Dragon's Roar S: 9",
				"Effect 3": "Dragon's Roar M: 13",
				"Effect 4": "Dragon's Roar L: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Critical Rate Up +12%: -8",
				"Effect 2": "Critical Rate Up +8%: -6",
				"Effect 3": "Critical Rate Up +5%: -3",
				"Effect 4": "None: 0",
				"Effect 5": "Enhance Stun +12%: 4",
				"Effect 6": "Enhance Stun +15%: 8",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Dragon Horn",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Dream Anchor Indigonia": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Dreamchaser Bonds S: 5",
				"Effect 3": "Dreamchaser Bonds M: 10",
				"Effect 4": "Dreamchaser Bonds L: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Enhance Skills +15%: -10",
				"Effect 2": "Enhance Skills +12%: -5",
				"Effect 3": "None: 0",
				"Effect 4": "DEF +12: 5",
				"Effect 5": "DEF +15: 10",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Gunpowder)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Dream Vision": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Distorts Vision: 0",
				"Effect 3": "Distorts Perception: 10",
				"Effect 4": "Distorts World: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Sonic Move L: -10",
				"Effect 2": "Sonic Move S: -5",
				"Effect 3": "None: 0",
				"Effect 4": "Action Cut S: 4",
				"Effect 5": "Action Cut M: 7",
				"Effect 6": "Action Cut L: 10",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "2"
	},
	"Elemental Breath": {
		"Effects": [
			{
				"Effect 1": "Earth Spirit Chaser: -5",
				"Effect 2": "None: 0",
				"Effect 3": "Fire Spirit Chaser: 6",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Lightning Spirit Chaser: -5",
				"Effect 2": "None: 0",
				"Effect 3": "Ice Spirit Chaser: 5",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Elemental Fragment",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Elemental Canon": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "All-Element DMG S: 0",
				"Effect 3": "All-Element DMG M: 10",
				"Effect 4": "All-Element DMG L: 16",
				"Effect 5": "All Energy Unlocked: 17",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Negate Buffs: -4",
				"Effect 2": "None: 0",
				"Effect 3": "Inflicts Impurity XS: 5",
				"Effect 4": "Inflicts Impurity S: 8",
				"Effect 5": "Inflicts Impurity M: 12",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Demon Canon",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Jar of Four Spirits",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "3"
			}
		],
		"Uses": "2"
	},
	"Elixir": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "HP Recovery M: 0",
				"Effect 3": "HP Recovery L: 13",
				"Effect 4": "HP Recovery XL: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Removes Ailments: -6",
				"Effect 2": "None: 0",
				"Effect 3": "Cleanses Impurity S: 4",
				"Effect 4": "Cleanses Impurity M: 7",
				"Effect 5": "Cleanses Impurity L: 10",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sage Herb",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Nectar",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Water)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Elixirs)",
				"Qty": "2"
			}
		],
		"Uses": "2"
	},
	"Ether Ink": {
		"Effects": [
			{
				"Effect 1": "Ice Resistance Down+: -7",
				"Effect 2": "Ice Resistance Down: -1",
				"Effect 3": "Pollutant: 0",
				"Effect 4": "Fire Resistance Down: 1",
				"Effect 5": "Fire Resistance Down+: 7",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Earth Resistance Down+: -7",
				"Effect 2": "Earth Resistance Down: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Lightning Resistance Down: 1",
				"Effect 5": "Lightning Resistance Down+: 7",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Magic Paint",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Jar of Four Spirits",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "2"
	},
	"Exorcism Incense": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Fuel): 16",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Medicine Base",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Hay",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Poisons)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Fairy Sack": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Portable Whirlwind: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Balloon Fruit",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Cloth)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Threads)",
				"Qty": "2"
			}
		],
		"Uses": "5"
	},
	"Falling Star Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Glittering Rainbow Stars: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Jar of Four Spirits",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rainbow Fragment",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Fate Talisman": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Great Learner S: 0",
				"Effect 3": "Great Learner M: 9",
				"Effect 4": "Great Learner L: 12",
				"Effect 5": "Great Learner XL: 15",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Hidden Spell Page",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Magic Paint",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "3"
			}
		],
		"Uses": "1"
	},
	"Feather Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "White Feather Dance: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Audra's Tail",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rabbit Fur",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Fessellmeer": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Ocean Pressure S: 4",
				"Effect 3": "Ocean Pressure M: 6",
				"Effect 4": "Ocean Pressure L: 8",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Enhance Skills +8%: -6",
				"Effect 2": "Enhance Skills +5%: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Enhance Stun +5%: 2",
				"Effect 5": "Enhance Stun +8%: 5",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Crystal Piece",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Seafood)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Fire Spirit Crystal Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Red Wall: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Bomb",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Fuel Dirt",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Ore)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Fire Spirit Ring": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Add Fire Resistance S: 0",
				"Effect 3": "Add Fire Resistance L: 8",
				"Effect 4": "Fire Spirit Clan: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Magic Paint",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Fish Sauce": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Meat): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "2",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Small Sardine",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Butterfly Fish",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Fishing Rod": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Catches Fish: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Delicious Fishing Bait",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Green Bamboo",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rabbit Fur",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Threads)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Flash Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Roaring Lightning: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Quake Crystal",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Komet",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Clay)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Flawless Principle": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Strength of Purity S: 6",
				"Effect 3": "Strength of Purity M: 9",
				"Effect 4": "Strength of Purity L: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Max MP +20: -4",
				"Effect 2": "Max MP +15: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Critical Power Up +8%: 7",
				"Effect 5": "Critical Power Up +12%: 10",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Undying Wind",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Flour": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Gunpowder): 8",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "4",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Wheat",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "Scrap Paper",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Flower Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Scattered Petals: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Balloon Fruit",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Clear Grass",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Plants)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vegetables)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Fortune's Light": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Beginner's Luck S: 6",
				"Effect 3": "Beginner's Luck M: 9",
				"Effect 4": "Beginner's Luck L: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Convert Damage 5%: -7",
				"Effect 2": "Convert Damage 3%: -4",
				"Effect 3": "None: 0",
				"Effect 4": "ACC +5%: 4",
				"Effect 5": "ACC +8%: 7",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Gaia Earth Ring": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Add Earth Resistance S: 0",
				"Effect 3": "Add Earth Resistance L: 10",
				"Effect 4": "Gaia Earth Clan: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Magic Paint",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Clay)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Ghostly Long Sword": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Hurricane Blade S: 5",
				"Effect 3": "Hurricane Blade M: 8",
				"Effect 4": "Hurricane Blade L: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "ACC +20%: -9",
				"Effect 2": "ACC +16%: -5",
				"Effect 3": "ACC +12%: -1",
				"Effect 4": "None: 0",
				"Effect 5": "Critical Power Up +12%: 6",
				"Effect 6": "Critical Power Up +15%: 10",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Bunt Resin",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Glacier Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Gleaming Hoarfrost: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Distilled Water",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Globe": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Earth DMG S: 0",
				"Effect 3": "Earth DMG M: 6",
				"Effect 4": "Earth DMG L: 10",
				"Effect 5": "Earth DMG XL: 14",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Unbalancing Impact M: -6",
				"Effect 2": "Unbalancing Impact S: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Ignores Luck S: 4",
				"Effect 5": "Ignores Luck M: 7",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Globe Sphere",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "4"
	},
	"Gnardi Ring": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Power Rune S: 0",
				"Effect 3": "Power Rune M: 6",
				"Effect 4": "Power Rune L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Mountain Pearl",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Gemstones)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"God Speed Boots": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Lightens the Body S: 0",
				"Effect 3": "Lightens the Body M: 12",
				"Effect 4": "Lightens the Body L: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sylph Breath",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sacred Bird Wing",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Cloth)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Golden Lion Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Pride of the Lion King: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Beast Fur",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Meat)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Clay)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Grand Impact": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Excavator S: 3",
				"Effect 3": "Excavator M: 6",
				"Effect 4": "Excavator L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "DEF +12: -4",
				"Effect 2": "DEF +8: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Add Stun +5: 4",
				"Effect 5": "Add Stun +10: 6",
				"Effect 6": "Add Stun +15: 8",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Tanned Leather",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Clay)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Grand Lightning Bomb": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Lightning DMG L: 0",
				"Effect 3": "Lightning DMG XL: 10",
				"Effect 4": "Bolt Damage: 14",
				"Effect 5": "Thunder God's Judgment: 17",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Induce Split M: -4",
				"Effect 2": "Induce Split S: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Convergent Thunderbolt: 8",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Lightning Bomb",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sylph Breath",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Gemstones)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Green Glow Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Wind Spirit Glow: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Mountain Pearl",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Plants)",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Guardian Liquor": {
		"Effects": [
			{
				"Effect 1": "",
				"Effect 2": "",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": ""
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Guardian Slice",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sea Puddle",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Distilled Water",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Fuel)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Hailsfyre": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Poseidon's Blessing S: 4",
				"Effect 3": "Poseidon's Blessing M: 8",
				"Effect 4": "Poseidon's Blessing L: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Enhance Items +12%: -4",
				"Effect 2": "Enhance Items +8%: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Critical Power Up +8%: 5",
				"Effect 5": "Critical Power Up +12%: 8",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Wispstone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Handmade Basket": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Holds a Lot: 0",
				"Effect 3": "Holds an Awful Lot: 15",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Hay",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Threads)",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Harvest Gloves": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Gather a Lot S: 0",
				"Effect 3": "Gather a Lot M: 10",
				"Effect 4": "Gather a Lot L: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Muffcot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Tanned Leather",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Threads)",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Hay": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Fuel): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "4",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "(Plants)",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Healing Bell": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "HP Recovery XS: 0",
				"Effect 3": "HP Recovery S: 6",
				"Effect 4": "HP Recovery M: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Cleanses Impurity L: -5",
				"Effect 2": "Cleanses Impurity M: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Recovery Up XS: 3",
				"Effect 5": "Recovery Up S: 5",
				"Effect 6": "Recovery Up M: 7",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Elixirs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Healing Incense": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "KO Recovery XS: 0",
				"Effect 3": "KO Recovery S: 10",
				"Effect 4": "KO Recovery M: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "MP Healing M: -7",
				"Effect 2": "MP Healing S: -4",
				"Effect 3": "None: 0",
				"Effect 4": "HP Healing M: 6",
				"Effect 5": "HP Healing L: 9",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Undying Wind",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Pure Oil",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Plants)",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Clay)",
				"Qty": "2"
			}
		],
		"Uses": "2"
	},
	"Healing Salve": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "HP Recovery XS: 0",
				"Effect 3": "HP Recovery S: 6",
				"Effect 4": "HP Recovery M: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "HP Healing S: -4",
				"Effect 2": "HP Healing XS: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Recovery Up XS: 2",
				"Effect 5": "Recovery Up S: 4",
				"Effect 6": "Recovery Up M: 6",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Magic Grass",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Medicinal)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			}
		],
		"Uses": "4"
	},
	"Heart Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Shining Heart: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Quake Crystal",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Heart of Wisdom": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Philosopher's Knowledge S: 8",
				"Effect 3": "Philosopher's Knowledge M: 11",
				"Effect 4": "Philosopher's Knowledge L: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "SPD +15: -9",
				"Effect 2": "SPD +12: -5",
				"Effect 3": "None: 0",
				"Effect 4": "ATK +12: 3",
				"Effect 5": "ATK +15: 7",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sage Herb",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Herculean Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Youthful Zeal: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Gold Puniball",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Himmel Linen": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: DEF & SPD +5: 8",
				"Effect 4": "Equipment Creation: DEF & SPD +7: 12",
				"Effect 5": "Equipment Creation: DEF & SPD +10: 17",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Azure Wing",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Glittery Water",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Himmelstein": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "Physical DMG XL: 0",
				"Effect 3": "Biological Decay: 12",
				"Effect 4": "Molecular Decay: 16",
				"Effect 5": "Quantum Decay: 17",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Cell Erosion M: -6",
				"Effect 2": "Cell Erosion S: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Inflicts Impurity M: 6",
				"Effect 5": "Physical Resistance Down: 10",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Meteor",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Pure Poison",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Supplements)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "2"
			}
		],
		"Uses": "2"
	},
	"Honey": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Gemstones): 6",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Beehive",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Hyper Particle": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "ITEM_EFF_AROUSAL_EQUIP_UNIQUE_4: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Thunder Water",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Ore)",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Puni Drop": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Water): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Honey",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Eraezyko Charm": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Elixirs): 14",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Pendelook",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Zettel",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Magic Paint",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Medicinal)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Sands of Time": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Magic Tool): 10",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Red Sand",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "Forgotten Bone",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Elemental Fragment",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Ice Cascade Bomb": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Elixirs): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Distilled Water",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Black Ore",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Bombs)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Heavenly Parasol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Supplements): 15",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sylph Breath",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Ice Bomb",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "3"
			}
		],
		"Uses": "1"
	},
	"Night Vision Goggles": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Threads): 11",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Crystal Ball",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"True Dragon Hourglass": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Dragon): 10",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sands of Time",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Crystal Ball",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Magic Paint",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Time Brooch": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Metals): 13",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sands of Time",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Black Ore",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Star Piece",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Special Goddess Statue": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Mystery): 10",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Divine Iron Piece",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Clay)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Plain Pie": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Vegetables): 9",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Flour",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Honey",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Frixell Pie": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Mushrooms): 10",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Flour",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Honey",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Rustic Gloves": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Gunpowder): 14",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Cloth)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Fool's Stone": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Clay): 16",
				"Effect 4": "Add (Metals): 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Broken Item",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "Stinky Trash",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Appetite Away Pill": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Spices): 15",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "(Bugs)",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Poisons)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Ultimate Lululu Curry": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "HP Part. Recovery L: 0",
				"Effect 3": "HP Part. Recovery XL: 14",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Lucky Interrupt L: -10",
				"Effect 2": "Lucky Interrupt M: -6",
				"Effect 3": "None: 0",
				"Effect 4": "Fast Interrupt S: 4",
				"Effect 5": "Fast Interrupt M: 7",
				"Effect 6": "Fast Interrupt L: 10",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Guardian Curry",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Dunkel Curry",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Philosopher's Curry",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "3"
			}
		],
		"Uses": "2"
	},
	"ITEM_MIX_RESERVE_MATERIAL_001": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: ATK +10: 6",
				"Effect 4": "Equipment Creation: ATK & DEF +10: 10",
				"Effect 5": "ITEM_EFF_CREATE_RESERVE_01: 14",
				"Effect 6": "ITEM_EFF_CREATE_RESERVE_03: 17",
				"L Elem": "Ice",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Attribute: Lightning +5: -6",
				"Effect 2": "Attribute: Lightning +3: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Attribute: Fire +3: 5",
				"Effect 5": "Attribute: Fire +5: 10",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Philosopher's Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Elixirs)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"ITEM_MIX_RESERVE_MATERIAL_002": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: DEF +10: 11",
				"Effect 4": "Equipment Creation: DEF & SPD +10: 13",
				"Effect 5": "ITEM_EFF_CREATE_RESERVE_02: 15",
				"Effect 6": "ITEM_EFF_CREATE_RESERVE_03: 17",
				"L Elem": "Fire",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Attribute: Earth +5: -8",
				"Effect 2": "Attribute: Earth +3: -4",
				"Effect 3": "None: 0",
				"Effect 4": "Attribute: Ice +3: 6",
				"Effect 5": "Attribute: Ice +5: 10",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Himmel Linen",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Philosopher's Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"ITEM_MIX_RESERVE_MATERIAL_003": {
		"Effects": [
			{
				"Effect 1": "Attribute: Lightning +5: -10",
				"Effect 2": "Attribute: Lightning +4: -5",
				"Effect 3": "None: 0",
				"Effect 4": "Attribute: Fire +4: 5",
				"Effect 5": "Attribute: Fire +5: 10",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Attribute: Earth +5: -10",
				"Effect 2": "Attribute: Earth +4: -5",
				"Effect 3": "None: 0",
				"Effect 4": "Attribute: Ice +4: 5",
				"Effect 5": "Attribute: Ice +5: 10",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Philosopher's Stone",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Jar of Four Spirits",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"ITEM_MIX_RESERVE_MATERIAL_004": {
		"Effects": [
			{
				"Effect 1": "Attribute: Earth +5: -10",
				"Effect 2": "Attribute: Earth +4: -5",
				"Effect 3": "None: 0",
				"Effect 4": "Attribute: Ice +4: 5",
				"Effect 5": "Attribute: Ice +5: 10",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Attribute: Lightning +5: -10",
				"Effect 2": "Attribute: Lightning +4: -5",
				"Effect 3": "None: 0",
				"Effect 4": "Attribute: Fire +4: 5",
				"Effect 5": "Attribute: Fire +5: 10",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Fool's Stone",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Jar of Four Spirits",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Appetite Boost Pill": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Elixirs): 13",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "(Seafood)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Meat)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Person Finder": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Lumber): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Living Rope",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Fatal Buster": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Bombs): 17",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Tanned Leather",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Guardian Curry": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Spices): 14",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Nostalgic Curry",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Guardian",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Mysterious Spice",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "3"
			}
		],
		"Uses": "1"
	},
	"Dunkel Curry": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Plants): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Nostalgic Curry",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Dunkelheit",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Mysterious Spice",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "3"
			}
		],
		"Uses": "1"
	},
	"Philosopher's Curry": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Supplements): 13",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Nostalgic Curry",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Philosopher's Stone",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Mysterious Spice",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "3"
			}
		],
		"Uses": "1"
	},
	"Bunt Resin": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Magic Tool): 9",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Fish's Whiskers",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Medicinal)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Clay)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Authorized Key": {
		"Effects": [
			{
				"Effect 1": "",
				"Effect 2": "",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": ""
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Personal Key",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Burning Ore",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Slice of Night",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Memory Core": {
		"Effects": [
			{
				"Effect 1": "",
				"Effect 2": "",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": ""
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Windslice Body Feather",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sands of Time",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Azure Wing",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Restore Core": {
		"Effects": [
			{
				"Effect 1": "",
				"Effect 2": "",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": ""
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Windslice Wing Feather",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sands of Time",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Dragon Piece",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Steering Lever": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Metals): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Mystical Ankh",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Rota Fortunae",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "4"
			}
		],
		"Uses": "1"
	},
	"Alchemy Textbook": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ITEM_EFF_EQUIP_WEP_DLC_01_1_1: 8",
				"Effect 3": "ITEM_EFF_EQUIP_WEP_DLC_01_1_2: 10",
				"Effect 4": "ITEM_EFF_EQUIP_WEP_DLC_01_1_3: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "ATK +5: -4",
				"Effect 2": "ATK +3: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Max MP +5: 3",
				"Effect 5": "Max MP +10: 6",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Elemental Fragment",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Minstrel Book": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ITEM_EFF_EQUIP_WEP_DLC_01_2_1: 8",
				"Effect 3": "ITEM_EFF_EQUIP_WEP_DLC_01_2_2: 10",
				"Effect 4": "ITEM_EFF_EQUIP_WEP_DLC_01_2_3: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Evasion +5%: -5",
				"Effect 2": "Evasion +3%: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Block Poison: 3",
				"Effect 5": "Block Sleep: 5",
				"Effect 6": "Block Slowness: 8",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Hidden Spell Page",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Arch Anatomis": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ITEM_EFF_EQUIP_WEP_DLC_01_3_1: 7",
				"Effect 3": "ITEM_EFF_EQUIP_WEP_DLC_01_3_2: 9",
				"Effect 4": "ITEM_EFF_EQUIP_WEP_DLC_01_3_3: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Ailments Resistance +25%: -4",
				"Effect 2": "Ailments Resistance +20%: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Block Seal: 4",
				"Effect 5": "Block Curse: 6",
				"Effect 6": "Resist One-Hit KO: 8",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Destroyed Grimoire",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Stellar Score": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ITEM_EFF_EQUIP_WEP_DLC_01_4_1: 7",
				"Effect 3": "ITEM_EFF_EQUIP_WEP_DLC_01_4_2: 10",
				"Effect 4": "ITEM_EFF_EQUIP_WEP_DLC_01_4_3: 13",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Evasion +10%: -8",
				"Effect 2": "Evasion +8%: -4",
				"Effect 3": "None: 0",
				"Effect 4": "ATK +8: 2",
				"Effect 5": "ATK +12: 4",
				"Effect 6": "ATK +15: 6",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Zettel",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Mythical Tome Atracalta": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ITEM_EFF_EQUIP_WEP_DLC_01_5_1: 10",
				"Effect 3": "ITEM_EFF_EQUIP_WEP_DLC_01_5_2: 14",
				"Effect 4": "ITEM_EFF_EQUIP_WEP_DLC_01_5_3: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Enhance Items +15%: -8",
				"Effect 2": "Enhance Items +12%: -4",
				"Effect 3": "None: 0",
				"Effect 4": "Weaken Items +8%: 4",
				"Effect 5": "Weaken Items +12%: 7",
				"Effect 6": "Weaken Items +15%: 10",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Philosopher's Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Elixirs)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Alchemy Girl's Sword": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ITEM_EFF_EQUIP_WEP_DLC_02_1_1: 3",
				"Effect 3": "ITEM_EFF_EQUIP_WEP_DLC_02_1_2: 6",
				"Effect 4": "ITEM_EFF_EQUIP_WEP_DLC_02_1_3: 9",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Critical Rate Up +5%: -4",
				"Effect 2": "Critical Rate Up +3%: -2",
				"Effect 3": "None: 0",
				"Effect 4": "ATK +3: 3",
				"Effect 5": "ATK +5: 5",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Cosmos Code": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ITEM_EFF_EQUIP_WEP_DLC_02_2_1: 9",
				"Effect 3": "ITEM_EFF_EQUIP_WEP_DLC_02_2_2: 6",
				"Effect 4": "ITEM_EFF_EQUIP_WEP_DLC_02_2_3: 9",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Critical Rate Up +5%: -5",
				"Effect 2": "Critical Rate Up +3%: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Critical Power Up +3%: 4",
				"Effect 5": "Critical Power Up +5%: 7",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Star Piece",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Princess Saver": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ITEM_EFF_EQUIP_WEP_DLC_02_3_1: 8",
				"Effect 3": "ITEM_EFF_EQUIP_WEP_DLC_02_3_2: 10",
				"Effect 4": "ITEM_EFF_EQUIP_WEP_DLC_02_3_3: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "SPD +12: -6",
				"Effect 2": "SPD +8: -3",
				"Effect 3": "None: 0",
				"Effect 4": "ATK +8: 4",
				"Effect 5": "ATK +12: 8",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Pendelook",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Lunatomic Edge": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ITEM_EFF_EQUIP_WEP_DLC_02_4_1: 7",
				"Effect 3": "ITEM_EFF_EQUIP_WEP_DLC_02_4_2: 10",
				"Effect 4": "ITEM_EFF_EQUIP_WEP_DLC_02_4_3: 13",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Weaken Items +15%: -5",
				"Effect 2": "Weaken Items +12%: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Critical Power Up +8%: 3",
				"Effect 5": "Critical Power Up +12%: 5",
				"Effect 6": "Critical Power Up +15%: 8",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Komet",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Holy Sword Weiselende": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "ITEM_EFF_EQUIP_WEP_DLC_02_5_1: 10",
				"Effect 3": "ITEM_EFF_EQUIP_WEP_DLC_02_5_2: 14",
				"Effect 4": "ITEM_EFF_EQUIP_WEP_DLC_02_5_3: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "DEF +15: -7",
				"Effect 2": "DEF +12: -4",
				"Effect 3": "None: 0",
				"Effect 4": "Ailments Resistance +20%: 3",
				"Effect 5": "Ailments Resistance +25%: 6",
				"Effect 6": "Ailments Resistance +30%: 10",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Philosopher's Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Ice Bomb": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Ice DMG XS: 0",
				"Effect 3": "Ice DMG S: 8",
				"Effect 4": "Ice DMG M: 11",
				"Effect 5": "Ice DMG L: 15",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Icebind L: -5",
				"Effect 2": "Icebind S: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Speed Down S: 2",
				"Effect 5": "Speed Down M: 5",
				"Effect 6": "Speed Down L: 8",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Snow Stone",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "4"
	},
	"Ingot": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: ATK +1: 3",
				"Effect 4": "Equipment Creation: ATK +3: 5",
				"Effect 5": "Equipment Creation: ATK +5: 7",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Fest",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Ore)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Jar of Four Spirits": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Vapors): 10",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "2",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Elemental Fragment",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rainbow Fragment",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Judgement Tarot": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Arcana of Judgment S: 5",
				"Effect 3": "Arcana of Judgment M: 8",
				"Effect 4": "Arcana of Judgment L: 11",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Critical Power Up +8%: -6",
				"Effect 2": "Critical Power Up +5%: -4",
				"Effect 3": "None: 0",
				"Effect 4": "Enhance Stun +5%: 5",
				"Effect 5": "Enhance Stun +8%: 8",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Zettel",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"King of Thunder Ring": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Add Lightning Resistance S: 0",
				"Effect 3": "Add Lightning Resistance L: 7",
				"Effect 4": "Thunder King Clan: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Magic Paint",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Komet": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Elixirs): 14",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "2",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Isle Amber",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Blessed Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Light Bug Catcher Net": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Catches Any Bug: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Bug Catcher Net",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sylph Breath",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Threads)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Lightning Bomb": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Lightning DMG XS: 0",
				"Effect 3": "Lightning DMG S: 7",
				"Effect 4": "Lightning DMG M: 10",
				"Effect 5": "Lightning DMG L: 14",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Fast Interrupt M: -5",
				"Effect 2": "Fast Interrupt S: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Intuition Down S: 2",
				"Effect 5": "Intuition Down M: 4",
				"Effect 6": "Intuition Down L: 6",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Quake Crystal",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Vapors)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "2"
			}
		],
		"Uses": "4"
	},
	"Living Rope": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Bugs): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Hay",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Threads)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Locket of Friendship": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Power of Fellowship S: 0",
				"Effect 3": "Power of Fellowship M: 9",
				"Effect 4": "Power of Fellowship L: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Komet",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Lululu Curry": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "HP Part. Recovery M: 0",
				"Effect 3": "HP Part. Recovery L: 9",
				"Effect 4": "HP Part. Recovery XL: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "MP Healing L: -5",
				"Effect 2": "MP Healing M: -3",
				"Effect 3": "None: 0",
				"Effect 4": "HP Healing XS: 6",
				"Effect 5": "HP Healing S: 8",
				"Effect 6": "HP Healing M: 10",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Elixir",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Meat)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Vegetables)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mushrooms)",
				"Qty": "2"
			}
		],
		"Uses": "2"
	},
	"Luminous Lance": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Lance of Light: 0",
				"Effect 3": "Bursting Light Lance: 11",
				"Effect 4": "Piercing Light Lance: 15",
				"Effect 5": "Stormlight Lance: 16",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Light Steal L: -4",
				"Effect 2": "Light Steal S: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Level Down XS: 5",
				"Effect 5": "Level Down S: 7",
				"Effect 6": "Level Down M: 10",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Magic Tool)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Machina Gear Mechanism": {
		"Effects": [
			{
				"Effect 1": "",
				"Effect 2": "",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": ""
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Windslice Tail Feather",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rota Fortunae",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Magic Paint": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Fuel): 7",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "4",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Crystal Piece",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Tar Fruit",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Magic Sword": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Magic Sword Strike: 0",
				"Effect 3": "Magic Sword Flash Attack: 10",
				"Effect 4": "Magic Sword Blink Edge: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Absorb MP M: -5",
				"Effect 2": "Absorb MP S: -3",
				"Effect 3": "Absorb MP XS: -1",
				"Effect 4": "None: 0",
				"Effect 5": "Induce Split S: 6",
				"Effect 6": "Induce Split M: 10",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Magma Launcher": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Heat Enhance S: 10",
				"Effect 3": "Heat Enhance M: 14",
				"Effect 4": "Heat Enhance L: 18",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Critical Power Up +8%: -5",
				"Effect 2": "Critical Power Up +5%: -3",
				"Effect 3": "Critical Power Up +3%: -1",
				"Effect 4": "None: 0",
				"Effect 5": "SPD +8: 2",
				"Effect 6": "SPD +12: 4",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Magma Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Medicine Base": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Gunpowder): 13",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "4",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Med Tree Root",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Supplements)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Medicinal)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Poisons)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Meister Tarte": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "HP Part. Recovery XS: 0",
				"Effect 3": "HP Part. Recovery S: 7",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "HP Healing M: -4",
				"Effect 2": "HP Healing S: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Cures Poison: 2",
				"Effect 5": "Cures Burns: 4",
				"Effect 6": "Cures Curse: 6",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Flour",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Honey",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "2"
			}
		],
		"Uses": "4"
	},
	"Mercurius's Eye": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "All-Seeing Eye S: 0",
				"Effect 3": "All-Seeing Eye M: 8",
				"Effect 4": "All-Seeing Eye L: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Crystal Piece",
				"Qty": "4"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Meteor": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Drops Puni: 0",
				"Effect 3": "Drops Stars: 11",
				"Effect 4": "Drops Stars: 14",
				"Effect 5": "Drops ???: 17",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Giant Strike: -4",
				"Effect 2": "Heavy Strike: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Induce Split M: 6",
				"Effect 5": "Induce Split L: 10",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Star Piece",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Crystal Ball",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Migraine Syrup": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "MP Recovery XS: 0",
				"Effect 3": "MP Recovery S: 9",
				"Effect 4": "MP Recovery M: 13",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "MP Healing S: -4",
				"Effect 2": "MP Healing XS: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Recovery Up XS: 2",
				"Effect 5": "Recovery Up S: 4",
				"Effect 6": "Recovery Up M: 6",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Clear Grass",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Med Tree Root",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "4"
	},
	"Mind Water": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "MP Recovery S: 0",
				"Effect 3": "MP Recovery M: 10",
				"Effect 4": "MP Recovery L: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "MP Healing M: -8",
				"Effect 2": "MP Healing S: -4",
				"Effect 3": "None: 0",
				"Effect 4": "Recovery Up S: 3",
				"Effect 5": "Recovery Up M: 6",
				"Effect 6": "Recovery Up L: 9",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Water Tree Fruit",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Supplements)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Medicinal)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Bugs)",
				"Qty": "1"
			}
		],
		"Uses": "3"
	},
	"Mining Bomb": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Destructive Gathering: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Bomb",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Fuel Dirt",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Gunpowder)",
				"Qty": "2"
			}
		],
		"Uses": "5"
	},
	"Mont Blanc": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "HP Part. Recovery S: 0",
				"Effect 3": "HP Part. Recovery M: 11",
				"Effect 4": "HP Part. Recovery L: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Removes Ailments: -5",
				"Effect 2": "Cures Slowness: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Cures Burns: 4",
				"Effect 5": "Cures Seal: 7",
				"Effect 6": "Cures Curse: 9",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Uni",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "Chariot Milk",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Food)",
				"Qty": "1"
			}
		],
		"Uses": "3"
	},
	"Moonbeam Veil": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Lunar Ward S: 6",
				"Effect 3": "Lunar Ward M: 11",
				"Effect 4": "Lunar Ward L: 16",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Weaken Items +15%: -10",
				"Effect 2": "Weaken Items +12%: -7",
				"Effect 3": "None: 0",
				"Effect 4": "Critical Rate Up +8%: 4",
				"Effect 5": "Critical Rate Up +12%: 7",
				"Effect 6": "Critical Rate Up +15%: 10",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Spirit Tears",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Muffcot": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: DEF +3: 9",
				"Effect 4": "Equipment Creation: DEF +5: 12",
				"Effect 5": "Equipment Creation: DEF +7: 15",
				"Effect 6": "Equipment Creation: DEF +10: 17",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Cotton Flower",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Rabbit Fur",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Music Note Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Melody of the World: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Rota Fortunae",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Crystal Ball",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Clay)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Mysterious Spice": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Gunpowder): 14",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "4",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Nostalgic Spice",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Spices)",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Mushrooms)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Seafood)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Mystical Ankh": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Faint Recovery M: 0",
				"Effect 3": "Faint Recovery L: 10",
				"Effect 4": "Faint Recovery XL: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Banishes Disease Demons: -7",
				"Effect 2": "Cures Slowness: -4",
				"Effect 3": "None: 0",
				"Effect 4": "Cures Curse: 6",
				"Effect 5": "Cleanses Evil: 9",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Original Gem",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Crystal Piece",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Ore)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Mythical Ring": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Curse of Conversion S: 0",
				"Effect 3": "Curse of Conversion L: 14",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Blessed Stone",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Jar of Four Spirits",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Elixirs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"N/A": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "10,000 Explosions: 0",
				"Effect 3": "100 Million Explosions: 8",
				"Effect 4": "1 Trillion Explosions: 12",
				"Effect 5": "Infinite Explosions: 15",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Mega Pressure: -5",
				"Effect 2": "Destroyer's Intimidation: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Level Down S: 7",
				"Effect 5": "Level Down M: 10",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tera Bomb",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rocket Ice Bomb",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Grand Lightning Bomb",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Bombs)",
				"Qty": "3"
			}
		],
		"Uses": "2"
	},
	"N/A Alpha": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "HP Recovery L: 0",
				"Effect 3": "HP Recovery XL: 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Consume HP XL: -7",
				"Effect 2": "Consume HP & MP XL: 0",
				"Effect 3": "Consume MP XL: 7",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "N/A",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Nectar",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Elixirs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"N/A Beta": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "10,000 Explosions: 0",
				"Effect 3": "100 Million Explosions: 10",
				"Effect 4": "1 Trillion Explosions: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Light of Purity: -5",
				"Effect 2": "Removes Ailments: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Negate Buffs: 5",
				"Effect 5": "Light of Purity: 8",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "N/A",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Witch Salve",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Poisons)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Bugs)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"N/A Gamma": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Indiscriminate Blast S: 0",
				"Effect 3": "Indiscriminate Blast M: 9",
				"Effect 4": "Indiscriminate Blast L: 13",
				"Effect 5": "Indiscriminate Blast XL: 16",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Ice Resistance Down+: -9",
				"Effect 2": "Ice Resistance Down: -4",
				"Effect 3": "None: 0",
				"Effect 4": "Fire Resistance Down: 5",
				"Effect 5": "Fire Resistance Down+: 10",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "N/A",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rainbow Supplement",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Bombs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"N/A Omega": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "1 Trillion Explosions: 0",
				"Effect 3": "Infinite Explosions: 12",
				"Effect 4": "Planet-Shattering Explosion: 16",
				"Effect 5": "Antimatter Annihilation: 17",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Giga Pressure: -5",
				"Effect 2": "Avatar of Destruction: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Level Down M: 4",
				"Effect 5": "Level Down L: 6",
				"Effect 6": "Light of Purity: 8",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "N/A Alpha",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "N/A Beta",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "N/A Gamma",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "3"
			}
		],
		"Uses": "1"
	},
	"Nectar": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "KO Recovery S: 0",
				"Effect 3": "KO Recovery M: 6",
				"Effect 4": "KO Recovery L: 10",
				"Effect 5": "KO Recovery XL: 14",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Recycle L: -5",
				"Effect 2": "Recycle S: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Lucky Interrupt S: 6",
				"Effect 5": "Lucky Interrupt M: 8",
				"Effect 6": "Lucky Interrupt L: 10",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Pendelook",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Forgotten Bone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Medicinal)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			}
		],
		"Uses": "2"
	},
	"Nightshade": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Shadowlurk S: 3",
				"Effect 3": "Shadowlurk M: 6",
				"Effect 4": "Shadowlurk L: 9",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "SPD +5: -4",
				"Effect 2": "SPD +3: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Evasion +3%: 3",
				"Effect 5": "Evasion +5%: 5",
				"Effect 6": "Evasion +8%: 7",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Nylonfeather",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Armor Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Poisons)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Nobel Buster": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Acute Perception S: 5",
				"Effect 3": "Acute Perception M: 8",
				"Effect 4": "Acute Perception L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Max MP +10: -3",
				"Effect 2": "Max MP +5: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Max HP +5: 1",
				"Effect 5": "Max HP +10: 3",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Nostalgic Curry": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "HP Part. Recovery XS: 0",
				"Effect 3": "HP Part. Recovery S: 8",
				"Effect 4": "HP Part. Recovery M: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Nostalgic Spice",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Seafood)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Meat)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vegetables)",
				"Qty": "1"
			}
		],
		"Uses": "3"
	},
	"Nylonfeather": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: DEF & SPD +1: 8",
				"Effect 4": "Equipment Creation: DEF & SPD +3: 11",
				"Effect 5": "Equipment Creation: DEF & SPD +5: 15",
				"Effect 6": "Equipment Creation: DEF & SPD +7: 17",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Audra's Tail",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Tar Fruit",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Olgenrium": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: ATK & DEF +5: 11",
				"Effect 4": "Equipment Creation: ATK & DEF +7: 14",
				"Effect 5": "Equipment Creation: ATK & DEF +10: 17",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Divine Iron Piece",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Eternity Flame",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Ore)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Omega Craft": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Physical DMG L: 0",
				"Effect 3": "Physical DMG XL: 10",
				"Effect 4": "High Impact Damage: 13",
				"Effect 5": "Demon Strike: 16",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Unbalancing Impact L: -4",
				"Effect 2": "Unbalancing Impact M: -2",
				"Effect 3": "Unbalancing Impact S: 0",
				"Effect 4": "Drowsiness S: 3",
				"Effect 5": "Drowsiness M: 6",
				"Effect 6": "Drowsiness L: 9",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Craft",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Gunpowder)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Fuel)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Plants)",
				"Qty": "2"
			}
		],
		"Uses": "4"
	},
	"Personal Key": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Gemstones): 13",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Crystal Ball",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Wispstone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Magic Tool)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Phantom Ice Ring": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Add Ice Resistance S: 0",
				"Effect 3": "Add Ice Resistance L: 7",
				"Effect 4": "Ice Phantom Clan: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Magic Paint",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Philosopher's Necklace": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Alchemy Master S: 0",
				"Effect 3": "Alchemy Master M: 10",
				"Effect 4": "Alchemy Master L: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Philosopher's Stone",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Supplements)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Philosopher's Pie": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Mushrooms): 13",
				"Effect 4": "Add (Seafood): 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Flour",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Philosopher's Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Vegetables)",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Spices)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Philosopher's Stone": {
		"Effects": [
			{
				"Effect 1": "Attribute: Lightning +5: -10",
				"Effect 2": "Attribute: Lightning +3: -1",
				"Effect 3": "Broken Item: 0",
				"Effect 4": "Attribute: Fire +3: 1",
				"Effect 5": "Attribute: Fire +5: 10",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Attribute: Earth +5: -10",
				"Effect 2": "Attribute: Earth +3: -1",
				"Effect 3": "Broken Item: 0",
				"Effect 4": "Attribute: Ice +3: 1",
				"Effect 5": "Attribute: Ice +5: 10",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ashes of Failure",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Pollutant",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Original Gem",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Elixirs)",
				"Qty": "3"
			}
		],
		"Uses": "1"
	},
	"Pickaxe": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Destructive Gathering Infinity: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Polish Powder": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Supplements): 5",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "5",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Fest",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Ore)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Professional Fishing Rod": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Catches a Lot of Fish: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Fishing Rod",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Delicious Fishing Bait",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Seafood)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Bugs)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Pseudo-sonne": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Poisons): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Uni",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Forest Dew",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Flour",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Seafood)",
				"Qty": "3"
			}
		],
		"Uses": "1"
	},
	"Pure Oil": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Medicinal): 10",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tar Fruit",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Plants)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Pure Poison": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Vapors): 10",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Wicked Fang",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Boa Venom Gland",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Poison Dragonfly",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Poisons)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Rainbow Supplement": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Mystery): 17",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Spirit Tears",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rainbow Puniball",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Elixirs)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Red Ray Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Fire Spirit Glow: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Fuel Dirt",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Researcher's Key": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Opens Any Lock: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Glow Sand",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Gold Puniball",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Rocket Ice Bomb": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Ice DMG L: 0",
				"Effect 3": "Ice DMG XL: 9",
				"Effect 4": "Freeze Damage: 12",
				"Effect 5": "Permafrost: 15",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Negate Buffs: -6",
				"Effect 2": "None: 0",
				"Effect 3": "Ice Cage S: 2",
				"Effect 4": "Ice Cage M: 4",
				"Effect 5": "Ice Cage L: 6",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ice Bomb",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Distilled Water",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Gunpowder)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Rota Fortunae": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Gemstones): 9",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "2",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Black Runestone",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Wispstone",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Runeblade": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Crest Rage S: 8",
				"Effect 3": "Crest Rage M: 12",
				"Effect 4": "Crest Rage L: 16",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Convert Damage 10%: -4",
				"Effect 2": "Convert Damage 7%: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Enhance Stun +8%: 4",
				"Effect 5": "Enhance Stun +12%: 6",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Black Runestone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Runestone": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Barrier Rune S: 8",
				"Effect 3": "Barrier Rune M: 12",
				"Effect 4": "Barrier Rune L: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Mountain Pearl",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Polish Powder",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Sack of the Wind God": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Portable Waterspout: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Fairy Sack",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sylph Breath",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Vapors)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Cloth)",
				"Qty": "2"
			}
		],
		"Uses": "4"
	},
	"Scale Cloth": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: DEF & SPD +3: 6",
				"Effect 4": "Equipment Creation: DEF & SPD +5: 9",
				"Effect 5": "Equipment Creation: DEF & SPD +7: 12",
				"Effect 6": "Equipment Creation: DEF & SPD +10: 15",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Chainweb",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Ore)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Scarlet Anchor": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Guiding Light S: 6",
				"Effect 3": "Guiding Light M: 8",
				"Effect 4": "Guiding Light L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "ACC +16%: -5",
				"Effect 2": "ACC +12%: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Enhance Skills +8%: 5",
				"Effect 5": "Enhance Skills +12%: 9",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Sunlite",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Tanned Leather",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Secret Bag": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Send to Container: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Living Rope",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Cloth)",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Magic Tool)",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "1"
			}
		],
		"Uses": "2"
	},
	"Secret Remedy": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "HP & MP Recovery S: 0",
				"Effect 3": "HP & MP Recovery M: 10",
				"Effect 4": "HP & MP Recovery L: 13",
				"Effect 5": "HP & MP Recovery XL: 16",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "HP & MP Healing L: -6",
				"Effect 2": "HP & MP Healing S: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Fast Interrupt S: 3",
				"Effect 5": "Fast Interrupt M: 6",
				"Effect 6": "Fast Interrupt L: 9",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Medicine Base",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Alchemy Yeast",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Medicinal)",
				"Qty": "3"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Shaky Pickaxe": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Destructive Gathering Infinity: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Pickaxe",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Lightning Bomb",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Sharp Ice Sword": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Ice Sword Strike: 0",
				"Effect 3": "Ice Sword Frost Tusk: 10",
				"Effect 4": "Ice Sword Gale Edge: 13",
				"Effect 5": "War God's Ice Blade: 14",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Absorb HP & MP L: -4",
				"Effect 2": "Absorb HP & MP S: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Freezing Air S: 5",
				"Effect 5": "Freezing Air M: 8",
				"Effect 6": "Freezing Air L: 10",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Magic Sword",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Ice Bomb",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "(Vapors)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "1"
			}
		],
		"Uses": "2"
	},
	"Shellper Horn": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Add Ailments Resistance XS: 0",
				"Effect 3": "Add Ailments Resistance S: 6",
				"Effect 4": "Add Ailments Resistance M: 9",
				"Effect 5": "Add Ailments Resistance L: 12",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Creates Barrier L: -6",
				"Effect 2": "Creates Barrier S: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Faint Recovery XS: 4",
				"Effect 5": "Faint Recovery S: 6",
				"Effect 6": "Faint Recovery M: 8",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Swirly Shell",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Seafood)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Soul Absorbing Gourd": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Absorb HP S: 0",
				"Effect 3": "Absorb HP M: 10",
				"Effect 4": "Absorb HP L: 14",
				"Effect 5": "Absorb HP XL: 17",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Dark Dew",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Ghost Orb",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Special Meat": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "HP Recovery S: 0",
				"Effect 3": "HP Recovery M: 9",
				"Effect 4": "HP Recovery L: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Faint Recovery S: -6",
				"Effect 2": "Faint Recovery XS: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Burst of Strength S: 3",
				"Effect 5": "Burst of Strength M: 5",
				"Effect 6": "Burst of Strength L: 7",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Fresh Meat",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Spices)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "3"
			}
		],
		"Uses": "2"
	},
	"Special Plate": {
		"Effects": [
			{
				"Effect 1": "Stinky Trash: -2",
				"Effect 2": "HP Part. Recovery S: 0",
				"Effect 3": "HP Part. Recovery M: 10",
				"Effect 4": "HP Part. Recovery L: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Stun Recovery: -4",
				"Effect 2": "None: 0",
				"Effect 3": "Faint Recovery XS: 4",
				"Effect 4": "Faint Recovery S: 6",
				"Effect 5": "Faint Recovery M: 8",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Dragon Meat",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Fish Sauce",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Vegetables)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Food)",
				"Qty": "2"
			}
		],
		"Uses": "2"
	},
	"Spirit Necklace": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Fire Bolt Protection S: 0",
				"Effect 3": "Fire Bolt Protection L: 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Jar of Four Spirits",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Spirit Tears",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Metals)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Spirit Robe": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Max MP +5: 6",
				"Effect 3": "Max MP +10: 9",
				"Effect 4": "Max MP +15: 12",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Stun Resistance +20: -5",
				"Effect 2": "Stun Resistance +10: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Damage Cut 3%: 2",
				"Effect 5": "Damage Cut 5%: 4",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Nylonfeather",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Elemental Fragment",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Armor Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Spirit Tears": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Gemstones): 13",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Attribute: Earth +3: -5",
				"Effect 2": "Attribute: Earth +2: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Attribute: Fire +2: 4",
				"Effect 5": "Attribute: Fire +3: 6",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "2",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Distilled Water",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "World Spirit",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Star Soul Staff": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Lux Ursa Major S: 6",
				"Effect 3": "Lux Ursa Major M: 11",
				"Effect 4": "Lux Ursa Major L: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Weaken Items +15%: -10",
				"Effect 2": "Weaken Items +12%: -6",
				"Effect 3": "Weaken Items +8%: -2",
				"Effect 4": "Enhance Items +8%: 0",
				"Effect 5": "Enhance Items +12%: 7",
				"Effect 6": "Enhance Items +15%: 10",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Arland Crystal",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Gemstones)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Ster Metal": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: ATK & DEF +1: 7",
				"Effect 4": "Equipment Creation: ATK & DEF +3: 10",
				"Effect 5": "Equipment Creation: ATK & DEF +5: 13",
				"Effect 6": "Equipment Creation: ATK & DEF +7: 16",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Stim Stone",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Metal Ore",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Ore)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Sticky Resin": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "ITEM_EFF_AROUSAL_EQUIP_UNIQUE_5: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Natural Fertilizer",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Clay)",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Stim Leather Mail": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Max HP +15: 4",
				"Effect 3": "Max HP +20: 6",
				"Effect 4": "Max HP +25: 8",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Add Physical Resistance: -7",
				"Effect 2": "None: 0",
				"Effect 3": "Stun Resistance +20: 1",
				"Effect 4": "Stun Resistance +30: 3",
				"Effect 5": "Stun Resistance +40: 5",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tanned Leather",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Stim Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Armor Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Strength Tarot": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Arcana of Might S: 5",
				"Effect 3": "Arcana of Might M: 7",
				"Effect 4": "Arcana of Might L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "SPD +5: -5",
				"Effect 2": "SPD +3: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Max MP +5: 2",
				"Effect 5": "Max MP +10: 5",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Scrap Paper",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Styrom Board": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Plants): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Attribute: Lightning +3: -5",
				"Effect 2": "Attribute: Lightning +2: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Attribute: Ice +2: 6",
				"Effect 5": "Attribute: Ice +3: 10",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Eiche",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Green Bamboo",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Clay)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Sulfite": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "ITEM_EFF_AROUSAL_EQUIP_UNIQUE_2: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tar Fruit",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Gunpowder)",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Sun Cloak": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Sun's Grace S: 5",
				"Effect 3": "Sun's Grace M: 9",
				"Effect 4": "Sun's Grace L: 13",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Avoid KO 10%: -7",
				"Effect 2": "Avoid KO 5%: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Ailments Resistance +10%: 3",
				"Effect 5": "Ailments Resistance +15%: 7",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Scale Cloth",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sunny Crystal",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Armor Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Sun Flare": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Red Star: 0",
				"Effect 3": "Expanding Star: 6",
				"Effect 4": "Blazing Star: 11",
				"Effect 5": "Falling Sun: 12",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Solar Flare L: -6",
				"Effect 2": "Solar Flare M: -3",
				"Effect 3": "Solar Flare S: -1",
				"Effect 4": "None: 0",
				"Effect 5": "Level Down XS: 3",
				"Effect 6": "Level Down S: 6",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Globe",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Alchemy Coal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Magma Stone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "3"
			}
		],
		"Uses": "3"
	},
	"Sunburst Staff": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Sunlit Affection S: 8",
				"Effect 3": "Sunlit Affection M: 11",
				"Effect 4": "Sunlit Affection L: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Convert Damage 5%: -4",
				"Effect 2": "Convert Damage 3%: -1",
				"Effect 3": "None: 0",
				"Effect 4": "Max MP +5: 5",
				"Effect 5": "Max MP +10: 7",
				"Effect 6": "Max MP +15: 9",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Sunny Crystal",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Lumber)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Sunlite": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: ATK & DEF +3: 9",
				"Effect 4": "Equipment Creation: ATK & DEF +5: 11",
				"Effect 5": "Equipment Creation: ATK & DEF +7: 14",
				"Effect 6": "Equipment Creation: ATK & DEF +10: 17",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Black Ore",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Star Piece",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Ore)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Super Cooling Agent": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "ITEM_EFF_AROUSAL_EQUIP_UNIQUE_3: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Foamy Water",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Water)",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Super Helix Rod": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Catches Any Fish: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Professional Fishing Rod",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Delicious Fishing Bait",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Styrom Board",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Bugs)",
				"Qty": "3"
			}
		],
		"Uses": "1"
	},
	"Super Mining Bomb": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Destructive Gathering: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Mining Bomb",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Pure Oil",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Gunpowder)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Vapors)",
				"Qty": "1"
			}
		],
		"Uses": "4"
	},
	"Superb Supplement Black": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Poisons): 15",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "4",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Distilled Water",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Dark Dew",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Poisons)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Superb Supplement White": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Medicinal): 15",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "4",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Distilled Water",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Wispstone",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Supplement Blue": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Attribute: Ice +1: 8",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "5",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "(Seafood)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Supplement Purple": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Attribute: Lightning +1: 6",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "5",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "(Bugs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Supplement Red": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Attribute: Fire +1: 8",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "5",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "(Gunpowder)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Supplement Yellow": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Attribute: Earth +1: 8",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "5",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "(Clay)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Sylph Breath": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Bugs): 13",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "2",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Undying Wind",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Elemental Fragment",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Tanned Leather": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Meat): 13",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Beast Fur",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Tanning Liquid",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Tanning Liquid": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Elixirs): 15",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "4",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "(Poisons)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Plants)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Tar Liquid": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Poisons): 12",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tar Fruit",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Lumber)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Tempest Gear": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Stormbringer S: 7",
				"Effect 3": "Stormbringer M: 11",
				"Effect 4": "Stormbringer L: 15",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Add Stun +10: -3",
				"Effect 2": "Add Stun +5: -1",
				"Effect 3": "None: 0",
				"Effect 4": "DEF +5: 4",
				"Effect 5": "DEF +8: 7",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Gunpowder)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Tera Bomb": {
		"Effects": [
			{
				"Effect 1": "Ashes of Failure: -2",
				"Effect 2": "Fire DMG L: 0",
				"Effect 3": "Fire DMG XL: 9",
				"Effect 4": "Explosion Damage: 12",
				"Effect 5": "World-Engulfing Fire: 15",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Overkill Explosion L: -4",
				"Effect 2": "Overkill Explosion M: -2",
				"Effect 3": "Overkill Explosion S: 0",
				"Effect 4": "Mindscouring Fire S: 2",
				"Effect 5": "Mindscouring Fire M: 4",
				"Effect 6": "Mindscouring Fire L: 6",
				"L Elem": "Elec",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Bomb",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Tar Liquid",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Fuel)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"The World Tarot": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Arcana of the World S: 6",
				"Effect 3": "Arcana of the World M: 12",
				"Effect 4": "Arcana of the World L: 18",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Evasion +12%: -10",
				"Effect 2": "Evasion +10%: -6",
				"Effect 3": "Evasion +8%: -3",
				"Effect 4": "Critical Rate Up +8%: 0",
				"Effect 5": "Critical Rate Up +12%: 5",
				"Effect 6": "Critical Rate Up +15%: 9",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "World Spirit",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Tinc": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Equipment Creation: ATK +3: 9",
				"Effect 4": "Equipment Creation: ATK +5: 11",
				"Effect 5": "Equipment Creation: ATK +7: 13",
				"Effect 6": "Equipment Creation: ATK +10: 16",
				"L Elem": "Ice",
				"R Elem": "Earth"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Stim Stone",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Fuel Dirt",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Ore)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Fuel)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Tonic": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Turn into good materials?: 0",
				"Effect 3": "Turn into great materials?: 15",
				"Effect 4": "Turn into superb materials?: 16",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Water Tree Fruit",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Plants)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Water)",
				"Qty": "1"
			}
		],
		"Uses": "3"
	},
	"Torrent Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Bursting Bubbles: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Original Gem",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Isle Amber",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Traveler Shoes": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Movement Speed Up S: 0",
				"Effect 3": "Movement Speed Up M: 12",
				"Effect 4": "Movement Speed Up L: 13",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tanned Leather",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Living Rope",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Animal Products)",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Traveler's Attire": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Max HP +5: 3",
				"Effect 3": "Max HP +10: 5",
				"Effect 4": "Max HP +15: 7",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "SPD +5: -3",
				"Effect 2": "SPD +3: -1",
				"Effect 3": "None: 0",
				"Effect 4": "DEF +3: 1",
				"Effect 5": "DEF +5: 3",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Cloth",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Armor Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Threads)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Twin Anchor": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Seaman's Pride S: 4",
				"Effect 3": "Seaman's Pride M: 7",
				"Effect 4": "Seaman's Pride L: 10",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Max HP +10: -6",
				"Effect 2": "Max HP +5: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Critical Power Up +3%: 3",
				"Effect 5": "Critical Power Up +5%: 6",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Seafood)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Twin Memoir": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Gladiator's Might S: 10",
				"Effect 3": "Gladiator's Might M: 14",
				"Effect 4": "Gladiator's Might L: 18",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Add Stun +10: -6",
				"Effect 2": "Add Stun +5: -3",
				"Effect 3": "None: 0",
				"Effect 4": "ACC +8%: 2",
				"Effect 5": "ACC +12%: 4",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Tanned Leather",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Animal Products)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Valkyrie Mail": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "War Goddess's Might S: 10",
				"Effect 3": "War Goddess's Might M: 14",
				"Effect 4": "War Goddess's Might L: 18",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Block Curse: -5",
				"Effect 2": "None: 0",
				"Effect 3": "Block Seal: 7",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Himmel Linen",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "World Spirit",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Armor Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Metals)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Valkyrie's Oath": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "War God's Awakening S: 6",
				"Effect 3": "War God's Awakening M: 11",
				"Effect 4": "War God's Awakening L: 17",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Elec"
			},
			{
				"Effect 1": "Enhance Stun +15%: -10",
				"Effect 2": "Enhance Stun +12%: -7",
				"Effect 3": "Enhance Stun +8%: -3",
				"Effect 4": "Add Stun +10: 0",
				"Effect 5": "Add Stun +15: 5",
				"Effect 6": "Add Stun +20: 10",
				"L Elem": "Fire",
				"R Elem": "Earth"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Olgenrium",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Rota Fortunae",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Dragon)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Warp Gate": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Return to Town: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Azure Wing",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Mystery)",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "5"
	},
	"Wheel of Fortune Tarot": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Arcana of Luck S: 5",
				"Effect 3": "Arcana of Luck M: 7",
				"Effect 4": "Arcana of Luck L: 9",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Fire"
			},
			{
				"Effect 1": "Critical Rate Up +5%: -7",
				"Effect 2": "Critical Rate Up +3%: -3",
				"Effect 3": "None: 0",
				"Effect 4": "Evasion +3%: 3",
				"Effect 5": "Evasion +5%: 5",
				"Effect 6": "Evasion +8%: 8",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Zettel",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Medicinal)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Wheel of Isyos": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Prayer for Harvest S: 4",
				"Effect 3": "Prayer for Harvest M: 6",
				"Effect 4": "Prayer for Harvest L: 8",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Weaken Items +8%: -5",
				"Effect 2": "Weaken Items +5%: -2",
				"Effect 3": "None: 0",
				"Effect 4": "Enhance Items +5%: 2",
				"Effect 5": "Enhance Items +8%: 5",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Tinc",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Crystal Piece",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Mystery)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"White Haze Symbol": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "Rainbow Mirage: 0",
				"Effect 3": "",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Ice",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Dark Firefly",
				"Qty": "2"
			},
			{
				"Awake": "NO",
				"Name": "Ster Metal",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Puniballs)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Clay)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	},
	"Winged Chakram": {
		"Effects": [
			{
				"Effect 1": "None: 0",
				"Effect 2": "Wingbeat Blade S: 2",
				"Effect 3": "Wingbeat Blade M: 4",
				"Effect 4": "Wingbeat Blade L: 6",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "",
				"R Elem": "Earth"
			},
			{
				"Effect 1": "Critical Rate Up +5%: -6",
				"Effect 2": "Critical Rate Up +3%: -3",
				"Effect 3": "None: 0",
				"Effect 4": "ACC +5%: 3",
				"Effect 5": "ACC +8%: 6",
				"Effect 6": "",
				"L Elem": "Elec",
				"R Elem": "Fire"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Ingot",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Audra's Tail",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Weapon Materials)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Vapors)",
				"Qty": "2"
			}
		],
		"Uses": "1"
	},
	"Witch Salve": {
		"Effects": [
			{
				"Effect 1": "Pollutant: -2",
				"Effect 2": "Level Down M: 0",
				"Effect 3": "Level Down L: 8",
				"Effect 4": "Level Down XL: 14",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			},
			{
				"Effect 1": "Negate Buffs: -7",
				"Effect 2": "None: 0",
				"Effect 3": "Restricts Movement S: 4",
				"Effect 4": "Restricts Movement M: 7",
				"Effect 5": "Restricts Movement L: 10",
				"Effect 6": "",
				"L Elem": "Fire",
				"R Elem": "Elec"
			}
		],
		"Make #": "1",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Pure Poison",
				"Qty": "1"
			},
			{
				"Awake": "NO",
				"Name": "Medicine Base",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Poisons)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Seafood)",
				"Qty": "2"
			}
		],
		"Uses": "3"
	},
	"Zettel": {
		"Effects": [
			{
				"Effect 1": "Broken Item: -2",
				"Effect 2": "None: 0",
				"Effect 3": "Add (Mystery): 11",
				"Effect 4": "",
				"Effect 5": "",
				"Effect 6": "",
				"L Elem": "Earth",
				"R Elem": "Ice"
			}
		],
		"Make #": "3",
		"Mats": [
			{
				"Awake": "NO",
				"Name": "Scrap Paper",
				"Qty": "3"
			},
			{
				"Awake": "NO",
				"Name": "(Plants)",
				"Qty": "1"
			},
			{
				"Awake": "YES",
				"Name": "(Water)",
				"Qty": "2"
			},
			{
				"Awake": "YES",
				"Name": "(Supplements)",
				"Qty": "1"
			}
		],
		"Uses": "1"
	}
}    GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح����mow�*��f�&��Cp�ȑD_��ٮ}�)� C+���UE��tlp�V/<p��ҕ�ig���E�W�����Sթ�� ӗ�A~@2�E�G"���~ ��5tQ#�+�@.ݡ�i۳�3�5�l��^c��=�x�Н&rA��a�lN��TgK㼧�)݉J�N���I�9��R���$`��[���=i�QgK�4c��%�*�D#I-�<�)&a��J�� ���d+�-Ֆ
��Ζ���Ut��(Q�h:�K��xZ�-��b��ٞ%+�]�p�yFV�F'����kd�^���:[Z��/��ʡy�����EJo�񷰼s�ɿ�A���N�O��Y��D��8�c)���TZ6�7m�A��\oE�hZ�{YJ�)u\a{W��>�?�]���+T�<o�{dU�`��5�Hf1�ۗ�j�b�2�,%85�G.�A�J�"���i��e)!	�Z؊U�u�X��j�c�_�r�`֩A�O��X5��F+YNL��A��ƩƗp��ױب���>J�[a|	�J��;�ʴb���F�^�PT�s�)+Xe)qL^wS�`�)%��9�x��bZ��y
Y4�F����$G�$�Rz����[���lu�ie)qN��K�<)�:�,�=�ۼ�R����x��5�'+X�OV�<���F[�g=w[-�A�����v����$+��Ҳ�i����*���	�e͙�Y���:5FM{6�����d)锵Z�*ʹ�v�U+�9�\���������P�e-��Eb)j�y��RwJ�6��Mrd\�pyYJ���t�mMO�'a8�R4��̍ﾒX��R�Vsb|q�id)	�ݛ��GR��$p�����Y��$r�J��^hi�̃�ūu'2+��s�rp�&��U��Pf��+�7�:w��|��EUe�`����$G�C�q�ō&1ŎG�s� Dq�Q�{�p��x���|��S%��<
\�n���9�X�_�y���6]���մ�Ŝt�q�<�RW����A �y��ػ����������p�7�l���?�:������*.ո;i��5�	 Ύ�ș`D*�JZA����V^���%�~������1�#�a'a*�;Qa�y�b��[��'[�"a���H�$��4� ���	j�ô7�xS�@�W�@ ��DF"���X����4g��'4��F�@ ����ܿ� ���e�~�U�T#�x��)vr#�Q��?���2��]i�{8>9^[�� �4�2{�F'&����|���|�.�?��Ȩ"�� 3Tp��93/Dp>ϙ�@�B�\���E��#��YA 7 `�2"���%�c�YM: ��S���"�+ P�9=+D�%�i �3� �G�vs�D ?&"� !�3nEФ��?Q��@D �Z4�]�~D �������6�	q�\.[[7����!��P�=��J��H�*]_��q�s��s��V�=w�� ��9wr��(Z����)'�IH����t�'0��y�luG�9@��UDV�W ��0ݙe)i e��.�� ����<����	�}m֛�������L ,6�  �x����~Tg����&c�U��` ���iڛu����<���?" �-��s[�!}����W�_�J���f����+^*����n�;�SSyp��c��6��e�G���;3Z�A�3�t��i�9b�Pg�����^����t����x��)O��Q�My95�G���;w9�n��$�z[������<w�#�)+��"������" U~}����O��[��|��]q;�lzt�;��Ȱ:��7�������E��*��oh�z���N<_�>���>>��|O�׷_L��/������զ9̳���{���z~����Ŀ?� �.݌��?�N����|��ZgO�o�����9��!�
Ƽ�}S߫˓���:����q�;i��i�]�t� G��Q0�_î!�w��?-��0_�|��nk�S�0l�>=]�e9�G��v��J[=Y9b�3�mE�X�X�-A��fV�2K�jS0"��2!��7��؀�3���3�\�+2�Z`��T	�hI-��N�2���A��M�@�jl����	���5�a�Y�6-o���������x}�}t��Zgs>1)���mQ?����vbZR����m���C��C�{�3o��=}b"/�|���o��?_^�_�+��,���5�U��� 4��]>	@Cl5���w��_$�c��V��sr*5 5��I��9��
�hJV�!�jk�A�=ٞ7���9<T�gť�o�٣����������l��Y�:���}�G�R}Ο����������r!Nϊ�C�;m7�dg����Ez���S%��8��)2Kͪ�6̰�5�/Ӥ�ag�1���,9Pu�]o�Q��{��;�J?<�Yo^_��~��.�>�����]����>߿Y�_�,�U_��o�~��[?n�=��Wg����>���������}y��N�m	n���Kro�䨯rJ���.u�e���-K��䐖��Y�['��N��p������r�Εܪ�x]���j1=^�wʩ4�,���!�&;ج��j�e��EcL���b�_��E�ϕ�u�$�Y��Lj��*���٢Z�y�F��m�p�
�Rw�����,Y�/q��h�M!���,V� �g��Y�J��
.��e�h#�m�d���Y�h�������k�c�q��ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[          [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://0rjbjuyhet6g"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 {
	"Alchemyriddle": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Letter": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Demon Crystal Core": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Coffee": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Liquor Candy": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Missive": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Pretty Shell": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Amazing Adventurer Notes": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Locket": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Benon's Diary": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Charm": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Pure Truffle": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Lottery Ticket": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "[Alchemyriddle] Ecology of the Sea Guardian [Chapter of Answers]"
	},
	"Super Simple Alchemy": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Acqusition": "** Event/Quest **"
	},
	"Gem Polishing": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Acqusition": "** Event/Quest **"
	},
	"Ingredients for Beginners": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Acqusition": "** Event/Quest **"
	},
	"Delightful Craft": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Acqusition": "** Event/Quest **"
	},
	"Secrets of Master Blacksmith": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Acqusition": "Smithy, Chapter 8"
	},
	"The Art of Burning Soul": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Acqusition": "** Event/Quest **"
	},
	"My First Recipes": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Acqusition": "Sunrise Cafe, Chapter 6"
	},
	"You Can Do This": {
		"Level": "0",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Acqusition": "** Event/Quest **"
	},
	"Plain Grass": {
		"Level": "1",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Awakened TP Increase +3",
		"Awakened Recovery": "Awakened TP Increase +3",
		"Awakened Equipment": "Awakened TP Increase +3",
		"Cat 1": "(Plants)",
		"Location": "Morning Dew Forest, Summer Breeze Road, Empty Neighborhood, Eternal Spring, Settler's Road, Old Kingdom Checkpoint, Trombe Plateau, Old Empire Border: Merulia Gate, Guiding Light Forest, Modis Ruins, Quelei Forest, Stein Hill, Dusty Nail Canyon, Rolling Hill"
	},
	"Fest": {
		"Level": "1",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Earth +1",
		"Awakened Attack (Bombs)": "Awakened: Earth +1",
		"Awakened Recovery": "Awakened: Earth +1",
		"Awakened Equipment": "Awakened: Earth +1",
		"Cat 1": "(Ore)",
		"Location": "Morning Dew Forest, Summer Breeze Road, Empty Neighborhood, Eternal Spring, Settler's Road, Old Kingdom Checkpoint, Hart Outpost, Trombe Plateau, Old Empire Border: Merulia Gate, Stalhang Castle, Arls National Mine, Stone Coliseum, Scorched Wasteland, Mt. Velus, Izuko Beach, Runestone Nest, Stein Hill, Dusty Nail Canyon",
		"Monster": "Rock Punk, Fang Flyer"
	},
	"Scrap Paper": {
		"Level": "1",
		"Fire": "1",
		"Ice": "0",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Awakened: Fire +1",
		"Awakened Recovery": "Awakened: Fire +1",
		"Awakened Equipment": "Awakened: Fire +1",
		"Cat 1": "(Fuel)",
		"Location": "Fellsgalaxen, Old Kingdom Checkpoint, Hart Outpost, Old Empire Border: Merulia Gate, Ancient Monastery, Forgotten Village, Dusty Nail Canyon, Fellsgalaxen: Another"
	},
	"Pollutant": {
		"Level": "1",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Awakened: Earth +2",
		"Awakened Recovery": "Awakened: Earth +2",
		"Awakened Equipment": "Awakened: Earth +2",
		"Cat 1": "(Poisons)",
		"Location": "Forgotten Village, Dusty Nail Canyon"
	},
	"Broken Item": {
		"Level": "1",
		"Fire": "0",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +2",
		"Awakened Attack (Bombs)": "Awakened: Lightning +2",
		"Awakened Recovery": "Awakened: Lightning +2",
		"Awakened Equipment": "Awakened: Lightning +2",
		"Cat 1": "(Magic Tool)",
		"Location": "Ancient Monastery, Forgotten Village, Dusty Nail Canyon"
	},
	"Ashes of Failure": {
		"Level": "1",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Awakened: Fire +2",
		"Awakened Recovery": "Awakened: Fire +2",
		"Awakened Equipment": "Awakened: Fire +2",
		"Cat 1": "(Medicinal)",
		"Location": "Ancient Monastery, Forgotten Village, Dusty Nail Canyon"
	},
	"Stinky Trash": {
		"Level": "1",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Awakened: Ice +2",
		"Awakened Recovery": "Awakened: Ice +2",
		"Awakened Equipment": "Awakened: Ice +2",
		"Cat 1": "(Spices)",
		"Location": "Forgotten Village"
	},
	"Nuse": {
		"Level": "2",
		"Fire": "1",
		"Ice": "1",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Awakened TP Increase +3",
		"Awakened Recovery": "Awakened TP Increase +3",
		"Awakened Equipment": "Awakened TP Increase +3",
		"Cat 1": "(Plants)",
		"Location": "Morning Dew Forest, Summer Breeze Road, Empty Neighborhood, Eternal Spring, Settler's Road, Nearby Forest, Guiding Light Forest, Golden Plains, Quelei Forest, Neumont Forest, Izuko Beach, Holy Slumbering Tree, Rolling Hill",
		"Monster": "Roamingshroom"
	},
	"Clean Water": {
		"Level": "2",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +1",
		"Awakened Attack (Bombs)": "Awakened: Ice +1",
		"Awakened Recovery": "Awakened: Ice +1",
		"Awakened Equipment": "Awakened: Ice +1",
		"Cat 1": "(Water)",
		"Location": "Summer Breeze Road, Empty Neighborhood, Eternal Spring, Modis Ruins, Rolling Winds Cavern, Ancient Monastery, Forgotten Village, Handel Farm",
		"Monster": "Blue Puni"
	},
	"Polish Powder": {
		"Level": "2",
		"Fire": "0",
		"Ice": "0",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 1",
		"Awakened Recovery": "Cures Sleep",
		"Awakened Equipment": "ATK Up Lvl 1",
		"Cat 1": "(Clay)",
		"Acqusition": "Book 'Gem Polishing'"
	},
	"Leather Production": {
		"Level": "2",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Uni": {
		"WT": "100",
		"Stun": "35",
		"Range": "Single",
		"Level": "3",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Lightning +1",
		"Awakened Attack (Bombs)": "Awakened: Lightning +1",
		"Awakened Recovery": "Awakened: Lightning +1",
		"Awakened Equipment": "Awakened: Lightning +1",
		"Cat 1": "(Plants)",
		"Cat 2": "(Vegetables)",
		"Location": "Morning Dew Forest, Fellsgalaxen, Summer Breeze Road, Empty Neighborhood, Eternal Spring, Settler's Road, Nearby Forest, Guiding Light Forest, Golden Plains, Quelei Forest, Neumont Forest, Izuko Beach, Holy Slumbering Tree, Rolling Hill, Fellsgalaxen: Another"
	},
	"Craft": {
		"WT": "250",
		"Stun": "60",
		"Range": "Normal Range",
		"Level": "3",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 1",
		"Awakened Recovery": "Temp ATK Up Lvl 1",
		"Awakened Equipment": "ACC Up Lvl 1",
		"Cat 1": "(Bombs)",
		"Location": "Hart Outpost",
		"Acqusition": "Event STR_LIBRARY_BUILD_004"
	},
	"Red Sand": {
		"Level": "3",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Earth +1",
		"Awakened Attack (Bombs)": "Awakened: Earth +1",
		"Awakened Recovery": "Awakened: Earth +1",
		"Awakened Equipment": "Awakened: Earth +1",
		"Cat 1": "(Clay)",
		"Location": "Morning Dew Forest, Summer Breeze Road, Empty Neighborhood, Eternal Spring, Settler's Road, Old Kingdom Checkpoint, Trombe Plateau, Old Empire Border: Merulia Gate, Stalhang Castle, Arls National Mine, Old Blocked Mining Tunnel, Stone Coliseum, Rolling Winds Cavern, Forgotten Village, Scorched Wasteland, Handel Farm, Mt. Velus, Runestone Nest, Stein Hill, Dusty Nail Canyon, Fire's Domain, Holy Slumbering Tree"
	},
	"Small Sardine": {
		"Level": "3",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Awakened TP Increase +3",
		"Awakened Recovery": "Awakened TP Increase +3",
		"Awakened Equipment": "Awakened TP Increase +3",
		"Cat 1": "(Seafood)",
		"Location": "Summer Breeze Road, Empty Neighborhood, Eternal Spring, Settler's Road, Old Kingdom Checkpoint, Old Empire Border: Merulia Gate, Guiding Light Forest, Golden Plains, Quelei Forest, Handel Farm, Stein Hill, Dusty Nail Canyon, Large Conifer Forest",
		"Monster": "Isle Fish"
	},
	"Beehive": {
		"Level": "3",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Awakened: Fire +1",
		"Awakened Recovery": "Awakened: Fire +1",
		"Awakened Equipment": "Awakened: Fire +1",
		"Cat 1": "(Vegetables)",
		"Cat 2": "(Gunpowder)",
		"Location": "Morning Dew Forest, Summer Breeze Road, Empty Neighborhood, Eternal Spring, Settler's Road, Trombe Plateau, Nearby Forest, Guiding Light Forest, Golden Plains, Quelei Forest, Neumont Forest, Izuko Beach, Holy Slumbering Tree, Rolling Hill",
		"Monster": "Ginger Bear"
	},
	"Hard Potato": {
		"Level": "3",
		"Fire": "2",
		"Ice": "1",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Awakened Quality Up +10",
		"Awakened Equipment": "Awakened Quality Up +10",
		"Cat 1": "(Plants)",
		"Cat 2": "(Vegetables)",
		"Location": "Empty Neighborhood, Old Empire Border: Merulia Gate, Nearby Forest, Neumont Forest, Handel Farm, Holy Slumbering Tree"
	},
	"Carrot": {
		"Level": "3",
		"Fire": "0",
		"Ice": "0",
		"Elec": "1",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Awakened TP Increase +3",
		"Awakened Recovery": "Awakened TP Increase +3",
		"Awakened Equipment": "Awakened TP Increase +3",
		"Cat 1": "(Plants)",
		"Cat 2": "(Vegetables)",
		"Location": "Empty Neighborhood, Old Empire Border: Merulia Gate, Nearby Forest, Neumont Forest, Handel Farm, Holy Slumbering Tree",
		"Monster": "Alumi Rabbit"
	},
	"Healing Salve": {
		"WT": "200",
		"Stun": "0",
		"Range": "Single",
		"Level": "4",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 1",
		"Awakened Recovery": "Temp SPD Up Lvl 1",
		"Awakened Equipment": "Add Ailments Resistance XS",
		"Cat 1": "(Medicines)",
		"Location": "Hart Outpost",
		"Acqusition": "Event STR_LIBRARY_BUILD_025"
	},
	"Clear Grass": {
		"Level": "4",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Ice +1",
		"Awakened Attack (Bombs)": "Awakened: Ice +1",
		"Awakened Recovery": "Add MP Recovery Lvl 1",
		"Awakened Equipment": "Max MP Up Lvl 1",
		"Cat 1": "(Plants)",
		"Cat 2": "(Medicinal)",
		"Location": "Morning Dew Forest, Summer Breeze Road, Empty Neighborhood, Eternal Spring, Settler's Road, Guiding Light Forest, Dusty Nail Canyon, Large Conifer Forest"
	},
	"Rabbit Fur": {
		"Level": "4",
		"Fire": "1",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Awakened Quality Up +10",
		"Awakened Equipment": "Awakened Quality Up +10",
		"Cat 1": "(Threads)",
		"Location": "Old Kingdom Checkpoint, Old Empire Border: Merulia Gate",
		"Monster": "Alumi Rabbit, Crystal Horn, Furball Rabbit, Snow Heart, Shadow Arch, Magi Mirage, Piercing Unicorn"
	},
	"Crystal Piece": {
		"Level": "4",
		"Fire": "0",
		"Ice": "1",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened TP Increase +5",
		"Awakened Attack (Bombs)": "Awakened TP Increase +5",
		"Awakened Recovery": "Awakened TP Increase +5",
		"Awakened Equipment": "Awakened TP Increase +5",
		"Cat 1": "(Mystery)",
		"Location": "Fellsgalaxen, Old Blocked Mining Tunnel, Stone Coliseum, Modis Ruins, Rolling Winds Cavern, Quelei Forest, Ster Highlands, Scorched Wasteland, Mt. Velus, Runestone Nest, Fire's Domain, Fellsgalaxen: Another",
		"Monster": "Aphostol, Audra"
	},
	"Rock Salt": {
		"Level": "4",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Earth +1",
		"Awakened Attack (Bombs)": "Inflict Poison Lvl 1",
		"Awakened Recovery": "Damage Reducer Lvl 1",
		"Awakened Equipment": "Evasion Up Lvl 1",
		"Cat 1": "(Spices)",
		"Cat 2": "(Ore)",
		"Location": "Arls National Mine, Ster Highlands"
	},
	"Supplement Red": {
		"Level": "4",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Awakened: Fire +1",
		"Awakened Recovery": "Awakened: Fire +1",
		"Awakened Equipment": "Awakened: Fire +1",
		"Cat 1": "(Supplements)",
		"Acqusition": "Event STR_LIBRARY_BUILD_026"
	},
	"Nostalgic Curry": {
		"WT": "200",
		"Stun": "0",
		"Range": "Single",
		"Level": "5",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 1",
		"Awakened Recovery": "Temp ATK Up Lvl 2",
		"Awakened Equipment": "ATK Up Lvl 2",
		"Cat 1": "(Food)",
		"Acqusition": "[Alchemyriddle] Stimulation and Fond Memories [Chapter of Impetus]"
	},
	"Bomb": {
		"WT": "250",
		"Stun": "35",
		"Range": "Narrow Range",
		"Level": "5",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 1",
		"Awakened Recovery": "Cures Burns",
		"Awakened Equipment": "ATK Up Lvl 1",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Regarding Bombs (Basic) [Chapter of Impetus]"
	},
	"Killer Bee": {
		"Level": "5",
		"Fire": "1",
		"Ice": "0",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +1",
		"Awakened Attack (Bombs)": "Awakened: Lightning +1",
		"Awakened Recovery": "Awakened: Lightning +1",
		"Awakened Equipment": "Awakened: Lightning +1",
		"Cat 1": "(Bugs)",
		"Location": "Morning Dew Forest, Settler's Road, Trombe Plateau, Nearby Forest, Golden Plains, Foggy Forest, Quelei Forest, Handel Farm"
	},
	"Bat Wing": {
		"Level": "5",
		"Fire": "1",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Awakened TP Increase +3",
		"Awakened Recovery": "Awakened TP Increase +3",
		"Awakened Equipment": "Awakened TP Increase +3",
		"Cat 1": "(Animal Products)",
		"Location": "Old Kingdom Checkpoint, Old Empire Border: Merulia Gate, Stalhang Castle, Stone Coliseum, Rolling Winds Cavern",
		"Monster": "Fang Flyer, Taker, Frozen Chiroptera, Shadow Bat, Pulse Wind, Silent Killer, Machete Wing"
	},
	"Wheat": {
		"Level": "5",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Awakened Quality Up +10",
		"Awakened Equipment": "Awakened Quality Up +10",
		"Cat 1": "(Plants)",
		"Cat 2": "(Vegetables)",
		"Location": "Summer Breeze Road, Old Empire Border: Merulia Gate, Stalhang Castle, Golden Plains, Ancient Monastery, Handel Farm, Large Conifer Forest"
	},
	"Magic Grass": {
		"Level": "5",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "HP Recovery XS",
		"Awakened Equipment": "Temp Stamina Buff S",
		"Cat 1": "(Medicinal)",
		"Cat 2": "(Plants)",
		"Location": "Summer Breeze Road, Empty Neighborhood, Eternal Spring, Settler's Road, Old Kingdom Checkpoint, Trombe Plateau, Old Empire Border: Merulia Gate, Guiding Light Forest, Golden Plains, Modis Ruins, Foggy Forest, Quelei Forest, Forgotten Village, Ster Highlands, Scorched Wasteland, Neumont Forest, Handel Farm, Izuko Beach, Stein Hill, Night's Domain, Dusty Nail Canyon, Large Conifer Forest, Holy Slumbering Tree, Rolling Hill",
		"Monster": "Green Puni"
	},
	"Puni Fluid": {
		"Level": "5",
		"Fire": "0",
		"Ice": "1",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Earth +1",
		"Awakened Attack (Bombs)": "Awakened: Earth +1",
		"Awakened Recovery": "Awakened: Earth +1",
		"Awakened Equipment": "Awakened: Earth +1",
		"Cat 1": "(Puniballs)",
		"Cat 2": "(Water)",
		"Monster": "Blue Puni, Green Puni, Red Puni, Gold Puni, Puni Black, Ultra Puni"
	},
	"Fishing Rod": {
		"Level": "5",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +1",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 1",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 1",
		"Awakened Equipment": "ATK Up Lvl 1",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Lumber)",
		"Acqusition": "[Alchemyriddle] Waterside Companion (Basic) [Chapter of Encounters]"
	},
	"Supplement Blue": {
		"Level": "5",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +1",
		"Awakened Attack (Bombs)": "Awakened: Ice +1",
		"Awakened Recovery": "Awakened: Ice +1",
		"Awakened Equipment": "Awakened: Ice +1",
		"Cat 1": "(Supplements)",
		"Acqusition": "Book 'Super Simple Alchemy'"
	},
	"Supplement Purple": {
		"Level": "5",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +1",
		"Awakened Attack (Bombs)": "Awakened: Lightning +1",
		"Awakened Recovery": "Awakened: Lightning +1",
		"Awakened Equipment": "Awakened: Lightning +1",
		"Cat 1": "(Supplements)",
		"Acqusition": "Book 'Super Simple Alchemy'"
	},
	"Supplement Yellow": {
		"Level": "5",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Earth +1",
		"Awakened Attack (Bombs)": "Awakened: Earth +1",
		"Awakened Recovery": "Awakened: Earth +1",
		"Awakened Equipment": "Awakened: Earth +1",
		"Cat 1": "(Supplements)",
		"Acqusition": "Book 'Super Simple Alchemy'"
	},
	"Flour": {
		"Level": "5",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 1",
		"Awakened Recovery": "Temp Critical Power Up Lvl 1",
		"Awakened Equipment": "Enhance Items Lvl 1",
		"Cat 1": "(Spices)",
		"Location": "Handel Farm",
		"Acqusition": "Book 'My First Recipes'"
	},
	"Delicious Fishing Bait": {
		"Level": "5",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 1",
		"Awakened Recovery": "Cures Blindness",
		"Awakened Equipment": "SPD Up Lvl 1",
		"Cat 1": "(Vegetables)",
		"Cat 2": "(Clay)",
		"Acqusition": "[Alchemyriddle] Waterside Companion (Basic) [Chapter of Encounters]"
	},
	"Traveler's Attire": {
		"Level": "5",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 1",
		"Awakened Recovery": "Temp DEF Up Lvl 1",
		"Awakened Equipment": "Temp Stamina Buff S",
		"Cat 1": "(Light Armor)",
		"Acqusition": "Old Kingdom Checkpoint"
	},
	"Alchemy of Materials": {
		"Level": "5",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "The Silver Chisel, Chapter 7"
	},
	"Ice Bomb": {
		"WT": "250",
		"Stun": "50",
		"Range": "Narrow Range",
		"Level": "6",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +1",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 1",
		"Awakened Recovery": "Cures Sleep",
		"Awakened Equipment": "DEF Up Lvl 1",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Regarding Bombs (Advanced) [Chapter of Impetus]"
	},
	"Migraine Syrup": {
		"WT": "250",
		"Stun": "0",
		"Range": "Single",
		"Level": "6",
		"Fire": "0",
		"Ice": "2",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Earth +1",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 1",
		"Awakened Recovery": "Damage Reducer Lvl 1",
		"Awakened Equipment": "Evasion Up Lvl 1",
		"Cat 1": "(Medicines)",
		"Acqusition": "[Alchemyriddle] When You're Feeling Down [Chapter of Impetus]"
	},
	"Meister Tarte": {
		"WT": "250",
		"Stun": "0",
		"Range": "Single",
		"Level": "6",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Inflict Burns Lvl 1",
		"Awakened Recovery": "HP Recovery XS",
		"Awakened Equipment": "Weaken Item Lvl 1",
		"Cat 1": "(Food)",
		"Acqusition": "Book 'My First Recipes'"
	},
	"Phlogiston": {
		"Level": "6",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Awakened: Fire +2",
		"Awakened Recovery": "Awakened: Fire +2",
		"Awakened Equipment": "Awakened: Fire +2",
		"Cat 1": "(Gunpowder)",
		"Cat 2": "(Ore)",
		"Location": "Morning Dew Forest, Fellsgalaxen, Summer Breeze Road, Settler's Road, Old Kingdom Checkpoint, Hart Outpost, Trombe Plateau, Old Empire Border: Merulia Gate, Stalhang Castle, Arls National Mine, Old Blocked Mining Tunnel, Stone Coliseum, Rolling Winds Cavern, Forgotten Village, Scorched Wasteland, Mt. Velus, Runestone Nest, Stein Hill, Dusty Nail Canyon, Fire's Domain, Fellsgalaxen: Another",
		"Monster": "Red Puni"
	},
	"Butterfly Fish": {
		"Level": "6",
		"Fire": "0",
		"Ice": "2",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Cures Blindness",
		"Awakened Equipment": "Temp Stamina Buff S",
		"Cat 1": "(Seafood)",
		"Location": "Summer Breeze Road, Empty Neighborhood, Eternal Spring, Settler's Road, Old Kingdom Checkpoint, Old Empire Border: Merulia Gate, Guiding Light Forest, Golden Plains, Quelei Forest, Handel Farm, Izuko Beach, Stein Hill, Large Conifer Forest"
	},
	"Honey": {
		"Level": "6",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 1",
		"Awakened Recovery": "Temp EXP Up Lvl 1",
		"Awakened Equipment": "Skill Up Lvl 1",
		"Cat 1": "(Spices)",
		"Acqusition": "Book 'My First Recipes'"
	},
	"Apprentice Alchemist's Staff": {
		"Level": "6",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 1",
		"Awakened Recovery": "HP Recovery XS",
		"Awakened Equipment": "Weaken Item Lvl 1",
		"Cat 1": "(Alchemy Staffs)",
		"Acqusition": "** Event/Quest **"
	},
	"Nobel Buster": {
		"Level": "6",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 1",
		"Awakened Recovery": "Temp ACC Up Lvl 1",
		"Awakened Equipment": "ACC Up Lvl 1",
		"Cat 1": "(Cannons)",
		"Acqusition": "** Event/Quest **"
	},
	"Strength Tarot": {
		"Level": "6",
		"Fire": "0",
		"Ice": "1",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 1",
		"Awakened Recovery": "Temp ATK Up Lvl 1",
		"Awakened Equipment": "ATK Up Lvl 1",
		"Cat 1": "(Charms)",
		"Acqusition": "** Event/Quest **"
	},
	"Black Steel": {
		"Level": "6",
		"Fire": "0",
		"Ice": "0",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 1",
		"Awakened Recovery": "Temp SPD Up Lvl 1",
		"Awakened Equipment": "SPD Up Lvl 1",
		"Cat 1": "(Swords)",
		"Acqusition": "** Event/Quest **"
	},
	"Twin Anchor": {
		"Level": "6",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 1",
		"Awakened Recovery": "Temp Critical Power Up Lvl 1",
		"Awakened Equipment": "DEF Up Lvl 1",
		"Cat 1": "(Anchors)",
		"Acqusition": "** Event/Quest **"
	},
	"Alchemy Cane": {
		"Level": "6",
		"Fire": "1",
		"Ice": "1",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 1",
		"Awakened Recovery": "HP Recovery S",
		"Awakened Equipment": "Enhance Items Lvl 2",
		"Cat 1": "(Decorative Staffs)",
		"Acqusition": "** Event/Quest **"
	},
	"Plain Pie": {
		"Level": "6",
		"Fire": "1",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Inflict Poison Lvl 1",
		"Awakened Recovery": "Cures Burns",
		"Awakened Equipment": "Temp Stamina Buff S",
		"Cat 1": "(Food)",
		"Acqusition": "Event STR_LIBRARY_BUILD_005"
	},
	"Fish's Whiskers": {
		"Level": "6",
		"Fire": "0",
		"Ice": "2",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 1",
		"Awakened Recovery": "HP Recovery XS",
		"Awakened Equipment": "Enhance Items Lvl 1",
		"Cat 1": "(Threads)",
		"Cat 2": "(Animal Products)",
		"Location": "Eternal Spring",
		"Monster": "Giant Isle Fish, Striped Isle Fish, Huge Isle Fish"
	},
	"Bunt Resin": {
		"Level": "6",
		"Fire": "2",
		"Ice": "1",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Inflict Slowness Lvl 1",
		"Awakened Recovery": "Add MP Recovery Lvl 1",
		"Awakened Equipment": "ATK Up Lvl 1",
		"Cat 1": "(Clay)",
		"Acqusition": "[Alchemyriddle] Uniquely Designed Gear (3) [Chapter of Bonds]"
	},
	"Processing the Elements": {
		"Level": "6",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"How to Repress an Appetite": {
		"Level": "6",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Chainweb": {
		"Level": "7",
		"Fire": "1",
		"Ice": "0",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +1",
		"Awakened Attack (Bombs)": "Awakened: Lightning +1",
		"Awakened Recovery": "Awakened: Lightning +1",
		"Awakened Equipment": "Awakened: Lightning +1",
		"Cat 1": "(Threads)",
		"Cat 2": "(Gunpowder)",
		"Location": "Fellsgalaxen, Eternal Spring, Old Kingdom Checkpoint, Old Empire Border: Merulia Gate, Stalhang Castle, Orthogalaxen, Old Blocked Mining Tunnel, Modis Ruins, Rolling Winds Cavern, Stein Hill, Large Conifer Forest, Fellsgalaxen: Another"
	},
	"Original Gem": {
		"Level": "7",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Awakened Quality Up +20",
		"Awakened Recovery": "Awakened Quality Up +20",
		"Awakened Equipment": "Awakened Quality Up +20",
		"Cat 1": "(Gemstones)",
		"Location": "Summer Breeze Road, Settler's Road, Hart Outpost, Trombe Plateau, Stalhang Castle, Arls National Mine, Old Blocked Mining Tunnel, Stone Coliseum, Forgotten Village, Stein Hill, Dusty Nail Canyon, Fire's Domain",
		"Monster": "Vulture, Aphostol, Ice Pixie"
	},
	"Honeypot Ant": {
		"Level": "7",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Awakened Quality Up +10",
		"Awakened Equipment": "Awakened Quality Up +10",
		"Cat 1": "(Bugs)",
		"Cat 2": "(Spices)",
		"Location": "Morning Dew Forest, Settler's Road, Trombe Plateau, Nearby Forest, Golden Plains, Foggy Forest, Handel Farm"
	},
	"Bug Catcher Net": {
		"Level": "7",
		"Fire": "2",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 2",
		"Awakened Recovery": "Cures Sleep",
		"Awakened Equipment": "SPD Up Lvl 2",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Threads)",
		"Acqusition": "[Alchemyriddle] The Road to Mastering Gathering (1) [Chapter of Impetus]"
	},
	"Fish Sauce": {
		"Level": "7",
		"Fire": "1",
		"Ice": "2",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened (Spices)",
		"Awakened Attack (Bombs)": "Awakened (Spices)",
		"Awakened Recovery": "Awakened (Spices)",
		"Awakened Equipment": "Awakened (Spices)",
		"Cat 1": "(Spices)",
		"Cat 2": "(Seafood)",
		"Acqusition": "Book 'My First Recipes'"
	},
	"Alchemy Textbook": {
		"Level": "7",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Awakened Quality Up +20",
		"Awakened Recovery": "Awakened Quality Up +20",
		"Awakened Equipment": "Awakened Quality Up +20",
		"Cat 1": "ITEM_CATEGORY_ALCHEMY_BOOK"
	},
	"Lightning Bomb": {
		"WT": "200",
		"Stun": "50",
		"Range": "Single",
		"Level": "8",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +1",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 1",
		"Awakened Recovery": "Cures Blindness",
		"Awakened Equipment": "SPD Up Lvl 1",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Regarding Bombs (Advanced) [Chapter of Impetus]"
	},
	"Snow Stone": {
		"Level": "8",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Awakened: Ice +2",
		"Awakened Recovery": "Awakened: Ice +2",
		"Awakened Equipment": "Awakened: Ice +2",
		"Cat 1": "(Ore)",
		"Location": "Fellsgalaxen, Empty Neighborhood, Eternal Spring, Old Kingdom Checkpoint, Stalhang Castle, Arls National Mine, Stone Coliseum, Ster Highlands, Izuko Beach, Runestone Nest, Night's Domain, Fellsgalaxen: Another",
		"Monster": "Snow Heart"
	},
	"Stim Stone": {
		"Level": "8",
		"Fire": "0",
		"Ice": "0",
		"Elec": "1",
		"Earth": "2",
		"Awakened Material": "Awakened: Light. & Earth +1",
		"Awakened Attack (Bombs)": "Awakened: Light. & Earth +1",
		"Awakened Recovery": "Awakened: Light. & Earth +1",
		"Awakened Equipment": "Awakened: Light. & Earth +1",
		"Cat 1": "(Ore)",
		"Location": "Summer Breeze Road, Settler's Road, Hart Outpost, Trombe Plateau, Stalhang Castle, Arls National Mine, Orthogalaxen, Old Blocked Mining Tunnel, Stone Coliseum, Forgotten Village, Ster Highlands, Scorched Wasteland, Neumont Forest, Mt. Velus, Stein Hill, Night's Domain, Fire's Domain",
		"Monster": "Rock Punk"
	},
	"Globe Sphere": {
		"Level": "8",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Earth +1",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 2",
		"Awakened Recovery": "Temp SPD Up Lvl 1",
		"Awakened Equipment": "Ignores Luck M",
		"Cat 1": "(Lumber)",
		"Location": "Hart Outpost, Modis Ruins, Large Conifer Forest"
	},
	"Beast Meat": {
		"Level": "8",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Awakened Quality Up +10",
		"Awakened Equipment": "Awakened Quality Up +10",
		"Cat 1": "(Meat)",
		"Cat 2": "(Animal Products)",
		"Monster": "Alumi Rabbit, Crystal Horn, Wolf, Jagd Wolf, Audra, Vulture, Fang Flyer, Taker, Shadow Bat"
	},
	"Forest Cabbage": {
		"Level": "8",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +5",
		"Awakened Attack (Bombs)": "Awakened TP Increase +5",
		"Awakened Recovery": "Awakened TP Increase +5",
		"Awakened Equipment": "Awakened TP Increase +5",
		"Cat 1": "(Plants)",
		"Cat 2": "(Vegetables)",
		"Location": "Nearby Forest, Neumont Forest, Holy Slumbering Tree"
	},
	"Chariot Milk": {
		"Level": "8",
		"Fire": "2",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Awakened TP Increase +7",
		"Awakened Recovery": "Awakened Quality Up +30",
		"Awakened Equipment": "Awakened TP Increase +7",
		"Cat 1": "(Spices)",
		"Cat 2": "(Water)",
		"Location": "Rolling Winds Cavern, Handel Farm"
	},
	"Nostalgic Spice": {
		"Level": "8",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Awakened Quality Up +10",
		"Awakened Equipment": "Awakened Quality Up +10",
		"Cat 1": "(Spices)",
		"Location": "Handel Farm"
	},
	"Blue Puniball": {
		"Level": "8",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +1",
		"Awakened Attack (Bombs)": "Awakened: Ice +1",
		"Awakened Recovery": "Awakened: Ice +1",
		"Awakened Equipment": "Awakened: Ice +1",
		"Cat 1": "(Puniballs)",
		"Monster": "Blue Puni, Black Puni, Puni?"
	},
	"Green Puniball": {
		"Level": "8",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +1",
		"Awakened Attack (Bombs)": "Awakened: Lightning +1",
		"Awakened Recovery": "Awakened: Lightning +1",
		"Awakened Equipment": "Awakened: Lightning +1",
		"Cat 1": "(Puniballs)",
		"Monster": "Green Puni, Black Puni, Puni?"
	},
	"Red Puniball": {
		"Level": "8",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Awakened: Fire +1",
		"Awakened Recovery": "Awakened: Fire +1",
		"Awakened Equipment": "Awakened: Fire +1",
		"Cat 1": "(Puniballs)",
		"Monster": "Red Puni, Black Puni, Puni?"
	},
	"Mining Bomb": {
		"Level": "8",
		"Fire": "3",
		"Ice": "0",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Inflict Poison Lvl 2",
		"Awakened Recovery": "Temp Evasion Up Lvl 2",
		"Awakened Equipment": "ATK Up Lvl 2",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Regarding Bombs (Supplementary) [Chapter of Impetus]"
	},
	"Fairy Sack": {
		"Level": "8",
		"Fire": "1",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Light. +1",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 2",
		"Awakened Recovery": "Cures Blindness",
		"Awakened Equipment": "ACC Up Lvl 2",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Cloth)",
		"Acqusition": "[Alchemyriddle] The Road to Mastering Gathering (1) [Chapter of Impetus]"
	},
	"Ingot": {
		"Level": "8",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Awakened: Fire +1",
		"Awakened Equipment": "Awakened Quality Up +10",
		"Cat 1": "(Weapon Materials)",
		"Cat 2": "(Metals)",
		"Location": "Orthogalaxen",
		"Acqusition": "Book 'Ingredients for Beginners'"
	},
	"Cloth": {
		"Level": "8",
		"Fire": "0",
		"Ice": "0",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Awakened: Lightning +1",
		"Awakened Recovery": "Awakened Quality Up +10",
		"Awakened Equipment": "Awakened: Lightning +1",
		"Cat 1": "(Armor Materials)",
		"Cat 2": "(Cloth)",
		"Location": "Orthogalaxen",
		"Acqusition": "Book 'Ingredients for Beginners'"
	},
	"Alchemy Girl's Sword": {
		"Level": "8",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Awakened TP Increase +7",
		"Awakened Recovery": "Awakened TP Increase +7",
		"Awakened Equipment": "Awakened TP Increase +7",
		"Cat 1": "ITEM_CATEGORY_RAPIER"
	},
	"Gem Mysteries": {
		"Level": "8",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Globe": {
		"WT": "500",
		"Stun": "100",
		"Range": "Single",
		"Level": "9",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Earth +1",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 1",
		"Awakened Recovery": "Cures Poison",
		"Awakened Equipment": "Temp Stamina Buff S",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] A Perfect Sphere [Chapter of Impetus]"
	},
	"Quake Crystal": {
		"Level": "9",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "1",
		"Awakened Material": "Awakened: Lightning +2",
		"Awakened Attack (Bombs)": "Awakened: Lightning +2",
		"Awakened Recovery": "Awakened: Lightning +2",
		"Awakened Equipment": "Awakened: Lightning +2",
		"Cat 1": "(Ore)",
		"Location": "Fellsgalaxen, Summer Breeze Road, Settler's Road, Old Kingdom Checkpoint, Hart Outpost, Trombe Plateau, Old Empire Border: Merulia Gate, Stalhang Castle, Arls National Mine, Old Blocked Mining Tunnel, Stone Coliseum, Rolling Winds Cavern, Forgotten Village, Ster Highlands, Scorched Wasteland, Mt. Velus, Runestone Nest, Stein Hill, Fire's Domain, Rolling Hill, Fellsgalaxen: Another",
		"Monster": "Taker, Ghost"
	},
	"Audra's Tail": {
		"Level": "9",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +1",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 1",
		"Awakened Recovery": "Temp Evasion Up Lvl 1",
		"Awakened Equipment": "SPD Up Lvl 1",
		"Cat 1": "(Animal Products)",
		"Cat 2": "(Threads)",
		"Location": "Trombe Plateau, Holy Slumbering Tree",
		"Monster": "Audra, Vulture, Garuda, White Hunter"
	},
	"Beast Fur": {
		"Level": "9",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 1",
		"Awakened Recovery": "Temp Critical Power Up Lvl 1",
		"Awakened Equipment": "Ignores Luck S",
		"Cat 1": "(Animal Products)",
		"Cat 2": "(Threads)",
		"Location": "Stalhang Castle, Stone Coliseum, Foggy Forest, Scorched Wasteland",
		"Monster": "Alumi Rabbit, Crystal Horn, Furball Rabbit, Snow Heart, Shadow Arch, Magi Mirage, Wolf, Jagd Wolf, Elder Fang, Audra, Ginger Bear, Blue Hands, Yellowsein, Wailing Ursidae"
	},
	"Forgotten Bone": {
		"Level": "9",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 1",
		"Awakened Recovery": "Temp Evasion Up Lvl 1",
		"Awakened Equipment": "Evasion Up Lvl 1",
		"Cat 1": "(Animal Products)",
		"Cat 2": "(Medicinal)",
		"Location": "Stalhang Castle, Stone Coliseum, Foggy Forest, Ster Highlands, Scorched Wasteland, Night's Domain",
		"Monster": "Crystal Horn, Wolf"
	},
	"Mudhead": {
		"Level": "9",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Awakened Quality Up +10",
		"Awakened Equipment": "Awakened Quality Up +10",
		"Cat 1": "(Mushrooms)",
		"Cat 2": "(Medicinal)",
		"Location": "Nearby Forest, Arls National Mine, Guiding Light Forest, Old Blocked Mining Tunnel, Modis Ruins, Foggy Forest, Mt. Velus, Large Conifer Forest"
	},
	"Winged Chakram": {
		"Level": "9",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 1",
		"Awakened Recovery": "Temp DEF Up Lvl 1",
		"Awakened Equipment": "Evasion Up Lvl 1",
		"Cat 1": "(Battle Rings)",
		"Acqusition": "** Event/Quest **"
	},
	"Barrel": {
		"WT": "300",
		"Stun": "75",
		"Range": "Single",
		"Level": "10",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Inflict Slowness Lvl 2",
		"Awakened Recovery": "Cures Slowness",
		"Awakened Equipment": "Enhance Items Lvl 2",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Barrel! [Chapter of Impetus]"
	},
	"Eiche": {
		"Level": "10",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 1",
		"Awakened Recovery": "Awakened Quality Up +10",
		"Awakened Equipment": "DEF Up Lvl 1",
		"Cat 1": "(Lumber)",
		"Location": "Fellsgalaxen, Empty Neighborhood, Eternal Spring, Nearby Forest, Guiding Light Forest, Foggy Forest, Forgotten Village, Neumont Forest, Izuko Beach, Fellsgalaxen: Another"
	},
	"Natural Fertilizer": {
		"Level": "10",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Awakened: Earth +2",
		"Awakened Recovery": "Awakened: Earth +2",
		"Awakened Equipment": "Awakened: Earth +2",
		"Cat 1": "(Clay)",
		"Cat 2": "(Fuel)",
		"Cat 3": "(Medicinal)",
		"Location": "Eternal Spring, Stalhang Castle, Handel Farm"
	},
	"Hidden Spell Page": {
		"Level": "10",
		"Fire": "0",
		"Ice": "2",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 1",
		"Awakened Recovery": "Cures Burns",
		"Awakened Equipment": "Awakened Quality Up +20",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Fuel)",
		"Location": "Old Kingdom Checkpoint, Old Empire Border: Merulia Gate, Orthogalaxen, Ancient Monastery",
		"Monster": "Scare Phantom"
	},
	"Bitter Worm": {
		"Level": "10",
		"Fire": "1",
		"Ice": "0",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened TP Increase +5",
		"Awakened Attack (Bombs)": "Awakened TP Increase +5",
		"Awakened Recovery": "Temp ACC Up Lvl 1",
		"Awakened Equipment": "ACC Up Lvl 1",
		"Cat 1": "(Bugs)",
		"Cat 2": "(Medicinal)",
		"Location": "Empty Neighborhood, Eternal Spring, Trombe Plateau, Nearby Forest, Golden Plains, Foggy Forest, Handel Farm"
	},
	"Pickaxe": {
		"Level": "10",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 2",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 2",
		"Awakened Equipment": "DEF Up Lvl 2",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Metals)",
		"Acqusition": "[Alchemyriddle] Basic Mining Methodology [Chapter of Succession]"
	},
	"Zettel": {
		"Level": "10",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Light. & Earth +1",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 1",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 2",
		"Awakened Equipment": "ATK Up Lvl 2",
		"Cat 1": "(Fuel)",
		"Location": "Ancient Monastery",
		"Acqusition": "Book 'Alchemy of Materials'"
	},
	"Fortune's Light": {
		"Level": "10",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 1",
		"Awakened Recovery": "Add MP Recovery Lvl 2",
		"Awakened Equipment": "Weaken Item Lvl 2",
		"Cat 1": "(Alchemy Staffs)",
		"Acqusition": "** Event/Quest **"
	},
	"Tempest Gear": {
		"Level": "10",
		"Fire": "1",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Inflict Slowness Lvl 1",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 2",
		"Awakened Equipment": "ACC Up Lvl 2",
		"Cat 1": "(Cannons)",
		"Acqusition": "** Event/Quest **"
	},
	"Divinity's Edge": {
		"Level": "10",
		"Fire": "1",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +2",
		"Awakened Attack (Bombs)": "Inflict Slowness Lvl 1",
		"Awakened Recovery": "Damage Reducer Lvl 2",
		"Awakened Equipment": "SPD Up Lvl 2",
		"Cat 1": "(Swords)",
		"Acqusition": "** Event/Quest **"
	},
	"Adventurer's Clothing": {
		"Level": "10",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 1",
		"Awakened Recovery": "Damage Reducer Lvl 1",
		"Awakened Equipment": "Skill Up Lvl 1",
		"Cat 1": "(Light Armor)",
		"Acqusition": "** Event/Quest **"
	},
	"Flower Symbol": {
		"Level": "10",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Awakened Quality Up +20",
		"Awakened Recovery": "Awakened Quality Up +20",
		"Awakened Equipment": "Awakened Quality Up +20",
		"Cat 1": "(Symbols)",
		"Acqusition": "** Event/Quest **"
	},
	"Fire Spirit Crystal Symbol": {
		"Level": "10",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Awakened: Fire +2",
		"Awakened Recovery": "Awakened: Fire +2",
		"Awakened Equipment": "Awakened: Fire +2",
		"Cat 1": "(Symbols)",
		"Acqusition": "** Event/Quest **"
	},
	"Crossment Symbol": {
		"Level": "10",
		"Fire": "2",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Ice +2",
		"Awakened Attack (Bombs)": "Awakened: Fire & Ice +2",
		"Awakened Recovery": "Awakened: Fire & Ice +2",
		"Awakened Equipment": "Awakened: Fire & Ice +2",
		"Cat 1": "(Symbols)",
		"Acqusition": "** Event/Quest **"
	},
	"Feather Symbol": {
		"Level": "10",
		"Fire": "0",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +2",
		"Awakened Attack (Bombs)": "Awakened: Lightning +2",
		"Awakened Recovery": "Awakened: Lightning +2",
		"Awakened Equipment": "Awakened: Lightning +2",
		"Cat 1": "(Symbols)",
		"Acqusition": "** Event/Quest **"
	},
	"Abyss Symbol": {
		"Level": "10",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire & Earth +1",
		"Awakened Attack (Bombs)": "Awakened: Fire & Earth +1",
		"Awakened Recovery": "Awakened: Ice & Light. +1",
		"Awakened Equipment": "Awakened: Ice & Light. +1",
		"Cat 1": "(Symbols)",
		"Acqusition": "** Event/Quest **"
	},
	"Torrent Symbol": {
		"Level": "10",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Awakened: Ice +2",
		"Awakened Recovery": "Awakened: Ice +2",
		"Awakened Equipment": "Awakened: Ice +2",
		"Cat 1": "(Symbols)",
		"Acqusition": "** Event/Quest **"
	},
	"Heart Symbol": {
		"Level": "10",
		"Fire": "2",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Awakened TP Increase +7",
		"Awakened Recovery": "Awakened TP Increase +7",
		"Awakened Equipment": "Awakened TP Increase +7",
		"Cat 1": "(Symbols)",
		"Acqusition": "** Event/Quest **"
	},
	"Golden Lion Symbol": {
		"Level": "10",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Awakened: Earth +2",
		"Awakened Recovery": "Awakened: Earth +2",
		"Awakened Equipment": "Awakened: Earth +2",
		"Cat 1": "(Symbols)",
		"Acqusition": "** Event/Quest **"
	},
	"Puni Drop": {
		"Level": "10",
		"Fire": "2",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Ice +1",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 2",
		"Awakened Recovery": "Add MP Recovery Lvl 2",
		"Awakened Equipment": "Max MP Up Lvl 2",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Conversing with Puni [Chapter of Impetus]"
	},
	"Danish": {
		"WT": "250",
		"Stun": "0",
		"Range": "Single",
		"Level": "11",
		"Fire": "1",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 1",
		"Awakened Recovery": "Add MP Recovery Lvl 2",
		"Awakened Equipment": "Weaken Item Lvl 1",
		"Cat 1": "(Food)",
		"Acqusition": "Book 'Alchemy of Materials'"
	},
	"Med Tree Root": {
		"Level": "11",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Awakened Quality Up +20",
		"Awakened Recovery": "Cures Poison",
		"Awakened Equipment": "DEF Up Lvl 1",
		"Cat 1": "(Plants)",
		"Cat 2": "(Medicinal)",
		"Location": "Eternal Spring, Nearby Forest, Guiding Light Forest, Golden Plains, Modis Ruins, Foggy Forest, Quelei Forest, Forgotten Village, Scorched Wasteland, Neumont Forest, Izuko Beach, Stein Hill, Night's Domain, Rolling Hill"
	},
	"Cotton Flower": {
		"Level": "11",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 1",
		"Awakened Recovery": "Temp DEF Up Lvl 1",
		"Awakened Equipment": "Avoid KO Lvl 1",
		"Cat 1": "(Threads)",
		"Cat 2": "(Plants)",
		"Location": "Trombe Plateau, Golden Plains, Ster Highlands, Neumont Forest, Izuko Beach, Stein Hill, Holy Slumbering Tree, Rolling Hill",
		"Monster": "Furball Rabbit"
	},
	"Some Egg": {
		"Level": "11",
		"Fire": "2",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Awakened Quality Up +20",
		"Awakened Recovery": "Awakened Quality Up +20",
		"Awakened Equipment": "Awakened Quality Up +20",
		"Cat 1": "(Fuel)",
		"Cat 2": "(Meat)",
		"Location": "Eternal Spring, Trombe Plateau, Nearby Forest, Guiding Light Forest, Holy Slumbering Tree, Rolling Hill"
	},
	"Swift Lizard Tail": {
		"Level": "11",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 1",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 1",
		"Awakened Equipment": "SPD Up Lvl 1",
		"Cat 1": "(Animal Products)",
		"Location": "Stalhang Castle, Stone Coliseum"
	},
	"Alchemy Yeast": {
		"Level": "11",
		"Fire": "2",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 1",
		"Awakened Recovery": "Cures Poison",
		"Awakened Equipment": "Evasion Up Lvl 1",
		"Cat 1": "(Spices)",
		"Monster": "Mellowshroom",
		"Acqusition": "[Alchemyriddle] Mushroom Magic [Chapter of Succession]"
	},
	"Pure Oil": {
		"Level": "11",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 1",
		"Awakened Recovery": "Cures Burns",
		"Awakened Equipment": "Add Ailments Resistance S",
		"Cat 1": "(Fuel)",
		"Acqusition": "Book 'Delightful Craft'"
	},
	"Shellper Horn": {
		"WT": "350",
		"Stun": "0",
		"Range": "All",
		"Level": "12",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire & Earth +1",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 3",
		"Awakened Recovery": "Cleanses Impurity S",
		"Awakened Equipment": "Temp Stamina Buff L",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Shell Melody [Chapter of Succession]"
	},
	"Nectar": {
		"WT": "500",
		"Stun": "0",
		"Range": "Single",
		"Level": "12",
		"Fire": "0",
		"Ice": "3",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 4",
		"Awakened Recovery": "Removes Ailments",
		"Awakened Equipment": "Add Ailments Resistance M",
		"Cat 1": "(Medicines)",
		"Acqusition": "Clear Alchemyriddle Chapter of Impetus"
	},
	"Fertile Soil": {
		"Level": "12",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire & Earth +1",
		"Awakened Attack (Bombs)": "Awakened: Fire & Earth +1",
		"Awakened Recovery": "Awakened: Fire & Earth +1",
		"Awakened Equipment": "Awakened: Fire & Earth +1",
		"Cat 1": "(Fuel)",
		"Cat 2": "(Clay)",
		"Location": "Settler's Road, Trombe Plateau"
	},
	"Balloon Fruit": {
		"Level": "12",
		"Fire": "1",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 1",
		"Awakened Recovery": "Temp ATK Up Lvl 2",
		"Awakened Equipment": "ATK Up Lvl 2",
		"Cat 1": "(Vapors)",
		"Cat 2": "(Plants)",
		"Location": "Trombe Plateau, Golden Plains, Neumont Forest, Stein Hill, Dusty Nail Canyon, Rolling Hill"
	},
	"Pendelook": {
		"Level": "12",
		"Fire": "0",
		"Ice": "2",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +1",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 2",
		"Awakened Recovery": "Temp ATK Up Lvl 1",
		"Awakened Equipment": "Avoid KO Lvl 1",
		"Cat 1": "(Mystery)",
		"Cat 2": "(Gemstones)",
		"Location": "Orthogalaxen, Old Blocked Mining Tunnel, Stone Coliseum, Rolling Winds Cavern, Ancient Monastery, Ster Highlands, Mt. Velus, Runestone Nest",
		"Monster": "Ghost, Scare Phantom, Deep Phantom, Twilight Phantom, Jagd Wolf"
	},
	"Isle Fish Filet": {
		"Level": "12",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened (Seafood)",
		"Awakened Attack (Bombs)": "Awakened (Seafood)",
		"Awakened Recovery": "Awakened (Seafood)",
		"Awakened Equipment": "Awakened (Seafood)",
		"Cat 1": "(Animal Products)",
		"Cat 2": "(Threads)",
		"Location": "Quelei Forest",
		"Monster": "Isle Fish, Giant Isle Fish, Striped Isle Fish, Huge Isle Fish"
	},
	"Eicheloa": {
		"Level": "12",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Awakened Quality Up +20",
		"Awakened Recovery": "Awakened Quality Up +20",
		"Awakened Equipment": "Awakened Quality Up +20",
		"Cat 1": "(Mushrooms)",
		"Cat 2": "(Vapors)",
		"Location": "Nearby Forest, Arls National Mine, Guiding Light Forest, Old Blocked Mining Tunnel, Modis Ruins, Foggy Forest, Mt. Velus, Large Conifer Forest, Rolling Hill",
		"Monster": "Roamingshroom, Runningshroom, Ladyshroom, Shiningshroom, Toxishroom, Mellowshroom"
	},
	"Artisan's Key": {
		"Level": "12",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 2",
		"Awakened Recovery": "Temp SPD Up Lvl 2",
		"Awakened Equipment": "ACC Up Lvl 2",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Metals)",
		"Acqusition": "[Alchemyriddle] Lord of the Locks: Part 1 [Chapter of Succession]"
	},
	"Tinc": {
		"Level": "12",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire & Earth +1",
		"Awakened Attack (Bombs)": "Awakened Quality Up +20",
		"Awakened Recovery": "Awakened: Fire & Earth +1",
		"Awakened Equipment": "Awakened Quality Up +20",
		"Cat 1": "(Weapon Materials)",
		"Cat 2": "(Metals)",
		"Monster": "Rock Punk",
		"Acqusition": "Book 'Delightful Craft'"
	},
	"Muffcot": {
		"Level": "12",
		"Fire": "0",
		"Ice": "1",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Awakened: Ice & Light. +1",
		"Awakened Recovery": "Awakened Quality Up +20",
		"Awakened Equipment": "Awakened: Ice & Light. +1",
		"Cat 1": "(Armor Materials)",
		"Cat 2": "(Cloth)",
		"Acqusition": "Book 'Delightful Craft'"
	},
	"Hay": {
		"Level": "12",
		"Fire": "2",
		"Ice": "0",
		"Elec": "1",
		"Earth": "3",
		"Awakened Material": "Awakened: Lightning +1",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 2",
		"Awakened Recovery": "Add MP Recovery Lvl 2",
		"Awakened Equipment": "Weaken Item Lvl 2",
		"Cat 1": "(Threads)",
		"Acqusition": "Book 'Alchemy of Materials'"
	},
	"Alchemy Activator": {
		"Level": "12",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Elemental Activator",
		"Cat 1": "(Boost)",
		"Acqusition": "[Alchemyriddle] Enhancing Synthesis (Basic) [Chapter of Destiny]"
	},
	"Captain's Long Sword": {
		"Level": "12",
		"Fire": "0",
		"Ice": "0",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened: Lightning +1",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 1",
		"Awakened Recovery": "Cures Seal",
		"Awakened Equipment": "Add Ailments Resistance S",
		"Cat 1": "(Long Swords)",
		"Acqusition": "** Event/Quest **"
	},
	"Beast Armor": {
		"Level": "12",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened TP Increase +5",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 1",
		"Awakened Recovery": "Temp SPD Up Lvl 2",
		"Awakened Equipment": "Temp Stamina Buff M",
		"Cat 1": "(Heavy Armor)",
		"Acqusition": "** Event/Quest **"
	},
	"Exorcism Incense": {
		"Level": "12",
		"Fire": "2",
		"Ice": "3",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 2",
		"Awakened Recovery": "HP Recovery M",
		"Awakened Equipment": "Max MP Up Lvl 3",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Vapors)",
		"Acqusition": "Event STR_LIBRARY_BUILD_010"
	},
	"Pseudo-sonne": {
		"Level": "12",
		"Fire": "0",
		"Ice": "2",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Awakened TP Increase +7",
		"Awakened Recovery": "Awakened Quality Up +20",
		"Awakened Equipment": "Awakened Quality Up +20",
		"Cat 1": "(Food)",
		"Cat 2": "(Medicinal)",
		"Acqusition": "** Event/Quest **"
	},
	"Adventurer's Accessories": {
		"Level": "12",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Frixell Family Recipes": {
		"Level": "12",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Totori's Dear Recipe": {
		"Level": "12",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Bomb Curry": {
		"WT": "250",
		"Stun": "0",
		"Range": "Single",
		"Level": "13",
		"Fire": "3",
		"Ice": "0",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Inflict Burns Lvl 2",
		"Awakened Recovery": "Temp ATK Up Lvl 2",
		"Awakened Equipment": "ATK Up Lvl 2",
		"Cat 1": "(Food)",
		"Acqusition": "[Alchemyriddle] An Acquired Taste [Chapter of Destiny]"
	},
	"Fuel Dirt": {
		"Level": "13",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire & Earth +1",
		"Awakened Attack (Bombs)": "Inflict Burns Lvl 2",
		"Awakened Recovery": "Cures Burns",
		"Awakened Equipment": "Add Ailments Resistance S",
		"Cat 1": "(Fuel)",
		"Cat 2": "(Clay)",
		"Location": "Stalhang Castle, Arls National Mine, Orthogalaxen, Old Blocked Mining Tunnel, Rolling Winds Cavern, Scorched Wasteland, Stein Hill, Dusty Nail Canyon, Fire's Domain"
	},
	"Green Bamboo": {
		"Level": "13",
		"Fire": "0",
		"Ice": "2",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Light. +1",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Temp ATK Up Lvl 2",
		"Awakened Equipment": "Awakened Quality Up +10",
		"Cat 1": "(Lumber)",
		"Cat 2": "(Plants)",
		"Location": "Eternal Spring, Guiding Light Forest, Neumont Forest, Izuko Beach"
	},
	"Elemental Fragment": {
		"Level": "13",
		"Fire": "2",
		"Ice": "2",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 3",
		"Awakened Recovery": "Cleanses Impurity M",
		"Awakened Equipment": "Add Ailments Resistance M",
		"Cat 1": "(Mystery)",
		"Cat 2": "(Elixirs)",
		"Location": "Fire's Domain",
		"Monster": "Blood Elemental, Ice Pixie, Echo Elemental, Fertility Spirit"
	},
	"Medicine Base": {
		"Level": "13",
		"Fire": "2",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 1",
		"Awakened Recovery": "HP Recovery S",
		"Awakened Equipment": "Skill Up Lvl 2",
		"Cat 1": "(Medicinal)",
		"Cat 2": "(Poisons)",
		"Acqusition": "Book 'Alchemy of Materials'"
	},
	"Wheel of Isyos": {
		"Level": "13",
		"Fire": "1",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +2",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 1",
		"Awakened Recovery": "Cures Slowness",
		"Awakened Equipment": "Evasion Up Lvl 2",
		"Cat 1": "(Battle Rings)",
		"Acqusition": "** Event/Quest **"
	},
	"Gnardi Ring": {
		"Level": "13",
		"Fire": "2",
		"Ice": "2",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 3",
		"Awakened Recovery": "Cures Blindness",
		"Awakened Equipment": "Temp Stamina Buff L",
		"Cat 1": "(Accessories)",
		"Acqusition": "[Alchemyriddle] Introduction to Accessory Creation [Chapter of Succession]"
	},
	"Appetite Away Pill": {
		"Level": "13",
		"Fire": "0",
		"Ice": "1",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 3",
		"Awakened Recovery": "Temp ATK Up Lvl 3",
		"Awakened Equipment": "Weaken Item Lvl 4",
		"Cat 1": "(Medicines)",
		"Cat 2": "(Medicinal)",
		"Acqusition": "Event STR_LIBRARY_BUILD_013"
	},
	"Spirit Garb Mark - Crimson": {
		"Level": "13",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)"
	},
	"Foamy Water": {
		"Level": "14",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 2",
		"Awakened Recovery": "Add MP Recovery Lvl 2",
		"Awakened Equipment": "Enhance Items Lvl 2",
		"Cat 1": "(Water)",
		"Cat 2": "(Vapors)",
		"Location": "Modis Ruins, Rolling Winds Cavern, Ancient Monastery, Forgotten Village, Handel Farm, Izuko Beach"
	},
	"Isle Amber": {
		"Level": "14",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Ice & Earth +1",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 1",
		"Awakened Recovery": "Cures Slowness",
		"Awakened Equipment": "Avoid KO Lvl 2",
		"Cat 1": "(Gemstones)",
		"Cat 2": "(Medicinal)",
		"Monster": "Isle Fish, Giant Isle Fish, Striped Isle Fish, Huge Isle Fish"
	},
	"Bomb Fish": {
		"Level": "14",
		"Fire": "2",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 2",
		"Awakened Recovery": "Cures Blindness",
		"Awakened Equipment": "ATK Up Lvl 2",
		"Cat 1": "(Seafood)",
		"Cat 2": "(Gunpowder)",
		"Location": "Guiding Light Forest, Quelei Forest, Handel Farm, Izuko Beach, Stein Hill, Dusty Nail Canyon",
		"Monster": "Yellowsein"
	},
	"Star Ladybug": {
		"Level": "14",
		"Fire": "0",
		"Ice": "2",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Light. +1",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 2",
		"Awakened Recovery": "HP Recovery S",
		"Awakened Equipment": "Evasion Up Lvl 2",
		"Cat 1": "(Bugs)",
		"Location": "Trombe Plateau, Nearby Forest, Golden Plains, Foggy Forest, Quelei Forest, Neumont Forest, Handel Farm, Izuko Beach"
	},
	"Fresh Meat": {
		"Level": "14",
		"Fire": "0",
		"Ice": "3",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +5",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 2",
		"Awakened Recovery": "Temp DEF Up Lvl 2",
		"Awakened Equipment": "Evasion Up Lvl 2",
		"Cat 1": "(Meat)",
		"Cat 2": "(Animal Products)",
		"Monster": "Furball Rabbit, Snow Heart, Shadow Arch, Magi Mirage, Piercing Unicorn, Jagd Wolf, Elder Fang, Garuda, White Hunter, Taker, Frozen Chiroptera, Pulse Wind"
	},
	"Dizzy Cap Spore": {
		"Level": "14",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened (Mushrooms)",
		"Awakened Attack (Bombs)": "Awakened (Mushrooms)",
		"Awakened Recovery": "Awakened (Mushrooms)",
		"Awakened Equipment": "Awakened (Mushrooms)",
		"Cat 1": "(Medicinal)",
		"Cat 2": "(Poisons)",
		"Cat 3": "(Spices)",
		"Location": "Nearby Forest, Arls National Mine, Guiding Light Forest, Old Blocked Mining Tunnel, Modis Ruins, Foggy Forest, Neumont Forest, Mt. Velus, Night's Domain, Large Conifer Forest, Rolling Hill",
		"Monster": "Ladyshroom"
	},
	"Wicked Bone": {
		"Level": "14",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Fire +1",
		"Awakened Attack (Bombs)": "Inflict Poison Lvl 2",
		"Awakened Recovery": "Cures Slowness",
		"Awakened Equipment": "ACC Up Lvl 2",
		"Cat 1": "(Poisons)",
		"Cat 2": "(Animal Products)",
		"Location": "Stone Coliseum, Night's Domain",
		"Monster": "Aphostol, Black Demon, Thoth, Eternal Darkness Demon"
	},
	"Handmade Basket": {
		"Level": "14",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 3",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 3",
		"Awakened Equipment": "Temp Stamina Buff L",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Threads)",
		"Acqusition": "[Alchemyriddle] So You Want to Gather More? [Chapter of Destiny]"
	},
	"Alchemy Coal": {
		"Level": "14",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 2",
		"Awakened Recovery": "Temp ATK Up Lvl 3",
		"Awakened Equipment": "Skill Up Lvl 3",
		"Cat 1": "(Gunpowder)",
		"Acqusition": "[Alchemyriddle] Growth of an Alchemist [Chapter of Destiny]"
	},
	"Minstrel Book": {
		"Level": "14",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +10",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 3",
		"Awakened Recovery": "HP Recovery M",
		"Awakened Equipment": "Enhance Items Lvl 2",
		"Cat 1": "ITEM_CATEGORY_ALCHEMY_BOOK"
	},
	"Angel Charm": {
		"Level": "14",
		"Fire": "0",
		"Ice": "2",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Light. +2",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 3",
		"Awakened Recovery": "Temp Critical Power Up Lvl 3",
		"Awakened Equipment": "Add Ailments Resistance M",
		"Cat 1": "(Accessories)",
		"Location": "Golden Plains",
		"Acqusition": "[Alchemyriddle] Angel's Providence [Chapter of Destiny]"
	},
	"Thunder Water": {
		"Level": "15",
		"Fire": "0",
		"Ice": "3",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +2",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 2",
		"Awakened Recovery": "HP Recovery S",
		"Awakened Equipment": "Weaken Item Lvl 2",
		"Cat 1": "(Water)",
		"Location": "Orthogalaxen, Modis Ruins, Rolling Winds Cavern, Ancient Monastery, Forgotten Village, Large Conifer Forest"
	},
	"Ointment Water": {
		"Level": "15",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Awakened Quality Up +10",
		"Awakened Recovery": "Temp EXP Up Lvl 1",
		"Awakened Equipment": "Skill Up Lvl 1",
		"Cat 1": "(Water)",
		"Cat 2": "(Medicinal)",
		"Cat 3": "(Elixirs)",
		"Location": "Eternal Spring"
	},
	"Winding Grass": {
		"Level": "15",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 1",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 1",
		"Awakened Equipment": "Add Ailments Resistance XS",
		"Cat 1": "(Threads)",
		"Cat 2": "(Plants)",
		"Location": "Golden Plains, Modis Ruins, Foggy Forest, Forgotten Village, Scorched Wasteland, Izuko Beach, Stein Hill, Night's Domain, Rolling Hill"
	},
	"Professional Fishing Rod": {
		"Level": "15",
		"Fire": "0",
		"Ice": "3",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 2",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 2",
		"Awakened Equipment": "ATK Up Lvl 2",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Lumber)",
		"Acqusition": "[Alchemyriddle] Professional Fishing Rod [Chapter of Destiny]"
	},
	"Cosmos Code": {
		"Level": "15",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 3",
		"Awakened Recovery": "Temp ACC Up Lvl 3",
		"Awakened Equipment": "Weaken Item Lvl 2",
		"Cat 1": "ITEM_CATEGORY_RAPIER"
	},
	"Nightshade": {
		"Level": "15",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Ice & Earth +1",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 2",
		"Awakened Recovery": "Temp Evasion Up Lvl 5",
		"Awakened Equipment": "ATK Up Lvl 2",
		"Cat 1": "(Light Armor)",
		"Acqusition": "** Event/Quest **"
	},
	"Barrel Bomb": {
		"WT": "500",
		"Stun": "80",
		"Range": "Normal Range",
		"Level": "16",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 2",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 2",
		"Awakened Equipment": "Ignores Luck M",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Explosive Textbook [Chapter of Destiny]"
	},
	"Water Tree Fruit": {
		"Level": "16",
		"Fire": "0",
		"Ice": "3",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 2",
		"Awakened Recovery": "Awakened Quality Up +30",
		"Awakened Equipment": "Temp Stamina Buff M",
		"Cat 1": "(Plants)",
		"Cat 2": "(Spices)",
		"Cat 3": "(Water)",
		"Location": "Modis Ruins, Quelei Forest, Handel Farm, Izuko Beach, Stein Hill, Large Conifer Forest, Rolling Hill"
	},
	"Tar Fruit": {
		"Level": "16",
		"Fire": "3",
		"Ice": "0",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +5",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 2",
		"Awakened Recovery": "Cures Seal",
		"Awakened Equipment": "Skill Up Lvl 2",
		"Cat 1": "(Fuel)",
		"Cat 2": "(Plants)",
		"Location": "Orthogalaxen, Golden Plains, Ancient Monastery, Neumont Forest, Holy Slumbering Tree"
	},
	"Blazing Ice Element": {
		"Level": "16",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Exchange: Fire/Ice",
		"Cat 1": "(Boost)",
		"Location": "Modis Ruins, Scorched Wasteland, Runestone Nest, Fire's Domain"
	},
	"Blazing Thunder Element": {
		"Level": "16",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Exchange: Fire/Lightning",
		"Cat 1": "(Boost)",
		"Location": "Modis Ruins, Ster Highlands, Runestone Nest, Fire's Domain"
	},
	"Blazing Earth Element": {
		"Level": "16",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Exchange: Fire/Earth",
		"Cat 1": "(Boost)",
		"Location": "Modis Ruins, Scorched Wasteland, Fire's Domain"
	},
	"Freezing Thunder Element": {
		"Level": "16",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Exchange: Ice/Lightning",
		"Cat 1": "(Boost)",
		"Location": "Modis Ruins, Quelei Forest, Runestone Nest, Fire's Domain"
	},
	"Freezing Earth Element": {
		"Level": "16",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Exchange: Ice/Earth",
		"Cat 1": "(Boost)",
		"Location": "Modis Ruins, Quelei Forest, Runestone Nest, Fire's Domain"
	},
	"Crackling Earth Element": {
		"Level": "16",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Exchange: Lightning/Earth",
		"Cat 1": "(Boost)",
		"Location": "Modis Ruins, Ster Highlands, Runestone Nest, Fire's Domain"
	},
	"Tonic": {
		"Level": "16",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Ice & Earth +1",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 2",
		"Awakened Recovery": "Cures Poison",
		"Awakened Equipment": "Ignores Luck M",
		"Cat 1": "(Medicines)",
		"Acqusition": "[Alchemyriddle] For More Efficient Gathering [Chapter of Advice]"
	},
	"Tanning Liquid": {
		"Level": "16",
		"Fire": "3",
		"Ice": "2",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Earth +1",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 2",
		"Awakened Recovery": "Cures Blindness",
		"Awakened Equipment": "Add Ailments Resistance XS",
		"Cat 1": "(Poisons)",
		"Acqusition": "Book 'Leather Production'"
	},
	"Pure Poison": {
		"Level": "16",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 3",
		"Awakened Recovery": "Cleanses Impurity L",
		"Awakened Equipment": "Max MP Up Lvl 3",
		"Cat 1": "(Poisons)",
		"Monster": "Violet Fang",
		"Acqusition": "[Alchemyriddle] 100% Pure Poison [Chapter of Advice]"
	},
	"Sulfite": {
		"Level": "16",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute +: Fire",
		"Cat 1": "(Boost)",
		"Acqusition": "[Alchemyriddle] Enhancing Synthesis (Fire/Ice) [Chapter of Advice]"
	},
	"Super Cooling Agent": {
		"Level": "16",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute +: Ice",
		"Cat 1": "(Boost)",
		"Acqusition": "[Alchemyriddle] Enhancing Synthesis (Fire/Ice) [Chapter of Advice]"
	},
	"Fessellmeer": {
		"Level": "16",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 1",
		"Awakened Recovery": "Temp ACC Up Lvl 2",
		"Awakened Equipment": "DEF Up Lvl 2",
		"Cat 1": "(Anchors)",
		"Acqusition": "** Event/Quest **"
	},
	"Green Glow Symbol": {
		"Level": "16",
		"Fire": "0",
		"Ice": "0",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +3",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 3",
		"Awakened Recovery": "Temp EXP Up Lvl 3",
		"Awakened Equipment": "SPD Up Lvl 3",
		"Cat 1": "(Symbols)",
		"Acqusition": "[Alchemyriddle] Enshrouded in Light (Green/Red) [Chapter of Advice]"
	},
	"Red Ray Symbol": {
		"Level": "16",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +3",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 3",
		"Awakened Recovery": "Removes Ailments",
		"Awakened Equipment": "ATK Up Lvl 3",
		"Cat 1": "(Symbols)",
		"Acqusition": "[Alchemyriddle] Enshrouded in Light (Green/Red) [Chapter of Advice]"
	},
	"Healing Bell": {
		"WT": "300",
		"Stun": "0",
		"Range": "All",
		"Level": "17",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire & Earth +1",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 1",
		"Awakened Recovery": "Cures Sleep",
		"Awakened Equipment": "Avoid KO Lvl 2",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Shelf Full of Medicines [Chapter of Advice]"
	},
	"Secret Remedy": {
		"WT": "300",
		"Stun": "0",
		"Range": "Single",
		"Level": "17",
		"Fire": "2",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +5",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 2",
		"Awakened Recovery": "Temp EXP Up Lvl 2",
		"Awakened Equipment": "Max MP Up Lvl 2",
		"Cat 1": "(Medicines)",
		"Acqusition": "[Alchemyriddle] Shelf Full of Medicines [Chapter of Advice]"
	},
	"Glow Grass": {
		"Level": "17",
		"Fire": "3",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 1",
		"Awakened Recovery": "Damage Reducer Lvl 2",
		"Awakened Equipment": "Ignores Luck M",
		"Cat 1": "(Plants)",
		"Cat 2": "(Poisons)",
		"Location": "Fellsgalaxen, Modis Ruins, Quelei Forest, Handel Farm, Izuko Beach, Stein Hill, Large Conifer Forest, Rolling Hill, Fellsgalaxen: Another"
	},
	"Swirly Shell": {
		"Level": "17",
		"Fire": "0",
		"Ice": "1",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 2",
		"Awakened Recovery": "HP Recovery S",
		"Awakened Equipment": "Temp Stamina Buff M",
		"Cat 1": "(Seafood)",
		"Cat 2": "(Ore)",
		"Location": "Orthogalaxen, Golden Plains, Handel Farm, Night's Domain, Large Conifer Forest",
		"Monster": "Giant Isle Fish"
	},
	"Hyper Particle": {
		"Level": "17",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute +: Lightning",
		"Cat 1": "(Boost)",
		"Acqusition": "[Alchemyriddle] Enhancing Synthesis (Lightning/Earth) [Chapter of Advice]"
	},
	"Sticky Resin": {
		"Level": "17",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute +: Earth",
		"Cat 1": "(Boost)",
		"Acqusition": "[Alchemyriddle] Enhancing Synthesis (Lightning/Earth) [Chapter of Advice]"
	},
	"Sunburst Staff": {
		"Level": "17",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 2",
		"Awakened Recovery": "Add MP Recovery Lvl 3",
		"Awakened Equipment": "Max MP Up Lvl 3",
		"Cat 1": "(Decorative Staffs)",
		"Acqusition": "** Event/Quest **"
	},
	"Mercurius's Eye": {
		"Level": "17",
		"Fire": "0",
		"Ice": "2",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 3",
		"Awakened Recovery": "Removes Ailments",
		"Awakened Equipment": "ACC Up Lvl 5",
		"Cat 1": "(Accessories)",
		"Acqusition": "Book 'Adventurer's Accessories'"
	},
	"How to Make Exorcism Incense": {
		"Level": "17",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Blessed Stone": {
		"Level": "18",
		"Fire": "0",
		"Ice": "3",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 3",
		"Awakened Recovery": "Cleanses Impurity M",
		"Awakened Equipment": "Add Ailments Resistance M",
		"Cat 1": "(Mystery)",
		"Cat 2": "(Ore)",
		"Location": "Old Blocked Mining Tunnel, Stone Coliseum, Ster Highlands, Mt. Velus, Night's Domain",
		"Monster": "Striped Isle Fish, Fertility Spirit"
	},
	"Wicked Fang": {
		"Level": "18",
		"Fire": "3",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +5",
		"Awakened Attack (Bombs)": "Inflict Poison Lvl 3",
		"Awakened Recovery": "Temp Critical Power Up Lvl 2",
		"Awakened Equipment": "Max MP Up Lvl 2",
		"Cat 1": "(Poisons)",
		"Cat 2": "(Animal Products)",
		"Location": "Night's Domain",
		"Monster": "Elder Fang, Violet Fang, Shadow Bat, Pulse Wind, Silent Killer, Machete Wing, Shadow Arch, Frozen Chiroptera"
	},
	"Warp Gate": {
		"Level": "18",
		"Fire": "1",
		"Ice": "1",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +3",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 3",
		"Awakened Recovery": "Temp Evasion Up Lvl 4",
		"Awakened Equipment": "Avoid KO Lvl 3",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "Clear Alchemyriddle Chapter of Destiny"
	},
	"Ster Metal": {
		"Level": "18",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Awakened Quality Up +30",
		"Awakened Recovery": "Awakened: Fire +2",
		"Awakened Equipment": "Awakened Quality Up +30",
		"Cat 1": "(Weapon Materials)",
		"Cat 2": "(Metals)",
		"Monster": "Rock Punk",
		"Acqusition": "Book 'Secrets of Master Blacksmith'"
	},
	"Nylonfeather": {
		"Level": "18",
		"Fire": "0",
		"Ice": "1",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Awakened: Lightning +2",
		"Awakened Recovery": "Awakened Quality Up +30",
		"Awakened Equipment": "Awakened: Lightning +2",
		"Cat 1": "(Armor Materials)",
		"Cat 2": "(Cloth)",
		"Acqusition": "Book 'Secrets of Master Blacksmith'"
	},
	"Wheel of Fortune Tarot": {
		"Level": "18",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 1",
		"Awakened Recovery": "HP Recovery S",
		"Awakened Equipment": "Temp Stamina Buff M",
		"Cat 1": "(Charms)",
		"Acqusition": "** Event/Quest **"
	},
	"Battle Scarf": {
		"Level": "18",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire +3",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 2",
		"Awakened Recovery": "Temp ATK Up Lvl 3",
		"Awakened Equipment": "ATK Up Lvl 3",
		"Cat 1": "(Accessories)",
		"Acqusition": "[Alchemyriddle] Symbol of Justice, Fluttering in the Wind [Chapter of Advice]"
	},
	"Brave Sigil": {
		"Level": "18",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 3",
		"Awakened Recovery": "Temp EXP Up Lvl 3",
		"Awakened Equipment": "ATK Up Lvl 3",
		"Cat 1": "(Accessories)",
		"Acqusition": "Book 'Adventurer's Accessories'"
	},
	"Appetite Boost Pill": {
		"Level": "18",
		"Fire": "2",
		"Ice": "1",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +5",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 3",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 2",
		"Awakened Equipment": "ATK Up Lvl 2",
		"Cat 1": "(Medicines)",
		"Cat 2": "(Medicinal)",
		"Acqusition": "Event STR_LIBRARY_BUILD_014"
	},
	"Haute Fashion": {
		"Level": "18",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "Chest - Ancient Monastery"
	},
	"Merulua Fusion Recipe": {
		"Level": "18",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Hagel's Diary": {
		"Level": "18",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "Ficus Events"
	},
	"Spirit Garb Mark - Azure": {
		"Level": "18",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)"
	},
	"Magic Sword": {
		"WT": "200",
		"Stun": "60",
		"Range": "Single",
		"Level": "19",
		"Fire": "1",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +2",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 3",
		"Awakened Recovery": "Cures Curse",
		"Awakened Equipment": "Skill Up Lvl 3",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Quiet Smile of the Enchanted Sword [Chapter of Advice]"
	},
	"Dark Water": {
		"WT": "300",
		"Stun": "0",
		"Range": "Single",
		"Level": "19",
		"Fire": "1",
		"Ice": "2",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened TP Increase +10",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 2",
		"Awakened Recovery": "Temp Critical Power Up Lvl 3",
		"Awakened Equipment": "Avoid KO Lvl 3",
		"Cat 1": "(Medicines)",
		"Acqusition": "[Alchemyriddle] Poison among Poisons [Chapter of Advice]"
	},
	"Lotus": {
		"Level": "19",
		"Fire": "0",
		"Ice": "5",
		"Elec": "0",
		"Earth": "5",
		"Awakened Material": "Awakened (Poisons)",
		"Awakened Attack (Bombs)": "Awakened (Poisons)",
		"Awakened Recovery": "Awakened (Poisons)",
		"Awakened Equipment": "Awakened (Poisons)",
		"Cat 1": "(Plants)",
		"Cat 2": "(Elixirs)",
		"Location": "Quelei Forest"
	},
	"Metal Ore": {
		"Level": "19",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Lightning +2",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 3",
		"Awakened Recovery": "Temp ACC Up Lvl 3",
		"Awakened Equipment": "Temp Stamina Buff L",
		"Cat 1": "(Ore)",
		"Location": "Arls National Mine, Old Blocked Mining Tunnel, Rolling Winds Cavern, Forgotten Village, Ster Highlands, Scorched Wasteland, Mt. Velus, Runestone Nest, Stein Hill, Night's Domain, Dusty Nail Canyon, Fire's Domain, Rolling Hill",
		"Monster": "Rock Punk"
	},
	"Magic Paint": {
		"Level": "19",
		"Fire": "3",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 3",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 2",
		"Awakened Equipment": "ACC Up Lvl 2",
		"Cat 1": "(Mystery)",
		"Cat 2": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Growth of an Alchemist (2) [Chapter of Advice]"
	},
	"Runestone": {
		"Level": "19",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 2",
		"Awakened Recovery": "Damage Reducer Lvl 3",
		"Awakened Equipment": "Max MP Up Lvl 3",
		"Cat 1": "(Accessories)",
		"Location": "Handel Farm",
		"Acqusition": "Book 'Adventurer's Accessories'"
	},
	"Demon Canon": {
		"WT": "500",
		"Stun": "35",
		"Range": "Single",
		"Level": "20",
		"Fire": "1",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Ice +3",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 3",
		"Awakened Recovery": "Temp ACC Up Lvl 2",
		"Awakened Equipment": "ACC Up Lvl 2",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Sky-Rending Blast [Chapter of Advice]"
	},
	"Sunny Crystal": {
		"Level": "20",
		"Fire": "2",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 1",
		"Awakened Recovery": "Temp ATK Up Lvl 2",
		"Awakened Equipment": "Skill Up Lvl 2",
		"Cat 1": "(Ore)",
		"Cat 2": "(Gemstones)",
		"Location": "Stone Coliseum, Rolling Winds Cavern, Scorched Wasteland, Neumont Forest, Mt. Velus, Runestone Nest, Night's Domain, Fire's Domain",
		"Monster": "Gold Puni"
	},
	"Twinkle Flower": {
		"Level": "20",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Reversed: Fire",
		"Cat 1": "(Boost)",
		"Location": "Rolling Winds Cavern, Runestone Nest"
	},
	"Sacred Water": {
		"Level": "20",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Doubled: Ice",
		"Cat 1": "(Boost)",
		"Location": "Ancient Monastery"
	},
	"Distilled Water": {
		"Level": "20",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened (Water)",
		"Awakened Attack (Bombs)": "Awakened Quality Up +30",
		"Awakened Recovery": "Awakened TP Increase +7",
		"Awakened Equipment": "Awakened Quality Up +30",
		"Cat 1": "(Water)",
		"Acqusition": "Book 'You Can Do This'"
	},
	"Tanned Leather": {
		"Level": "20",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 3",
		"Awakened Recovery": "Temp DEF Up Lvl 3",
		"Awakened Equipment": "Temp Stamina Buff M",
		"Cat 1": "(Animal Products)",
		"Acqusition": "Book 'Leather Production'"
	},
	"Rustic Gloves": {
		"Level": "20",
		"Fire": "1",
		"Ice": "0",
		"Elec": "3",
		"Earth": "1",
		"Awakened Material": "Awakened: Lightning +3",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 3",
		"Awakened Recovery": "Temp DEF Up Lvl 4",
		"Awakened Equipment": "Faint Value Up Lvl 4",
		"Cat 1": "(Metals)",
		"Acqusition": "Event STR_LIBRARY_BUILD_012"
	},
	"Operation Manual": {
		"Level": "20",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Mont Blanc": {
		"WT": "250",
		"Stun": "0",
		"Range": "Single",
		"Level": "21",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 3",
		"Awakened Recovery": "Temp Critical Power Up Lvl 3",
		"Awakened Equipment": "Temp Stamina Buff L",
		"Cat 1": "(Food)",
		"Acqusition": "Book 'You Can Do This'"
	},
	"Mystical Ankh": {
		"WT": "400",
		"Stun": "0",
		"Range": "All",
		"Level": "21",
		"Fire": "0",
		"Ice": "1",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened: Ice & Earth +1",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 3",
		"Awakened Recovery": "Cures Seal",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Object Imbued with Divine Power [Chapter of Reunion]"
	},
	"Glow Sand": {
		"Level": "21",
		"Fire": "0",
		"Ice": "2",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +2",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 2",
		"Awakened Recovery": "Temp SPD Up Lvl 2",
		"Awakened Equipment": "Skill Up Lvl 2",
		"Cat 1": "(Gemstones)",
		"Cat 2": "(Ore)",
		"Location": "Old Blocked Mining Tunnel, Stone Coliseum, Rolling Winds Cavern, Forgotten Village, Ster Highlands, Mt. Velus, Runestone Nest, Holy Slumbering Tree",
		"Monster": "Gold Puni, Shiningshroom"
	},
	"Gold Puniball": {
		"Level": "21",
		"Fire": "3",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened (Gunpowder)",
		"Awakened Attack (Bombs)": "Awakened (Gunpowder)",
		"Awakened Recovery": "Awakened (Gunpowder)",
		"Awakened Equipment": "Awakened (Gunpowder)",
		"Cat 1": "(Puniballs)",
		"Cat 2": "(Gemstones)",
		"Monster": "Gold Puni, Ultra Puni, Marshall Puni"
	},
	"Magma Launcher": {
		"Level": "21",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +3",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 2",
		"Awakened Recovery": "Cures Burns",
		"Awakened Equipment": "ACC Up Lvl 2",
		"Cat 1": "(Cannons)",
		"Acqusition": "** Event/Quest **"
	},
	"Arch Anatomis": {
		"Level": "21",
		"Fire": "2",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 4",
		"Awakened Recovery": "Removes Ailments",
		"Awakened Equipment": "Max MP Up Lvl 3",
		"Cat 1": "ITEM_CATEGORY_ALCHEMY_BOOK"
	},
	"Blue Beam Symbol": {
		"Level": "21",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +3",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 3",
		"Awakened Recovery": "Damage Reducer Lvl 3",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Symbols)",
		"Acqusition": "[Alchemyriddle] Enshrouded in Light (Blue/Ice) [Chapter of Reunion]"
	},
	"Glacier Symbol": {
		"Level": "21",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Ice +3",
		"Awakened Attack (Bombs)": "Inflict Slowness Lvl 5",
		"Awakened Recovery": "Temp DEF Up Lvl 4",
		"Awakened Equipment": "DEF Up Lvl 4",
		"Cat 1": "(Symbols)",
		"Acqusition": "[Alchemyriddle] Enshrouded in Light (Blue/Ice) [Chapter of Reunion]"
	},
	"Omega Craft": {
		"WT": "300",
		"Stun": "60",
		"Range": "Normal Range",
		"Level": "22",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 3",
		"Awakened Recovery": "Damage Reducer Lvl 3",
		"Awakened Equipment": "ACC Up Lvl 3",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Powered-Up Spike Bomb [Chapter of Reunion]"
	},
	"Bear Oil": {
		"Level": "22",
		"Fire": "0",
		"Ice": "2",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 2",
		"Awakened Recovery": "ATK Up Lvl 3",
		"Awakened Equipment": "Temp Stamina Buff M",
		"Cat 1": "(Fuel)",
		"Monster": "Ginger Bear, Blue Hands, Yellowsein, Wailing Ursidae"
	},
	"Mountain Pearl": {
		"Level": "22",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 2",
		"Awakened Recovery": "Temp EXP Up Lvl 2",
		"Awakened Equipment": "Enhance Items Lvl 2",
		"Cat 1": "(Gemstones)",
		"Location": "Arls National Mine, Ster Highlands"
	},
	"Poison Dragonfly": {
		"Level": "22",
		"Fire": "2",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Inflict Poison Lvl 4",
		"Awakened Recovery": "Cleanses Impurity S",
		"Awakened Equipment": "Add Ailments Resistance S",
		"Cat 1": "(Bugs)",
		"Cat 2": "(Poisons)",
		"Location": "Foggy Forest, Neumont Forest"
	},
	"Living Rope": {
		"Level": "22",
		"Fire": "1",
		"Ice": "0",
		"Elec": "4",
		"Earth": "2",
		"Awakened Material": "Awakened: Lightning +3",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 4",
		"Awakened Recovery": "Temp SPD Up Lvl 3",
		"Awakened Equipment": "ACC Up Lvl 3",
		"Cat 1": "(Threads)",
		"Acqusition": "[Alchemyriddle] The Mysterious Moving Rope [Chapter of Reunion]"
	},
	"Elemental Breath": {
		"Level": "22",
		"Fire": "2",
		"Ice": "2",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Awakened: Ice +2",
		"Awakened Recovery": "Awakened: Lightning +2",
		"Awakened Equipment": "Awakened: Earth +2",
		"Cat 1": "(Alchemy Staffs)",
		"Acqusition": "** Event/Quest **"
	},
	"Runeblade": {
		"Level": "22",
		"Fire": "0",
		"Ice": "1",
		"Elec": "1",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 2",
		"Awakened Recovery": "Temp ACC Up Lvl 3",
		"Awakened Equipment": "Weaken Item Lvl 2",
		"Cat 1": "(Long Swords)",
		"Acqusition": "** Event/Quest **"
	},
	"Stim Leather Mail": {
		"Level": "22",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Ice & Earth +1",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 3",
		"Awakened Recovery": "Temp DEF Up Lvl 3",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Heavy Armor)",
		"Acqusition": "** Event/Quest **"
	},
	"Burning Ore": {
		"Level": "22",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Rorona's Pie Recipe": {
		"Level": "22",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Soul Absorbing Gourd": {
		"WT": "250",
		"Stun": "0",
		"Range": "Single",
		"Level": "23",
		"Fire": "2",
		"Ice": "1",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +3",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 4",
		"Awakened Recovery": "Temp EXP Up Lvl 3",
		"Awakened Equipment": "Avoid KO Lvl 4",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Soul-Devouring Gourd [Chapter of Truth]"
	},
	"Destroyed Grimoire": {
		"Level": "23",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Awakened Quality Up +30",
		"Awakened Recovery": "Awakened TP Increase +7",
		"Awakened Equipment": "Awakened Quality Up +30",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Fuel)",
		"Location": "Ancient Monastery, Dusty Nail Canyon"
	},
	"Mandrake Elixir": {
		"Level": "23",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +10",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 2",
		"Awakened Recovery": "Temp ACC Up Lvl 2",
		"Awakened Equipment": "Weaken Item Lvl 2",
		"Cat 1": "(Poisons)",
		"Cat 2": "(Plants)",
		"Location": "Orthogalaxen, Quelei Forest, Forgotten Village, Night's Domain, Large Conifer Forest"
	},
	"Boa Venom Gland": {
		"Level": "23",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "5",
		"Awakened Material": "Awakened (Poisons)",
		"Awakened Attack (Bombs)": "Inflict Poison Lvl 4",
		"Awakened Recovery": "Add MP Recovery Lvl 3",
		"Awakened Equipment": "Max MP Up Lvl 3",
		"Cat 1": "(Poisons)",
		"Cat 2": "(Animal Products)",
		"Location": "Foggy Forest, Ancient Monastery",
		"Monster": "Elder Fang"
	},
	"Superb Supplement White": {
		"Level": "23",
		"Fire": "0",
		"Ice": "3",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Awakened Quality Up +30",
		"Awakened Recovery": "Awakened Quality Up +30",
		"Awakened Equipment": "Awakened Quality Up +30",
		"Cat 1": "(Supplements)",
		"Monster": "Machina of God",
		"Acqusition": "[Alchemyriddle] Black and White Supplements [Chapter of Reunion]"
	},
	"Superb Supplement Black": {
		"Level": "23",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Awakened TP Increase +7",
		"Awakened Recovery": "Awakened TP Increase +7",
		"Awakened Equipment": "Awakened TP Increase +7",
		"Cat 1": "(Supplements)",
		"Acqusition": "[Alchemyriddle] Black and White Supplements [Chapter of Reunion]"
	},
	"Blinding Radiance": {
		"Level": "23",
		"Fire": "0",
		"Ice": "2",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Light. +1",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 2",
		"Awakened Recovery": "Temp Critical Power Up Lvl 2",
		"Awakened Equipment": "ACC Up Lvl 2",
		"Cat 1": "(Swords)",
		"Acqusition": "** Event/Quest **"
	},
	"Spirit Robe": {
		"Level": "23",
		"Fire": "1",
		"Ice": "2",
		"Elec": "1",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 3",
		"Awakened Recovery": "Cures Slowness",
		"Awakened Equipment": "Add Ailments Resistance M",
		"Cat 1": "(Light Armor)",
		"Acqusition": "** Event/Quest **"
	},
	"Eraezyko Charm": {
		"Level": "23",
		"Fire": "0",
		"Ice": "2",
		"Elec": "3",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 3",
		"Awakened Recovery": "Temp Evasion Up Lvl 3",
		"Awakened Equipment": "Evasion Up Lvl 3",
		"Cat 1": "(Fuel)",
		"Cat 2": "(Mystery)",
		"Acqusition": "[Alchemyriddle] On Exorcism Strategies [Chapter of Reunion]"
	},
	"Special Meat": {
		"WT": "300",
		"Stun": "0",
		"Range": "Single",
		"Level": "24",
		"Fire": "3",
		"Ice": "0",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened (Meat)",
		"Awakened Attack (Bombs)": "Inflict Burns Lvl 3",
		"Awakened Recovery": "Awakened (Meat)",
		"Awakened Equipment": "Skill Up Lvl 3",
		"Cat 1": "(Food)",
		"Acqusition": "[Alchemyriddle] Wild Meat Dish [Chapter of Reunion]"
	},
	"Wispstone": {
		"Level": "24",
		"Fire": "2",
		"Ice": "0",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Light. +2",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 3",
		"Awakened Recovery": "Temp EXP Up Lvl 3",
		"Awakened Equipment": "Avoid KO Lvl 3",
		"Cat 1": "(Gemstones)",
		"Cat 2": "(Mystery)",
		"Location": "Neumont Forest, Night's Domain",
		"Monster": "Deep Phantom, Twilight Phantom, Blood Elemental, Echo Elemental, Machina of God, Magi Mirage, Silent Killer, Fertility Spirit"
	},
	"Living Fossil": {
		"Level": "24",
		"Fire": "4",
		"Ice": "0",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened (Water)",
		"Awakened Attack (Bombs)": "Awakened (Water)",
		"Awakened Recovery": "Awakened (Water)",
		"Awakened Equipment": "Awakened (Water)",
		"Cat 1": "(Seafood)",
		"Location": "Stein Hill, Dusty Nail Canyon",
		"Monster": "Old Dragon Emperor, Dragon Spirit of Oblivion, Huge Isle Fish"
	},
	"Serenity Flower": {
		"Level": "24",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened TP Increase +3",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 2",
		"Awakened Recovery": "HP Recovery S",
		"Awakened Equipment": "Add Ailments Resistance S",
		"Cat 1": "(Medicinal)",
		"Cat 2": "(Elixirs)",
		"Location": "Quelei Forest, Ster Highlands, Handel Farm, Izuko Beach, Stein Hill, Large Conifer Forest, Holy Slumbering Tree"
	},
	"Mysterious Disk": {
		"Level": "24",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Reversed: Lightning",
		"Cat 1": "(Boost)",
		"Location": "Forgotten Village, Dusty Nail Canyon"
	},
	"Mysterious Spice": {
		"Level": "24",
		"Fire": "3",
		"Ice": "0",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened: Light. & Earth +1",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 3",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 2",
		"Awakened Equipment": "Weaken Item Lvl 2",
		"Cat 1": "(Spices)",
		"Cat 2": "(Gunpowder)",
		"Acqusition": "Book 'You Can Do This'"
	},
	"Judgement Tarot": {
		"Level": "24",
		"Fire": "0",
		"Ice": "3",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Earth +1",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 2",
		"Awakened Recovery": "Damage Reducer Lvl 3",
		"Awakened Equipment": "Weaken Item Lvl 3",
		"Cat 1": "(Charms)",
		"Acqusition": "** Event/Quest **"
	},
	"Princess Saver": {
		"Level": "24",
		"Fire": "2",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +2",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 4",
		"Awakened Recovery": "Cures Seal",
		"Awakened Equipment": "Skill Up Lvl 3",
		"Cat 1": "ITEM_CATEGORY_RAPIER"
	},
	"Person Finder": {
		"Level": "24",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 2",
		"Awakened Recovery": "Temp SPD Up Lvl 2",
		"Awakened Equipment": "Ignores Luck M",
		"Cat 1": "(Metals)",
		"Acqusition": "Event STR_LIBRARY_BUILD_015"
	},
	"Fatal Buster": {
		"Level": "24",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Fire +3",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 3",
		"Awakened Recovery": "Cleanses Impurity M",
		"Awakened Equipment": "ACC Up Lvl 3",
		"Cat 1": "(Metals)",
		"Acqusition": "Event STR_LIBRARY_BUILD_016"
	},
	"Slice of Night": {
		"Level": "24",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Acqusition": "[Alchemyriddle] A Knight's Necessity [Chapter of Encounters]"
	},
	"Hiding Cloud": {
		"Level": "25",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened (Bugs)",
		"Awakened Attack (Bombs)": "Awakened (Bugs)",
		"Awakened Recovery": "Awakened (Bugs)",
		"Awakened Equipment": "Awakened (Bugs)",
		"Cat 1": "(Plants)",
		"Cat 2": "(Mystery)",
		"Location": "Ster Highlands, Night's Domain, Holy Slumbering Tree"
	},
	"Undying Wind": {
		"Level": "25",
		"Fire": "2",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 3",
		"Awakened Recovery": "HP Recovery M",
		"Awakened Equipment": "Add Ailments Resistance M",
		"Cat 1": "(Vapors)",
		"Cat 2": "(Mystery)",
		"Location": "Fellsgalaxen, Quelei Forest, Izuko Beach, Fire's Domain, Rolling Hill, Fellsgalaxen: Another",
		"Monster": "Machete Wing, Twilight Phantom, Echo Elemental"
	},
	"Rainbow Fragment": {
		"Level": "25",
		"Fire": "3",
		"Ice": "3",
		"Elec": "3",
		"Earth": "3",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 4",
		"Awakened Recovery": "Temp EXP Up Lvl 4",
		"Awakened Equipment": "ATK Up Lvl 4",
		"Cat 1": "(Mystery)",
		"Cat 2": "(Poisons)",
		"Location": "Orthogalaxen, Runestone Nest",
		"Monster": "Ultra Puni, Eternal Darkness Demon, Blood Elemental, Old Dragon Emperor"
	},
	"Archfiend Claw": {
		"Level": "25",
		"Fire": "4",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 3",
		"Awakened Recovery": "HP Recovery M",
		"Awakened Equipment": "Skill Up Lvl 3",
		"Cat 1": "(Animal Products)",
		"Cat 2": "(Poisons)",
		"Location": "Scorched Wasteland",
		"Monster": "Piercing Unicorn, Violet Fang, Machete Wing, Yellowsein, Wailing Ursidae, Wind Stone, Schwarz Vogel, Shadow Arch, Elder Fang, Silent Killer, Blue Hands"
	},
	"Star Flower": {
		"Level": "25",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Doubled: Earth",
		"Cat 1": "(Boost)",
		"Location": "Ster Highlands, Holy Slumbering Tree"
	},
	"Traveler Shoes": {
		"Level": "25",
		"Fire": "0",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Light. & Earth +1",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 4",
		"Awakened Recovery": "Temp SPD Up Lvl 4",
		"Awakened Equipment": "SPD Up Lvl 4",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Cloth)",
		"Acqusition": "[Alchemyriddle] Shoes Treasured by Travelers [Chapter of Reunion]"
	},
	"Sylph Breath": {
		"Level": "25",
		"Fire": "3",
		"Ice": "0",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened (Vapors)",
		"Awakened Attack (Bombs)": "Awakened (Vapors)",
		"Awakened Recovery": "Awakened (Vapors)",
		"Awakened Equipment": "Awakened (Vapors)",
		"Cat 1": "(Vapors)",
		"Monster": "Blood Elemental, Celestial Emperor Adralda",
		"Acqusition": "[Alchemyriddle] Spirit's Breath [Chapter of Reunion]"
	},
	"Sour Apple King": {
		"Level": "25",
		"Fire": "0",
		"Ice": "4",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 3",
		"Awakened Recovery": "Cleanses Impurity M",
		"Awakened Equipment": "Avoid KO Lvl 3",
		"Cat 1": "(Plants)",
		"Cat 2": "(Vegetables)",
		"Location": "Neumont Forest"
	},
	"Rocket Ice Bomb": {
		"WT": "350",
		"Stun": "75",
		"Range": "All",
		"Level": "26",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +3",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 3",
		"Awakened Recovery": "Temp ACC Up Lvl 3",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] The Ultimate Ice and Electric Bombs [Chapter of Bonds]"
	},
	"Mind Water": {
		"WT": "350",
		"Stun": "0",
		"Range": "Single",
		"Level": "26",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +3",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 3",
		"Awakened Recovery": "Add MP Recovery Lvl 3",
		"Awakened Equipment": "Max MP Up Lvl 3",
		"Cat 1": "(Medicines)",
		"Acqusition": "[Alchemyriddle] Healing Heart [Chapter of Bonds]"
	},
	"Ghost House": {
		"Level": "26",
		"Fire": "3",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 3",
		"Awakened Recovery": "Temp EXP Up Lvl 2",
		"Awakened Equipment": "ACC Up Lvl 3",
		"Cat 1": "(Mushrooms)",
		"Cat 2": "(Poisons)",
		"Location": "Modis Ruins, Foggy Forest, Neumont Forest, Mt. Velus, Night's Domain",
		"Monster": "Ladyshroom, Shiningshroom, Toxishroom, Mellowshroom, Runningshroom"
	},
	"Dragon Scale": {
		"Level": "26",
		"Fire": "0",
		"Ice": "4",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened (Ore)",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 4",
		"Awakened Recovery": "Damage Reducer Lvl 3",
		"Awakened Equipment": "DEF Up Lvl 4",
		"Cat 1": "(Dragon)",
		"Cat 2": "(Mystery)",
		"Cat 3": "(Elixirs)",
		"Location": "Ster Highlands",
		"Monster": "Lesser Draco, Draconia, Draconius"
	},
	"Harvest Gloves": {
		"Level": "26",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Earth +3",
		"Awakened Attack (Bombs)": "Inflict Poison Lvl 3",
		"Awakened Recovery": "Awakened: Earth +3",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Cloth)",
		"Acqusition": "[Alchemyriddle] The Secret to Good Fortune [Chapter of Bonds]"
	},
	"Komet": {
		"Level": "26",
		"Fire": "1",
		"Ice": "0",
		"Elec": "1",
		"Earth": "3",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 3",
		"Awakened Recovery": "Temp DEF Up Lvl 3",
		"Awakened Equipment": "SPD Up Lvl 3",
		"Cat 1": "(Gemstones)",
		"Monster": "Eternal Darkness Demon",
		"Acqusition": "Book 'Gem Mysteries'"
	},
	"Hailsfyre": {
		"Level": "26",
		"Fire": "0",
		"Ice": "3",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Inflict Slowness Lvl 3",
		"Awakened Recovery": "Cures Slowness",
		"Awakened Equipment": "ACC Up Lvl 3",
		"Cat 1": "(Battle Rings)",
		"Acqusition": "** Event/Quest **"
	},
	"Juicy Peach": {
		"Level": "26",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire & Ice +2",
		"Awakened Attack (Bombs)": "Inflict Slowness Lvl 3",
		"Awakened Recovery": "Add MP Recovery Lvl 3",
		"Awakened Equipment": "Skill Up Lvl 3",
		"Cat 1": "(Plants)",
		"Cat 2": "(Water)",
		"Location": "Eternal Spring"
	},
	"Grand Lightning Bomb": {
		"WT": "450",
		"Stun": "60",
		"Range": "Narrow Range",
		"Level": "27",
		"Fire": "0",
		"Ice": "0",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +3",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 3",
		"Awakened Recovery": "Temp Evasion Up Lvl 3",
		"Awakened Equipment": "SPD Up Lvl 3",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] The Ultimate Ice and Electric Bombs [Chapter of Bonds]"
	},
	"Original Soil": {
		"Level": "27",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "5",
		"Awakened Material": "Awakened: Earth +3",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 3",
		"Awakened Recovery": "Cures Curse",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Clay)",
		"Cat 2": "(Elixirs)",
		"Location": "Fellsgalaxen, Forgotten Village, Holy Slumbering Tree, Fellsgalaxen: Another"
	},
	"Lunar Locust": {
		"Level": "27",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 2",
		"Awakened Recovery": "Temp SPD Up Lvl 3",
		"Awakened Equipment": "Max MP Up Lvl 2",
		"Cat 1": "(Bugs)",
		"Location": "Quelei Forest, Neumont Forest, Izuko Beach"
	},
	"Parallel Mushroom": {
		"Level": "27",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Reversed: Earth",
		"Cat 1": "(Boost)",
		"Location": "Neumont Forest, Night's Domain"
	},
	"Liquid Metal": {
		"Level": "27",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Doubled: Fire",
		"Cat 1": "(Boost)",
		"Location": "Ster Highlands, Night's Domain"
	},
	"Light Bug Catcher Net": {
		"Level": "27",
		"Fire": "3",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 3",
		"Awakened Recovery": "Cleanses Impurity S",
		"Awakened Equipment": "SPD Up Lvl 3",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Threads)",
		"Acqusition": "[Alchemyriddle] A Master Gatherer Appears! [Chapter of Bonds]"
	},
	"Crystal Ball": {
		"Level": "27",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened TP Increase +10",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 2",
		"Awakened Recovery": "Temp Evasion Up Lvl 3",
		"Awakened Equipment": "Weaken Item Lvl 3",
		"Cat 1": "(Mystery)",
		"Monster": "Twilight Phantom",
		"Acqusition": "Book 'Gem Mysteries'"
	},
	"Death Tarot": {
		"Level": "27",
		"Fire": "2",
		"Ice": "4",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Light. & Earth +1",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 5",
		"Awakened Recovery": "Temp ACC Up Lvl 3",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Charms)",
		"Acqusition": "** Event/Quest **"
	},
	"Ancient Memory": {
		"Level": "27",
		"Fire": "3",
		"Ice": "0",
		"Elec": "2",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 4",
		"Awakened Recovery": "Add MP Recovery Lvl 3",
		"Awakened Equipment": "Enhance Items Lvl 3",
		"Cat 1": "(Decorative Staffs)",
		"Acqusition": "** Event/Quest **"
	},
	"Dark Dew": {
		"Level": "28",
		"Fire": "3",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Inflict Poison Lvl 5",
		"Awakened Recovery": "Temp DEF Up Lvl 3",
		"Awakened Equipment": "Add Ailments Resistance L",
		"Cat 1": "(Water)",
		"Cat 2": "(Poisons)",
		"Location": "Fellsgalaxen, Ancient Monastery, Forgotten Village, Night's Domain, Fellsgalaxen: Another",
		"Monster": "Pulse Wind"
	},
	"Black Runestone": {
		"Level": "28",
		"Fire": "3",
		"Ice": "3",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 2",
		"Awakened Recovery": "Cures Seal",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Mystery)",
		"Cat 2": "(Ore)",
		"Cat 3": "(Poisons)",
		"Location": "Ster Highlands, Runestone Nest",
		"Monster": "Puni?, Shadow Bat, Deep Phantom, Black Demon"
	},
	"Night Lady": {
		"Level": "28",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened (Cloth)",
		"Awakened Attack (Bombs)": "Awakened (Cloth)",
		"Awakened Recovery": "Awakened (Cloth)",
		"Awakened Equipment": "Awakened (Cloth)",
		"Cat 1": "(Poisons)",
		"Cat 2": "(Plants)",
		"Cat 3": "(Threads)",
		"Location": "Fellsgalaxen, Foggy Forest, Night's Domain, Fellsgalaxen: Another",
		"Monster": "Thoth"
	},
	"Dragon Meat": {
		"Level": "28",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Inflict Burns Lvl 4",
		"Awakened Recovery": "HP Recovery M",
		"Awakened Equipment": "Max HP Up Lvl 4",
		"Cat 1": "(Dragon)",
		"Cat 2": "(Meat)",
		"Monster": "Lesser Draco, Draconia"
	},
	"Super Mining Bomb": {
		"Level": "28",
		"Fire": "5",
		"Ice": "0",
		"Elec": "2",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire & Light. +1",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 2",
		"Awakened Recovery": "Temp Evasion Up Lvl 3",
		"Awakened Equipment": "ATK Up Lvl 3",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Mining Explosives Redux [Chapter of Bonds]"
	},
	"Sack of the Wind God": {
		"Level": "28",
		"Fire": "2",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Light. +2",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 3",
		"Awakened Recovery": "Max MP Up Lvl 4",
		"Awakened Equipment": "ACC Up Lvl 3",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Cloth)",
		"Acqusition": "[Alchemyriddle] A Master Gatherer Appears! [Chapter of Bonds]"
	},
	"Arland Crystal": {
		"Level": "28",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "5",
		"Awakened Material": "Awakened (Ore)",
		"Awakened Attack (Bombs)": "Awakened (Ore)",
		"Awakened Recovery": "Awakened (Ore)",
		"Awakened Equipment": "Awakened (Ore)",
		"Cat 1": "(Gemstones)",
		"Monster": "White Hunter, Sky Ruler Edra",
		"Acqusition": "[Alchemyriddle] Uniquely Designed Gear (1) [Chapter of Bonds]"
	},
	"Direct Illusion": {
		"Level": "28",
		"Fire": "0",
		"Ice": "1",
		"Elec": "4",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire & Ice +2",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 3",
		"Awakened Recovery": "Temp SPD Up Lvl 3",
		"Awakened Equipment": "Add Ailments Resistance M",
		"Cat 1": "(Swords)",
		"Acqusition": "** Event/Quest **"
	},
	"Grand Impact": {
		"Level": "28",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Earth +3",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 2",
		"Awakened Recovery": "Temp DEF Up Lvl 3",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Anchors)",
		"Acqusition": "** Event/Quest **"
	},
	"Twin Memoir": {
		"Level": "28",
		"Fire": "1",
		"Ice": "0",
		"Elec": "1",
		"Earth": "3",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 3",
		"Awakened Recovery": "Temp ATK Up Lvl 4",
		"Awakened Equipment": "Temp Stamina Buff L",
		"Cat 1": "(Long Swords)",
		"Acqusition": "** Event/Quest **"
	},
	"THAT Egg": {
		"Level": "28",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Ice +2",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 3",
		"Awakened Recovery": "Awakened Quality Up +30",
		"Awakened Equipment": "SPD Up Lvl 3",
		"Cat 1": "(Fuel)",
		"Cat 2": "(Elixirs)",
		"Location": "Stalhang Castle"
	},
	"Guardian Slice": {
		"Level": "28",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Glittery Water": {
		"Level": "29",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 3",
		"Awakened Recovery": "Temp Evasion Up Lvl 2",
		"Awakened Equipment": "Weaken Item Lvl 3",
		"Cat 1": "(Water)",
		"Cat 2": "(Clay)",
		"Location": "Fellsgalaxen, Izuko Beach, Large Conifer Forest, Fellsgalaxen: Another"
	},
	"Star Piece": {
		"Level": "29",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Light. & Earth +1",
		"Awakened Attack (Bombs)": "Inflict Poison Lvl 3",
		"Awakened Recovery": "Temp ATK Up Lvl 3",
		"Awakened Equipment": "ATK Up Lvl 3",
		"Cat 1": "(Ore)",
		"Cat 2": "(Mystery)",
		"Location": "Ster Highlands, Mt. Velus, Dusty Nail Canyon, Fire's Domain, Rolling Hill",
		"Monster": "Black Puni, Puni Black, Pulse Wind"
	},
	"Sea Puddle": {
		"Level": "29",
		"Fire": "3",
		"Ice": "1",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened (Clay)",
		"Awakened Attack (Bombs)": "Awakened (Clay)",
		"Awakened Recovery": "Awakened (Clay)",
		"Awakened Equipment": "Awakened (Clay)",
		"Cat 1": "(Fuel)",
		"Cat 2": "(Gunpowder)",
		"Location": "Fellsgalaxen, Foggy Forest, Mt. Velus, Dusty Nail Canyon, Rolling Hill, Fellsgalaxen: Another"
	},
	"Missing Jewel": {
		"Level": "29",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Reversed: Ice",
		"Cat 1": "(Boost)",
		"Location": "Mt. Velus, Stein Hill"
	},
	"Rota Fortunae": {
		"Level": "29",
		"Fire": "0",
		"Ice": "0",
		"Elec": "2",
		"Earth": "4",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 3",
		"Awakened Recovery": "HP Recovery L",
		"Awakened Equipment": "DEF Up Lvl 4",
		"Cat 1": "(Metals)",
		"Acqusition": "[Alchemyriddle] Uniquely Designed Gear (2) [Chapter of Bonds]"
	},
	"Locket of Friendship": {
		"Level": "29",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 4",
		"Awakened Recovery": "Awakened Quality Up +40",
		"Awakened Equipment": "Avoid KO Lvl 2",
		"Cat 1": "(Accessories)",
		"Acqusition": "[Alchemyriddle] True Sign of Friendship [Chapter of Bonds]"
	},
	"Black Mist Symbol": {
		"Level": "29",
		"Fire": "3",
		"Ice": "0",
		"Elec": "1",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +10",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 4",
		"Awakened Recovery": "Damage Reducer Lvl 3",
		"Awakened Equipment": "ATK Up Lvl 3",
		"Cat 1": "(Symbols)",
		"Acqusition": "[Alchemyriddle] Enshrouded in Light (Black/White) [Chapter of Bonds]"
	},
	"Magmadurian": {
		"Level": "29",
		"Fire": "4",
		"Ice": "0",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 3",
		"Awakened Recovery": "Awakened Quality Up +30",
		"Awakened Equipment": "Avoid KO Lvl 3",
		"Cat 1": "(Plants)",
		"Cat 2": "(Vegetables)",
		"Location": "Mt. Velus"
	},
	"Frixell Pie": {
		"Level": "29",
		"Fire": "3",
		"Ice": "1",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened (Food)",
		"Awakened Attack (Bombs)": "Awakened (Food)",
		"Awakened Recovery": "Awakened (Food)",
		"Awakened Equipment": "Awakened (Food)",
		"Cat 1": "(Food)",
		"Cat 2": "(Elixirs)",
		"Acqusition": "Event STR_LIBRARY_BUILD_006"
	},
	"How to Boost an Appetite": {
		"Level": "29",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Luminous Lance": {
		"WT": "400",
		"Stun": "50",
		"Range": "Normal Range",
		"Level": "30",
		"Fire": "0",
		"Ice": "3",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened (Mystery)",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 5",
		"Awakened Recovery": "Temp ACC Up Lvl 5",
		"Awakened Equipment": "ACC Up Lvl 4",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Lance of Light, Bane of Evil [Chapter of Bonds]"
	},
	"Living Cactus": {
		"Level": "30",
		"Fire": "2",
		"Ice": "0",
		"Elec": "2",
		"Earth": "3",
		"Awakened Material": "Awakened: Earth +2",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 2",
		"Awakened Recovery": "Awakened Quality Up +30",
		"Awakened Equipment": "Weaken Item Lvl 2",
		"Cat 1": "(Plants)",
		"Cat 2": "(Poisons)",
		"Location": "Fellsgalaxen, Scorched Wasteland, Fellsgalaxen: Another",
		"Monster": "Toxishroom"
	},
	"Royal Crown": {
		"Level": "30",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened (Vegetables)",
		"Awakened Attack (Bombs)": "Awakened (Vegetables)",
		"Awakened Recovery": "Awakened (Vegetables)",
		"Awakened Equipment": "Awakened (Vegetables)",
		"Cat 1": "(Mushrooms)",
		"Cat 2": "(Gemstones)",
		"Location": "Large Conifer Forest, Rolling Hill",
		"Monster": "Mellowshroom, Toxishroom"
	},
	"Sage Herb": {
		"Level": "30",
		"Fire": "0",
		"Ice": "4",
		"Elec": "1",
		"Earth": "3",
		"Awakened Material": "Awakened (Plants)",
		"Awakened Attack (Bombs)": "Awakened (Plants)",
		"Awakened Recovery": "Awakened (Plants)",
		"Awakened Equipment": "Awakened (Plants)",
		"Cat 1": "(Medicinal)",
		"Cat 2": "(Poisons)",
		"Cat 3": "(Elixirs)",
		"Location": "Fellsgalaxen, Izuko Beach, Holy Slumbering Tree, Fellsgalaxen: Another",
		"Monster": "Magi Mirage"
	},
	"Fate Talisman": {
		"Level": "30",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire & Ice +1",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 3",
		"Awakened Recovery": "Cures Seal",
		"Awakened Equipment": "Add Ailments Resistance M",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Fuel)",
		"Acqusition": "[Alchemyriddle] The Secret to Good Fortune [Chapter of Bonds]"
	},
	"Sunlite": {
		"Level": "30",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire & Earth +2",
		"Awakened Attack (Bombs)": "Awakened Quality Up +40",
		"Awakened Recovery": "Awakened: Fire & Earth +2",
		"Awakened Equipment": "Awakened Quality Up +40",
		"Cat 1": "(Weapon Materials)",
		"Cat 2": "(Metals)",
		"Monster": "Ancient Draco",
		"Acqusition": "Book 'The Art of Burning Soul'"
	},
	"Scale Cloth": {
		"Level": "30",
		"Fire": "0",
		"Ice": "2",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Awakened: Ice & Light. +2",
		"Awakened Recovery": "Awakened Quality Up +40",
		"Awakened Equipment": "Awakened: Ice & Light. +2",
		"Cat 1": "(Armor Materials)",
		"Cat 2": "(Cloth)",
		"Acqusition": "Book 'The Art of Burning Soul'"
	},
	"Heart of Wisdom": {
		"Level": "30",
		"Fire": "0",
		"Ice": "4",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +10",
		"Awakened Attack (Bombs)": "Awakened Quality Up +30",
		"Awakened Recovery": "Awakened TP Increase +10",
		"Awakened Equipment": "Awakened Quality Up +30",
		"Cat 1": "(Alchemy Staffs)",
		"Acqusition": "** Event/Quest **"
	},
	"Clavaal's Halo": {
		"Level": "30",
		"Fire": "2",
		"Ice": "0",
		"Elec": "4",
		"Earth": "1",
		"Awakened Material": "Awakened: Lightning +3",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 3",
		"Awakened Recovery": "Temp SPD Up Lvl 3",
		"Awakened Equipment": "ACC Up Lvl 4",
		"Cat 1": "(Battle Rings)",
		"Acqusition": "** Event/Quest **"
	},
	"White Haze Symbol": {
		"Level": "30",
		"Fire": "1",
		"Ice": "3",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 3",
		"Awakened Recovery": "Temp ACC Up Lvl 4",
		"Awakened Equipment": "Evasion Up Lvl 3",
		"Cat 1": "(Symbols)",
		"Acqusition": "[Alchemyriddle] Enshrouded in Light (Black/White) [Chapter of Bonds]"
	},
	"Windslice Tail Feather": {
		"Level": "30",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Special Plate": {
		"WT": "350",
		"Stun": "0",
		"Range": "Single",
		"Level": "31",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened (Food)",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 5",
		"Awakened Recovery": "Add MP Recovery Lvl 5",
		"Awakened Equipment": "Max MP Up Lvl 5",
		"Cat 1": "(Food)",
		"Acqusition": "Book 'Wild's Wild Recipe'"
	},
	"Black Ore": {
		"Level": "31",
		"Fire": "0",
		"Ice": "0",
		"Elec": "3",
		"Earth": "3",
		"Awakened Material": "Awakened: Fire & Earth +1",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 3",
		"Awakened Recovery": "Temp Critical Power Up Lvl 3",
		"Awakened Equipment": "Evasion Up Lvl 3",
		"Cat 1": "(Ore)",
		"Cat 2": "(Gemstones)",
		"Location": "Fellsgalaxen, Scorched Wasteland, Mt. Velus, Runestone Nest, Night's Domain, Fire's Domain, Fellsgalaxen: Another",
		"Monster": "Puni?"
	},
	"Large Scale": {
		"Level": "31",
		"Fire": "3",
		"Ice": "0",
		"Elec": "3",
		"Earth": "1",
		"Awakened Material": "Awakened (Ore)",
		"Awakened Attack (Bombs)": "Awakened (Ore)",
		"Awakened Recovery": "Awakened (Ore)",
		"Awakened Equipment": "Awakened (Ore)",
		"Cat 1": "(Medicinal)",
		"Cat 2": "(Elixirs)",
		"Cat 3": "(Mystery)",
		"Location": "Orthogalaxen, Scorched Wasteland, Mt. Velus, Rolling Hill",
		"Monster": "Old Dragon Emperor, Dragon Spirit of Oblivion, Draconius"
	},
	"Dragon Piece": {
		"Level": "31",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened (Dragon)",
		"Awakened Attack (Bombs)": "Awakened (Dragon)",
		"Awakened Recovery": "Awakened (Dragon)",
		"Awakened Equipment": "Awakened (Dragon)",
		"Cat 1": "(Dragon)",
		"Cat 2": "(Mystery)",
		"Cat 3": "(Gemstones)",
		"Monster": "Draconius, Ancient Draco, Sky Ruler Edra, Celestial Emperor Adralda"
	},
	"Super Helix Rod": {
		"Level": "31",
		"Fire": "0",
		"Ice": "4",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice +3",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 4",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 4",
		"Awakened Equipment": "ATK Up Lvl 4",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Lumber)",
		"Acqusition": "[Alchemyriddle] Perfect for Fishing and Mining [Chapter of Answers]"
	},
	"Tar Liquid": {
		"Level": "31",
		"Fire": "4",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened (Gunpowder)",
		"Awakened Attack (Bombs)": "Awakened (Gunpowder)",
		"Awakened Recovery": "Awakened (Gunpowder)",
		"Awakened Equipment": "Awakened (Gunpowder)",
		"Cat 1": "(Gunpowder)",
		"Acqusition": "Book 'The Art of Burning Soul'"
	},
	"Styrom Board": {
		"Level": "31",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened (Lumber)",
		"Awakened Attack (Bombs)": "Awakened (Lumber)",
		"Awakened Recovery": "Awakened (Lumber)",
		"Awakened Equipment": "Awakened (Lumber)",
		"Cat 1": "(Lumber)",
		"Acqusition": "[Alchemyriddle] Combining Timber and Bamboo [Chapter of Answers]"
	},
	"Dragoon Lore": {
		"Level": "31",
		"Fire": "4",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +2",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 4",
		"Awakened Recovery": "Add MP Recovery Lvl 4",
		"Awakened Equipment": "ATK Up Lvl 4",
		"Cat 1": "(Cannons)",
		"Acqusition": "** Event/Quest **"
	},
	"Dragon Plate Armor": {
		"Level": "31",
		"Fire": "5",
		"Ice": "2",
		"Elec": "3",
		"Earth": "1",
		"Awakened Material": "Awakened (Gunpowder)",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 4",
		"Awakened Recovery": "Temp ATK Up Lvl 5",
		"Awakened Equipment": "ATK Up Lvl 5",
		"Cat 1": "(Heavy Armor)",
		"Acqusition": "** Event/Quest **"
	},
	"Herculean Symbol": {
		"Level": "31",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Fire & Light. +3",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 5",
		"Awakened Recovery": "Temp ATK Up Lvl 5",
		"Awakened Equipment": "ATK Up Lvl 5",
		"Cat 1": "(Symbols)",
		"Acqusition": "Event STR_LIBRARY_BUILD_009"
	},
	"Machina Gear Mechanism": {
		"Level": "31",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "Event STR_LIBRARY_BUILD_018"
	},
	"Wild's Wild Recipe": {
		"Level": "31",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"How to Make a Special Pickaxe": {
		"Level": "31",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Rorona's Dear Recipe": {
		"Level": "31",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Healing Incense": {
		"WT": "650",
		"Stun": "0",
		"Range": "All",
		"Level": "32",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Earth +3",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 4",
		"Awakened Recovery": "HP Recovery L",
		"Awakened Equipment": "Weaken Item Lvl 4",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] The Allure of a Healing Aroma [Chapter of Answers]"
	},
	"Spike Tuna": {
		"Level": "32",
		"Fire": "0",
		"Ice": "3",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Light. +1",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 3",
		"Awakened Recovery": "Temp DEF Up Lvl 2",
		"Awakened Equipment": "Evasion Up Lvl 2",
		"Cat 1": "(Seafood)",
		"Location": "Izuko Beach",
		"Monster": "Striped Isle Fish"
	},
	"Rainbow Puniball": {
		"Level": "32",
		"Fire": "3",
		"Ice": "3",
		"Elec": "3",
		"Earth": "3",
		"Awakened Material": "Awakened (Gemstones)",
		"Awakened Attack (Bombs)": "Awakened (Gemstones)",
		"Awakened Recovery": "Awakened (Gemstones)",
		"Awakened Equipment": "Awakened (Gemstones)",
		"Cat 1": "(Puniballs)",
		"Cat 2": "(Mystery)",
		"Location": "Orthogalaxen",
		"Monster": "Ultra Puni, Marshall Puni"
	},
	"Dragon Horn": {
		"Level": "32",
		"Fire": "0",
		"Ice": "0",
		"Elec": "4",
		"Earth": "2",
		"Awakened Material": "Awakened (Lumber)",
		"Awakened Attack (Bombs)": "Awakened (Lumber)",
		"Awakened Recovery": "Awakened (Lumber)",
		"Awakened Equipment": "Awakened (Lumber)",
		"Cat 1": "(Dragon)",
		"Cat 2": "(Medicinal)",
		"Cat 3": "(Elixirs)",
		"Location": "Ster Highlands",
		"Monster": "Lesser Draco, Draconia, Draconius, Ancient Draco, Piercing Unicorn"
	},
	"Shaky Pickaxe": {
		"Level": "32",
		"Fire": "3",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Light. & Earth +2",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 4",
		"Awakened Recovery": "Temp ATK Up Lvl 3",
		"Awakened Equipment": "Max HP Up Lvl 4",
		"Cat 1": "(Gathering Tools)",
		"Cat 2": "(Metals)",
		"Acqusition": "[Alchemyriddle] Perfect for Fishing and Mining [Chapter of Answers]"
	},
	"Researcher's Key": {
		"Level": "32",
		"Fire": "0",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 2",
		"Awakened Recovery": "Temp DEF Up Lvl 2",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Metals)",
		"Acqusition": "[Alchemyriddle] Lord of the Locks: Final Chapter [Chapter of Answers]"
	},
	"Stellar Score": {
		"Level": "32",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Ice & Earth +3",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 5",
		"Awakened Recovery": "Add MP Recovery Lvl 4",
		"Awakened Equipment": "Avoid KO Lvl 4",
		"Cat 1": "ITEM_CATEGORY_ALCHEMY_BOOK"
	},
	"Guardian Liquor": {
		"Level": "32",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "[Alchemyriddle] Key to a Door to the Past [Chapter of Truth]"
	},
	"Steering Lever": {
		"Level": "32",
		"Fire": "0",
		"Ice": "3",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Light. +2",
		"Awakened Attack (Bombs)": "Awakened: Ice & Light. +2",
		"Awakened Recovery": "Awakened: Ice & Light. +2",
		"Awakened Equipment": "Awakened: Ice & Light. +2",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "** Event/Quest **"
	},
	"The Secrets of Jewelry Making": {
		"Level": "32",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "Chest - Fire Domain"
	},
	"Witch Salve": {
		"WT": "300",
		"Stun": "0",
		"Range": "Single",
		"Level": "33",
		"Fire": "2",
		"Ice": "2",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Fire & Earth +3",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 5",
		"Awakened Recovery": "Temp SPD Up Lvl 3",
		"Awakened Equipment": "Enhance Items Lvl 4",
		"Cat 1": "(Medicines)",
		"Acqusition": "Clear Alchemyriddle Chapter of Bonds"
	},
	"Tera Bomb": {
		"WT": "350",
		"Stun": "35",
		"Range": "Large Range",
		"Level": "33",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +3",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 3",
		"Awakened Recovery": "Temp Critical Power Up Lvl 3",
		"Awakened Equipment": "ATK Up Lvl 3",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Powerful Bomb of Light and Flames [Chapter of Answers]"
	},
	"Magma Stone": {
		"Level": "33",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened (Fuel)",
		"Awakened Attack (Bombs)": "Awakened (Fuel)",
		"Awakened Recovery": "Awakened (Fuel)",
		"Awakened Equipment": "Awakened (Fuel)",
		"Cat 1": "(Gunpowder)",
		"Cat 2": "(Ore)",
		"Location": "Orthogalaxen, Scorched Wasteland, Mt. Velus, Fire's Domain",
		"Monster": "Sky Ruler Edra"
	},
	"Guardian": {
		"Level": "33",
		"Fire": "0",
		"Ice": "5",
		"Elec": "4",
		"Earth": "1",
		"Awakened Material": "Awakened (Meat)",
		"Awakened Attack (Bombs)": "Awakened (Meat)",
		"Awakened Recovery": "Awakened (Meat)",
		"Awakened Equipment": "Awakened (Meat)",
		"Cat 1": "(Seafood)",
		"Location": "Dusty Nail Canyon, Large Conifer Forest",
		"Monster": "Old Dragon Emperor, Dragon Spirit of Oblivion"
	},
	"Gold Scarab": {
		"Level": "33",
		"Fire": "3",
		"Ice": "0",
		"Elec": "4",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 4",
		"Awakened Recovery": "Temp DEF Up Lvl 4",
		"Awakened Equipment": "Max HP Up Lvl 4",
		"Cat 1": "(Bugs)",
		"Cat 2": "(Gemstones)",
		"Location": "Foggy Forest, Neumont Forest"
	},
	"Moonbeam Stone": {
		"Level": "33",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Attribute Doubled: Lightning",
		"Cat 1": "(Boost)",
		"Location": "Izuko Beach"
	},
	"Dark Firefly": {
		"Level": "33",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Radical Boost",
		"Cat 1": "(Boost)",
		"Location": "Night's Domain"
	},
	"Blitzstrom": {
		"Level": "33",
		"Fire": "0",
		"Ice": "1",
		"Elec": "2",
		"Earth": "4",
		"Awakened Material": "Awakened: Light. & Earth +2",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 4",
		"Awakened Recovery": "Add MP Recovery Lvl 3",
		"Awakened Equipment": "Enhance Items Lvl 4",
		"Cat 1": "(Long Swords)",
		"Acqusition": "** Event/Quest **"
	},
	"Lunatomic Edge": {
		"Level": "33",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened TP Increase +15",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 4",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 4",
		"Awakened Equipment": "Add Ailments Resistance L",
		"Cat 1": "ITEM_CATEGORY_RAPIER"
	},
	"Sun Cloak": {
		"Level": "33",
		"Fire": "2",
		"Ice": "0",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +20",
		"Awakened Attack (Bombs)": "Inflict Blindness Lvl 4",
		"Awakened Recovery": "Temp Evasion Up Lvl 4",
		"Awakened Equipment": "Ignores Luck L",
		"Cat 1": "(Light Armor)",
		"Acqusition": "** Event/Quest **"
	},
	"Dragoon Coat": {
		"Level": "33",
		"Fire": "3",
		"Ice": "2",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Fire & Earth +2",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 3",
		"Awakened Recovery": "Temp DEF Up Lvl 3",
		"Awakened Equipment": "Skill Up Lvl 3",
		"Cat 1": "(Light Armor)",
		"Acqusition": "** Event/Quest **"
	},
	"Mythical Ring": {
		"Level": "33",
		"Fire": "2",
		"Ice": "1",
		"Elec": "2",
		"Earth": "1",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 5",
		"Awakened Recovery": "Add MP Recovery Lvl 4",
		"Awakened Equipment": "ACC Up Lvl 3",
		"Cat 1": "(Accessories)",
		"Acqusition": "Book 'The Secrets of Jewelry Making'"
	},
	"Ice Cascade Bomb": {
		"Level": "33",
		"Fire": "0",
		"Ice": "4",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened (Bombs)",
		"Awakened Attack (Bombs)": "Awakened (Bombs)",
		"Awakened Recovery": "Awakened (Bombs)",
		"Awakened Equipment": "Awakened (Bombs)",
		"Cat 1": "(Bombs)",
		"Cat 2": "(Magic Tool)",
		"Acqusition": "Event STR_LIBRARY_BUILD_019"
	},
	"Fool's Stone": {
		"Level": "33",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened (Mystery)",
		"Awakened Attack (Bombs)": "Awakened (Mystery)",
		"Awakened Recovery": "Awakened (Mystery)",
		"Awakened Equipment": "Awakened (Mystery)",
		"Cat 1": "(Ore)",
		"Cat 2": "(Gunpowder)",
		"Cat 3": "(Medicinal)",
		"Acqusition": "Event STR_LIBRARY_BUILD_007"
	},
	"Windslice Body Feather": {
		"Level": "33",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"How to Make Charmed Items": {
		"Level": "33",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Dream Vision": {
		"WT": "350",
		"Stun": "0",
		"Range": "Single",
		"Level": "34",
		"Fire": "2",
		"Ice": "2",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened (Magic Tool)",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 5",
		"Awakened Recovery": "Temp ACC Up Lvl 5",
		"Awakened Equipment": "Evasion Up Lvl 5",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Alchemic Clones [Chapter of Answers]"
	},
	"Creation Tree's Twig": {
		"Level": "34",
		"Fire": "0",
		"Ice": "0",
		"Elec": "4",
		"Earth": "3",
		"Awakened Material": "Awakened (Medicinal)",
		"Awakened Attack (Bombs)": "Awakened (Medicinal)",
		"Awakened Recovery": "Awakened (Medicinal)",
		"Awakened Equipment": "Awakened (Medicinal)",
		"Cat 1": "(Lumber)",
		"Cat 2": "(Plants)",
		"Location": "Orthogalaxen, Holy Slumbering Tree",
		"Monster": "Piercing Unicorn"
	},
	"Ghost Orb": {
		"Level": "34",
		"Fire": "4",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 3",
		"Awakened Recovery": "Temp ATK Up Lvl 3",
		"Awakened Equipment": "Avoid KO Lvl 3",
		"Cat 1": "(Poisons)",
		"Cat 2": "(Mystery)",
		"Location": "Night's Domain",
		"Monster": "Thoth, Eternal Darkness Demon, Violet Fang, Machete Wing, Dragon Spirit of Oblivion"
	},
	"Huge Puniball": {
		"Level": "34",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened (Puniballs)",
		"Awakened Attack (Bombs)": "Awakened (Puniballs)",
		"Awakened Recovery": "Awakened (Puniballs)",
		"Awakened Equipment": "Awakened (Puniballs)",
		"Cat 1": "(Puniballs)",
		"Cat 2": "(Elixirs)",
		"Location": "Fellsgalaxen, Fellsgalaxen: Another",
		"Monster": "Marshall Puni"
	},
	"Spirit Tears": {
		"Level": "34",
		"Fire": "0",
		"Ice": "3",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened (Water)",
		"Awakened Attack (Bombs)": "Awakened (Water)",
		"Awakened Recovery": "Awakened (Water)",
		"Awakened Equipment": "Awakened (Water)",
		"Cat 1": "(Water)",
		"Cat 2": "(Mystery)",
		"Acqusition": "[Alchemyriddle] A Fairy's Tears [Chapter of Answers]"
	},
	"Spirit Necklace": {
		"Level": "34",
		"Fire": "2",
		"Ice": "3",
		"Elec": "3",
		"Earth": "2",
		"Awakened Material": "Awakened: Ice & Earth +2",
		"Awakened Attack (Bombs)": "Inflict Curse Lvl 4",
		"Awakened Recovery": "Temp Critical Power Up Lvl 4",
		"Awakened Equipment": "Skill Up Lvl 4",
		"Cat 1": "(Accessories)",
		"Acqusition": "Book 'The Secrets of Jewelry Making'"
	},
	"Philosopher's Necklace": {
		"Level": "34",
		"Fire": "0",
		"Ice": "3",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened (Elixirs)",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 5",
		"Awakened Recovery": "Temp DEF Up Lvl 5",
		"Awakened Equipment": "Ailments Resistance Lvl 5",
		"Cat 1": "(Accessories)",
		"Acqusition": "[Alchemyriddle] Necklace of Wisdom [Chapter of Answers]"
	},
	"How to Make the Special Goddess Statue": {
		"Level": "34",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Lululu Curry": {
		"WT": "300",
		"Stun": "0",
		"Range": "Single",
		"Level": "35",
		"Fire": "4",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +2",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 4",
		"Awakened Recovery": "HP Recovery L",
		"Awakened Equipment": "Max HP Up Lvl 4",
		"Cat 1": "(Food)",
		"Acqusition": "Event STR_LIBRARY_BUILD_020"
	},
	"Forest Dew": {
		"Level": "35",
		"Fire": "0",
		"Ice": "5",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Earth +2",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 4",
		"Awakened Recovery": "Cures Curse",
		"Awakened Equipment": "Max MP Up Lvl 3",
		"Cat 1": "(Water)",
		"Cat 2": "(Elixirs)",
		"Location": "Guiding Light Forest, Orthogalaxen, Large Conifer Forest",
		"Monster": "Machina of God"
	},
	"Eternity Flame": {
		"Level": "35",
		"Fire": "5",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened (Vapors)",
		"Awakened Attack (Bombs)": "Awakened (Vapors)",
		"Awakened Recovery": "Awakened (Vapors)",
		"Awakened Equipment": "Awakened (Vapors)",
		"Cat 1": "(Fuel)",
		"Cat 2": "(Mystery)",
		"Location": "Fellsgalaxen, Fire's Domain, Fellsgalaxen: Another",
		"Monster": "Wailing Ursidae, Celestial Emperor Adralda"
	},
	"Secret Bag": {
		"Level": "35",
		"Fire": "1",
		"Ice": "3",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened (Cloth)",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 2",
		"Awakened Recovery": "Cleanses Impurity M",
		"Awakened Equipment": "Add Ailments Resistance L",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Cloth)",
		"Acqusition": "[Alchemyriddle] Moving Bag [Chapter of Truth]"
	},
	"Rainbow Supplement": {
		"Level": "35",
		"Fire": "4",
		"Ice": "4",
		"Elec": "4",
		"Earth": "4",
		"Awakened Material": "Awakened (Supplements)",
		"Awakened Attack (Bombs)": "Awakened (Supplements)",
		"Awakened Recovery": "Awakened (Supplements)",
		"Awakened Equipment": "Awakened (Supplements)",
		"Cat 1": "(Supplements)",
		"Location": "Orthogalaxen",
		"Acqusition": "Clear Alchemyriddle Chapter of Answers"
	},
	"Jar of Four Spirits": {
		"Level": "35",
		"Fire": "3",
		"Ice": "3",
		"Elec": "3",
		"Earth": "3",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Temp ATK Debuff Lvl 5",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 5",
		"Awakened Equipment": "Avoid KO Lvl 5",
		"Cat 1": "(Mystery)",
		"Location": "Orthogalaxen",
		"Monster": "Schwarz Vogel",
		"Acqusition": "[Alchemyriddle] Bottling the Strength of the Spirits [Chapter of Decisions]"
	},
	"Philosopher's Stone": {
		"Level": "35",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +50",
		"Awakened Attack (Bombs)": "Awakened Quality Up +50",
		"Awakened Recovery": "Awakened Quality Up +50",
		"Awakened Equipment": "Awakened Quality Up +50",
		"Cat 1": "(Metals)",
		"Cat 2": "(Elixirs)",
		"Cat 3": "(Gemstones)",
		"Monster": "GX3-FS, GX3-FS2, Machina of God",
		"Acqusition": "[Alchemyriddle] Alchemic Wisdom [Chapter of Answers]"
	},
	"Flawless Principle": {
		"Level": "35",
		"Fire": "4",
		"Ice": "1",
		"Elec": "2",
		"Earth": "1",
		"Awakened Material": "Awakened: Ice & Light. +3",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 4",
		"Awakened Recovery": "Add MP Recovery Lvl 4",
		"Awakened Equipment": "Max MP Up Lvl 4",
		"Cat 1": "(Decorative Staffs)",
		"Acqusition": "** Event/Quest **"
	},
	"Philosopher's Pie": {
		"Level": "35",
		"Fire": "5",
		"Ice": "5",
		"Elec": "5",
		"Earth": "5",
		"Awakened Material": "Awakened (Puniballs)",
		"Awakened Attack (Bombs)": "Awakened (Puniballs)",
		"Awakened Recovery": "Awakened (Puniballs)",
		"Awakened Equipment": "Awakened (Puniballs)",
		"Cat 1": "(Food)",
		"Cat 2": "(Fuel)",
		"Cat 3": "(Dragon)",
		"Cat 4": "(Puniballs)",
		"Acqusition": "Event STR_LIBRARY_BUILD_017"
	},
	"Sharp Ice Sword": {
		"WT": "250",
		"Stun": "60",
		"Range": "Single",
		"Level": "36",
		"Fire": "0",
		"Ice": "4",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 5",
		"Awakened Recovery": "Temp ACC Up Lvl 4",
		"Awakened Equipment": "Ignores Luck L",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Mighty Magic Sword of Ice [Chapter of Decisions]"
	},
	"Alchemy Candy": {
		"WT": "300",
		"Stun": "0",
		"Range": "Single",
		"Level": "36",
		"Fire": "1",
		"Ice": "1",
		"Elec": "1",
		"Earth": "1",
		"Awakened Material": "Awakened TP Increase +7",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 3",
		"Awakened Recovery": "Temp EXP Up Lvl 3",
		"Awakened Equipment": "Ignores Luck L",
		"Cat 1": "(Medicines)",
		"Acqusition": "[Alchemyriddle] Alchemical Candy Making [Chapter of Truth]"
	},
	"Drachen Elixir": {
		"WT": "400",
		"Stun": "0",
		"Range": "Single",
		"Level": "36",
		"Fire": "3",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened: Earth +3",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 2",
		"Awakened Recovery": "Temp ACC Up Lvl 3",
		"Awakened Equipment": "ACC Up Lvl 3",
		"Cat 1": "(Medicines)",
		"Acqusition": "[Alchemyriddle] Dragon Power Imbued Medicine [Chapter of Decisions]"
	},
	"Sun Flare": {
		"WT": "500",
		"Stun": "60",
		"Range": "Single",
		"Level": "36",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened: Earth +3",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 3",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 3",
		"Awakened Equipment": "Temp Stamina Buff L",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Using the Strength of the Sun [Chapter of Truth]"
	},
	"Divine Iron Piece": {
		"Level": "36",
		"Fire": "3",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened (Metals)",
		"Awakened Attack (Bombs)": "Awakened (Metals)",
		"Awakened Recovery": "Awakened (Metals)",
		"Awakened Equipment": "Awakened (Metals)",
		"Cat 1": "(Ore)",
		"Location": "Fellsgalaxen, Fire's Domain, Fellsgalaxen: Another",
		"Monster": "Machina of God, Sky Ruler Edra"
	},
	"Heavenly Parasol": {
		"Level": "36",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened: Ice & Light. +2",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 4",
		"Awakened Recovery": "Add MP Recovery Lvl 4",
		"Awakened Equipment": "DEF Up Lvl 4",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Water)",
		"Acqusition": "[Alchemyriddle] Heat-Blocking Umbrella [Chapter of Truth]"
	},
	"Night Vision Goggles": {
		"Level": "36",
		"Fire": "1",
		"Ice": "0",
		"Elec": "2",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +30",
		"Awakened Attack (Bombs)": "Inflict Slowness Lvl 3",
		"Awakened Recovery": "Cleanses Impurity M",
		"Awakened Equipment": "Enhance Items Lvl 4",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Black Eyes that Light Up the Night [Chapter of Truth]"
	},
	"Special Goddess Statue": {
		"Level": "36",
		"Fire": "0",
		"Ice": "3",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened (Gemstones)",
		"Awakened Attack (Bombs)": "Awakened (Gemstones)",
		"Awakened Recovery": "Awakened (Gemstones)",
		"Awakened Equipment": "Awakened (Gemstones)",
		"Cat 1": "(Metals)",
		"Acqusition": "Event STR_LIBRARY_BUILD_011"
	},
	"Guardian Curry": {
		"Level": "36",
		"Fire": "0",
		"Ice": "4",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened (Seafood)",
		"Awakened Attack (Bombs)": "Awakened (Seafood)",
		"Awakened Recovery": "Awakened (Seafood)",
		"Awakened Equipment": "Awakened (Seafood)",
		"Cat 1": "(Food)",
		"Cat 2": "(Seafood)",
		"Acqusition": "Event STR_LIBRARY_BUILD_021"
	},
	"Dunkel Curry": {
		"Level": "36",
		"Fire": "1",
		"Ice": "4",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened (Plants)",
		"Awakened Attack (Bombs)": "Awakened (Plants)",
		"Awakened Recovery": "Awakened (Plants)",
		"Awakened Equipment": "Awakened (Plants)",
		"Cat 1": "(Food)",
		"Cat 2": "(Elixirs)",
		"Acqusition": "Event STR_LIBRARY_BUILD_022"
	},
	"Philosopher's Curry": {
		"Level": "36",
		"Fire": "4",
		"Ice": "4",
		"Elec": "4",
		"Earth": "4",
		"Awakened Material": "Awakened (Food)",
		"Awakened Attack (Bombs)": "Awakened (Food)",
		"Awakened Recovery": "Awakened (Food)",
		"Awakened Equipment": "Awakened (Food)",
		"Cat 1": "(Meat)",
		"Cat 2": "(Vegetables)",
		"Cat 3": "(Spices)",
		"Cat 4": "(Mushrooms)",
		"Acqusition": "Event STR_LIBRARY_BUILD_023"
	},
	"Windslice Wing Feather": {
		"Level": "36",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Meruru's Dear Recipe": {
		"Level": "36",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Elemental Canon": {
		"WT": "550",
		"Stun": "50",
		"Range": "Line",
		"Level": "37",
		"Fire": "2",
		"Ice": "2",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened (Mushrooms)",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 5",
		"Awakened Recovery": "Temp ACC Up Lvl 3",
		"Awakened Equipment": "Faint Value Up Lvl 4",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Cannon Designed for Magical Use [Chapter of Decisions]"
	},
	"Elixir": {
		"WT": "800",
		"Stun": "0",
		"Range": "All",
		"Level": "37",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened (Medicines)",
		"Awakened Attack (Bombs)": "Awakened (Medicines)",
		"Awakened Recovery": "Awakened (Medicines)",
		"Awakened Equipment": "Awakened (Medicines)",
		"Cat 1": "(Medicines)",
		"Acqusition": "[Alchemyriddle] Ultimate Panacea [Chapter of Truth]"
	},
	"Fire Spirit Ring": {
		"Level": "37",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +2",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 4",
		"Awakened Recovery": "Temp ATK Up Lvl 4",
		"Awakened Equipment": "ATK Up Lvl 4",
		"Cat 1": "(Accessories)",
		"Acqusition": "Book 'Processing the Elements'"
	},
	"Phantom Ice Ring": {
		"Level": "37",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Earth +2",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 4",
		"Awakened Recovery": "Temp DEF Up Lvl 4",
		"Awakened Equipment": "DEF Up Lvl 4",
		"Cat 1": "(Accessories)",
		"Acqusition": "Book 'Processing the Elements'"
	},
	"King of Thunder Ring": {
		"Level": "37",
		"Fire": "0",
		"Ice": "0",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened: Ice & Light. +2",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 4",
		"Awakened Recovery": "Temp SPD Up Lvl 4",
		"Awakened Equipment": "SPD Up Lvl 4",
		"Cat 1": "(Accessories)",
		"Acqusition": "Book 'Processing the Elements'"
	},
	"Gaia Earth Ring": {
		"Level": "37",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened: Fire & Earth +2",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 4",
		"Awakened Recovery": "Cleanses Impurity L",
		"Awakened Equipment": "Max HP Up Lvl 4",
		"Cat 1": "(Accessories)",
		"Acqusition": "Book 'Processing the Elements'"
	},
	"Music Note Symbol": {
		"Level": "37",
		"Fire": "0",
		"Ice": "2",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened TP Increase +10",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 4",
		"Awakened Recovery": "HP Recovery L",
		"Awakened Equipment": "DEF Up Lvl 3",
		"Cat 1": "(Symbols)",
		"Acqusition": "[Alchemyriddle] Enshrouded in Light (Sound) [Chapter of Truth]"
	},
	"Personal Key": {
		"Level": "37",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Metals)",
		"Acqusition": "Event STR_LIBRARY_BUILD_003"
	},
	"How to Make a Heavy Weight": {
		"Level": "37",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Chain of Karma": {
		"WT": "450",
		"Stun": "0",
		"Range": "Single",
		"Level": "38",
		"Fire": "0",
		"Ice": "3",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened: Earth +3",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 5",
		"Awakened Recovery": "Temp ATK Up Lvl 5",
		"Awakened Equipment": "SPD Up Lvl 5",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Karma in Chains, Chained to Karma [Chapter of Decisions]"
	},
	"Gomphrena": {
		"Level": "38",
		"Fire": "0",
		"Ice": "0",
		"Elec": "5",
		"Earth": "5",
		"Awakened Material": "Awakened (Threads)",
		"Awakened Attack (Bombs)": "Awakened (Threads)",
		"Awakened Recovery": "Awakened (Threads)",
		"Awakened Equipment": "Awakened (Threads)",
		"Cat 1": "(Plants)",
		"Location": "Fellsgalaxen, Rolling Hill, Fellsgalaxen: Another",
		"Monster": "Mellowshroom"
	},
	"World Spirit": {
		"Level": "38",
		"Fire": "0",
		"Ice": "4",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened (Animal Products)",
		"Awakened Attack (Bombs)": "Awakened (Animal Products)",
		"Awakened Recovery": "Awakened (Animal Products)",
		"Awakened Equipment": "Awakened (Animal Products)",
		"Cat 1": "(Mystery)",
		"Cat 2": "(Vapors)",
		"Location": "Orthogalaxen, Mt. Velus, Rolling Hill",
		"Monster": "Twilight Phantom, Eternal Darkness Demon, Marshall Puni, Celestial Emperor Adralda"
	},
	"Olgenrium": {
		"Level": "38",
		"Fire": "5",
		"Ice": "0",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened (Metals)",
		"Awakened Attack (Bombs)": "Awakened (Metals)",
		"Awakened Recovery": "Awakened (Metals)",
		"Awakened Equipment": "Awakened (Metals)",
		"Cat 1": "(Weapon Materials)",
		"Cat 2": "(Metals)",
		"Location": "Orthogalaxen",
		"Monster": "Huge Isle Fish, Machina of God",
		"Acqusition": "[Alchemyriddle] First Class Metal and Cloth [Chapter of Truth]"
	},
	"Himmel Linen": {
		"Level": "38",
		"Fire": "0",
		"Ice": "2",
		"Elec": "5",
		"Earth": "0",
		"Awakened Material": "Awakened (Cloth)",
		"Awakened Attack (Bombs)": "Awakened (Cloth)",
		"Awakened Recovery": "Awakened (Cloth)",
		"Awakened Equipment": "Awakened (Cloth)",
		"Cat 1": "(Armor Materials)",
		"Cat 2": "(Cloth)",
		"Location": "Orthogalaxen",
		"Monster": "Schwarz Vogel",
		"Acqusition": "[Alchemyriddle] First Class Metal and Cloth [Chapter of Truth]"
	},
	"Dragon Gun Gargantua": {
		"Level": "38",
		"Fire": "5",
		"Ice": "0",
		"Elec": "3",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire & Earth +3",
		"Awakened Attack (Bombs)": "Inflict Burns Lvl 5",
		"Awakened Recovery": "Temp ATK Up Lvl 3",
		"Awakened Equipment": "Evasion Up Lvl 4",
		"Cat 1": "(Cannons)",
		"Acqusition": "** Event/Quest **"
	},
	"Alchemy Coat": {
		"Level": "38",
		"Fire": "4",
		"Ice": "0",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened: Fire & Light. +2",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 5",
		"Awakened Recovery": "Temp EXP Up Lvl 5",
		"Awakened Equipment": "SPD Up Lvl 5",
		"Cat 1": "(Light Armor)",
		"Acqusition": "** Event/Quest **"
	},
	"Authorized Key": {
		"Level": "38",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "[Alchemyriddle] To Keep Hope Alive [Chapter of Decisions]"
	},
	"The World Tarot": {
		"Level": "39",
		"Fire": "1",
		"Ice": "5",
		"Elec": "1",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +15",
		"Awakened Attack (Bombs)": "Inflict Deadly Poison Lvl 5",
		"Awakened Recovery": "Cleanses Impurity M",
		"Awakened Equipment": "Skill Up Lvl 4",
		"Cat 1": "(Charms)",
		"Acqusition": "** Event/Quest **"
	},
	"Scarlet Anchor": {
		"Level": "39",
		"Fire": "2",
		"Ice": "4",
		"Elec": "1",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire +2",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 3",
		"Awakened Recovery": "HP Recovery M",
		"Awakened Equipment": "Max MP Up Lvl 3",
		"Cat 1": "(Anchors)",
		"Acqusition": "** Event/Quest **"
	},
	"Falling Star Symbol": {
		"Level": "39",
		"Fire": "3",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 4",
		"Awakened Recovery": "Removes Ailments",
		"Awakened Equipment": "Evasion Up Lvl 4",
		"Cat 1": "(Symbols)",
		"Acqusition": "[Alchemyriddle] Enshrouded in Light (Rainbow) [Chapter of Blank Pages]"
	},
	"Sands of Time": {
		"Level": "39",
		"Fire": "2",
		"Ice": "0",
		"Elec": "2",
		"Earth": "3",
		"Awakened Material": "Awakened: Ice & Earth +2",
		"Awakened Attack (Bombs)": "Inflict Slowness Lvl 4",
		"Awakened Recovery": "Temp SPD Up Lvl 4",
		"Awakened Equipment": "Ignores Luck L",
		"Cat 1": "(Clay)",
		"Cat 2": "(Mystery)",
		"Acqusition": "[Alchemyriddle] To Keep Hope Alive [Chapter of Decisions]"
	},
	"Memory Core": {
		"Level": "39",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "[Alchemyriddle] Changing the Past [Chapter of Blank Pages]"
	},
	"Ether Ink": {
		"WT": "350",
		"Stun": "0",
		"Range": "Single",
		"Level": "40",
		"Fire": "0",
		"Ice": "2",
		"Elec": "2",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +40",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 5",
		"Awakened Recovery": "Cleanses Impurity S",
		"Awakened Equipment": "ACC Up Lvl 3",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Magical Curative Agent [Chapter of Blank Pages]"
	},
	"Azure Wing": {
		"Level": "40",
		"Fire": "0",
		"Ice": "3",
		"Elec": "5",
		"Earth": "0",
		"Awakened Material": "Awakened (Elixirs)",
		"Awakened Attack (Bombs)": "Awakened (Elixirs)",
		"Awakened Recovery": "Awakened (Elixirs)",
		"Awakened Equipment": "Awakened (Elixirs)",
		"Cat 1": "(Gemstones)",
		"Cat 2": "(Mystery)",
		"Location": "Orthogalaxen, Holy Slumbering Tree",
		"Monster": "Garuda, White Hunter, Schwarz Vogel"
	},
	"Dunkelheit": {
		"Level": "40",
		"Fire": "3",
		"Ice": "5",
		"Elec": "3",
		"Earth": "5",
		"Awakened Material": "Awakened: Ice & Earth +3",
		"Awakened Attack (Bombs)": "Awakened: Ice & Earth +3",
		"Awakened Recovery": "Awakened: Ice & Earth +3",
		"Awakened Equipment": "Awakened: Ice & Earth +3",
		"Cat 1": "(Medicinal)",
		"Cat 2": "(Poisons)",
		"Cat 3": "(Elixirs)",
		"Cat 4": "(Plants)",
		"Location": "Eternal Spring, Orthogalaxen",
		"Monster": "Ancient Draco"
	},
	"Dragon's Eye": {
		"Level": "40",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Awakened Material": "Level Up",
		"Cat 1": "(Boost)",
		"Monster": "Ancient Draco, Sky Ruler Edra, Celestial Emperor Adralda, Lesser Draco, Draconia, Draconius, Old Dragon Emperor, Dragon Spirit of Oblivion"
	},
	"Moonbeam Veil": {
		"Level": "40",
		"Fire": "0",
		"Ice": "1",
		"Elec": "5",
		"Earth": "2",
		"Awakened Material": "Awakened: Ice +3",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 4",
		"Awakened Recovery": "Temp EXP Up Lvl 4",
		"Awakened Equipment": "ATK Up Lvl 4",
		"Cat 1": "(Battle Rings)",
		"Acqusition": "** Event/Quest **"
	},
	"True Dragon Hourglass": {
		"Level": "40",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened TP Increase +10",
		"Awakened Attack (Bombs)": "Inflict Sleep Lvl 3",
		"Awakened Recovery": "Temp ACC Up Lvl 3",
		"Awakened Equipment": "Add Ailments Resistance M",
		"Cat 1": "(Magic Tool)",
		"Cat 2": "(Mystery)",
		"Acqusition": "[Alchemyriddle] Parallel Universes [Chapter of Blank Pages]"
	},
	"Time Brooch": {
		"Level": "40",
		"Fire": "0",
		"Ice": "3",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Light. +2",
		"Awakened Attack (Bombs)": "Temp Critical Debuff Lvl 3",
		"Awakened Recovery": "Temp ACC Up Lvl 3",
		"Awakened Equipment": "Add Ailments Resistance L",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Parallel Universes [Chapter of Blank Pages]"
	},
	"N/A": {
		"WT": "1000",
		"Stun": "200",
		"Range": "Narrow Range",
		"Level": "41",
		"Fire": "3",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened (Bombs)",
		"Awakened Attack (Bombs)": "Fire DMG+ Lvl 5",
		"Awakened Recovery": "Temp Critical Rate Up Lvl 5",
		"Awakened Equipment": "Enhance Items Lvl 5",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Bomb of Ultimate Destruction [Chapter of Blank Pages]"
	},
	"Sacred Bird Wing": {
		"Level": "41",
		"Fire": "3",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened (Mystery)",
		"Awakened Attack (Bombs)": "Awakened (Mystery)",
		"Awakened Recovery": "Awakened (Mystery)",
		"Awakened Equipment": "Awakened (Mystery)",
		"Cat 1": "(Animal Products)",
		"Cat 2": "(Elixirs)",
		"Monster": "Garuda, White Hunter, Wind Stone, Schwarz Vogel"
	},
	"Aerven Staff of Light": {
		"Level": "41",
		"Fire": "3",
		"Ice": "0",
		"Elec": "0",
		"Earth": "5",
		"Awakened Material": "Awakened Quality Up +50",
		"Awakened Attack (Bombs)": "Awakened: Fire & Ice +3",
		"Awakened Recovery": "Damage Reducer Lvl 4",
		"Awakened Equipment": "ATK Up Lvl 4",
		"Cat 1": "(Alchemy Staffs)",
		"Acqusition": "** Event/Quest **"
	},
	"N/A Alpha": {
		"WT": "600",
		"Stun": "0",
		"Range": "Single",
		"Level": "42",
		"Fire": "0",
		"Ice": "3",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +15",
		"Awakened Attack (Bombs)": "Awakened TP Increase +15",
		"Awakened Recovery": "Awakened TP Increase +15",
		"Awakened Equipment": "Awakened TP Increase +15",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Forbidden Bomb Prototype Alpha [[Post-Game Secret Chapter]]"
	},
	"Valkyrie's Oath": {
		"Level": "42",
		"Fire": "2",
		"Ice": "1",
		"Elec": "0",
		"Earth": "5",
		"Awakened Material": "Awakened: Light. & Earth +3",
		"Awakened Attack (Bombs)": "Temp DEF Debuff Lvl 5",
		"Awakened Recovery": "Temp ACC Up Lvl 4",
		"Awakened Equipment": "DEF Up Lvl 5",
		"Cat 1": "(Long Swords)",
		"Acqusition": "** Event/Quest **"
	},
	"Flash Symbol": {
		"Level": "42",
		"Fire": "0",
		"Ice": "2",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened: Lightning +3",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 4",
		"Awakened Recovery": "Temp ACC Up Lvl 4",
		"Awakened Equipment": "Avoid KO Lvl 4",
		"Cat 1": "(Symbols)",
		"Acqusition": "[Alchemyriddle] Enshrouded in Light (Purple) [Chapter of Blank Pages]"
	},
	"Restore Core": {
		"Level": "42",
		"Fire": "0",
		"Ice": "0",
		"Elec": "0",
		"Earth": "0",
		"Cat 1": "(Important)",
		"Acqusition": "** Event/Quest **"
	},
	"Meteor": {
		"WT": "450",
		"Stun": "50",
		"Range": "All",
		"Level": "43",
		"Fire": "2",
		"Ice": "0",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened: Fire & Light. +2",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 5",
		"Awakened Recovery": "Temp ATK Up Lvl 3",
		"Awakened Equipment": "ATK Up Lvl 4",
		"Cat 1": "(Magic Tool)",
		"Acqusition": "[Alchemyriddle] Strength of Stars, Gift from Heavens [Chapter of Blank Pages]"
	},
	"N/A Beta": {
		"WT": "1000",
		"Stun": "200",
		"Range": "All",
		"Level": "43",
		"Fire": "3",
		"Ice": "0",
		"Elec": "3",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +15",
		"Awakened Attack (Bombs)": "Awakened TP Increase +15",
		"Awakened Recovery": "Awakened TP Increase +15",
		"Awakened Equipment": "Awakened TP Increase +15",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Forbidden Bomb Prototype Beta [[Post-Game Secret Chapter]]"
	},
	"Holy Sword Weiselende": {
		"Level": "43",
		"Fire": "1",
		"Ice": "2",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened (Elixirs)",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 5",
		"Awakened Recovery": "Temp Critical Power Up Lvl 5",
		"Awakened Equipment": "Ailments Resistance Lvl 5",
		"Cat 1": "ITEM_CATEGORY_RAPIER"
	},
	"N/A Gamma": {
		"WT": "1000",
		"Stun": "200",
		"Range": "Single",
		"Level": "44",
		"Fire": "0",
		"Ice": "0",
		"Elec": "3",
		"Earth": "3",
		"Awakened Material": "Awakened (Bombs)",
		"Awakened Attack (Bombs)": "Awakened (Bombs)",
		"Awakened Recovery": "Awakened (Bombs)",
		"Awakened Equipment": "Awakened (Bombs)",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Forbidden Bomb Prototype Gamma [[Post-Game Secret Chapter]]"
	},
	"God Speed Boots": {
		"Level": "44",
		"Fire": "2",
		"Ice": "0",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened Quality Up +50",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 5",
		"Awakened Recovery": "Temp SPD Up Lvl 5",
		"Awakened Equipment": "Faint Value Up Lvl 5",
		"Cat 1": "(Accessories)",
		"Acqusition": "Clear Alchemyriddle Chapter of Blank Pages"
	},
	"Ultimate Lululu Curry": {
		"WT": "350",
		"Stun": "0",
		"Range": "Single",
		"Level": "45",
		"Fire": "5",
		"Ice": "0",
		"Elec": "3",
		"Earth": "1",
		"Awakened Material": "Awakened: Fire & Light. +3",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 5",
		"Awakened Recovery": "HP Recovery XL",
		"Awakened Equipment": "Max HP Up Lvl 5",
		"Cat 1": "(Food)",
		"Acqusition": "Event STR_LIBRARY_BUILD_024"
	},
	"Himmelstein": {
		"WT": "500",
		"Stun": "150",
		"Range": "Single",
		"Level": "45",
		"Fire": "0",
		"Ice": "4",
		"Elec": "0",
		"Earth": "4",
		"Awakened Material": "Awakened (Poisons)",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 5",
		"Awakened Recovery": "Temp Critical Power Up Lvl 5",
		"Awakened Equipment": "Weaken Item Lvl 5",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Pinnacle of All Poisons [Chapter of Blank Pages]"
	},
	"Ghostly Long Sword": {
		"Level": "45",
		"Fire": "1",
		"Ice": "2",
		"Elec": "5",
		"Earth": "0",
		"Awakened Material": "Awakened: Fire & Ice +3",
		"Awakened Attack (Bombs)": "Temp SPD Debuff Lvl 5",
		"Awakened Recovery": "Damage Reducer Lvl 5",
		"Awakened Equipment": "Enhance Items Lvl 5",
		"Cat 1": "(Swords)",
		"Acqusition": "** Event/Quest **"
	},
	"Mythical Tome Atracalta": {
		"Level": "45",
		"Fire": "1",
		"Ice": "4",
		"Elec": "0",
		"Earth": "3",
		"Awakened Material": "Awakened (Magic Tool)",
		"Awakened Attack (Bombs)": "Ice DMG+ Lvl 5",
		"Awakened Recovery": "Cleanses Impurity L",
		"Awakened Equipment": "Enhance Items Lvl 5",
		"Cat 1": "ITEM_CATEGORY_ALCHEMY_BOOK"
	},
	"Dream Anchor Indigonia": {
		"Level": "46",
		"Fire": "1",
		"Ice": "5",
		"Elec": "0",
		"Earth": "2",
		"Awakened Material": "Awakened Quality Up +50",
		"Awakened Attack (Bombs)": "Faint Value Up Lvl 5",
		"Awakened Recovery": "Temp DEF Up Lvl 5",
		"Awakened Equipment": "Skill Up Lvl 5",
		"Cat 1": "(Anchors)",
		"Acqusition": "** Event/Quest **"
	},
	"Star Soul Staff": {
		"Level": "46",
		"Fire": "5",
		"Ice": "1",
		"Elec": "1",
		"Earth": "2",
		"Awakened Material": "Awakened TP Increase +15",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 5",
		"Awakened Recovery": "Temp ATK Up Lvl 5",
		"Awakened Equipment": "Evasion Up Lvl 5",
		"Cat 1": "(Decorative Staffs)",
		"Acqusition": "** Event/Quest **"
	},
	"Valkyrie Mail": {
		"Level": "46",
		"Fire": "0",
		"Ice": "4",
		"Elec": "4",
		"Earth": "0",
		"Awakened Material": "Awakened (Mystery)",
		"Awakened Attack (Bombs)": "Earth DMG+ Lvl 4",
		"Awakened Recovery": "Temp EXP Up Lvl 5",
		"Awakened Equipment": "Max HP Up Lvl 5",
		"Cat 1": "(Light Armor)",
		"Acqusition": "** Event/Quest **"
	},
	"N/A Omega": {
		"WT": "1500",
		"Stun": "200",
		"Range": "Single",
		"Level": "50",
		"Fire": "5",
		"Ice": "0",
		"Elec": "5",
		"Earth": "0",
		"Awakened Material": "Awakened TP Increase +15",
		"Awakened Attack (Bombs)": "Awakened TP Increase +15",
		"Awakened Recovery": "Awakened TP Increase +15",
		"Awakened Equipment": "Awakened TP Increase +15",
		"Cat 1": "(Bombs)",
		"Acqusition": "[Alchemyriddle] Final Ruin Bringer [[Post-Game Secret Chapter]]"
	},
	"Divine Auric Plate Armor": {
		"Level": "50",
		"Fire": "0",
		"Ice": "2",
		"Elec": "5",
		"Earth": "3",
		"Awakened Material": "Awakened (Metals)",
		"Awakened Attack (Bombs)": "Lightning DMG+ Lvl 5",
		"Awakened Recovery": "Add MP Recovery Lvl 5",
		"Awakened Equipment": "Enhance Items Lvl 5",
		"Cat 1": "(Heavy Armor)",
		"Acqusition": "** Event/Quest **"
	}
}     # This file is part of SyntViz.
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
         RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    line_spacing    font 
   font_size    font_color    outline_size    outline_color    shadow_size    shadow_color    shadow_offset    script 	   _bundled       Script    res://UI.gd ��������      local://LabelSettings_n40rj �         local://PackedScene_5peda �         LabelSettings                      PackedScene          	         names "   ;      UI    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    metadata/_edit_use_anchors_    Control    Vsplit    split_offset    dragger_visibility    VSplitContainer    HBoxContainer    custom_minimum_size    size_flags_vertical    MarginContainer    size_flags_horizontal %   theme_override_constants/margin_left $   theme_override_constants/margin_top &   theme_override_constants/margin_right '   theme_override_constants/margin_bottom    Label    text    label_settings    horizontal_alignment    vertical_alignment    text_direction    StartingSelect    unique_name_in_owner    OptionButton    MarginContainer2    VSplitContainer2    TargetSelect    Vsplit2    HSplitContainer    visible    VBoxContainer 
   FailCheck    expand_icon 	   CheckBox    EffectCheck    LvText $   theme_override_font_sizes/font_size 	   LvSlider 
   min_value 
   max_value    value    HSlider    Start    Button    ResultText 
   ColorRect    color    ScrollContainer    horizontal_scroll_mode    ItemContainer    Item    	   variants    #                    �?                               ����   ���
         C          P            ����      Starting Item                 Target Item    3���
         �B   K      
                Use Failures       Use Category Effects    (      U               Alchemy Level: 1      HB      Search            �?  �?  �?       2         
          B      node_count              nodes       ��������	       ����                                                                   
   ����                                                                    ����      	            
                          ����                                                         ����                                             ����                                                        ����                                        ����                                                      !   ����                                             ����                                                     "   ����                                    #   ����                                       $   $   ����                                      ����                                             ����   %                       &   &   ����                    )   '   ����                  
                (                 )   *   ����                  
                (                       ����                                             &   &   ����                       +   ����                     ,                                   1   -   ����                     .      /      0                        ����                                                         ����                    3   2   ����                      ,                             ����                                    4   ����                     ,                       5   5   ����                6                       ����
                                                 !                           7   7   ����         8   
              &   9   ����                                   :   ����            "                          conn_count              conns               node_paths              editable_instances              version             RSRC              # This file is part of SyntViz.
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

func transform_data(data: Array) -> void:
	var clean_data = {}
	var last_name = ""
	for i in range(data.size()):
		var dictionary = data[i]
		for key in dictionary.keys():
			if (
				dictionary[key] == ""
				or key == "Awakened Material"
				or key == "Awakened Attack (Bombs)"
				or key == "Awakened Recovery"
				or key == "Awakened Equipment"
				or key == "Cat 1"
				or key == "Cat 2"
				or key == "Cat 3"
			):
				dictionary.erase(key)

		if (dictionary.has("Name")) and (dictionary.has("Mat")):
			last_name = dictionary["Name"]
			clean_data[last_name] = {
				"Make #": dictionary["Make #"],
				"Uses": dictionary["Uses"],
				"Mats":
				[
					{
						"Name": dictionary["Mat"],
						"Qty": dictionary["Needed"],
						"Awake": dictionary.get("Awake", "NO")
					}
				],
				"Effects":
				[
					{
						"L Elem": dictionary.get("L Elem", ""),
						"R Elem": dictionary.get("R Elem", ""),
						"Effect 1": dictionary.get("Effect 1", ""),
						"Effect 2": dictionary.get("Effect 2", ""),
						"Effect 3": dictionary.get("Effect 3", ""),
						"Effect 4": dictionary.get("Effect 4", ""),
						"Effect 5": dictionary.get("Effect 5", ""),
						"Effect 6": dictionary.get("Effect 6", ""),
					}
				]
			}
		else:
			if dictionary.has("Mat"):
				clean_data[last_name]["Mats"].append(
					{
						"Name": dictionary["Mat"],
						"Qty": dictionary["Needed"],
						"Awake": dictionary.get("Awake", "NO")
					}
				)
			if dictionary.has("L Elem"):
				(
					clean_data[last_name]["Effects"]
					. append(
						{
							"L Elem": dictionary.get("L Elem", ""),
							"R Elem": dictionary.get("R Elem", ""),
							"Effect 1": dictionary.get("Effect 1", ""),
							"Effect 2": dictionary.get("Effect 2", ""),
							"Effect 3": dictionary.get("Effect 3", ""),
							"Effect 4": dictionary.get("Effect 4", ""),
							"Effect 5": dictionary.get("Effect 5", ""),
							"Effect 6": dictionary.get("Effect 6", ""),
						}
					)
				)


func cross_check_with_items(recipe: Dictionary, items: Dictionary):
	var removeList = []
	for recipe_item in recipe:
		if items.has(recipe_item):
			print("Item found in items: ", recipe_item)
		else:
			print("Item not found in items: ", recipe_item)
			removeList.append(recipe_item)

	for item in removeList:
		recipe.erase(item)
		print("Item removed from recipe: ", item)
          [remap]

path="res://.godot/exported/133200997/export-c3b50503a0477dc727cd659891fdb3c7-UI.scn"
 list=Array[Dictionary]([{
"base": &"Resource",
"class": &"AtelierMaterial",
"icon": "",
"language": &"GDScript",
"path": "res://atelier_resources/AtelierMaterial.gd"
}, {
"base": &"Resource",
"class": &"AtelierRecipe",
"icon": "",
"language": &"GDScript",
"path": "res://atelier_resources/AtelierRecipe.gd"
}, {
"base": &"Resource",
"class": &"AtelierRecipeBook",
"icon": "",
"language": &"GDScript",
"path": "res://atelier_resources/AtelierRecipeBook.gd"
}, {
"base": &"Resource",
"class": &"AtelierSynthesis",
"icon": "",
"language": &"GDScript",
"path": "res://atelier_resources/AtelierSynthesis.gd"
}])
 <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
              ��%Φ�   res://icon.svg�K�v�h7   res://UI.tscn         ECFG      application/config/name         SynthViz   application/run/main_scene         res://UI.tscn      application/config/features$   "         4.2    Forward Plus       application/config/icon         res://icon.svg  "   display/window/size/viewport_width         #   display/window/size/viewport_height      �              