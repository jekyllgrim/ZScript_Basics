🟢 [<<< BACK TO START](README.md)

🔵[<< Previous: Where to start](01_Where_to_start.md)        🔵[>> Next: How to see your classes in the game](05_How_to_see_your_classes.md)

------

# Defining ZScript classes

- [About classes](#about-classes)
- [ZDoom Wiki and ZScript vs DECORATE](#zdoom-wiki-and-zscript-vs-decorate)
- [Creating actors](#creating-actors)
- [Actor structure](#actor-structure)
- [Actor properties and flags](#actor-properties-and-flags)
- [Actor states](#actor-states)
  + [State keywords](#state-keywords)
  + [Invisible and 0-tic states](#invisible-and-0-tic-states)
  + [Custom and pre-existing state sequences](#custom-and-pre-existing-state-sequences)
- [Using inheritance](#using-inheritance)
- [Coding a basic prop](#coding-a-basic-prop)
- [Coding a basic monster](#coding-a-basic-monster)
- [Weapons](#weapons)
  * [Coding a basic weapon](#coding-a-basic-weapon)
  * [Creating a weapon with a reload mechanic](#creating-a-weapon-with-a-reload-mechanic)

## About classes

ZScript is an [object-oriented](https://en.wikipedia.org/wiki/Object-oriented_programming) coding language, which means that all of the code that is executed at runtime (during the game) must be defined within an object (the most common object being a Class). This is different from [ACS](https://zdoom.org/wiki/ACS) (another GZDoom coding language, used to script map events), which is a list of scripts that define various events that happen in order; ACS scripts are not bound to a specific object.

Some of the common ZScript base class types are `Actor`, as well as `Inventory` and `Weapon` that are based on `Actor`. Almost all objects that can be spawned in the map are based on the `Actor` class and therefore are referred to as "actors." ZScript, however, is not limited to objects that can be spawned in the map; there are also many other classes that can perform operations and/or handle some data which are not actors (more on that later in the guide).

Once you have a mod folder/archive and your base zscript file set up, [as described in the previous chapter](01_Where_to_start.md), you can start defining some classes. One of the easiest methods of designing classes is looking at how it's done in other mods, or just looking at the existing GZDoom classes. GZDoom's main file `gzdoom.pk3`, which can be found in the GZDoom root folder, contains all class definitions for Doom, Heretic, Hexen, Strife and Chex Quest games. You can also find the definitions for the base classes on [GZDoom github](https://github.com/coelckers/gzdoom/tree/master/wadsrc/static/zscript/). Note that you never need to (and **shouldn't**) copy those classes into your code; you can just inherit from them or design your own code similarly.

## ZDoom Wiki and ZScript vs DECORATE

A good resource that covers most of GZDoom's functionality, including a lot of ZScript, is the [ZDoom Wiki](https://zdoom.org/wiki/Main_Page).  However, the wiki has existed since the dawn of ZDoom and as such describes multiple methods, including the ones that have been considered deprecated or inefficient for years, and thus are no longer recommended for use. Most importantly, a lot of the code examples described on the wiki are written not in ZScript but in [DECORATE](https://zdoom.org/wiki/DECORATE).

DECORATE is a coding language that had been used in GZDoom before ZScript support was added. At the moment it's still supported by GZDoom (since GZDoom is designed for maximum backwards compatibility, so that all older projects are still playable in it), but there's no reason to use it for newer projects, because ZScript is an **extension** over DECORATE (and DECORATE is a subset of ZScript).

**ZScript supports all DECORATE methods and functions**, so all the examples you see on the wiki are still valid, provided you write them [using ZScript syntax](https://zdoom.org/wiki/Coding_language_differences). *However*, due to having a very limited set of features, DECORATE code tends to use complicated and often inconvenient workarounds that are unnecessary in ZScript. As a result, it requires a bit of research and critical thinking to use something from DECORATE in ZScript; often it'll be better to code a solution from scratch rather than try and convert DECORATE to ZScript (although the latter is [possible](https://zdoom.org/wiki/Converting_DECORATE_code_to_ZScript)).

Still, ZDoom Wiki remains an invaluable modding resource, it describes multiple functions and features available in GZDoom, and it's extensively references in this guide. It's also being updated by various members of the community (including yours truly) and features more and more relevant ZScript materials.

### References:

* [Information about DECORATE and ZScript differences on the wiki](https://zdoom.org/wiki/Coding_language_differences)
* Some information on the syntax differences in this guide can be found here: [Classes instead of actors](04_Classes_instead_of_actors.md)
* Apart from `gzdoom.pk3` you can also look at GZDoom's Github page to find all [ZScript classes used in GZDoom](https://github.com/coelckers/gzdoom/tree/master/wadsrc/static/zscript).

## Creating actors

To create an actor class (such as a decoration, a monster or a weapon/item) it is recommended to always have access to the following Wiki pages:

- [Action functions](https://zdoom.org/wiki/Action_functions)
- [Actor flags](https://zdoom.org/wiki/Actor_flags)
- [Actor properties](https://zdoom.org/wiki/Actor_properties)
- [Actor states](https://zdoom.org/wiki/Actor_states)

Functions, flags and properties are what makes an actor work.

The basic actor definition would look as follows:

```csharp
class MyClassName : Actor 
{
    // The Default block contains flags and properties that
    // determine the default values the actor uses upon spawning:
    Default
    {        
        +FLAGNAME //an example of how a flag is set (semicolon at the end is optional)
        property value; //an example of a property and a value (semicolon is required!)
    }

    // States keyword begins a block of states that define
    // the actor's animation and behavior:
    States 
    {
    // When spawned in the world, actors automatically
    // enter their Spawn sequence:
    Spawn:
        FRAM A 1; //an example of a sprite name and sprite duration
        loop; //this will loop the Spawn state
    }
}
```

The basic rules for defining your classes are:

* Don't use the same names as the existing classes (for example, don't try to code a custom actor named `Zombieman`, because an actor with that name is already defined in GZDoom to use in Doom games; give your class a different name).
* To make the actors appear in the game, you either need to create a custom map and place them there manually, or they need to replace existing actors. The [How to see your classes in the game](05_How_to_see_your_classes.md) chapter will explain how this works.
* If you're unfamiliar with sprite naming in GZDoom, check the [Sprite page on ZDoom wiki](https://zdoom.org/wiki/Sprite).

## Actor structure

Now let's take a look at the general actor structure. Some of the things outlined here may be confusing to you at first, but don't worry—they'll all be covered and expanded on in this chapter and the subsequent chapters of this guide.

```csharp
class MyActorName : Actor
{
    // This is where class-scope variables (aka fields)
    // are usually defined.
    int foo; // example of an integer variable
    double bar; //example of a double (float-point) variable

    Default
    {
        // This is where properties and flags are defined.
        // They define the actor's initial behavior, when
        // it spawns. Most of them can be dynamically
        // changed later.
    }

    // This is where functions are usually defined.
    // These can include both fully custom functions,
    // and virtual functions override (more on those
    // later).

    // An example of a custom function:
    void MyFunction()
    {
        // do something
    }

    // This is an example of a virtual function override.
    // Tick() is a function that all actors run automatically
    // every tic (1/35 second) while they exist in a level.
    // By overriding it, you can add extra behavior into
    // the actor without having to define it inside its
    // animation states:
    override void Tick()
    {
        // You need to call super.Tick() first to make sure
        // that the default Actor class Tick() is called
        // ("super" in this context means "parent class'").
        // The base Actor Tick() is where stuff like
        // collision, movement, animation progression and
        // such happen.
        super.Tick();

        // You can add more behavior here.
    }

    // The States keyword begings a states block that
    // defines the actor's animation states and
    // related behavior:
    States
    {
    // All actors enter their Spawn state sequence
    // by default when they spawn:
    Spawn:
        TROO ABCD 1; //display TROOA, TROOB, TROOC and TROOD sprites, each for 1 tic
        loop; //loop the Spawn state sequence
    }
}
```

## Actor properties and flags

> *Note*: The Default block that lets you define properties and flags only exists for classes based on `Actor`, i.e. the things that can be spawned in the map and display animations, play sounds, etc. (such as monsters, weapons, props). Non-Actor classes don't have defaults.

[Actor properties](https://zdoom.org/wiki/Actor_properties) are a list of properties that an actor has by default. There are hundreds of properties that can be used on actors, such as `health`, `scale`, `speed` and others. All properties take a value after them, e.g. `health 100` will set the actor's default health.

Flags are a special variation of properties that can only be true or false, they don't have a value, instead they simply enable or disable specific behaviors. Flags are set by preceding them with `+` and unset with `-`. For example, adding `+SOLID` to the actor's properties will make it solid (other actors won't be able to walk through it and projectiles will collide on it; note that it doesn't make it destructible, that involves a different flag, `+SHOOTALE`).

All properties have different default values. **All flags are false by default**.

Properties and flags are defined in the `Default` block:

```csharp
class MyActor : Actor
{
    Default
    {
        +SOLID
        +SHOOTABLE
        radius 32;
        height 56;
        health 100;
    }
}
```

This will create an actor that has 100 health, is solid (you can't pass through it by walking), shootable (attacks will damage it and reduce its health; it'll also bleed unless you add the `+NOBLOOD` flag), and has a 32x56 hitbox in map units. However, since it doesn't have a States block, it'll be invisible and won't have any animation.

Note that adding `;` after a flag definition is optional, in contrast to properties.

If you want to *unset* a flag, it has to be preceded with `-`. However, note that all flags are *false by default*. You may need to unset flags if your class is based on a different class rather than the base `Actor`, which already has some flags set (this is called inheritance, briefly covered further in this chapter). For example, if you create a new class based on `Zombieman` (the Doom enemy), it'll already have flags such as SOLID, SHOOTABLE, ACTIVATEMCROSS and some others set.

Most properties and flags can be modified dynamically on already spawned actors—this will be described in the [Pointers and casting](08_Pointers_and_casting.md) chapter.

ZScript also features two flag combos: `Monster` and `Projectile`. These can be added to the Default block as properties; simply adding them to the definition enables a set of flags that are normally used by all monsters or projectiles. These combos can be seen [on ZDoom Wiki](https://zdoom.org/wiki/Actor_properties#Flag_combos). Note that you don't always need these combos in full. For example, the `Projectile` combo enables the NOGRAVITY flag, but if you want to create a gravity-affected projectile (like a grenade), you'll need to unset that flag. 

## Actor states

The `States` keyword defines a states block of the actor where you can use predefined [actor states](https://zdoom.org/wiki/Actor_states) as well as add your own states. States are used by a state machine that displays specific frames and executes attached functions at runtime. Adding custom state sequences is also possible.

> *Note*: Just like the Default block described above, the States block and animation states exist only for classes based on `Actor`. Actor is the only class type in the game that can utilize a state machine and display animations in the world. There are other means to animate things (for example, some textures on the map can be animated, like the lava/acid textures; the player's HUD can be animated), but those animations are not done through actors and don't rely on any sort of states.

To control the states, you need to be aware of state flow control, which is described on the wiki, as well as in this guide: see [Flow Control: State Control](A1_Flow_Control.md#state-control). **Don't worry if some of this is confusing at first**; if you're not familiar with states, you'll likely need to keep that page open and check it frequently while coding until you get used to it.

A basic state sequence is defined as follows:

```csharp
// Pseudocode:
States 
{
StateLabel:
    SPRT A 1;
    SPRT B 2 A_Function();
    SPRT C 5;
    stop;
}
```

In this example `SPRT` is the sprite name, `A` is a frame letter, and numbers (1, 2 and 5) are the sprites' duration in tics (a tic in GZDoom is 1/35th of a second). **Sprites** have to be named in a specific format described [on the wiki](https://zdoom.org/wiki/Sprite) in order to work properly.

The `stop` command at the end stops the sequence and *destroys the actor*. There are many other commands (also described in [Flow Control: State Control](A1_Flow_Control.md#state-control)). Some of the most common ones are `stop` (stop animation and destroy the calling actor), `loop` (loop the current state sequence) and `goto <StateLabel>` which moves the actor to a new state sequence titled `StateLabel`.

By default actors spawned in the world will enter the `Spawn` state sequence. There are many ways to move from one state sequence to another, including `goto <StateLabel>` and various functions, including conditional jumps in the middle of one state sequence into another. There are also plenty of state sequences that are entered automatically under a certain conditions: for example, if an actor's health is reduced to 0, it'll enter its Death sequence, if one is present. Existing state labels and their conditions are described in full [on the wiki](https://zdoom.org/wiki/Actor_states).

> *Note:* Colloquially, "state" is often used as an umbrella term to refer to state sequences and state labels at the same time. *This is not correct*. The name of the sequence (such as Spawn, Death, etc.) is a **state label**; every separate frame in that sequence is a **state**; all states present under a specific state label collectively constitute a **state sequeence**.

Every separate sprite frame is a separate state in a state sequence. You can define states with a sprite and duration to display a specific animation frame for a specific time, and you can also attach functions for them to make something happen at that moment in the animation. When a function is attached to a state, it's executed at the *start* of the state, so the duration of that state isn't relevant for the function's execution. In the example above, the `A_Function()` call will happen 1 tic after the actor was spawned, as soon as the `SPRT A 1` state ends and at the same time as `SPRT B 2` is shown.

Since all sprites contain a base name and a frame letter, it's possible to string multiple letters together:

```csharp
Spawn:
    SPRT ABCD 5;
    loop;
```

The sequence above will display SPRTA, SPRTB, SPRTC, and SPRTD sprites, each for 5 tics, before looping and displaying them all from the beginning.

If you attach a function to a line with multiple frames, this function will be executed *for every frame*:

```csharp
Spawn:
    SPRT ABCD 5 A_Explode();
    loop;
```

This piece of code will show 4 frames of animation and also call [`A_Explode()`](https://zdoom.org/wiki/A_Explode) (a standard explosion function) *every time*, with 5 tics passing between each call.

If you want to call the function only once, it should be called on one frame. For example, if you want to do it as soon as the animation plays, you can do this:

```csharp
Spawn:
    SPRT A 5 A_Explode();
    SPRT BCD 5;
    loop;
```

The function call can also be attached to an empty frame with no duration instead:

```csharp
Spawn:
    TNT1 A 0 A_Explode();
    SPRT ABCD 5;
    loop;
```

> *Note*: `TNT1` is an internal name for a null sprite with special handling (the actor's rendering will be disabled when using this sprite). If there's ever a need to use a 0-duration state, most of the time it's preferable to use this null sprite. Note that *any* frame letter can be used with `TNT1`, it won't change the effect.

#### State keywords

States can also have special [keywords](https://zdoom.org/wiki/Actor_states#State_keywords) attached to them that add some extra behaviors. The keywords are placed between the duration and the function call:

```csharp
Spawn:
    SPRT ABCD 5 bright A_Explode();
    loop;
```

This code will make the calling actor fullbright (not affected by map sector light level) during those 5 frames, while also calling `A_Explode()`.

If a function is attached to the very first state in an actor's `Spawn` sequence, that function will not be executed immediately upon actor spawning, but it'll work later if the state sequence is looped. So, in the example above when SPRTA is show, `A_Explode()` will not be called; it'll only be called starting with SPRTB, and then every 5 tics. 

It's important to keep this in mind, because if you do something like this:

```csharp
Spawn:
    SPRT A 5 A_Explode();
    stop;
```

...there will be no explosion at all: the actor has only one state, that state is the first one in the Spawn sequence, and then the actor is destroyed because `stop` is called.

This behavior can be circumvented by using the `Nodelay` keyword:

```csharp
Spawn:
    SPRT A 5 Nodelay A_Explode();
    stop;
```

This keyword forces the function to execute immediately as the actor is spawned. Note, it only works on the first state of Spawn and is irrelevant in any other states.

#### Invisible and 0-tic states

If you want to make an actor invisible, use `TNT1` for the sprite name (you can use any frame letter with it, it doesn't matter). This name has special handling: it completely disables the rendering of the actor for the duration of the state. Note, you don't need to (and shouldn't!) add an actual empty image into your project and use that, you can just use `TNT1`.

```csharp
class BlinkingActor : Actor
{
    Default
    {
        +NOINTERACTION
    }

    States
    {
    Spawn:
        SPRT A 5;
        TNT1 A 10;
        loop;
    }
}
```

The actor above is completely non-interactive (thanks to the `NOINTERACTION` [flag](https://zdoom.org/wiki/Actor_flags)) and will show SPRTA for 5 tics, then become invisible for 10 tics, and loop the animation.

A state's duration can also be 0. This can be useful if you want something to happen before another thing. Since 0-tic states are never drawn due to having no duration, it's considered best practice to use `TNT1` for those states as well:

```csharp
Spawn:
    SPRT ABC 5;
    TNT1 A 0 A_Jump(128, "Null");
    TNT1 A 0 A_Explode();
    SPRT CDEF 4;
    stop;
```

The actor above shows SPRTA, SPRTB, and SPRTC in sequence, 5 tics for each state, then uses [`A_Jump`](https://zdoom.org/wiki/A_Jump) function with a 128/256 (50%) chance of jumping to the "Null" state sequence ("Null" is a special pre-existing state sequence that destroys the calling actor after 1 tic). If the jump doesn't happen, the actor calls `A_Explode()`  to deal area damage, shows some more animation, and calls `stop` to disappear.

There's one important rule to remember: **never loop state sequences with 0 total duration**. If you try to do this, you'll get a classic infinite loop, where the engine will try to call the same state over and over within the same tic, which will result in an infinite number of calls and an inevitable crash.

```csharp
// Ths will freeze the game!
Spawn:
    TNT1 A 0;
    loop;
```

#### Custom and pre-existing state sequences

Note, that there's a whole lot of actor state sequences that are used by default, defined by specific state labels, such as "Spawn" (entered when an actor spawns) or "Death" (entered when an actor's health is reduced to 0 and it dies). You can find a full list of them [on the ZDoom wiki](https://zdoom.org/wiki/Actor_states). 

You can, however, define custom state sequences simply by adding a state label with any name you want (without spaces). However, you will have to define your own conditions to enter those state sequences, such as `goto` or a jump function.

### References:

* [Actor states](https://zdoom.org/wiki/Actor_states) on the Wiki
* [Flow Control: State Control](A1_Flow_Control.md#state-control) in this guide
* [Sprite naming and use](https://zdoom.org/wiki/Sprite) on the Wiki

## Using inheritance

If you want to create a new version of an already existing class, you can do that by using inheritance. The basic syntax for it is:

```csharp
class NewClassName : ParentClassName
{
    // new code
}
```

When creating a new class this way, it inherits all properties, states, functions and other data (such as variables) defined in the parent class. 

If you want to change something this way in a custom class, you *only* need to change the things you need. You don't need to redefine anything that was already defined in the parent actor—that's the point of inheritance.

For example:

```csharp
class ToughZombieman : Zombieman
{
    Default
    {
        health 1000;
    }
}
```

This creates a new vesion of the [Doom Zombieman](https://zdoom.org/wiki/Classes:ZombieMan) (which is already defined in gzdoom.pk3, so it already exists in the game), different only in the fact that it has 1000 health instead of 20 that the standard Zombieman has.

You can add or remove flags defined in the original actor:

```csharp
class ToughNonsolidZombieman : Zombieman
{
    Default
    {
        health 1000;
        -SOLID
    }
}
```

This zombieman will not only have more health, but also won't be solid (`-SOLID` unsets the SOLID flag used by the parent actor), meaning it'll be possible to pass through it (however, it'll still be shootable because that's governed by another flag, `SHOOTABLE`, which is also set in Zombieman).

You can also redefine states this way if you want to add custom animation—in that case you simply need to add the new state sequences you want. You can also add new behavior to them:

```csharp
class ExplodingZombieman : Zombieman
{
    States
    {
    Death:
        MISL B 8 Bright A_Explode;
        MISL C 6 Bright;
        MISL D 4 Bright;
        Stop;
    }
}
```

This zombieman will explode on death, using the [Doom Rocket](https://zdoom.org/wiki/Classes:Rocket) sprites.

## Coding a basic prop

Basic props, such as decorations (trees, lamps, etc.) are the simplest type of actor you can define. For an example of a basic actor we can look at the Big Brown Tree from Doom:

```csharp
// NOTE: this actor already exists in GZDoom and doesn't need to be redefined
// I'm using it purely as an example.

class BigTree : Actor
{
    Default
    {
        Radius 32; //actor's width (collision with monster/player)
        Height 108; //actor's height (collision with monster/player)
        ProjectilePassHeight -16; //reduces vertical hitbox for projectiles by 16 units
        +SOLID //solid: other actors/projectiles can't pass through it, hitscan attacks can
    }
    States
    {
    Spawn:
        TRE2 A -1; //setting duration to -1 makes it not animate
        Stop;
    }
}
```

If you want to define a custom version of `BigTree` that is similar to the existing one, you can do it by [using inheritance](https://zdoom.org/wiki/Using_inheritance):

```csharp
class SmallerTree : BigTree
{
    Default 
    {
        Scale 0.5; //this makes the actor's sprite visually smaller
        Radius 16; //radius and height need to be redefined manually
        Height 54;
    }
}
// In this example states aren't redefined because
// we're reusing the existing animation from BigTree
```

This will create a version of `BigTree` that looks the same but appears twice as smaller and has twice as smaller collision box. Note that we had to change `height` and `radius`, because `scale` defines only the visual scale of the sprite, nothing else.

## Coding a basic monster

For an example of a  basic monster you can look at the code for Doom Zombieman:

```csharp
//NOTE: this actor already exists in GZDoom and doesn't need to be redefined

class ZombieMan : Actor
{
    Default
    {
        Health 20;
        Radius 20;
        Height 56;
        Speed 8; //How many map units it can move per A_Chase call (see See state sequence below)
        PainChance 200; //how often the monster will flinch when attacked
        Monster; //this keywords adds various flags that define this actor as a monster
        +FLOORCLIP //it'll be submerged into deep water if defined in TERRAIN lump
        SeeSound "grunt/sight"; //the sound played when it sees a player
        AttackSound "grunt/attack"; //the sound played when attacking
        PainSound "grunt/pain"; //the sound played when entering its Pain state sequence
        DeathSound "grunt/death"; //the sound played when A_Scream is called (see Death sequence)
        ActiveSound "grunt/active"; //the sound played periodically when it's chasing the player
        Obituary "$OB_ZOMBIE"; //a LANGUAGE lump reference that contains "played was killed by a Zombieman" string
        Tag "$FN_ZOMBIE"; //an internal name for the monster
        DropItem "Clip"; //an item it'll drop when killed
    }
     States
    {
    // The animation sequence at actor spawn:
    Spawn:
        POSS AB 10 A_Look; //this makes the monster listen for and look for players
        Loop;
    // See sequence is used when an alerted monster is chasing the player:
    See:
        POSS AABBCCDD 4 A_Chase; //a basic walking and chasing function
        Loop;
    // Missile sequence is entered when the monster tries to attack the player:
    Missile:
        POSS E 10 A_FaceTarget; //the monster turns towards its target
        POSS F 8 A_PosAttack; //the monster uses a standard Zombieman attack
        POSS E 8;
        Goto See;
    // Pain sequence is entered when the monster is shot
    // and its painchance check succeeds:
    Pain:
        POSS G 3;
        POSS G 3 A_Pain; //plays painsound (see Default block)
        Goto See;
    // Death sequence is entered when the monster
    // is killed (its health reaches 0):
    Death:
        POSS H 5;
        POSS I 5 A_Scream; //plays deathsound (see Default block)
        POSS J 5 A_NoBlocking; //makes the monster non-solid and spawns its Dropitem
        POSS K 5;
        POSS L -1; //final frame of the unmoving corpse
        Stop;
    // XDeath sequence is entered when the monster was dealt very high damage
    // and its health was reduced to a negative value that is equal or below
    // its default Health value (by default):
    XDeath:
        POSS M 5;
        POSS N 5 A_XScream; //plays a gibbed player sound, defined globally
        POSS O 5 A_NoBlocking; //makes the monster non-solid and spawns its Dropitem
        POSS PQRST 5;
        POSS U -1; //final frame of the unmoving gibbed corpse
        Stop;
    // Raise sequence is used when the monster is resurrected by an Arch-Vile.
    // If this isn't defined in a monster, it can't be resurrected.
    Raise:
        POSS K 5;
        POSS JIH 5;
        Goto See;
    }
}
```

There are multiple other ways to define a monster. For an example of a flying monster, you can look at the code for [Cacodemon](https://github.com/coelckers/gzdoom/blob/master/wadsrc/static/zscript/actors/doom/cacodemon.zs) or [Lost Soul](https://github.com/coelckers/gzdoom/blob/master/wadsrc/static/zscript/actors/doom/lostsoul.zs).

Instead of using predefined attack functions, such as `A_PosAttack`, you can find other [generic attack functions on ZDoom Wiki](https://zdoom.org/wiki/Category:Decorate_Generic_Attack_functions) that will allow you to specify custom damage, spread, bullet puff actor, etc.

You also don't have to always rely on sound properties to play sounds for you, and instead you can use [A_StartSound](https://zdoom.org/wiki/A_StartSound) function to play desired sounds. Note that those sounds need to be defined in the [SNDINFO](https://zdoom.org/wiki/SNDINFO) lump to be accessible, since you can't use sound file names directly in sound-related functions.

## Weapons

Weapons are classes than can be used by the player. There are a lot of special rules regarding how they're animated and behave (described in detail in a much later chapter, [Weapons, overlays and PSprite](12_Weapons_Overlays_PSprite.md)), but here are the basics.

There are a few basic rules regarding weapons:

* Weapons must be based on the `Weapon` class (or you can create your own basic class based on `Weapon` and have your weapons inherit from it, or inherit from one of the existing weapons, such as `Pistol`).
* Weapons use [their own attack functions](https://zdoom.org/wiki/Category:Decorate_Weapon_attack_functions). While various attack functions are called from the weapon, they're actually executed by the player pawn, a player-controlled class. It's a special interaction; as a result you can't call monster attack functions on weapons.
* Weapon states define frames that are drawn directly on the screen.

### Coding a basic weapon

For an example of a basic weapon let's look at Pistol from Doom:

```csharp
class Pistol : DoomWeapon //DoomWeapon is a base class based on Weapon. It only defines kickback (recoil).
{
     Default
    {
        Weapon.SelectionOrder 1900; //defines the priority of selecting this weapons when others run out of ammo
        Weapon.AmmoUse 1; //how much ammo it uses per shot
        Weapon.AmmoGive 20; //how much ammo the weapon gives you when you get it
        Weapon.AmmoType "Clip"; //the class name of the ammo type used by the weapon
        Obituary "$OB_MPPISTOL"; //a message printed on the screen when one player kills another in multiplayer
        +WEAPON.WIMPY_WEAPON //defines the weapon as "weak" (switch to another as soon as possible)
        Inventory.Pickupmessage "$PICKUP_PISTOL_DROPPED"; //the message printed on the screen when picking this up
        Tag "$TAG_PISTOL"; //name of the weapon
    }
    States
    {
    // Ready sequence is the default sequence used when the weapon is prepared:
    Ready:
        PISG A 1 A_WeaponReady; //makes the weapon ready for firing (will react to pressing Fire button)
        Loop;
    // Deselect sequence is played when you're switching to another weapon:
    Deselect:
        PISG A 1 A_Lower; //lowers the weapon on the screen until it disappears, then selects another weapon
        Loop;
    // Select sequence is played when you've switched to this weapon:
    Select:
        PISG A 1 A_Raise; //raises the weapon from below the screen, then goes to Ready
        Loop;
    // Fire sequence is played when you press Fire while A_WeaponReady() was called:
    Fire:
        PISG A 4;
        PISG B 6 A_FirePistol; //default Doom pistol attack
        PISG C 4;
        PISG B 5 A_ReFire; //loops the sequence if the player was holding down Fire button
        Goto Ready; //otherwise goes back to ready
    // Flash sequence draws a muzzle flash on a separate layer, on top of the main weapon sprite:
    Flash:
        PISF A 7 Bright A_Light1; //illuminates the whole level
        Goto LightDone;
    // Spawn sequence is used when the weapon is spawned in the world:
     Spawn:
        PIST A -1;
        Stop;
    }
}
```

This is a very simple weapon. It's also possible to create weapons that use a magazine/reload functionality, don't consume ammo, perform melee attacks, and so on.

You can use one of the [generic weapon attack functions](https://zdoom.org/wiki/Category:Decorate_Weapon_attack_functions) instead of relying on predefined functions such as `A_FirePistol`. In this case you'll also need [A_StartSound](https://zdoom.org/wiki/A_StartSound) to play the sound, and [A_GunFlash](https://zdoom.org/wiki/A_GunFlash) to draw a muzzle flash (if you choose to do it on a separate layer, like Doom weapons do).

You can also [create a new ammo type](https://zdoom.org/wiki/Creating_new_ammo_types) and a custom weapon that uses custom ammo.

### Creating a weapon with a reload mechanic

Weapons with a reload mechanic are very common in gameplay mods. Usually to achieve that a special "magazine" ammo type is defined and is used as `AmmoType` while the reserve ammo is defined as `AmmoType2`. A "Reload" state sequence is used to handle the reload mechanics. 

Note, the example below is likely too complex for you to understand right away, so it's recommend that you revisit it later, when you get further in the guide.

Here's an example of a modified Doom Pistol with a reload mechanic:

```csharp
class PistolWithReload : Pistol //it's based on the existing Pistol, so it inherits all of its properties
{
     Default
    {
        +WEAPON.AMMO_OPTIONAL //without this flag the weapon will be deselected as soon as the magazine is empty
        Weapon.AmmoType "PistolMagazine"; //a special "magazine" ammo type 
        Weapon.AmmoUse 1;
        Weapon.AmmoGive 0; //We don't want weapon pickups to refill the magazine
        Weapon.AmmoType2 "Clip"; //Clip is still used as reserve ammo
        Weapon.AmmoGive2 20; //the weapon will give some reserve ammo when picked up
    }

    // This defines a custom version of the A_WeaponReady function
    // that will block the ability to reload if the player
    // doesn't have any reserve ammo, or if their magazine
    // is already full:
    action void A_WeaponReadyReload(int flags = 0)
    {
        // Check that the amount of ammo1 (magazine) is lower than maxamount
        // and the amount of ammo2 (reserve ammo) is at least the same as ammouse1 
        // (the amount of magazine ammo required for firing):
        if (invoker.ammo1.amount < invoker.ammo1.maxamount && invoker.ammo2.amount >= invoker.ammouse1)
        {
            // If true, add WRF_ALLOWRELOAD to the flags, 
            // which is a A_WeaponReady() flag that allows 
            // using the Reload state sequence:
            flags |= WRF_ALLOWRELOAD;
        }
        // Pass the resulting value to A_WeaponReady 
        // (which will be either 0 or WRF_ALLOWRELOAD):
        A_WeaponReady(flags);
    }

    // This defines a custom function that in a loop takes
    // 1 ammo from reserve and adds 1 ammo to the magazine,
    // until either the reserve is empty ot the magazine
    // is full:
    action void A_MagazineReload()
    {
        // Loop this while ammo2 is above 0 AND ammo1 is
        // less than maximum:
        while (invoker.ammo2.amount > 0 && invoker.ammo1.amount < invoker.ammo1.maxamount) 
        {
            invoker.ammo2.amount--; //take 1 of AmmoType2
            invoker.ammo1.amount++; //give 1 of AmmoType1
        }
    }

    States
    {
    Ready:
        PISG A 1 A_WeaponReadyReload;
        Loop;
    Fire:
        // If PistolMagazine ammo is 0, jumps to Reload instead of firing:
        PISG A 4 A_JumpIfNoAmmo("Reload"); 
        PISG B 6 A_FirePistol;
        PISG C 4;
        PISG B 5 A_ReFire;
        Goto Ready;
    Reload:
        PISG AAAA 2 A_WeaponOffset(3, 5, WOF_ADD); //simply shifts the weapon downward and to the right
        PISG A 15; // simply wait for 15 tics
        TNT1 A 0  // perform the following anonymous function:
        {
            A_StartSound("misc/w_pkup"); //plays Doom's "weapon pickup" sound
            A_MagazineReload(); //do the reload
        }
        PISG AAAA 2 A_WeaponOffset(-3, -5, WOF_ADD); //shift the sprite upward and to the right
        goto Ready;
    }
}

// This is the magazine ammo; it's not based on any other ammo type:
class PistolMagazine : Ammo
{
    Default
    {
        Inventory.Amount 1; //default given amount
        Inventory.MaxAmount 10; //maximum amount (functions as the magazine capacity)
        Ammo.BackPackAmount 0; //Backpack shouldn't refill our magazines, so this is 0
        Ammo.BackPackMaxAmount 10; //backpack shouldn't increase our magazine capacity, so this is the same as maxamount
        +INVENTORY.IGNORESKILL //without this the player will receive 2 ammo on ITYTD and Nightmare! difficulties
        Inventory.Icon "PISTA0"; //this will use Pistol pickup sprite as its icon
    }
}
```

There are other ways to achieve a similar result, but this is arguably the most universal one.

Anonymous and action functions used above will be explained further in the guide, so keep reading, and you will understand this better!

------

🟢 [<<< BACK TO START](README.md)

🔵[<< Previous: Where to start](01_Where_to_start.md)        🔵[>> Next: How to see your classes in the game](05_How_to_see_your_classes.md)
