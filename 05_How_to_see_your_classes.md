🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Classes instead of actors](04_Classes_instead_of_actors.md)        🔵 [>> Next: Anonymous functions](06_Anonymous_functions.md)

------

# How to see your classes in the game

So, you've created a class. How do you see it in the game?

The answer depends on the exact goal.

* [Spawning a class for testing purposes](#spawning-a-class-for-testing-purposes)
* [Replacing existing classes in a mod](#replacing-existing-classes-in-a-mod)
* [Placing your classes in a custom map](#placing-your-classes-in-a-custom-map)
  + [Giving your actors editor DoomEdNums](#giving-your-actors-editor-doomednums)
  + [Seeing your actors in a map editor](#seeing-your-actors-in-a-map-editor)

## Spawning a class for testing purposes

If you just want to see your class in the game to test how it works, all you need to do is spawn it. For that you can use the `summon` console command. Open the console using the tilda (~) key and type:

```
summon classname
```

where `classname` is the actual name of your class. For example, `summon zombieman` will summon a Zombieman.

> *Note:* console commands, just like ZScript itself, are case-insensitive.

Note, like any other console command, you can bind it to a key using the console. For example:

```
bind m "summon zombieman"
```

This will let you summon a Zombieman simply by pressing the M key. This command will be saved to your config, so you won't have to re-enter it every time you load GZDoom. Doing something like this may be a good idea if you're working on a complex class and need to constantly load the game and see how it looks, since typing the command every time is rather annoying.

If you're creating a monster and would like to observe its behavior without being attacked by it, you can summon it as a friend using `summonfriend` console command:

```
summonfriend zombieman
```

This will summon a zombieman as a friend, as if it had a +FRIENDLY flag in its definition.

There are many other useful console commands you could use during testing; I recommend checking out the [CCMDs page on the ZDoom wiki](https://zdoom.org/wiki/CCMDs).

## Replacing existing classes in a mod

If you're creating a weapon/gameplay mod that does *not* include any maps, you can't place your actors on the maps manually; instead you will have to replace existing classes, so that yours spawn instead. There are several ways to achieve that.

The most basic way, which has been available since DECORATE, is to use the `replaces` keyword in the actor's definition:

```cs
// This actor inherits from Cacodemon and will also replace
// all cacodemons in the maps you play with this code:

class MyCustomCacodemon : Cacodemon replaces Cacodemon
{
    // actor code
}
```

There are two downsides to this method:

1. If your mod is run with another mod or a map that includes replacements for the same monster, they may conflict. In fact, the last replacement always takes precedence. So, for example, if you have a custom version of a Cacodemon in your mod, and your mod is played with a mapset that *also* comes with its own custom Cacodemon, the monster from the file that comes last in the load order will be used. For example, if you're running GZDoom from command line or a .bat file:
   
   ```csharp
   // With this order your cacodemon will be used:
   gzdoom.exe -file mapset.wad yourmod.pk3
   
   // And with this one you'll see the cacodemons from the mapset, not your mod:
   gzdoom.exe -file yourmod.pk3 mapset.wad
   ```
   
   Whether this is desirable or not may vary, but this is definitely something you need to be aware of. And not just you, but the players of your mod as well, since they're the ones in control of the load order.

2. This method only allows 1:1 replacements; if for some reason you want one class to replace several classes from the vanilla game, you'll have to create copies of it just for the sake of replacement. This is undesirable, since this leads to needlessly messy code and potential issues.

A more robust way is to use an event handler. This method is described in the [event handlers chapter](11_Event_Handlers.md#actor-replacement-via-event-handlers); however, being able to use it requires knowing about virtual functions and event handlers, so I recommend that you continue reading the guide first.

## Placing your classes in a custom map

If you're working on a project that has its own maps, you don't need to bother with replacements described in the previous subsection; you can simply place your actors in your map. To be able to do that, you need to do a few things.

### Giving your actors editor numbers

To be placable on maps, your actors need DoomEdNums, also known as editor numbers. An editor number is a unique object identifier that actors need to have in order to be placeable on the map from a map editor. (Not to be confused with [Spawn IDs or spawn numbers](https://zdoom.org/wiki/Spawn_number), they're a completely different thing and are largely useless in modern GZDoom. You don't need Spawn IDs to place your actors on the map.)

*All* existing GZDoom objects from all supported games have DoomEdNums: you can see them [on the ZDoom wiki](https://zdoom.org/wiki/Standard_editor_numbers). If you give your own actors DoomEdNums, *they have to be unique and different from the ones used by GZDoom*.

DoomEdNums are given differently in DECORATE and ZScript. While you can attach DoomEdNums to actors directly in DECORATE, ZScript doesn't support that. Instead they should be defined via [MAPINFO](https://zdoom.org/wiki/MAPINFO).

The process is very simple. Let's say you have a custom actor defined:

```cs
class BigZombieman : Zombieman
{
    Default
    {
        health 1000;
        scale 2;
        radius 40;
        height 40;
    }
}
```

Create a MAPINFO lump at the root of your project's folder or archive and add:

```cs
DoomEdNums
{
    16000 = "BigZombieman"
}
```

Good! Move on to the next step.

> *Note*, if an object is only meant to be manually spawned by another object (for example, it's some kind of a special effects particle), they don't need DoomEdNums. DoomEdNums are only necessary for objects that you should be able to place on your map from the Things menu, so that they're there at map start.

### Seeing your actors in a map editor

Now you will, naturally, need to get a map editor—the most current map editor for GZDoom is [Ultimate Doom Builder](https://forum.zdoom.org/viewtopic.php?t=66745). Note that only maps in ZDoom format support custom actors, so the recommended map format is *GZDoom UDMF*.

Do the following:

1. Start UDB, choose *File > New Map* (or click Ctrl+N), or, if you already have a map, hit F2 to open the *Map Options* dialogue.
2. Click *Add Resource* to open the *Add Resource* window.
3. Choose the *From PK3/PK7* tab and find and add **gzdoom.pk3** as a resource. 
4. Before clicking OK, tick the *Exclude this resource from testing parameters* checkbox. 
5. Now you naturally need to add your classes as a resource. If your classes are defined in a [PK3 or a structured folder](https://zdoom.org/wiki/Using_ZIPs_as_WAD_replacement), just add them as a resource using the suitable tab and hit OK.

> *Note*: While it's possible to store your classes in a WAD, it's not recommended because WADs are very hard to organize. It's preferable to keep your maps in a WAD (since they don't support any other format), while keeping your code and assets in a PK3 or a folder.

Now place a thing on your map, right-click it, and if you scroll down the list of available thing categories, at the bottom you'll see "User-defined". There you will find your custom actors.

If you're planning a big project with multiple classes and you want them to have custom categories, you will need to create a custom UDB config.

------

🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Classes instead of actors](04_Classes_instead_of_actors.md)        🔵 [>> Next: Anonymous functions](06_Anonymous_functions.md)
