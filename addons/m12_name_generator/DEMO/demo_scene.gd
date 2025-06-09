extends Node


func _ready() -> void:
	var name_generator := m12NameGenerator.new()
	print(name_generator.m12_name_dictionary["Marli"])
