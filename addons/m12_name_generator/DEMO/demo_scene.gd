extends Node

func _ready() -> void:
	
	#When you want to generate names, generate a new m12NameGeneratorObject
	var name_generator := m12NameGenerator.new()
	
	#The get_all_tags() method returns all tags available to the name generator for debug purposes
	var tag_list := name_generator.get_all_tags()
	tag_list.sort()
	print("List of all tags: " + str(tag_list))

	#Get a pool of names from the generator by passing an array of tags to generate_name_pool()
	#Rather than typing strings directly, they can be accessed as constants via m12NameGeneratorAutoTags
	#generate_name_pool() will return an array of names which possess all of the tags passed in as argument
	#If no tags are passed, generate_name_pool() will return all names in all sources
	var name_pool = name_generator.generate_name_pool([m12NameGeneratorAutoTags.MALE])
	print("Random English Name: " + name_pool.pick_random())
	
	#If you want your entities to have unique names, remove entries as you use them
	name_pool.shuffle()
	var unique_name : String = name_pool.pop_back()
	print("Is " + unique_name + " a unique name? It's " + str(not name_pool.has(name)) + "!")

	#If you want to see what tags a name has, access the dictionary in your m12NameGenerator instance with one of the names from it
	print("The tags for " + unique_name + " are " + str(name_generator.m12_name_dictionary[unique_name]))
