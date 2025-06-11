# <img src="media/logo.png" width="48" height="48"> m12 Name Generator
 An extensible name generator suitable for NPCs or units, based on plaintext source files

Portions of this code were adapted from the excellent plugin const_generator by tischenkob, specifically the functionality to access tags in code as constants.
If you appreciate that sort of thing and would like your whole project to have that convenience, check out [const_generator](https://github.com/game-gems/godot-const-generator) in the Godot Asset Library

# About m12 Name Generator

The m12 Name Generator provides a class which returns an array of words (presumably but not necessarily names) which, with minimal effort, can be used to generate random names for NPCs (e.g Alice, Bob Wilkins, Ms. Appleby), units (e.g 101st Airborne, Red Squadron), towns (North Sunnyville), or whatever else you want.

The generator derives these words from plaintext files located in the "sources" subfolder. These sources are extensible, meaning the user can add their own folders and files to this source folder and have their names generatable (csv and json files are currently not supported.)

These sources are organized with a tag system. Filenames and parent folder names are applied to their children automatically, and further tags can be defined in a "tags" file.

Tags can be accessed as constants in the editor from the class "m12NameGeneratorAutoTags", e.g m12NameGeneratorAutoTags.m12_english

A demo scene located in the DEMO subfolder demonstrates some basic use cases of this name generator. "demo_scene.gd" provides code examples whose output is printed to console if you run the scene.

# Documentation

## Code

In the script you want to use the name generator, instantiate it as a new object with m12NameGenerator.new() At this time the object will read in all the names in the "sources" folder and add them to a dictionary as keys. The values of these keys is an array of strings, the tags used to access the names. Tags are applied automatically (see tags header below for details)

To extract the words from the object, the generate_name_pool() method returns an array of names based on the array of tags passed in. If a name has the "m12_english", "english_male", and "american" tags, for example, then passing in any one of those tags will result in that name being added to the name pool

m12NameGenerator also has a get_all_tags() method which returns an array of all the tags that m12NameGenerator can see. Useful for debugging if your tags are not functioning as expected

For examples of some of the ways you can build or manipulate names, refer to demo_scene.gd in the DEMO folder

## Sources

The sources folder is where m12NameGenerator looks to pull names from. It expects names to be stored in plaintext files (e.g .txt, .md) within subfolders of the sources folder. These files should have only the names seperated by commas or newline (\n) breaks. There is some tolerance for stripping spaces and tabs and things, but otherwise the m12NameGenerator does not attempt to format the source files (no automatic capitalization of names, for example.) There is currently not support for .csv or .json files

You can add your own sources easily. First, add a subfolder to the "sources" folder. Then add your text files to that subfolder (or subfolders) and they will be automatically found by m12NameGenerator! Note that files placed directly in "sources" will not be used- add them to a subfolder.

Because .txt and .md files are not automatically treated as resources by Godot, they will NOT be added to your exported project automatically. In order to use m12NameGenerator in an exported project you will need to manually set the non-resource export filter in the Export dialog to include the file extensions of your sources (e.g *.txt, *.md). Consult the FileAccess documentation and/or m12_export_settings.jpg to see exactly what you need to change.

## Tags

Tags are added to names as they are added to the m12NameGenerator Dictionary. Tags are applied automatically. All names have at least one tag- the name of the file they were found in. They also are tagged with the name of the subfolders they are found in. Nesting folders is one way of applying more granular tags to a name file, and is demonstrated in the m12_ordinal_numbers folder. A more direct way is to create a "tags" file alongside the files you wish to tag, as demonstrated in the m12_english folder. The "tags" file must be called that exactly, and is case-sensitive. The tags within this file should be formatted the same as the names in the source files.

m12NameGeneratorAutoTags is a class which automatically collects all the tags being used in the project and saves them as constants for in-editor reference and autocomplete. This class updates itself when the project starts and every 5 seconds thereafter by default. This behavior can be changed in m12_name_generator.gd
