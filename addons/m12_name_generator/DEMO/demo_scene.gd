extends Node

func _ready() -> void:
	
	#When you want to generate names, generate a new m12NameGeneratorObject
	var name_generator := m12NameGenerator.new()
	
	#The get_all_tags() method returns all tags available to the name generator for debug purposes
	var tag_list := name_generator.get_all_tags()
	print("List of all tags: " + str(tag_list))

	#Get a pool of names from the generator by passing an array of tags to generate_name_pool()
	#Rather than typing strings directly, they can be accessed as constants via m12NameGeneratorAutoTags
	#generate_name_pool() will return an array of names which possess all of the tags passed in as argument
	#If no tags are passed, generate_name_pool() will return all names in all sources
	var name_pool := name_generator.generate_name_pool([m12NameGeneratorAutoTags.MALE])
	print("Random Male Name: " + name_pool.pick_random())
	
	#You can also pass tags to exclude from the result
	var full_color_pool := name_generator.generate_name_pool([m12NameGeneratorAutoTags.COLOR])
	var culled_color_pool := name_generator.generate_name_pool([m12NameGeneratorAutoTags.COLOR], [m12NameGeneratorAutoTags.X_11_COLORS])
	print("Full color pool has " + str(full_color_pool.size()) + " entries, culling x11 brings it down to " + str(culled_color_pool.size()))
	
	#Be sure to check that you actually got names back, in case no results match your tags
	var empty_name_pool:= name_generator.generate_name_pool([m12NameGeneratorAutoTags.MALE, m12NameGeneratorAutoTags.CRYPTID])
	print("How many names were found tagged both Male and Cryptid? " + str(empty_name_pool.size()))
	
	#If you want your entities to have unique names, remove entries as you use them
	name_pool.shuffle()
	var unique_name : String = name_pool.pop_back()
	print("Is " + unique_name + " a unique name? It's " + str(not name_pool.has(name)) + "!")

	#Be aware of the format your names are in, and whether they need help from String methods for formatting
	#For compound names, m12NameGenerator has a helper function called create_compound_name to glue the names together (literally if single_word is true)
	var animal_pool := name_generator.generate_name_pool([m12NameGeneratorAutoTags.ANIMALS])
	var scary_name := name_generator.create_compound_name([culled_color_pool.pick_random(), animal_pool.pick_random()])
	var sidekick_last_name := name_generator.create_compound_name([culled_color_pool.pick_random(), animal_pool.pick_random()], true)
	var sidekick_name := name_generator.create_compound_name([name_pool.pick_random(), sidekick_last_name])
	print("Behold, the brave knight known only as the " + scary_name + " and their squire, " + sidekick_name)
	
	#The helper function create_x_the_y can be used to generate names in the form of "Clooney the Scourge"
	var personality_trait_pool := name_generator.generate_name_pool([m12NameGeneratorAutoTags.PERSONALITY])
	var liege_name := name_generator.create_x_the_y_name(name_pool.pick_random(), personality_trait_pool.pick_random())
	print("He fights on behalf of his liege, " + liege_name)

	#If you want to see what tags a name has, access the dictionary in your m12NameGenerator instance with one of the names from it
	print("The tags for " + unique_name + " are " + str(name_generator.m12_name_dictionary[unique_name]))
	
	#You can check for a particular tag at runtime with the helper function name_has_tag()
	#The function names_share_a_tag() can be used to find pairs in large name pools. Here unique_name is a random male name, surname_pool is a pool of surnames, neither is sorted by source but names_share_a_tag() can be used to pick a surname with a matching origin to unique_name
	var formal_name: String
	var male_honorifics_pool := name_generator.generate_name_pool([m12NameGeneratorAutoTags.HONORIFICS_MALE])
	var female_honorifics_pool := name_generator.generate_name_pool([m12NameGeneratorAutoTags.HONORIFICS_FEMALE])
	var surname_pool := name_generator.generate_name_pool([m12NameGeneratorAutoTags.SURNAME])
	var matching_surname := surname_pool.filter(func(surname: String): return name_generator.names_share_a_tag(unique_name, surname,[m12NameGeneratorAutoTags.M_12_DEFAULTS, m12NameGeneratorAutoTags.MALE, m12NameGeneratorAutoTags.FEMALE])).pick_random()
	if name_generator.name_has_tag(unique_name, m12NameGeneratorAutoTags.MALE):
		formal_name= name_generator.create_compound_name([male_honorifics_pool.pick_random(), unique_name, matching_surname])
	else:
		formal_name= name_generator.create_compound_name([female_honorifics_pool.pick_random(), unique_name, matching_surname])
	print("To " + formal_name + ",")
