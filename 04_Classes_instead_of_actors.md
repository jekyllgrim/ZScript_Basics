🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Why ZScript?](01_Where_to_start.md)        🔵 [>> Next: How to see your classes in the game](05_How_to_see_your_classes.md)

------

# Classes instead of actors

Let’s talk basic syntax. The first thing you need to know is that DECORATE is used only to define actors—objects that "physically" spawn in the game world. These are monsters, decorations, weapons, inventory items, and player pawns (the actors you control in the game). There are some special cases, for example built-in GZDoom particles (the ones that spawn by default when you use `A_RailAttack` or `A_CustomRailGun`), which are not technically actors, but more on that later.

ZScript covers much more. ZScript also defines the HUD (fullscreen HUD, statusbar, etc.), menus (yes, even the main menu) and other stuff. The basic unit of ZScript is not an actor but a **class**.

A class is just a container for code (and that can be HUD code, menu code, actor code, etc.). An actor *is a type of class*. **Actor** is just a base class used by Doom actors; it contains the definitions for all properties, flags and functions available to Doom actors. Other common base classes are `BaseStatusBar` (contains all base code for HUD elements) and `ListMenu` (which contains menu stuff).

As a result, in DECORATE a definition (i.e. a part of code) begins with the word `Actor`, because DECORATE can’t be used to code anything that isn’t an actor. In ZScript definitions begin with the word `Class`.

There are also some simple differences in syntax. Here’s a comparison of templates.

```csharp
//DECORATE:

Actor MyActor 
{
    property1
    property2
    property3
    +FLAGNAME
    States 
    {
    Spawn:
        SPRT A 1
        loop
    Death:
        SPRT B 5 A_Function
        SPRT CD 5
        SPRT E -1
        stop
    }
}
```

```csharp
//ZScript:

//at the top of your main zscript file you need to declare version (once)
version "4.11" 

class MyClass : Actor 
{
    Default 
    {
        property1;
        property2;
        property3;
        +FLAGNAME
    }
    States 
    {
    Spawn:
        SPRT A 1;
        loop;
    Death:
        SPRT B 5 A_Function;
        SPRT CD 5;
        SPRT E -1;
        stop;
    }
}
```

> *Note:* In case you don’t know, this is called pseudocode and it’s widely used as examples in programming manuals as well as by people. Pseudocode represents the way actual code would look but does not contain actual functions, properties, etc.

So, what are the differences here?

- Definitions begin with the word `class`
- If you want to make a completely original actor, your class has to inherit from `Actor` (which is the base class for all actors).
- Default properties and flags have to be enclosed in a `Default { }` block instead of just being written somewhere above states
- All lines except block names (`Class`, `Default`, `states`) and flags have to end with a semicolon. (Flags *can* end with a semicolon, but it’s optional.)
- Not shown in the example: flag prefixes are *not* optional in ZScript. I.e. for example, in `+INVENTORY.AUTOACTIVATE` you can’t omit `INVENTORY`.

## More syntax differences

There are a few extra syntax differences between ZScript and DECORATE you need to be aware about:

1. In ZScript, class names can't begin with a number, while DECORATE doesn't have that limitation. So, in Decorate you can create a class named `12gauge`, but in ZScript it won't work. You can use something like `Shells_12gauge` or `ShotgunAmmo_12gauge` instead.

2. DECORATE allows specifying DoomEdNums (aka editor numbers) directly in the code, while ZScript doesn't. Instead you should specify them with MAPINFO. (This is a preferred method anyway, even if you were using DECORATE, since it's more convenient to keep all your editor numbers in one place.)

3. Class-specific flag prefixes, such as `INVENTORY` in `INVENTORY.AUTOACTIVATE` or `WEAPON` in `WEAPON.NOAUTOFIRE`, and others, are *not* optional in ZScript.

4. In classes based on `PowerupGiver`, the `Powerup.Type` property requires a full powerup class name. So, while in DECORATE you could use `Powerup.Type "Invulnerable"`, in ZScript it has to be `Powerup.Type "PowerInvulnerable"`. On the flipside, when creating custom powerup classes in ZScript, their names don't have to begin with "Power", as opposed to DECORATE.

5. `A_ChangeFlag`, while still supported, is considered deprecated in ZScript. Instead you can and should change flag values directly (e.g. `bFLAGNAME = true` / `bFLAGNAME = false`).

Knowing just these points, you can already start coding in ZScript. Next, we delve into ZScript-only features.

------

🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Why ZScript?](01_Where_to_start.md)        🔵 [>> Next: How to see your classes in the game](05_How_to_see_your_classes.md)
