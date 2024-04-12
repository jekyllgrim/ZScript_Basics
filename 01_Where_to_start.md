🟢 [<<< BACK TO START](README.md)

🔵 [>> Next: Defining classes in zscript](02_Defining_ZScript_classes.md)

------

# Where to start

## What is ZScript?

[ZScript](https://zdoom.org/wiki/ZScript) is a coding language used by the [GZDoom](https://zdoom.org/index) source port. ZScript allows to define the following aspects of the game:

* Player classes (also known as [player pawns](https://zdoom.org/wiki/Classes:PlayerPawn))
* Weapons and items
* Enemies, props, and other objects that can be spawned in the world
* UI elements such as game menus and heads-up display / statusbar

## How do I start coding in zscript?

### Preface

GZDoom projects can exist in 3 forms:

1. A WAD file. <u>This format should not be used for anything besides maps.</u> WAD is the oldest file format that dates back to the original Doom. WAD is an **ordered** archive type. This means that, everything in it has to be in a specific order, and special markers (empty files with special names) must be used to mark specific file types (for examplel to separate graphics that function as in-game sprites, from graphics that function as map textures). This file format can only be edited with specialized tools, like the  [SLADE archive manager](https://slade.mancubus.net/) made specifically for editing old game archives.
   **Maps** made for Doom or any of its source ports, including GZDoom, *must* be in the WAD format (no other format will work). While it's also possible to add custom assets and code into a WAD, it's very much not recommended. A WAD file is very hard to organize, because it relies on specific order of things, all file names are limited to 8 characters, and it doesn't support subfolders. It's strongly recommended to only use the WAD format for maps, and use other options for code and assets.

2. A PK3 file. PK3 is just a ZIP archive whose extension was manually changed from "zip" to "pk3" to signify that it's not supposed to be unpacked, and instead should be loaded into GZDoom directly. To function properly in GZDoom, this archive has to utilize a specific set of subfolders with specific names (for example, `/sprites/` for all actor sprites, `/sounds/` for sounds, and so on). 
   Shipping projects as PK3 archives is the most common approach nowadays. In a PK3 you can use long file names and subfolders, the archive doesn't rely on the order or markers to function (markers are not needed at all), and is in general vastly more convenient to use.
   The use of PK3 and the folders that must be added to it are [described on ZDoom Wiki](https://zdoom.org/wiki/Using_ZIPs_as_WAD_replacement).

3. A folder. In essence, this would be the same PK3 archive, but in an unpacked form. If a folder is structured the same way as a PK3 archive would (with the same subfodler names and such), it can be loaded into GZDoom the same way a PK3 archive would. It's recommended to use folders while working on a project, and only pack them into a PK3 archive to upload your completed project somewhere. The advantage of using a folder is that you don't have to rely on SLADE for all your editing, instead you can directly open any file format with any tool your like (note that SLADE will still be required for a few very specific operations, but SLADE *can* open folders the same way it can open PK3/WAD files).
   The disadvantage is that SLADE, while being able to automatically make backups for PK3/WAD files, does *not* back up folders. However, I very much don't recommend relying on SLADE backups anyway, because they're nowhere as safe or robust as a dedicated backup system could be. Nowadays, most big projects are backed up via a [GitHub reposotry](https://docs.github.com/en/repositories/creating-and-managing-repositories/quickstart-for-repositories) (which is easy to set up and free to use); a repository offers detailed tracking of all your changes, detailed version history, and it saves *all changes ever made* to your project, so you never lose any work.
   Using folders instead of archives is also [described on ZDoom Wiki](https://zdoom.org/wiki/Using_ZIPs_as_WAD_replacement#Using_folders_instead_of_archives).

### Step #1: Make a folder for your project

Create a folder with the name of your choice (such as the name of your future project). In that folder create a text file called `zscript`; you can use any file extension (`.zsc` and `.zs` are some of the common options, but `.txt` will work just the same), or even no extension at all (GZDoom doesn't care about file extensions in general, since it can see the type of the  file directly).

### Step #2: Choose editing method

You can use one of the following approaches to edit ZScript files:

1. [SLADE](https://slade.mancubus.net/index.php?page=downloads) archive manager. It's a specialized tool that can edit .wad, .pk3 and many other file formats, as well as folders, and it has a number of unique features that are required for proper GZDoom modding (such as image offsetting). Using Slade, just open the mod folder you created, click on your `zscript.zs` file, and a text editing window will open. If the file's extension is `.zs` or `.zsc`, the code in it will be automatically highlighted.
2. Use a code editing software: some of the simplest choices are [Notepad++](https://notepad-plus-plus.org/downloads/) and [Textpad](https://www.textpad.com/products/textpad/intro). You'll need to download a [syntax highlighting plugin](https://forum.zdoom.org/viewtopic.php?f=3&t=46674) to make sure Notepad++/Textpad will properly highlight your ZScript code. Either of those editors is faster to use than SLADE's built-in editor, and allows easy multi-window/multi-tab editing, so for pure coding purposes it's preferable.
   A more powerful option for an editor is [Visual Studio Code](https://code.visualstudio.com/). It also has a [ZScript highlighting extension](https://marketplace.visualstudio.com/items?itemName=kaptainmicila.gzdoom-zscript), available at VS Code Marketplace. VS Code has more features, its ZScript extension can update automatically, but also doesn't have autocompletion.

### Step #3: Define ZScript version

Put the following line at the top of your `zscript.zs` file:

```csharp
version "4.11"
```

Where instead of `4.11` use the desired GZDoom version. This will tell the engine that the code shouldn't compile on an earlier version of GZDoom. Without this some features may not be available, and it may not be immediately obvious to players of your mods that they're trying to run them on an outdated version of GZDoom. 

There's rarely ever a good reason to *not* use the latest version of GZDoom, so just try to use the latest one.

### Step #4: Split code into multiple files

While you *can* start coding inside that `zscript.zs` file, it's preferable to instead create another subfolder (such as "MyMod_Scripts" where "MyMod" is the name of your mod) and split your code into various files, such as `weapons.zs`, `monsters.zs` and so on. (This is just an example; you can use any naming convention that works for you, such as having a separate file for each weapon, each monster, etc.) To do that, you'll then need to use `#include` command in your root `zscript.zs` file to make sure those files are compiled. For example:

```csharp
version "4.6.1"

#include "MyMod_Scripts/constants.zs"
#include "MyMod_Scripts/player.zs"
#include "MyMod_Scripts/weapons.zs"
#include "MyMod_Scripts/monsters.zs"
#include "MyMod_Scripts/decorations.zs"
```

Note:

* `zscript.zs` file must always be at the *root* of your mod folder.
* Other zscript files can be placed *anywhere* in your mod folder, as long as you use `#include` with the correct path.
* `version` only needs to be specified *once* in your root `zscript.zs` file.

### Step #5: How to test your project

When you want to test your mod, you can just run the folder directly in GZDoom. For example, using the command line:

```css
start gzdoom.exe -iwad doom2.wad -file "<path to your mod folder>/<Mod folder name>"
```

When your mod is ready and you want to ship it, you need to pack it into a `.pk3` archive. However, during testing and coding this isn't necessary, and most of the time working with a folder is faster and safer.

If you are not comfortable with using the command line, the other option is to run GZDoom and its mods through a launcher. One of the common choices is ZDL (ZDoom Launcher). You can find a guide on setting it up on ZDoom Forums [here](https://forum.zdoom.org/viewtopic.php?t=76814).

### Step #6: Take care of the backups (!)

A lot of people work out of a PK3 file rather than an unpacked folder. Partially this is force of habit (this used to be the default approach in the past), but another reason is that SLADE will automatically create backups for PK3 files that you edit.

However, if you'r working with a folder, *you'll have to to handle the backups yourself*. It doesn't matter if you edit the files in the folder with external editors (Notepad++, Photoshop, etc.), or if you're using SLADE on it: SLADE does *not* create backups for folders. However, even if you were working from a PK3 file using SLADE, SLADE's backup system is pretty fiddly and not something that you should rely on it.

As such, it's *highly recommended* that you set up your own backup and version control system. One of the best options you can use is [making your mod into a Github repository](https://docs.github.com/en/get-started). It's a robust and secure way to make sure all changes are visible and reversible, plus Github offers easy tools to publish versions, updates and keep track of changes. Making a repository is free, they can be kept private if you wish, and it requires no special skills since it can all be handled via [the GitHub client software](https://desktop.github.com/).

### Step #7: Start coding

You're now ready to create some classes.

### Extra: How to set up your project if you have custom maps

Since this is a ZScript guide, most of it is about using ZScript specifically. But if you're planning a big project that is also going to include maps, you'll likely have more questions. Let's cover them briefly.

Maps are stored in WAD files, and this is the only format that supports maps for all Doom engine versions. Maps themselves can be compiled in different formats (such as vanilla, Boom, UDMF), but the *file* format they use doesn't change, it's always WAD. The most up-to-date map editor is [Ultimate Doom Builder](https://forum.zdoom.org/viewtopic.php?t=66745), which can be used to create maps in any format, from vanilla (compatible with doom2.exe) to UDMF.

Everything else *besides* the maps—that is, assets (graphics, sounds, etc.) and code—must be kept in a PK3 file (that file can be unpacked in a folder during development). It's possible to store assets in a WAD file as well, but that's an extremely headache-inducing apporach because WADs don't support subfolders and their structure wholly relies on the order in which things are placed, which quickly becomes very hard to keep track of.

So, the question here is **how to properly combine maps with assets**. There are several approaches here.

First, one WAD file can contain any number of maps, but it's recommended to save every map in a separate file—this is relevant for most approaches.

*During development* you can keep maps and assets as completely separate entities: you can have a PK3 (or a folder) with all your assets in one place, and you can have a WAD file (or multiple WAD files) with your maps in another place. With this approach, you can open your map in UDB and then using Map Options attach your PK3 (or folder) with assets to load them as well. And in GZDoom you could use `gzdoom.exe -file yourmaps.wad yourassets.pk3` to run the whole thing together (this could also be done with a launcher of your choice).

Once your project is ready and you're ready to ship it, there are several options:

1. You can ship your project as two files: a WAD containing all your maps, and a PK3 containing all your assets. It's easy to do but it might not be optimal for the players who need to be aware that they need to run both files together.

2. Put every WAD file under the `maps/` subdirectory in your PK3 file. NOTE: this *requires* that every map is in a separate file, and that they're all named the same way you named your map when creating it (this refers to its internal name, such as MAP01): i.e., `map01.wad`, `map02.wad`, and so on. With this approach, the core MAPINFO lump that defines your maps' "nice" names and properties would be placed in your PK3.

> *Note*: While it's possible to have a single WAD file with all your maps at the *root* of your PK3, it's not recommended. This will cause GZDoom to load all maps into RAM at once, which can cause notable performance issues.

------

🟢 [<<< BACK TO START](README.md)

🔵 [>> Next: Defining classes in zscript](02_Defining_ZScript_classes.md)
