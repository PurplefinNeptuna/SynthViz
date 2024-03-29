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
