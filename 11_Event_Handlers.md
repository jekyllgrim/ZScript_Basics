🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Virtual Functions](10_Virtual_functions.md)        🔵 [>> Next: Player, PlayerInfo and PlayerPawn](12.0_Player.md)

------

# Event Handlers

* [Overview](#overview)
  + [Static vs dynamic event handlers](#static-vs-dynamic-event-handlers)
* [Injecting behavior with event handlers and Inventory](#injecting-behavior-with-event-handlers-and-inventory)
* [Using event handlers to store global variables](#using-event-handlers-to-store-global-variables)
* [Actor replacement via event handlers](#actor-replacement-via-event-handlers)
  + [Marking bosses and special enemies](#marking-bosses-and-special-enemies)
* [Examples of advanced event handler applications](#examples-of-advanced-event-handler-applications)

## Overview

We mentioned at the beginning of this guide that ZScript isn't restricted to actors and has other types of classes. One of the commonly used (and extremely handy) non-Actor classes is `EventHandler`. An event handler calls various virtual functions when certain events happen in the game and can be used as a replacement for some of the ACS scripts and much more.

To create an event handler, you need to define a class that inherits from `EventHandler` (or `StaticEventHandler` if you want a static one, but more on that below), and also add that class in MAPINFO, so the basic definition of any event handler looks like this:

```csharp
//ZScript:

class MyCustomStuffHandler : EventHandler 
{
    //custom stuff goes here
}


//MAPINFO:

Gameinfo 
{
    AddEventHandlers = "MyCustomStuffHandler"
}
```

By overriding virtual functions of an event handler, you can make stuff happen in the game that isn't attached to any specific actors. (You can find all event handler virtuals [on the ZDoom wiki](https://zdoom.org/wiki/Events_and_handlers)).

Using event handlers allows adding behavior to actors without replacing them, which allows to create universal mods with high compatibility, or produce effects that, for example, affect all monsters without the need to replace them.

Here's a simple event handler:

```csharp
class CorpseDestroyer : EventHandler 
{
    override void WorldThingDied (Worldevent e) 
    {
        if (e.thing && e.thing.bISMONSTER);
            e.thing.Destroy();
    }
}
```

This event destroys monsters as soon as they die. Let's break it down how this works:

- All events of an event handler have access to a pointer `e` (in this case the type of that pointer is `WorldEvent). This pointer is a bit different from actor pointers we covered earlier; it's not a pointer to an in-game object, but rather to the *event itself*. 
- Through pointer `e` you can access various other pointers that this specific event can access.
- Whenever anything in the world is killed, it triggers a `WorldThingDied` event. This event has access to the actor that was killed via `e.thing` pointer (`e` being pointer to the event, and `thing` being the pointer to the thing that event is concerned with—the thing that died).
- In the example above we first check if `e.thing` exists (a standard null-check), and then we check if it has an `ISMONSTER` flag (which is normally the best defining feature of a monster).
- If both checks pass, we call `Destroy()` on the thing to make it disappear from the map.

Notice that event virtual functions don't need a `super.` call as opposed to [Actor virtual functions](10_Virtual_functions.md), because the virtual functions of the `EventHandler` class are empty: other things that need to happen when something dies will happen anyway, it's not tied to event handlers.

### Static vs dynamic event handlers

Event handlers can be static and dynamic. Dynamic event handlers need to inherit from the `EventHandler` class, while static event handlers inherit from the `StaticEventHandler` class.

Dynamic event handlers are created at map start, before any of the actors, and exist only for one map. The state of a dynamic event handler is written into save games, so you can use it to store some global data (see below) but it'll only exist for one map.

Static event handlers exist throughout the game session. However, they're not written into save games, so you can't store any data in them as it'll be wiped when you quit, and it won't change if you load an earlier save. Static event handlers are more niche; you can utilize them to execute some events when the player loads a save (which regular event handlers don't have access too), like displaying some kind of a message.

Most of the time you only need the regular event handlers. Static event handlers are normally used for advanced features where you need to handle something in global context, not tied to playsim. You can find more information on [ZDoom wiki](https://zdoom.org/wiki/Events_and_handlers).

## Injecting behavior with event handlers and Inventory

The handler provided in the previous subsection will remove anything that we kill from the map. However, it's not very elegant, since every monster will just pop out of existence as soon as it dies—and it won't even finish its Death animation, it'll disappear as soon as its health reaches 0.

Let's say we want corpses of all monsters to fade it out. But we can't make it via an event handler alone—this event is called only once, the moment the monster is killed, so we can't loop `A_FadeOut` in it. Since we don't want to replace the actors themselves, we need to find a way to inject code into them.

For something like this `Inventory` objects are usually used as containers for special effects. For example:

```csharp
class CorpseFadeHandler : EventHandler 
{
    override void WorldThingDied (WorldEvent e) 
    {
        if (e.thing && e.thing.bISMONSTER)    //check the killed actor exists and is a monster
            e.thing.GiveInventory("CorpseFader",1);    //if so, give it this inventory token
    }
}

// The following item will fade out its owner:
class CorpseFader : Inventory 
{
    Default 
    {
        inventory.maxamount 1;
    }

    override void AttachToOwner (Actor other) 
    {
        super.AttachToOwner(other);
        //once the item is attached, set owner's renderstyle to 'Translucent':
        if (owner)
            owner.A_SetRenderstyle(alpha,Style_Translucent); 
    }

    override void DoEffect() 
    {
        super.DoEffect();
        if (owner)
            owner.A_FadeOut(0.01);    //phase the owner out
    }
}

// Don't forget to add your handler via MAPINFO
```

This is an easy and handy method to attach code to an actor without actually replacing the actor, which is something you might want to do if you're making a minimod that is meant to be universally compatible with other mods.

## Using event handlers to store global variables

Handlers can be used to store global data, similarly to global variables in ACS (but they will only exist within one map). To retrieve that data from a class you'll need to cast your event handler just like you cast custom actors, using a static `EventHandlers.Find()` function. In the context of that function `EventHandlers` is an array of all event handlers loaded in the current game (you'll read about [arrays](13_Arrays.md) a bit later in the guide). 

Here's an example:

```csharp
class CheckMonsterAmount : EventHandler
{
    int alivemonsters;    //this simple int will hold the number of alive monsters

    // This is called when an actor is spawned in map:
    override void WorldThingSpawned (worldevent e) 
    { 
        //check if actor exists, is a monster and isn't friendly:
        if (e.thing && e.thing.bISMONSTER && !e.thing.bFRIENDLY)    
            alivemonsters++; //if so, increase counter
    }

    // This is called when an actor dies in a map:
    override void WorldThingDied (worldevent e) 
    {
        if (e.thing && e.thing.bISMONSTER && !!e.thing.bFRIENDLY)
            alivemonsters--; //decrease counter
    }

    // This is called when an actor is destroyed,
    // e.g. when Destroy() is called on it:
    override void WorldThingDestroyed (worldevent e) 
    {
        if (e.thing && e.thing.bISMONSTER && !!e.thing.bFRIENDLY)
            alivemonsters--; //decrease counter
    }

    // This is called when an actor is revived,
    // e.g. when an Arch-Vile resurrects it:
    override void WorldThingRevived (worldevent e) 
    {
        if (e.thing && e.thing.bISMONSTER && !!e.thing.bFRIENDLY)
            alivemonsters++; //decrease counter
    }
}

class CyberdemonLeader : Cyberdemon replaces Cyberdemon 
{
    override void PostBeginPlay() 
    {
        super.PostBeginPlay();
        //cast the event handler just like you cast actors:
        let event = CheckMonsterAmount(EventHandler.Find("CheckMonsterAmount"));
        if (event) //null-check the cast        
            A_SetHealth(3000 + 100*event.alivemonsters); //change health value
        console.Printf("cyberdemon health: %d",health);     //debug string that prints the result
    }
}

// As always, don't forget to add your handler via MAPINFO
```

When spawned, this Cyberdemon will check the `alivemonsters` variable held in our custom event handler, then its health will be set to 3000 plus 100 health per each monster alive.

## Actor replacement via event handlers

Weapon and gameplay mods that don't contain any maps widely use actor replacement, so that the mod's actors will spawn instead of the vanilla actors on whatever map the user is playing. Traditionally this is done with the use of the `replaces` keyword in the actor's definition:

```csharp
class NewClassName : ParentClassName replaces NameOfReplacedClass
{
    //actor code
}
```

However, ZScript allows to do this more conveniently with the help of a `CheckReplacement()` event. It's used as follows:

```csharp
class MyEventHandler : EventHandler
{
    override void CheckReplacement (ReplaceEvent e)
    {
        if (e.Replacee == "ReplaceeClassName")
        {
            e.Replacement = "ReplacementClassName";
        }
    }
}
```

`CheckReplacement()` event has access to the following values:

- `Replacee` — a `Class<Actor>`-type value that contains the name of the class to be replaced
- `Replacement` — a `Class<Actor>`-type value that contains the name of the class to be used as a replacement
- `isFinal` — a boolean value that determines if this replacement should be considered final. If there are multiple event handlers that have their own `CheckReplacement()` overrides (such as when multiple mods are run together), some of the overrides can choose to not set their `Replacement`s if another handler set `e.isFinal` to true. If this isn't used, then whatever event handler comes last in the load order will take precedence. Normally you don't need to worry about this.

An event handler with replacements would look like this:

```csharp
class ActorReplacementHandler : EventHandler
{
    override void CheckReplacement(replaceEvent e)
    {
        if (e.Replacee == "Zombieman")
        {
            e.Replacement = "MyCustomZombieman";
        }
    }
}
```

If you want to allow other mods to replace it with priority over your project, you can also add an `isFinal` check:

```csharp
class ActorReplacementHandler : EventHandler
{
    override void CheckReplacement(replaceEvent e)
    {
        if (e.Replacee == "Zombieman" && !e.isFinal)
        {
            e.Replacement = "MyCustomZombieman";
        }
    }
}
```

Replacing multiple monsters with if/else blocks may be inconvenient, so I would recommend using a `switch` block (you can read more about it in the [Flow Control](A1_Flow_Control.md#Switch) chapter):

```csharp
class ActorReplacementHandler : EventHandler
{
    override void CheckReplacement(replaceEvent e)
    {
        let cls = e.Replacee.GetClassName();
        switch (cls)
        {
        case 'Zombieman':
            e.Replacement = "MyCustomZombieman";
            break;
        case 'DoomImp':
            e.Replacement = "MyCustomDoomImp";
            break;
        case 'ChaingunGuy':
            e.Replacement = "MyCustomChaingunGuy";
            break;
        // and so on...
        }
    }
}

// As always, don't forget to add your handler via MAPINFO
```

And that's it!

So, why do you want to use that instead of `replaces`? Primarily two reasons:

* Event handler replacements actually take precedence over the `replaces` keyword. And this may be important. Let's say you've made a monster pack or a mod that comes with custom monsters and you've spent a while on working on them. However, some map packs come with their own versions of monsters but those versions are only marginally different: for example, they define a custom blood color something else purely visual. Unless you use `CheckReplacement()`, you can't guarantee your custom monsters will be visible on those maps.
  
  * The other, perhaps more obvious case is when you want to make a modern ZScript patch for an older DECORATE mod. Making something like this may require overriding some of the original mod's replacements, and this is your way.

* What's even better, this allows you to avoid duplicates! If you want the same class to replace multiple existing classes, or have an existing class replace something, in DECORATE you'd have to create a duplicate class for that, but in ZScript you just use it in `CheckReplacement()` multiple times:
  
  ```csharp
  class CacodemonsForEveryone : EventHandler
  {
      override void CheckReplacement(replaceEvent e)
      {
          let cls = e.Replacee.GetClassName();
          switch (cls)
          {
          case 'Zombieman':
              e.Replacement = "Cacodemon";
              break;
          case 'DoomImp':
              e.Replacement = "Cacodemon";
              break;
          case 'ChaingunGuy':
              e.Replacement = "Cacodemon";
              break;
          }
      }
  }
  ```

### Marking bosses and special enemies

There's a second part to replacing actors via event handlers, and that's when it comes to what I like to call "the dead simple problem." This refers, of course, to the Doom II map 07 "Dead Simple", where a bunch of doors opens when all mancubi are killed, and then a platform raises when all arachnotrons are killed. This behavior occurs in many other maps as well (e.g. in Doom, E1M8, with barons of hell), and since it comes from the vanilla Doom, which didn't have any sort of fancy scripting like ACS, it's incorporated in a special way.

That behavior is tied to the monster calling `A_BossDeath()` in their Death sequence. But that's not all. The thing is, if you replace any of the monsters involved into that behavior (such as Fatso), that behavior will not work unless that monster *inherits* from the original one. 

But what if that's not convenient? For example, what if you made your own custom base monster class for your project, and you want all your monsters to inherit from that class because it has a bunch of custom behavior tied to it?

That's where the `CheckReplacee()` event comes in! `CheckReplacee()` is basically an inverse of `CheckReplacement()`: it allows you to find a monster that works as a replacement for something, and tell the engine *what* it's a replacement *for*. Here's an example:

```csharp
class ActorReplacementHandler : EventHandler
{
    // Replaces arachnotrons with our custom class:
    override void CheckReplacement(replaceEvent e)
    {
        if (e.Replacee == "Arachnotron")
        {
            e.Replacement = "ShotgunguyTest";
        }
    }
    // Tells the game that ShotgunguyTest is a replacement for Arachnotron.
    // Note, the argument type is REPLACEDevent, not REPLACEevent, as
    // opposed to CheckReplacement():
    override void CheckReplacee (replacedEvent e)
    {
        if (e.Replacement == "ShotgunguyTest")
        {
            e.Replacee = "Arachnotron";
        }
    }
}

// Note, the replacement actor *still* has to call A_BossDeath,
// otherwise the desired behavior will not be triggered:
class ShotgunguyTest : Shotgunguy
{
    // We could override the actor's Death and XDeath state
    // sequences, but we're using a Die virtual instead to
    // make it a bit simpler:
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
    {
        A_BossDeath();
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}
```

> *Note:* `Die()` is a [virtual function](https://zdoom.org/wiki/ZScript_virtual_functions) that is called by actors when their `health` is 0 or lower. It can be used to add some special effects based on the source, inflictor or other behavior (these arguments are the same as the ones used by the [`DamageMobj()`](https://zdoom.org/wiki/DamageMobj) function), but here we're simply adding behavior to it.

As noted, the replacement actor still has to call [`A_BossDeath`](https://zdoom.org/wiki/A_BossDeath), but both that function *and* a `CheckReplacee()` override are required for it to trigger the map special (lowering floors in this case).

You don't have to override `Die()` as in the example above; you can insert the function into the actor's state sequences. But in that case remember that you may need to override both Death and XDeath, if the actor can be gibbed.

## Examples of advanced event handler applications

Let's take a look at a few other examples.

This handler could be used as a basis for a reward/score system:

```csharp
class RewardStuff : EventHandler 
{
    int killedmonsters; //this will serve as a counter

    override void WorldThingDied (worldevent e) 
    {
        //check the thing is a monster and was killed by the player:
        if (e.thing && e.thing.bISMONSTER && e.thing.target && e.thing.target.player) 
        {
            killedmonsters++; //increase the counter by 1            
            console.Printf("Monsters killed: %d",killedmonsters); //print the resulting number
            if (killedmonsters >= 50) 
            {
                Actor.Spawn("Megasphere",e.thing.target.pos); //spawn a megasphere under the player
                Console.Printf("Here's a megasphere");
                killedmonsters = 0; //reset counter
            }
        }
    }
}

// As always, don't forget to add your handler via MAPINFO
```

Notes:

- Normally when actor A kills actor B, actor A will become actor B's `target`, so the `target` pointer serves as a pointer to the killer. Hence `e.thing.target && e.thing.target.player` checks that the killed thing has a `target` and that it's a player.
- `Console.PrintF` is a Java-like function that prints stuff into the console and the standard Doom message area. It's often used for debugging as well: it works similarly to `A_Log` and allows passing values to it via `%d`, `%f` and such, which are described [here](https://zdoom.org/wiki/String#Methods).
- Since `EventHandler` is not an actor, to use ZScript Actor functions from it you need to explicitly tell it it's an actor function. `Actor.Spawn` tells it to use `Spawn` as defined in `Actor`. You won't need to do it for DECORATE action functions.

This event handler could also be written the following way:

```csharp
class RewardStuff : EventHandler
{
    int killedmonsters;

    override void WorldThingDied (worldevent e) 
    {
        if (!e.thing || !e.thing.bISMONSTER || !e.thing.target || !e.thing.target.player)
            return;
        killedmonsters++;
        Console.Printf("Monsters killed: %d",killedmonsters);
        if (killedmonsters >= 50) 
        {
            Actor.Spawn("Megasphere",e.thing.target.pos);
            Console.Printf("Here's a megasphere");
            killedmonsters = 0;
        }
    }
}
```

It doesn't make any difference performance-wise (both `||` and `&&` strings of checks will be cut off as soon as one check returns false), but it's arguably easier to read because it contains fewer curly braces.

Here's a slightly more advanced example where an event handler and a dummy item container are used to create a bleeding system:

```csharp
/*    This is our control item: when in player's inventory, it'll control
    bleed buildup and bleed damage:
*/
class PlayerBleedControl : Inventory
{
    Default 
    {
        // These make sure that the item can't be dropped
        // or otherwise removed from player's inventory,
        // and the player can't receive duplicates of it:
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNTOSSABLE
        inventory.maxamount 1;
    }

    bool isbleeding;    //if this is true, owner is bleeding    
    int bleedbuildup;    //this holds the buildup value
    actor bleedsource;    //holds the actor that dealt damage, for proper kill credit

    //runs every tic the item is in possession:
    override void DoEffect ()
    {
        super.DoEffect();
        //null-check the owner:
        if (!owner)
            return;
        //debug printf, uncomment to see the information in game:
        //Console.Printf("Bleed buildup: %d; Bleeding: %d",bleedbuildup,isbleeding); 

        //this thing only runs once a second:
        if (level.time % 35 == 0) 
        {
            //decrease buildup value by 1, keeping it within 0-100 range
            bleedbuildup = Clamp(bleedbuildup - 1, 0, 100);
            //if currently bleeding, deal damage:
            if (isbleeding)
            {
                /*    Damage value is equal to 20% of buildup, but always between 1-5,
                    so, the higher bleedbuildup is, the greater the damage.
                    Also, damage ignores armor, powerups and doesn't move the player:
                */
                owner.DamageMobj(owner,bleedsource,Clamp(bleedbuildup * 0.2,1,5),"normal",DMG_NO_ARMOR|DMG_THRUSTLESS|DMG_NO_ENHANCE); 
            }
            /*    Also every second we may stop bleeding if a random value between 1–80
                turns out to be higher than bleedbuildup value.
                So, the lower the buildup, the higher is the chance that we stop
                bleeding. This simulates wound drying over time.
            */
            if (random(1,80) > bleedbuildup) 
            {
                isbleeding = false;                    
            }
        }
    }
}

// This event handler gives the control item and activates the bleeding itself:
class BleedingHandler : EventHandler 
{
    //check if spawned thing is a player and doesn't have the control item:
    override void WorldThingSpawned (WorldEvent e)
    {
        if (e.thing.player && !e.thing.FindInventory("PlayerBleedControl"))            
            e.thing.GiveInventory("PlayerBleedControl",1);    //if so, give them the item                
    }
    //this is called whenever an actor is damaged:
    override void WorldThingDamaged (WorldEvent e) 
    {
        //do nothing if the thing doesn't exist:
        if (!e.thing != "bleed")
            return;                                    
        //if for some reason they don't have our control item, also do nothing:
        if (!e.thing.FindInventory("PlayerBleedControl"))                        
            return;
        //otherwise cast the item:
        let bleeder = PlayerBleedControl(e.thing.FindInventory("PlayerBleedControl"));    
        if (!bleeder)                                                                        
            return;    //do nothing if cast failed
        //if successful, raise buildup value to the same number as dealt damage:
        bleeder.bleedbuildup = Clamp(bleeder.bleedbuildup + e.Damage, 0, 100);
        //immediately after, run the resulting buildup value against a random 0-100 value:
        if (random(1,100) < bleeder.bleedbuildup)
        {
            //if check passed, start bleeding:
            bleeder.isbleeding = true;
            //and save the actor that dealt damage for proper kill credit if player bleeds out:
            bleeder.bleedsource = e.DamageSource;                                            
        }
    }    
}
```

The basic mechanics of this system is actually relatively simple:

- Whenever a player is spawned in a map, they receive the control item. That item holds `bleedbuildup` which serves as an invisible "gauge" that shows how close the player is to starting bleeding.
- Whenever damage is dealt to the player, their `bleedbuildup` value increases by the same number as the damage dealt. So, for example, if a Zombieman shot us for 7 damage, `bleedbuildup` will raise by 7. (`bleedbuildup` can not go beyond 100, however.) For a stronger effect, you can multiply it.
- Also, every time the player is damaged, a random 0–100 value is checked against `bleedbuildup`. The higher `bleedbuildup` is, the higher is the chance the check will pass. If the check passes, the player will start bleeding.
- The control item handles the bleeding itself. While the player isn't bleeding, the item doesn't do anything. But as soon as they start bleeding, the player will be damaged every second. The damage is always between 1 and 5, but it'll be higher depending on how high `bleedbuildup` is.
- *Also* every second the player has a chance to stop bleeding. This chance is a value between 0–80 compared to `bleedbuildup`. Since `bleedbuildup` can go up to 100, the player can't stop bleeding as long as `bleedbuildup` is over 80. (So, if you're "heavily wounded", some bleeding is guaranteed.)

Some notes of the functions used in this script:

- `Clamp(value, min, max)` allows modifying a value while making sure it doesn't exceed the `min` or `max` values. In the example above `bleedbuildup = Clamp(bleedbuildup - 1, 0, 100)` is similar to doing `bleedbuildup -= 1`, but it makes sure it never goes below 0 or above 100.
- `level.time` is a [ZScript global variable](https://zdoom.org/wiki/ZScript_global_variables) that returns how much time (in tics) has passed since the current map was started. It's a neat and simple way to make sure effects occur only after a specific period of time or with specific intervals (as above). It's necessary in constantly executing functions, such as `Tick()` or `DoEffect()`, since they don't have any analog of `wait` or `delay`.
- `%` is a modulo operator (see [Wikipedia](https://en.wikipedia.org/wiki/Modulo_operation) and the [Flow Control chapter](#arithmetic-operators)): `value1 % value2` will return the remaining number after a division of `value1` by `value2`, known as **modulus**. For example, the expression `5 % 2` would give us modulus 1 because 5 divided by 2 has a quotient of 2 and a remainder of 1, while `9 % 3` would evaluate to 0 because the division of 9 by 3 has a quotient of 3 and leaves a remainder of 0; there is nothing to subtract from 9 after multiplying 3 times 3. Hence, the check `if (level.time % 35 == 0)` will return `true` every 35 tics, because a value such as 105 divided by 35 has a quotient of 3 (since 3 x 35 = 105) and a remainder of 0.

------

🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Virtual Functions](10_Virtual_functions.md)        🔵 [>> Next: Player, PlayerInfo and PlayerPawn](12.0_Player.md)
