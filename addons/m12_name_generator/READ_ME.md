![](images\icon)

# m12 Name Generator
 An extensible name generator suitable for NPCs, units, town names, or whatever use you might have for random access to plaintext source files. Features an autotag system, a demo scene/script, and functions to assist with manipulating the collected data.

Portions of this code were adapted from the excellent plugin const_generator by tischenkob, specifically the functionality to access tags in code as constants.
If you appreciate that sort of thing and would like your whole project to have that convenience (seriously, super useful for groups,) check out [const_generator](https://github.com/game-gems/godot-const-generator) in the Godot Asset Library

# About m12 Name Generator

The m12 Name Generator provides a class which returns an array of words (presumably but not necessarily names) which, with minimal effort, can be used to generate random names for NPCs (e.g Alice, Bob Wilkins, Ms. Appleby), units (e.g 101st Airborne, Red Squadron), towns (North Sunnyville), or whatever else you want.

The generator derives these words from plaintext files located in the "sources" subfolder. These sources are extensible, meaning the user can add their own folders and files to this source folder and have their names generatable (csv and json files are currently not supported.)

These sources are organized with a tag system. Filenames and parent folder names are applied to their children automatically, and further tags can be defined in a "tags" file.

Tags can be accessed as constants in the editor from the class "m12NameGeneratorAutoTags", e.g m12NameGeneratorAutoTags.english

A demo scene located in the DEMO subfolder demonstrates some basic use cases of this name generator. "demo_scene.gd" provides code examples whose output is printed to console if you run the scene.

# Documentation

## Code

In the script you want to use the name generator, instantiate it as a new object with m12NameGenerator.new() At this time the object will read in all the names in the "sources" folder and add them to a dictionary as keys. The values of these keys is an array of strings, the tags used to access the names. Tags are applied automatically (see tags header below for details)

### Properties

m12_name_dictionary is the Dictionary generated to contain all the names (the words in the source files) as keys, with their values being an array of Strings used as tags. Accessing the data in this dictionary is best done through the built in functions below.

### Methods

generate_name_pool(tags_to_get: Array[String], tags_to_exclude: Array[String]) method returns an array of names which contain ALL of the tags in the tags_to_get array and NONE of the tags in tags_to_exclude. It is used to extract the words from m12_name_dictionary. If a name has the "m12_defaults", "english", and "male" tags, for example, then passing in any one of those tags will result in that name being added to the name pool. If passing in ["male","female"], by contrast, then the returned names will have BOTH tags, and if no name in m12_name_dictionary has all tags in the array (the likely result from, say, ["male", "color"]) then an empty array will be returned.

get_all_tags() returns a dictionary of all the tags that m12NameGenerator can see (sorted alphabetically by tag) paired with their frequency of occurence in the sources. Useful for debugging if your tags are not functioning as expected, or basic analysis of your tags

name_has_tag(name: String, tag: String) returns true if the name has the tag, false otherwise (or if the name does not exist in m12_name_dictionary.) Useful for logic, for example determining whether a random name has the male tag.

names_share_a_tag(name1: String, name2: String, excluded_names: Array[String]) returns true if the names share a tag that is not also in the optional list of excluded tags (useful for excluding high-level folder tags) and false otherwise

filter_pool_for_tag(name_pool: Array[String], tag: String) returns an array of names from the provided name pool which all have the provided tag. Useful for refining already generated name pools

create_compound_name(names: Array[String], single_word: bool) takes the array of names, merges them with a space in between, then capitalizes the result and returns it. If single_word is true, the names are merged with no spaces in between (will e.g return "Goldmane" instead of "Gold Mane")

create_x_the_y(x_name: String, y_name: String) returns the names capitalized with " the " in between. Useful for making name structures like "Clooney the Scourge" or "Arthur the Black"

For examples of some of the ways you can build or manipulate names, refer to demo_scene.gd in the DEMO folder

## Sources

The sources folder is where m12NameGenerator looks to pull names from. It expects names to be stored in plaintext files (e.g .txt, .md) within subfolders of the sources folder. These files should have only the names separated by commas or newline (\n) breaks. There is some tolerance for stripping spaces and tabs and things, but otherwise the m12NameGenerator does not attempt to format the source files (no automatic capitalization of names, for example.) There is currently not support for .csv or .json files

m12 Name Generator comes bundled with the m12_defaults source, which serve as a working example of sources and tags in action. I say "working" because they're the curated lists of names and name compounds I want to generate in my own games. Feel free to copy, cull, reorganize, or remove these files as suits your purpose.

You can add your own sources easily. First, add a subfolder to the "sources" folder. Then add your text files to that subfolder (or subfolders) and they will be automatically found by m12NameGenerator! Note that files placed directly in "sources" will not be used- add them to a subfolder. Names are allowed to exist in more than one source location; such names will merely gain additional tags (for example, while male and female are seperate files (and thus tags) in m12_defaults/english, unisex names appearing in both files will be tagged both male and female.)

### Exporting

Because .txt and .md files are not automatically treated as resources by Godot, they will NOT be added to your exported project automatically. In order to use m12NameGenerator in an exported project you will need to manually set the non-resource export filter in the Export dialog to include the file extensions of your sources (e.g *.txt, *.md). Consult the [FileAccess documentation](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html) and/or m12_export_settings.jpg to see exactly what you need to change.

## Tags

Tags are added to names as they are added to the m12NameGenerator Dictionary. Tags are applied automatically. All names have at least one tag- the name of the file they were found in. They also are tagged with the name of the subfolders they are found in (so really, at least 2 tags since files cannot be placed directly in the "sources" folder.) Nesting folders is one way of applying more granular tags to a name file, for example the file m12_defaults/descriptors/adjectives/color/common_colors.txt will apply 5 tags to the names in that file automatically.

A more direct way is to create a "tags" file alongside the files you wish to tag, as demonstrated in the m12_defaults/english folder. The "tags" file must be called that exactly, and is case-sensitive. The tags within this file should be formatted the same as the names in the source files. This method is useful for applying multiple tags to source files without making an unnecessarily complicated file system.

Tags work across source folders. For example, if you have a file with french male names called "male" in your "french" folder, and a file with english male names called "male" in your "english" folder, those names will all get the same "male" tag. To access names from a specific file it is recommended to pass generate_name_pool() the tag for the file you want as well as the tag for its parent folder. If you know you will never want this tagging functionality (either for a single file or across your sources) simply give each filename a unique name, and thus identifying tag.

m12NameGeneratorAutoTags is a class which automatically collects all the tags being used in the project and saves them as constants for in-editor reference and autocomplete. This class is updated by m12_name_generator.gd when the project starts and every 5 seconds thereafter by default. This update happens in a separate thread, so there should be no lag in the editor itself, but be aware there may be performance implications on older hardware, particularly with large sources. This behavior can be changed in m12_name_generator.gd, including making updates only happen on project load.

m12_name_generator only runs in the editor, not the exported project, meaning that master_tag_list.gd will not be created/updated at that point. Be sure it is up to date before exporting!

# Support

If you have an issue, be it bug report, feature request, or documentation request, refer to https://github.com/monk125/m12-name-generator/issues
