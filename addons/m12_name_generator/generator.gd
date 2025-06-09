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
				var file_list := next_dir.get_files()
				if file_list.size() > 0:
					
					for file_list_entry: String in file_list:
						if strip_path(file_list_entry) == "tags":
							var file_path := (SOURCES_PATH.path_join(source_path)).path_join(file_list_entry)
							var file := FileAccess.open(file_path, FileAccess.READ)
							var file_contents := file.get_file_as_string(file_path)
							file_contents= file_contents.replace("\n", ",")
							var file_contents_list := file_contents.split(",", false)
							for tag: String in file_contents_list:
								tag= tag.strip_edges()
								source_tags.append(tag)
							file.close()
					
					for file_list_entry: String in file_list:
						var file_path := (SOURCES_PATH.path_join(source_path)).path_join(file_list_entry)
						var file := FileAccess.open(file_path, FileAccess.READ)
						var file_contents := file.get_file_as_string(file_path)
						file_contents= file_contents.replace("\n", ",")
						var file_contents_list := file_contents.split(",", false)
						if strip_path(file_list_entry) == "tags":
							continue
						else:
							for name_string : String in file_contents_list:
								name_string= name_string.strip_edges()
								var new_tags : Array[String] = [source_path, strip_path(file_path)]
								for source_tag: String in source_tags:
									if not new_tags.has(source_tag):
										new_tags.append(source_tag)
								if m12_name_dictionary.has(name_string):
									for tag : String in new_tags:
										if not m12_name_dictionary[name_string].has(tag):
											m12_name_dictionary[name_string].append(tag)
								else:
									m12_name_dictionary[name_string]= new_tags
						file.close()
	else:
		printerr("Sources Folder not found!")


func strip_path(path: String) -> String:
	var file_extension := path.get_extension()
	if file_extension:
		path = path.get_file()
		path = path.get_slice(".", 0)
	return path


func generate_name_pool(tags: Array[String] = []) -> Array[String]:
	if not tags:
		return m12_name_dictionary.keys()
	var name_pool : Array[String] = []
	for name: String in m12_name_dictionary.keys():
		for tag: String in tags:
			if m12_name_dictionary[name].has(tag):
				name_pool.append(name)
	
	return name_pool
