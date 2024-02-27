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
