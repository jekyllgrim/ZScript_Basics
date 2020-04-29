## [<<< Back to  start](README.md)

[<< Previous: Virtual Functions](Virtual_functions.md)

# Event Handlers

We mentioned at the beginning of this guide that ZScript isn't restricted to actors and has other types of classes. One of the commonly used (and extremely handy) non-Actor classes is `EventHandler`. An event handler calls various virtual functions when certain events happen in the game and can be used as a replacement for some of the ACS scripts and much more.

To create an event handler, you need to define a class that inherits from `EventHandler`, and also add that class in MAPINFO, so the basic definition of any event handler looks like this:

```csharp
//ZScript:

Class MyCustomStuffHandler : EventHandler {
	//custom stuff goes here
}


//MAPINFO:

Gameinfo {
	AddEventHandlers = "MyCustomStuffHandler"
}
```

By overriding virtual functions of an event handler, you can make stuff happen in the game without replacing actors, which allows to create universal mods with high compatibility, or produce effects that, for example, affect all monsters without the need to replace them.

Here's a simple event handler:

```csharp
Class CorpseDestroyer : EventHandler {
	override void WorldThingDied (Worldevent e) {
		if (e.thing && e.thing.bISMONSTER);
			e.thing.destroy();
	}
}
```

Let's break it down how this works:

- All events of an event handler have access to a pointer `e` (the type of the pointer is `WorldEvent`). This pointer is a bit different from actor pointers we covered earlier; it's not a pointer to an in-game object, but rather to the *event itself*. 
- Through pointer `e` you can access various other pointers that this specific event can access.
- Whenever anything in the world is killed, it triggers a `WorldThingDied` event. This event has access to the actor that was killed via `e.thing` pointer (`e` being pointer to the event, and `thing` being the pointer to the thing that event is concerned with).
- In the example above we first check if `e.thing` exists (a standard null-check), and then we check if it has an `ISMONSTER` flag (which is normally the best defining feature of a monster).
- If both checks pass, we call `destroy()` on the thing to make it disappear from the map.

Notice that event virtual functions don't need a `super.` call as opposed to [Actor virtual functions](Virtual_functions.md), because the virtual functions of the `EventHandler` class are empty: other things that need to happen when something dies will happen anyway, it's not tied to event handlers.

So, this handler will remove anything that we kill. However, it's not very elegant, since every monster will just pop out of existence as soon as it dies—and it won't even finish its Death animation, it'll disappear as soon as its health reaches 0.

Let's say we want to fade it out. But we can't make it via an event handler—this event is called only once when the monster is killed, so we can't loop `A_FadeOut` in it. For something like this `Inventory` objects are usually used as containers for special effects, like so:

```csharp
Class CorpseFadeHandler : EventHandler {
	override void WorldThingDied (WorldEvent e) {		
		if (e.thing && e.thing.bISMONSTER)	//check the killed actor exists and is a monster
			e.thing.GiveInventory("CorpseFader",1);	//if so, give it this inventory token
	}
}

Class CorpseFader : Inventory {
	Default {
		inventory.maxamount 1;
	}	
	override void AttachToOwner (Actor user) {
		super.AttachToOwner(user);
        //once the item is attached, set owner's renderstyle to 'Translucent':
		if (owner)
			owner.A_SetRenderstyle(alpha,Style_Translucent); 
	}
	override void DoEffect() {
		super.DoEffect();
		if (!owner)
			return;
		owner.A_FadeOut(0.01);	//phase the owner out
	}
}
```

This is an easy and handy method to attach code to an actor without actually replacing the actor, which is something you might want to do if you're making a minimod that is meant to be universally compatible with other mods.



Let's take a look at a few other examples.

This handler could be used as a basis for a reward/score system:

```csharp
Class RewardStuff : EventHandler {
	int killedmonsters; //this will serve as a counter
	override void WorldThingDied (worldevent e) {
		//check the thing is a monster and was killed by the player:
		if (e.thing && e.thing.bISMONSTER && e.thing.target && e.thing.target.player) {
			killedmonsters++;	//increase the counter by 1			
			Console.Printf("Monsters killed: %d",killedmonsters); //print the resulting number
			if (killedmonsters >= 50) {
				Actor.Spawn("Megasphere",e.thing.target.pos); //spawn a megasphere under the player
				Console.Printf("Here's a megasphere");
				killedmonsters = 0;				//reset counter
			}
		}
	}
}
```

Notes:

- Normally when actor A kills actor B, actor A will become actor B's `target`, so the `target` pointer serves as a pointer to the killer. Hence `e.thing.target && e.thing.target.player` checks that `target` exists and that it's a player.
- `Console.PrintF` is a Java-like function that prints stuff into the console and the standard Doom message area. It's often used for debugging as well: it works similarly to `A_Log` and allows passing values to it via `%d`, `%f` and such, which are described [here](https://zdoom.org/wiki/String#Methods).
- Since `EventHandler` is not actor, to use some ZScript functions you need to explicitly tell it it's an actor function. `Actor.Spawn` tells it to use `Spawn` as defined in `Actor`. You won't need to do it for DECORATE action functions.

It's important that this event handler could be optimized like so:

```csharp
Class RewardStuff : EventHandler {
	int killedmonsters;
	override void WorldThingDied (worldevent e) {
		if (!e.thing || !e.thing.bISMONSTER || !e.thing.target || !e.thing.target.player)
			return;
		killedmonsters++;
		Console.Printf("Monsters killed: %d",killedmonsters);
		if (killedmonsters >= 50) {
			Actor.Spawn("Megasphere",e.thing.target.pos);
			Console.Printf("Here's a megasphere");
			killedmonsters = 0;
		}
	}
}
```

In this version we inverted the check: instead of doing "if A and B and C and D — do the thing" it's doing "if not A, do nothing; otherwise if not B, do nothing; otherwise if not C, do nothing; otherwise if not D, do nothing".

This makes the string of checks shorter, and whenever any of the checks is false, `return;` is called and the function is cut off. In other words, GZDoom will mostly have to do fewer checks: one or two most of the time, instead of doing *all* 4 checks *every* time a thing is spawned. This can affect the game's performance.



Handlers can be used to store global data, similarly to global variables in ACS. To retrive that data from a class, you'll need to cast your event handler just like you cast custom actors:

```csharp
Class CheckMonsterAmount : EventHandler {
	int alivemonsters;	//this simple int will hold the number of alive monsters
    //called when an actor is spawned in map:
	override void WorldThingSpawned (worldevent e) { 
        //check if actor exists, is a monster and isn't friendly:
		if (e.thing && e.thing.bISMONSTER && !e.thing.bFRIENDLY)	
			alivemonsters++; 	//if so, increase counter
	}
    //called when an actor dies in a map:
	override void WorldThingDied (worldevent e) {
		if (e.thing && e.thing.bISMONSTER && !!e.thing.bFRIENDLY)
			alivemonsters--;	//decrease counter
	}
}

Class CyberdemonLeader : Cyberdemon replaces Cyberdemon {
	override void PostBeginPlay() {
		super.PostBeginPlay();
		//cast the event handler just like you cast actors:
		let event = CheckMonsterAmount(EventHandler.Find("CheckMonsterAmount"));
		if (event) //null-check the cast		
			A_SetHealth(3000 + 100*event.alivemonsters); //change health value
		console.Printf("cyberdemon health: %d",health);	 //debug string that prints the result
	}
}
```

When spawned, this Cyberdemon will check the `alivemonsters` variable held in our custom event handler, then its health will be set to 3000 plus 100 health per each monster alive.



Finally, here's a slightly more advanced example where an event handler and a dummy item container are used to create a bleeding system:

```csharp
/*	this is our control item: when in player's inventory, it'll control
	bleed buildup and bleed damage:
*/
Class PlayerBleedControl : Inventory {
	Default {
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		inventory.maxamount 1;
	}
	
	bool isbleeding;	//if this is true, owner is bleeding	
	int bleedbuildup;	//this holds the buildup value
	actor bleedsource;	//holds the actor who dealt damage, for proper kill credit

	//runs every tic the item is in possession:
	override void DoEffect () {
		super.DoEffect();
		//null-check the owner:
		if (!owner)
			return;
		//debug printf, uncomment to see the information in game:
		//Console.Printf("Bleed buildup: %d; Bleeding: %d",bleedbuildup,isbleeding); 

		//this thing only runs once a second:
		if (level.time % 35 == 0) {
			//decrease buildup value by 1, keeping it within 0-100 range
			bleedbuildup = Clamp(bleedbuildup - 1, 0, 100);
			//if currently bleeding, deal damage:
			if (isbleeding)	 {
				/*	Damage value is equal to 20% of buildup, but always between 1-5,
					so, the higher bleedbuildup is, the greater the damage.
					Also, damage ignores armor, powerups and doesn't move the player:
				*/
				owner.DamageMobj(owner,bleedsource,Clamp(bleedbuildup * 0.2,1,5),"normal",DMG_NO_ARMOR|DMG_THRUSTLESS|DMG_NO_ENHANCE); 
			}
			/*	Also every second we may stop bleeding if a random value between 1–80
				turns out to be higher than bleedbuildup value.
				So, the lower the buildup, the higher is the chance that we stop
				bleeding. This simulates wound drying over time.
			*/
			if (random(1,80) > bleedbuildup) {			
				isbleeding = false;					
			}
		}
	}
}

// This event handler gives the control item and activates the bleeding itself:

Class BleedingHandler : EventHandler {
	//check if spawned thing is a player and doesn't have the control item:
	override void WorldThingSpawned (WorldEvent e) {         
		if (e.thing.player && !e.thing.FindInventory("PlayerBleedControl"))            
			e.thing.GiveInventory("PlayerBleedControl",1);	//if so, give them the item				
	}
	//this is called whenever an actor is damaged:
	override void WorldThingDamaged (WorldEvent e) {										
		//do nothing if the thing doesn't exist:
		if (!e.thing != "bleed")
			return;									
		//if for some reason they don't have our control item, also do nothing:
		if (!e.thing.FindInventory("PlayerBleedControl"))						
			return;
		//otherwise cast the item:
		let bleeder = PlayerBleedControl(e.thing.FindInventory("PlayerBleedControl"));	
		if (!bleeder)																		
			return;	//do nothing if cast failed
		//if successful, raise buildup value to the same number as dealt damage:
		bleeder.bleedbuildup = Clamp(bleeder.bleedbuildup + e.Damage, 0, 100);
		//immediately after, run the resulting buildup value against a random 0-100 value:
		if (random(1,100) < bleeder.bleedbuildup) {
			//if check passed, start bleeding:
			bleeder.isbleeding = true;
			//save the actor that dealt damage for proper kill credit if player bleeds out:
			bleeder.bleedsource = e.DamageSource;											
		}
	}	
}
```

The basic mechanics of this system is actually relatively simple:

- Whenever a player is spawned in a map, they receive the control item. That item holds `bleedbuildup` which serves as an invisible "gauge" that shows how close the player is to starting bleeding.
- Whenever damage is dealt to the player, their `bleedbuildup` value increases by the same number as the damage dealt. So, for example, if a Zombieman shot us for 7 damage, `bleedbuildup` will raise by 7. (`bleedbuildup` can not go beyond 100, however.)
- Also, every time the player is damaged, a random 0–100 value is checked against `bleedbuildup`. The higher `bleedbuildup` is, the higher is the chance the check will pass. If the check passes, the player will start bleeding.
- The control item handles the bleeding itself. While the player isn't bleeding, the item doesn't do anything. But as soon as they start bleeding, the player will be damaged every second. The damage is always between 1 and 5, but it'll be higher depending on how high `bleedbuildup` is.
- *Also* every second the player has a chance to stop bleeding. This chance is a value between 0–80 compared to `bleedbuildup`. Since `bleedbuildup` can go up to 100, if it's over 80, the player can't stop bleeding. (So, if you're "heavily wounded", bleeding is guaranteed.)

Some notes of the functions used in this script:

- `Clamp(value, min, max)` allows modifying a value while making sure it doesn't exceed the `min` or `max` values. In the example above `bleedbuildup = Clamp(bleedbuildup - 1, 0, 100)` is similar to doing `bleedbuildup -= 1`, but it makes sure it never goes below 0 or above 100.
- `level.time` is a global variable that returns how much time (in tics) has passed since the current map was started. It's a neat and simple way to make sure effects occur only after a specific period of time or with specific intervals (as above). It's necessary in constantly executing functions, such as `Tick()` or `DoEffect()`, since they don't have any analog of `wait` or `delay`.
- `%` is a [modulo operator](https://en.wikipedia.org/wiki/Modulo_operation): `value1 % value2` will return the remaining number after a division of `value1` by `value2`, known as **modulus**. For example, the expression `5 % 2` would give us modulus 1 because 5 divided by 2 has a quotient of 2 and a remainder of 1, while `9 % 3` would evaluate to 0 because the division of 9 by 3 has a quotient of 3 and leaves a remainder of 0; there is nothing to subtract from 9 after multiplying 3 times 3. Hence, the check `if (level.time % 35 == 0)` will return true every 35 tics, because a value such as 105 divided by 35 has a quotient of 3 (since 3 x 35 = 105) and a remainder of 0.



### [>> Arrays](Arrays.md)