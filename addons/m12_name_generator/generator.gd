## Class which populates a dictionary of names and tags when instantiated
class_name m12NameGenerator
extends RefCounted

const SOURCES_PATH := "res://addons/m12_name_generator/sources/"

var m12_name_dictionary : Dictionary[String, Array] = {}

func _init() -> void:
	
	var dir := DirAccess.open(SOURCES_PATH)

	if dir:
		var source_dirs := dir.get_directories()
		if source_dirs.size() > 0:
			for source_path: String in source_dirs:
				var source_tags : Array[String] = []
				var next_dir := DirAccess.open(SOURCES_PATH.path_join(source_path))
				_check_dir(next_dir, SOURCES_PATH.path_join(source_path), source_tags)
				
	else:
		printerr("Sources Folder not found!")
		

func _check_dir(dir: DirAccess, path: String, collected_tags: Array[String]) -> Array[String]:
	var file_list := dir.get_files()
	var dir_tags: Array[String] = []
	if not collected_tags.has(dir.get_current_dir().get_file()):
		collected_tags.append(dir.get_current_dir().get_file())
	if file_list.size() > 0:
	
		for file_list_entry: String in file_list:
			if _strip_path(file_list_entry) == "tags":
				var file_path := path.path_join(file_list_entry)
				var file := FileAccess.open(file_path, FileAccess.READ)
				var file_contents := file.get_file_as_string(file_path)
				file_contents= file_contents.replace("\n", ",")
				var file_contents_list := file_contents.split(",", false)
				for tag: String in file_contents_list:
					tag= tag.strip_edges()
					if not collected_tags.has(tag):
						collected_tags.append(tag)
						dir_tags.append(tag)
				file.close()
		
		for file_list_entry: String in file_list:
			var file_path := path.path_join(file_list_entry)
			var file := FileAccess.open(file_path, FileAccess.READ)
			var file_contents := file.get_file_as_string(file_path)
			file_contents= file_contents.replace("\n", ",")
			var file_contents_list := file_contents.split(",", false)
			if _strip_path(file_list_entry) == "tags":
				continue
			else:
				for name_string : String in file_contents_list:
					name_string= name_string.strip_edges()
					var new_tags : Array[String] = [_strip_path(path.get_file()), _strip_path(file_path)]
					for source_tag: String in collected_tags:
						if not new_tags.has(source_tag):
							new_tags.append(source_tag)
					if m12_name_dictionary.has(name_string):
						for tag : String in new_tags:
							if not m12_name_dictionary[name_string].has(tag):
								m12_name_dictionary[name_string].append(tag)
					else:
						m12_name_dictionary[name_string]= new_tags
			file.close()
	
	for sub_dir in dir.get_directories():
		var sub_dir_path := dir.get_current_dir().path_join(sub_dir)
		if not collected_tags.has(sub_dir):
			collected_tags.append(sub_dir)
		var current_dir := dir.get_current_dir()
		dir.change_dir(sub_dir_path)
		_check_dir(dir, sub_dir_path, collected_tags)
		collected_tags.erase(sub_dir)
		dir.change_dir(current_dir)
	
	for dir_tag in dir_tags:
		collected_tags.erase(dir_tag)
		
	return collected_tags


## Takes a local filepath, returns the name without the extension
func _strip_path(path: String) -> String:
	var file_extension := path.get_extension()
	if file_extension:
		path = path.get_file()
		path = path.get_slice(".", 0)
	return path


## Optionally pass an Array of tags to get, return an Array of names which have ALL tags (if no tags to get, all names in sources will be returned)
## Any matches to excluded_tags will remove a name from output
func generate_name_pool(tags_to_get: Array[String] = [], excluded_tags: Array[String] = []) -> Array[String]:
	if not tags_to_get:
		return m12_name_dictionary.keys()
	var name_pool : Array[String] = []
	for name: String in m12_name_dictionary.keys():
		if excluded_tags.any(func(tag): return m12_name_dictionary[name].has(tag)):
			break
		if tags_to_get.all(func(tag): return m12_name_dictionary[name].has(tag)):
			name_pool.append(name)
	
	return name_pool


## Returns an Dictionary with all the tags m12NameGenerator can see as well as their frequency. Useful for debugging or basic analysis
func get_all_tags() -> Dictionary[String, int]:
	var tag_list : Dictionary[String, int]
	for name: String in m12_name_dictionary.keys():
		for tag: String in m12_name_dictionary[name]:
			if not tag_list.has(tag):
				tag_list[tag]= 1
			else:
				tag_list[tag] += 1
	tag_list.sort()
	return tag_list
	
	
## Returns whether the name has the given tag
func name_has_tag(name: String, tag: String) -> bool:
	if m12_name_dictionary.has(name):
		if m12_name_dictionary[name].has(tag):
			return true
	return false


## Returns whether two names share a tag, ignoring a set of excluded tags
func names_share_a_tag(name1: String, name2: String, excluded_tags: Array[String] = []) -> bool:
	if m12_name_dictionary.has(name1) and m12_name_dictionary.has(name2):
		for tag : String in m12_name_dictionary[name1]:
			if name_has_tag(name2, tag) and not excluded_tags.has(tag):
				return true
	return false


## Returns an array of names from the provided name pool which all have the provided tag. Useful for refining already generated name pools
func filter_pool_for_tag(name_pool: Array[String], tag: String) -> Array[String]:
	return name_pool.filter(func(name): return name_has_tag(name, tag))


## Returns the names fed in capitalized and with spaces between them. If single_word is true, returns the compound without spaces (e.g Blackhound instead of Black Hound, be careful if your source files already include compound names)
func create_compound_name(names: Array[String], single_word := false) -> String:
	var compound_name: String = ""
	var interstitial: String = " "
	if single_word:
		interstitial= ""
	for name : String in names:
		compound_name= compound_name + name + interstitial
	compound_name= compound_name.strip_edges()
	compound_name= compound_name.capitalize()
	return compound_name


##Returns the names given capitalized with " the " in between them. Useful for name structures like "Rodric the Bold" or "Clooney the Scourge"
func create_x_the_y_name(x_name: String, y_name: String) -> String:
	x_name= x_name.capitalize()
	y_name= y_name.capitalize()
	var full_name : String = x_name + " the " + y_name
	return full_name
