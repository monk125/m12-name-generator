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
			
	return collected_tags


## Takes a local filepath, returns the name without the extension
func _strip_path(path: String) -> String:
	var file_extension := path.get_extension()
	if file_extension:
		path = path.get_file()
		path = path.get_slice(".", 0)
	return path


## Optionally pass an Array of tags, return an Array of names (if no tags, all names will be returned)
func generate_name_pool(tags: Array[String] = []) -> Array[String]:
	if not tags:
		return m12_name_dictionary.keys()
	var name_pool : Array[String] = []
	for name: String in m12_name_dictionary.keys():
		for tag: String in tags:
			if m12_name_dictionary[name].has(tag):
				name_pool.append(name)
	
	return name_pool


## Returns an Array of all the tags m12NameGenerator can see. Useful for debugging
func get_all_tags() -> Array[String]:
	var tag_list : Array[String] = []
	for name: String in m12_name_dictionary.keys():
		for tag: String in m12_name_dictionary[name]:
			if not tag_list.has(tag):
				tag_list.append(tag)
	return tag_list
