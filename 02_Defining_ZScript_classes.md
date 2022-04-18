🟢 [<<< BACK TO START](README.md)

🔵[<< Previous: Where to start](01_Where_to_start.md)        🔵[>> Next: How to see your classes in the game](05_How_to_see_your_classes.md)

------

# Defining ZScript classes

* [About classes](#about-classes)
* [ZDoom Wiki and ZScript vs DECORATE](#zdoom-wiki-and-zscript-vs-decorate)
* [Creating actors](#creating-actors)
* [Actor states](#actor-states)
* [Coding a basic object](#coding-a-basic-object)
* [Coding a basic monster](#coding-a-basic-monster)
* [Coding a basic weapon](#coding-a-basic-weapon)
* [Creating a weapon with a reload mechanic](#creating-a-weapon-with-a-reload-mechanic)

## About classes

ZScript is an [object-oriented](https://en.wikipedia.org/wiki/Object-oriented_programming) coding language, which means that all of the code that is executed at runtime (during the game) must be defined within an object (the most common object being a Class). This is different from [ACS](https://zdoom.org/wiki/ACS) (another GZDoom coding language used to code map events), which is a list of scripts that define various events that happen in order; ACS scripts are not bound to a specific object.

Some of the common ZScript base class types are `Actor`, as well as `Inventory` and `Weapon` that are based on `Actor`. Almost all objects that can be spawned in the map are based on the `Actor` class and therefore are referred to as "actors."

Once you have a [mod folder/archive and your base zscript file set up](01_Where_to_start.md), you can start defining some classes. One of the easiest methods of designing classes is looking at how it's done in other mods, or just looking at the existing GZDoom classes. GZDoom's main file `gzdoom.pk3`, which can be found in the GZDoom root folder, contains all class definitions for Doom, Heretic, Hexen, Strife and Chex Quest games. You can also find the definitions for the base classes on [GZDoom github](https://github.com/coelckers/gzdoom/tree/master/wadsrc/static/zscript/). Note that you never need to (and **shouldn't**) copy those classes into your code; you can just inherit from them or design your own code similarly.

## ZDoom Wiki and ZScript vs DECORATE

A good resource that covers most of GZDoom's functionality, including a lot of ZScript, is the [ZDoom Wiki](https://zdoom.org/wiki/Main_Page).  However, the wiki has existed since the dawn of ZDoom and as such describes multiple methods, including the ones that are deprecated or inefficient and no longer recommended for use. Most importantly, a lot of the code examples described on the wiki are written not in ZScript but in [DECORATE](https://zdoom.org/wiki/DECORATE).

DECORATE is a coding language that had been used in GZDoom before ZScript support was added. At the moment it's still supported by GZDoom (since GZDoom is designed for maximum backwards compatibility, so that all older projects are still playable in it), but there's no reason to use it for newer projects because ZScript is an **extension** over DECORATE. 

**ZScript supports all DECORATE methods and functions**, so all the examples you see on the wiki are still valid, provided you write them [using ZScript syntax](https://zdoom.org/wiki/Coding_language_differences). *However*, due to having a relatively small number of features, DECORATE code tends to use complicated and often inconvenient workarounds that are unnecessary and not recommended in ZScript. As a result, it requires a bit of research and critical thinking to use something from DECORATE in ZScript; often it'll be better to code a solution from scratch rather than try and convert DECORATE to ZScript (although the latter is [possible](https://zdoom.org/wiki/Converting_DECORATE_code_to_ZScript)).

Still, ZDoom Wiki remains an invaluable modding resource, it describes multiple functions and features available in GZDoom, and it's extensively references in this guide.

### References:

* [Information about DECORATE and ZScript differences on the wiki](https://zdoom.org/wiki/Coding_language_differences)
* Some information on the syntax differences in this guide can be found here: [Classes instead of actors](04_Classes_instead_of_actors.md)
* Apart from `gzdoom.pk3` you can also look at GZDoom github page to find all [ZScript classes used in GZDoom](https://github.com/coelckers/gzdoom/tree/master/wadsrc/static/zscript).

## Creating actors

To create an actor class (such as a decoration, a monster or a weapon) it is recommended to always have access to the following Wiki pages:

- [Action functions](https://zdoom.org/wiki/Action_functions)
- [Actor flags](https://zdoom.org/wiki/Actor_flags)
- [Actor properties](https://zdoom.org/wiki/Actor_properties)
- [Actor states](https://zdoom.org/wiki/Actor_states)

Functions, flags and properties are what makes an actor work.

The basic actor definition would look as follows:

```csharp
class MyClassName : Actor 
{
    Default //flags and properties go into the Defaults block
    {        
        +FLAGNAME //an example of how a flag is set (semicolon at the end is optional)
        property value; //an example of a property and a value
    }
    //States keyword begins a block of states that define the actor's animation and behavior:
    States 
    {
    //when spawned in the world, actors enter their Spawn state by default:
    Spawn:
        FRAM A 1; //an example of a sprite name and sprite duration
        loop; //this will loop the Spawn state
    }
}
```

The basic rules for defining your classes are:

* Don't use the same names as the existing classes (for example, don't try to code a custom actor named `Zombieman`, give it a different name)
* To make the actors appear in the game, you either need to create a custom map and place them there manually, or they need to replace existing actors. The [How to see your classes in the game](05_How_to_see_your_classes.md) chapter explains how this works.

## Actor states

The `States` keyword defines a states block of the actor where you can use predefined [actor states](https://zdoom.org/wiki/Actor_states) as well as add your own states. States are used by a state machine that displays specific frames and executes attached functions at runtime.

To control the states you need to read about state flow control, which is described on the wiki, as well as in this guide: see [Flow Control: State Control](A1_Flow_Control.md#state-control). **Don't worry if some of this is confusing at first**; if you're not familiar with states, you'll likely need to keep that page open and check it frequently while coding until you get used to it.

A basic state sequence is defined as follows:

```csharp
States 
{
StateLabel:
    SPRT A 1;
    SPRT B 2 A_Function();
    SPRT C 5;
    stop;
}
```

In this example `SPRT` is the sprite name, `A` is a frame letter, and numbers (1, 2 and 5) are the sprites duration in tics (a tic in GZDoom is 1/35th of a second). **Sprites** have to be named in a specific format described [here](https://zdoom.org/wiki/Sprite) in order to work properly.

### References:

* [Actor states](https://zdoom.org/wiki/Actor_states) on the Wiki
* [Flow Control: State Control](A1_Flow_Control.md#state-control) in this guide
* [Sprite naming and use](https://zdoom.org/wiki/Sprite) on the Wiki

## Coding a basic object

Basic objects, such as decorations (trees, lamps, etc.) are the simplest type of actor you can define. For an example of a basic actor we can look at a big brown tree from Doom:

```csharp
//NOTE: this actor already exists in GZDoom and doesn't need to be redefined

class BigTree : Actor
{
    Default
    {
        Radius 32; //actor's width
        Height 108; //actor's height for collision with monstrers/player
        ProjectilePassHeight -16; //vertical collision for projectiles is 16 units shorter than its height
        +SOLID //makes the actor solid (monsters/players/projectiles can't pass through it; hitscan attacks can)
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
//in this example states aren't redefined because we're reusing the same frames
```

This will create a version of `BigTree` that looks the same but appears twice as smaller and has twice as smaller collision box.

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
        POSS U -1; //final frame of the unmoving corpse
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

### Coding a basic weapon

There are a few rules regarding weapons:

* Weapons must be based on the `Weapon` class (or you can create your own basic class based on `Weapon` and have your weapons inherit from it).
* [Weapons use their own attack functions](https://zdoom.org/wiki/Category:Decorate_Weapon_attack_functions). While various attack functions are called from the weapon, they're actually executed by the player pawn, a player-controlled class. It's a special interaction; as a result you can't call monster attack functions on weapons.
* Weapon states define frames that are drawn directly on the screen.

For an example of a basic weapon let's look at Pistol from Doom:

```csharp
class Pistol : DoomWeapon //DoomWeapon is a base class based on Weapon. It only defines kickback (recoil).
{
     Default
    {
        Weapon.SelectionOrder 1900 //defines the priority of selecting this weapons when others run out of ammo
        Weapon.AmmoUse 1 //how much ammo it uses per shot
        Weapon.AmmoGive 20 //how much ammo the weapon gives you when you get it
        Weapon.AmmoType "Clip" //the class name of the ammo type used by the weapon
        Obituary "$OB_MPPISTOL" //a message printed on the screen when one player kills another in multiplayer
        +WEAPON.WIMPY_WEAPON //tells the game to switch to another weapon as soon as ammo is available
        Inventory.Pickupmessage "$PICKUP_PISTOL_DROPPED" //the message printed on the screen when picking this up
        Tag "$TAG_PISTOL" //name of the weapon
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

Weapons with a reload mechanic are very common. Usually to achieve that a special "magazine" ammo type is defined and is used as `AmmoType` while the reserve ammo is defined as `AmmoType2`. A `Reload` state sequence is used to handle the reload mechanics. 

Note, the example below is likely too complex for you to understand right away, so it's recommend that you revisit it later, when you get further in the guide.

Here's an example of a modified Doom Pistol with a reload mechanic:

```csharp
class PistolWithReload : Pistol //it's based on the existing Pistol, so it inherits all of its properties
{
     Default
    {
        +WEAPON.AMMO_OPTIONAL //without this flag the weapon will be deselected as soon as the magazine is empty
        Weapon.AmmoType "PistolMagazine"; //a special "magazine" ammo type 
        Weapon.AmmoType2 "Clip"; //Clip is still used as reserve ammo
        Weapon.AmmoGive2 20; //the weapon will give some reserve ammo when picked up
    }

    // This defines a custom version of the A_WeaponReady function
    // that will block the ability to reload if the player
    // doesn't have any reserve ammo, or if their magazine
    // is already full:
    action void A_WeaponReadyReload(int flags = 0)
    {
		// Check that ammo1 (magazine) is lower than maxamount
        // and ammo2 (reserve ammo) is above ammouse1 (the amount
        // of magazine ammo used for firing):
		if (invoker.ammo1.amount < invoker.ammo1.maxamount && invoker.ammo2.amount > invoker.ammouse1)
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
            TakeInventory(invoker.ammo2.GetClass(), 1); //take 1 of AmmoType2
            GiveInventory(invoker.ammo1.GetClass(), 1); //give 1 of AmmoType1
        }
    }

    States
    {
    Ready:
        PISG A 1 A_WeaponReadyReload;
        Loop;
    Fire:
        PISG A 4 A_JumpIfNoAmmo("Reload"); //if PistolMagazine ammo is 0, jumps to Reload instead of playing the animation
        PISG B 6 A_FirePistol;
        PISG C 4;
        PISG B 5 A_ReFire;
        Goto Ready;
    Reload:
        PISG AAAA 2 A_WeaponOffset(3, 5, WOF_ADD); //simply shifts the weapon downward and to the right
        PISG A 15 //wait for 15 tics and perform the following anonymous function:
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
