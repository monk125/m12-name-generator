@tool
extends EditorPlugin


## This sets whether the master tag list is only updated when the project loads
const ONLY_RUN_ON_LOAD := false
## This is how often the project is scanned for changes (in seconds)
const GENERATION_FREQUENCY := 5.0

## The path to where the names and tags live
const SOURCES_PATH := "res://addons/m12_name_generator/sources/"

## The path to where all tags are stored
const MASTER_TAG_LIST_PATH = "res://addons/m12_name_generator/master_tag_list.gd"

## The class name that will be generated
const GENERATED_CLASS_NAME := "m12NameGeneratorAutoTags"

## The plugin name is used for debug identification
const PLUGIN_NAME := "m12_name_generator"

## Print debug messages
const DEBUG := false

var illegal_symbols_regex: RegEx
var previous_tags_list_array: Array[String]
var mutex: Mutex

func _enter_tree() -> void:
	if not Engine.is_editor_hint(): return

	mutex = Mutex.new()
	illegal_symbols_regex = RegEx.create_from_string("[^\\p{L}\\p{N}_]")
	
	var timer := Timer.new()
	timer.name = PLUGIN_NAME.to_pascal_case() + "Timer"
	timer.wait_time = GENERATION_FREQUENCY
	timer.one_shot = ONLY_RUN_ON_LOAD
	timer.autostart = true
	timer.timeout.connect(WorkerThreadPool.add_task.bind(generate_filepath_class, false, "Generating filepaths"))
	add_child(timer)

	
func debug(message: String):
	if DEBUG: print_debug(Time.get_time_string_from_system(), " [", PLUGIN_NAME, "] ", message)


func generate_filepath_class() -> void:
	if not mutex.try_lock(): return
	var walking_started := Time.get_ticks_usec()


	var current_sources_tags := walk(SOURCES_PATH)
	if previous_tags_list_array == current_sources_tags:
		return

	debug("Generating " + GENERATED_CLASS_NAME + " class...")

	var generated_file := FileAccess.open(MASTER_TAG_LIST_PATH, FileAccess.WRITE)
	generated_file.store_line("## Provides access to all m12NameGenerator tags as constants. Updates every ~" + str(GENERATION_FREQUENCY) +"s. Edit frequency of update in m12_name_generator.gd")
	generated_file.store_line("class_name " + GENERATED_CLASS_NAME)
	for tag in current_sources_tags:
		write_tag_to_file(generated_file, tag)
	generated_file.close()

	debug("Finished in %dms" % ((Time.get_ticks_usec() - walking_started) / 1000))
	previous_tags_list_array = current_sources_tags
	mutex.unlock()

func write_tag_to_file(generated_file: FileAccess, tag: String) -> void:
	if not tag: return
	
	var tag_name := tag.to_snake_case().to_upper()
	tag_name = illegal_symbols_regex.sub(tag_name, "_", true)
	generated_file.store_line("const %s = \"%s\"" % [tag_name, tag])

func walk(path: String) -> Array[String]:
	var tag_list: Array[String] = []
	
	var walker := DirAccess.open(path)
	_walk(walker, tag_list)
	return tag_list

func _walk(walker: DirAccess, collected_tags: Array[String]) -> void:
	walker.list_dir_begin()

	var current_dir := walker.get_current_dir()
	for file in walker.get_files():
		var file_path := current_dir.path_join(file)
		var extension := file.get_extension()
		if extension:
			var file_name := file.get_file().rstrip("." + extension)
			if file_name == "tags":
				collected_tags.append_array(_get_tags_from_tag_file(file_path))
			else:
				if not collected_tags.has(file_name):
					collected_tags.append(file_name)

	for dir in walker.get_directories():
		var dir_path := current_dir.path_join(dir)
		if not collected_tags.has(dir):
			collected_tags.append(dir)

		walker.change_dir(dir_path)
		_walk(walker, collected_tags)

	walker.list_dir_end()
	
func _get_tags_from_tag_file(path: String) -> Array[String]:
	var open_file:= FileAccess.open(path, FileAccess.READ)
	var file_contents:= open_file.get_file_as_string(path)
	file_contents= file_contents.replace("\n", ",")
	var file_contents_list := file_contents.split(",", false)
	var tag_list : Array[String]
	for tag: String in file_contents_list:
		tag= tag.strip_edges()
		if not tag_list.has(tag):
			tag_list.append(tag)
	return tag_list
