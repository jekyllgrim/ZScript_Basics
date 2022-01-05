🟢 [<<< BACK TO START](README.md)

🔵 [>> Next: Defining classes in zscript](Defining_ZScript_classes.md)

------

# Where to start



## What is ZScript?

[ZScript](https://zdoom.org/wiki/ZScript) is a coding language used by the [GZDoom](https://zdoom.org/index) source port. ZScript allows to code the following aspects of the game:

* Player classes (also known as [player pawns](https://zdoom.org/wiki/Classes:PlayerPawn))
* Weapons
* Monsters, decorations and any other objects that can be spawned in the world
* UI elements such as game menus and heads-up display / statusbar



## How do I start coding in zscript?

### Step #1

Create a folder with the name of your choice (such as the name of your future mod). In that folder create a text file called `zscript`; you can use any file extension (`.zsc` and `.zs` are some of the common options, but `.txt` will work just the same).

### Step #2:

You can use one of the following approaches to edit ZScript files:

1. [SLADE](https://slade.mancubus.net/index.php?page=downloads) archive manager. It's a specialized tool that can edit .wad, .pk3 and many other file formats, as well as folders, and it has a number of unique features that are required for proper GZDoom modding (such as image offsetting). Using Slade, just open the mod folder you created, click on your `zscript.zs` file, and a text editing window will open. If the file's extension is `.zs` or `.zsc`, the code in it will be automatically highlighted.
2. Use a code editing software: one of the simplest choices is [Notepad++](https://notepad-plus-plus.org/downloads/). You'll need to download a [syntax highlighting plugin](https://forum.zdoom.org/viewtopic.php?f=3&t=46674) to make sure N++ will highlight your ZScript code. Notepad++ is faster to use than SLADE and allows easy multi-window/multi-tab editing, so for pure coding purposes it's preferable.

### Step #3

Put the following line at the top of your `zscript.zs` file:

```cs
version "4.6.1"
```

Where instead of `4.6.1` use the desired GZDoom version. This will tell the engine that the code shouldn't compile on an earlier version of GZDoom. Without this some features may not be available, and it may not be immediately obvious to players of your mods that they're trying to run them on an outdated version of GZDoom. 

There's never a good reason to *not* use the latest version of GZDoom, so just try to use the latest one.

### Step #4

While you *can* start coding inside that `zscript.zs` file, it's preferable to instead create another subfolder (such as "MyMod_Scripts" where "MyMod" is the name of your mod) and split your code into various files, such as `weapons.zs`, `monsters.zs` and so on. To do that, you'll then need to use `#include` command in your root `zscript.zs` file to make sure those files are compiled. For example:

```cs
version "4.6.1"

#include "MyMod_Scripts/constants.zs"
#include "MyMod_Scripts/player.zs"
#include "MyMod_Scripts/weapons.zs"
#include "MyMod_Scripts/monsters.zs"
#include "MyMod_Scripts/decorations.zs"
```

Note:

* `zscript.zs` file must always be at the *root* of your mod folder.
* Other zscript files can be placed *anywhere* in your mod folder, as long as you use `#inlude` with the correct path.
* `version` only needs to be specified *once* in your root `zscript.zs` file.

### Step #5

When you want to test your mod, you can just run the folder directly in GZDoom. For example, using the command line:

```css
start gzdoom.exe -iwad doom2.wad -file "<path to your mod folder>/<Mod folder name>"
```

When your mod is ready and you want to ship it, you need to pack it into a `.pk3` archive. However, during testing and coding this isn't necessary, and most of the time working with a folder is faster and safer.

### Step #6

Note that if you're using SLADE to edit anything in your mod folder (such as a [TEXTURES](https://zdoom.org/wiki/TEXTURES) lump or set some image offsets), it <u>will not create backups for the folder</u>. SLADE only creates backups when editing files (like .wad or .pk3 files). It's recommended to use another method for backups and versioning, such as [making your mod into a Github repository](https://docs.github.com/en/get-started). It's a robust and secure way to make sure all changes are reversible, plus Github offers easy tools to publish versions, updates and keep track of changes.

### Step #7

You're now ready to create some classes.



------

🟢 [<<< BACK TO START](README.md)

🔵 [>> Next: Defining classes in zscript](Defining_ZScript_classes.md)
