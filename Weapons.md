🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Event Handlers](Event_Handlers.md)

------

# Weapons, overlays and PSprite

Weapons (i.e. classes that inherit from the base `Weapon` class) feature a number of special behaviors that aren't found in other classes, and you need to be aware of those behaviors to use them effectively.

Here's a brief overview:

* `Weapon` and `CustomInventory` are the only two base classes that inherit from an internal `StateProvider` class, which allows them to draw stuff on the screen. This is how weapon animations are performed. These sprites drawn on the screen are themselves a special object called `PSprite` (the name is an abbreviation for "player sprite").
* Weapon sprites can be drawn in multiple layers with the help of `A_Overlay` and the related functions. Those sprites can be independently offset, scaled and rotated. Each of those layers is a separate PSprite.
* Most weapon functions, such as `A_FireBullets`, `A_WeaponReady` and other functions that are called from the States block, are actually executed by the `PlayerPawn` carrying that weapon rather than the weapon itself. For example, when you call `A_FireProjectile` from the weapon's `Fire` state sequence, it's actually the player pawn that fires the projectile in the world, not the weapon (because at that point the weapon isn't present in the world, it exists only in the player's inventory). That's why monster attack functions, such as `A_SpawnProjectile`, can't be used in weapons, and vice versa.
    * When you make custom weapon functions, if the function is meant to be called from a weapon state, it has to be prefixed with `action` keyword—this designates it as a function meant to be called from a weapon state.
* As a result, in the context of a weapon state `self` is not the weapon, but the player pawn carrying it.
* If you define a [variable](Variables_and_data_types.md) on a weapon, to access that same variable from a weapon state you have to put an `invoker.` prefix before it.



## Accessing data from weapons

Weapons are a subcategory of the [Inventory](https://zdoom.org/wiki/Classes:Inventory) class. As such, they have access to Inventory's [virtual functions](Virtual_functions.md), such as `DoEffect()` (called every tic while the weapon is in somebody's inventory).

However, weapon *states* are unique to weapons (`CustomInventory` has them as well but it has its own peculiarities, so we'll talk about it elsewhere), and calling things from those states is also a special process.

> *Note*: At this point you may want to refresh your memory about [state flow control](Flow_Control.md#state-control), especially if you're not clear on what "state", "state sequence" and "state label" mean.

### Data manipulation in states

The simple rules regarding accessing data from weapon states are as follows:

* In the context of a weapon state `self` is not the weapon but the player that owns it. The weapon itself is accessed via a special pointer: `invoker`.
* If you have a variable `varname` defined in your weapon, to access it from a state you need to use `invoker.varname`.
* If you want to access it from the weapon but outside of a state—for example, from a `DoEffect()` override—use the variable name directly, as you normally would.
* Skipping a prefix in a weapon state context is not optional: GZDoom will abort with a "Self pointer used in ambiguous context" error.

For an example let's look at this version of the Plasma Rifle with an overheat/cooldown mechanic. Instead of showing a "cooldown" PLSGB0 sprite unconditionally, it shows it only if the `heatCounter` value reaches 40:

```cs
class OverheatingPlasmaRifle : PlasmaRifle
{
	int heatCounter; //this holds how much heat is accumulated
	States
	{
	Ready:
		PLSG A 10
		{
			A_WeaponReady();
			//while we're not firing, the heat will decay at the rate of 1 per 10 tics:
			if (invoker.heatCounter > 0)
				invoker.heatCounter--;
		}
		loop;
	Fire:
		PLSG A 3 
		{
			//if we've gained too much heat, jump to Cooldown:
			if (invoker.heatCounter >= 40)
				return ResolveState("Cooldown");
			//otherwise accumulate heat and fire:
			invoker.heatCounter++;
			A_FirePlasma();
			return ResolveState(null);
		}
		TNT1 A 0 A_ReFire; //note this frame has no duration
		goto Ready;
	Cooldown:
		//display a cooldown frame for 50 tics:
		PLSG B 50 
		{
			//this is meant to be a custom sound, it's not present in Doom:
			A_StartSound("weapons/plasma/cool");
			//reset the heat counter:
			invoker.heatCounter = 0;
		}
		goto Ready;
	}
}
```

Note that whenever `heatCounter` is referenced in a state, it has to be prefixed with `invoker.` to tell the game it's a variable on the weapon. This happens because, as stated earlier, weapon states interact both with the weapon and with the player carrying it, and as a result the context has to be specified explicitly.

### Data manipulation in virtual functions

The above rules are only true in the context of *states*. However, as you remember, weapons also have virtual functions, and those virtual functions are not considered states, and they follow the usual rules. 

For example, if you take the Plasma Rifle described above and decide to let the gained heat decay at *all* times instead of just the Ready state sequence, you can do it in `DoEffect()`—and there you won't need to use `invoker`:

```cs
class OverheatingPlasmaRifle2 : PlasmaRifle
{
	int heatCounter;
	override void DoEffect()
	{
		super.DoEffect();
		//using the modulo operator we can call this block every 10 tics (see Operators and operands):
		if (level.time % 10 == 0)
		{
			//no invoker. required here:
			if (heatCounter > 0)
				heatCounter--;
		}
	}
	States
	{
	Fire:
		PLSG A 3 
		{
			if (invoker.heatCounter >= 40)
				return ResolveState("Cooldown");
			invoker.heatCounter++;
			A_FirePlasma();
			return ResolveState(null);
		}
		TNT1 A 0 A_ReFire;
		goto Ready;
	Cooldown:
		PLSG B 50 
		{
			A_StartSound("weapons/plasma/cool");
			invoker.heatCounter = 0;
		}
		goto Ready;
	}
}
```

The reason here is simple: while weapon states can execute stuff both on the weapon and the player, `DoEffect()` is a virtual only called by the weapon, that's why there's no confusion about context.

If you want to do something to the player pawn from `DoEffect()`, this is possible in the same manner, as it would be from Inventory—just use the `owner` pointer:

```cs
//This pistol will give 1 HP to its owner every second:
class HealingPistol : Pistol
{
	override void DoEffect()
	{
		super.DoEffect();
		//null-check the owner pointer and call the code every 35 tics (=1 sec):
		if (owner && level.time % 35 == 0)
			owner.GiveBody(1); //heal 1 HP
	}
}
```

> *Note*: There are some misconceptions regarding how healing should be done. In fact, [`GiveBody()`](https://zdoom.org/wiki/GiveBody) is the one and only function that should be used for this. Most of the time it's a bad idea to try and modify the actor's `health` value directly.



## PSprite and overlays

PSprite (short for "player sprite") is a special object; basically PSprite is a sprite that is defined within an actor but drawn on the player's screen. 

Internally PSprite is a separate ZScript class, but it doesn't exist by itself and instead is meant to be created by other classes. The only base class that is allowed to create PSprites in GZDoom is `StateProvider`; as mentioned above, `Weapon` and `CustomInventory` are the only two classes based on it, thus inheriting this functionality. (You normally won't need to create custom classes based on `StateProvider` directly.)

PSprites are somewhat similar to regular sprites: they have duration in tics, offsets (those define their position on the screen), and as of GZDoom 4.5.0 they can also be rolled and scaled. You can even use the same images as PSprite and as an actor sprite, although normally this won't work because different offsets are used, but in principle they're all sprites.

The main differences between PSprites and regular actor sprites are:

* PSprites are drawn on the screen, just below the HUD. A PSprite by definition can't be drawn in the world.
    * They're different from the HUD, however, because they are affected by the sector's light level (you can't see your weapon in the dark) and they're updated every tic, like actor sprites (whereas HUD is updated every frame).
* PSprites can be drawn in multiple layers, over and under each other, while still being part of the same weapon or CustomInventory. Actor sprites can't have layers.
* As mentioned above, PSprites are actually classes drawn on the screen. They are not just images, they also contain various data in them: for example, each PSprite contains its own offsets, its scale, rotation, the layer it's being drawn on and other things.
* You can access the current actor's sprite via the actor's `sprite` variable. Accessing the weapon's PSprite, however, requires `FindPSprite()` or `GetPSprite()` functions that return a PSprite pointer (more on that below).

> *Note:* The terms "PSprite" and "overlay" are often used interchangeably. They usually point to the same thing, but if you want to be precise, an overlay is a state sequence meant to be drawn on a layer that isn't the weapon's main sprite layer, whereas a PSprite is an object that contains a sprite that you can get a pointer to.

You can interact with PSprites by using existing functions, such as `A_Overlay`, or by getting a pointer to a PSprite and modifying its values directly. Both methods are valid and usually have different applications.

### Overlays and overlay functions

As mentioned, PSprites can be drawn in multiple layers. By default weapon sprites are drawn on layer 1, which also has an alias of `PSP_Weapon` (i.e. writing `PSP_Weapon` is the same as writing `1`).

Vanilla Doom used layers in a very limited manner: most of the weapon sprites were drawn on the same layer (PSP_Weapon), and only muzzle flashes were placed on a separate layer, so that they could be made fullbright without making the whole weapon fullbright. This was achieved via `A_GunFlash`, which is a simple function that draws a predefined state sequence (either `Flash` or `AltFlash`, depending the function was called in `Fire` or `AltFire`). `A_GunFlash` doesn't allow to choose the layer at which the muzzle flash will be drawn; instead it always draws it on layer 1000, which also uses an alias `PSP_Flash`.

GZDoom, however, offers functions that allow drawing any state sequence on any layer, allowing mod authors to create weapons with however many layers they want, and control those layers in various ways. There's a number of `A_Overlay*` functions that can be found among the [list of weapon functions on the ZDoom wiki](https://zdoom.org/wiki/Category:Decorate_Weapon_functions).

The main function is `A_Overlay(<layer>, <state label>)`. Historically an expanded version of `A_GunFlash`, it allows drawing a specific state sequence independently, on a different layer than PSP_Weapon. For example, it can be used to draw an akimbo weapon:

```cs
Ready:
	PISR A 1
	{
		A_WeaponReady();
		A_Overlay(2, "ReadyLeft");
	}
	loop;
ReadyLeft:
	PISL A 1;
	stop;
```

Now, it's important to remember a few things:

1. Every time `A_Overlay` is called, it'll draw the overlay again. In the example above the `A_Overlay` call (alongside the `A_WeaponReady` call) is looped every tic, so `ReadyLeft` state is also drawn every tic.
2. If `A_Overlay` is no longer code, the `ReadyLeft` sequence will hit a `stop` and the overlay will be destroyed. So, you need to call `A_Overlay` again at the beginning of each sequence to make sure another corresponding overlay is created.

```cs
// Purely example code. Not the most optimal way to handle this (see below).
Ready:
	PISR A 1
	{
		A_WeaponReady();
		A_Overlay(2, "ReadyLeft");
	}
	loop;
ReadyLeft:
	PISL A 1;
	stop;
Fire:
	PISR B 1
	{
		A_Overlay(2, "LeftWait");
		A_FirePistol();
	}
	PISR CDE 2;
	PISR F 3 A_ReFire;
	goto ready;
LeftWait:
	PISL A 10;
	stop; 
```

But this is rather convoluted, because then you have to figure out when to fire the other weapon and how.

`A_Overlay` actually has a third argument: a boolean `nooverride` argument; if set to `true`, it won't redraw the overlay if that layer is already busy:

```cs
Ready:
	PISR A 1
	{
		A_WeaponReady();
		A_Overlay(2, "ReadyLeft", true);
	}
	loop;
//this is drawn once and not redrawn again:
ReadyLeft:
	PISL A 1;
	loop;
```

But when it comes to the firing animation, it may actually be a good idea to draw both guns on one sprite and animate them manually.

However, using overlays is a great way to have a separate element on a weapon. For example, a plasma rifle that has a visible heat gauge drawn on top of it:

```cs
Ready:
	PLGG A 1
	{
		A_WeaponReady();
		A_Overlay(2, "HeatGauge", true);
	}
	loop;
HeatGauge:
	PHEA ABCDE 1;
	loop;
```

Note that the heat gauge animation sequence is `PHEA ABCDE`—it's a 5-tic animation, completely separated from the main layer. Since the `nooverride` argument of `A_Overlay` is set to `true`, the repeated calls of `A_Overlay` will not override it, allowing the main weapon layer to be a 1-tic long loop, but the overlay to be a 5-tic animation.

You can combine the overriding and non-overriding calls. For example, while firing your plasma rifle's heat gauge may need a completely different animation:

```cs
Ready:
	PLGG A 1
	{
		A_WeaponReady();
		//this is drawn once and not overriden:
		A_Overlay(2, "HeatGaugeReady", true);
	}
	loop;
HeatGaugeReady:
	PHEA ABCDE 1;
	loop;
Fire:
	PLGG B 1
	{
		//when you start firing, this 
		A_Overlay(2, "HeatGaugeFiring");
		A_FireProjectile("Plasmaball"):
	}
	[...] //the rest of the attack animation
HeatGaugeFiring:
	PHEA FGFGFG 1;
	stop;
```

Note, however, that if your Fire animation ends before the HeatGaugeFiring animation, the HeatGaugeFiring animation will still be drawn before it reaches `stop`, and only then HeatGaugeReady will be drawn.

------

🔵 [>> Next: Arrays](Arrays.md)
