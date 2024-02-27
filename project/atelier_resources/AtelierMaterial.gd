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
