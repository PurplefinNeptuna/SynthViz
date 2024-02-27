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
