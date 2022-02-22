🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Event Handlers](11_Event_Handlers.md)        🔵 [>> Next: Arrays](13_Arrays.md)

------

*This chapter is a work-in-progress. To be revised/completed.*

# Weapons, overlays and PSprite

[TOC]

## Overview

Weapons (i.e. classes that inherit from the base `Weapon` class) feature a number of special behaviors that aren't found in other classes, and you need to be aware of those behaviors to use them effectively.

Here's a brief overview of their features:

* `Weapon` and `CustomInventory` are the only two classes that inherit from an internal `StateProvider` class, which allows them to draw sprite animations on the screen. The sprites drawn on the screen are handled by a separate special class called `PSprite` (short for "player sprite").
* PSprite is a special internal class whose main purpose is to handle on-screen sprite drawing. PSprites hold various properties of those sprite layers, such as duration in tics, position on the screen, and so on.
* On-screen sprites can be drawn in multiple layers. The main layer is layer 1, also defined as `PSP_Weapon` (PSP_Weapon is just an alias of number 1). New layers can be drawn above and below it. A separate PSprite class instance is be created to handle each layer.
* Most weapon functions, such as `A_FireBullets`, `A_WeaponReady` and other functions that are called from the States block, despite being defined in the weapon, are actually called and executed by the [player pawn](https://zdoom.org/wiki/Classes:PlayerPawn) carrying that weapon, rather than the weapon itself. For example, when you call `A_FireProjectile` from the weapon, it's the player pawn that spawns the projectile in the world.
  * For this reason monster attack functions, such as `A_SpawnProjectile`, can't be used in weapons, and vice versa.
* Functions that can be called from weapon states are always [action functions](09_Custom_functions.md#action-functions). Custom functions also have to be defined as action functions.

## Handling data from weapons

Weapons are a subclass of [Inventory](https://zdoom.org/wiki/Classes:Inventory) (the inheritance chain is Inventory > StateProvider > Weapon), so they have access to Inventory's [virtual functions](10_Virtual_functions.md), such as `DoEffect()` (called every tic while the weapon is in somebody's inventory).

However, weapons also have states, which, as described earlier, exist in a unique context, where sprites are drawn by PSprite and functions are executed by the player. Accessing data in those states has its peculiarities.

> *Note*: At this point you may want to refresh your memory about [state flow control](A1_Flow_Control.md#state-control), especially if you're not clear on what "state", "state sequence" and "state label" mean.

### Accessing data from weapon states

Excluding the Spawn sequence states (which are just regular actor states, just like the Spawn states of monsters, decorations, etc.), weapon states (e.g. those in the Ready, Fire, Select sequences, etc.) are not really actor states. They're drawn by a special PSprite class (more on that later), and the functions in those states are executed by the player pawn holding the weapon. This last part means that weapon functions need to interact both with the weapon and with the player: for example, `A_FireProjectile` needs to check various data on the weapon (such as what type of ammo to consume when firing), and then some data on the player pawn (such as its angle and pitch, to determine the direction in which to fire the projectile).

This is true not only for the weapon functions, however, but also for all weapon states. All weapon states exist in a special context, where they interact both with the weapon itself, and with the player pawn that holds that weapon. As a result, there are some rules regarding accessing data from weapon states:

* In the context of a weapon state, `self` is *not* the weapon iself but rather the *player pawn* that holds that weapon.
* The weapon itself is accessible via the `invoker` pointer.
* If you have a variable `varname` defined in your weapon, to access it from a state you need to use `invoker.varname`.
* If you want to access a variable on the player pawn, you can just use its name directly. For example, `speed` returns the value of the `speed` property of the player pawn. You can also use `self` pointer (as in, `self.speed`) but, as everywhere else in ZScript, this prefix is optional.
* Skipping `invoker` in a weapon state context is not optional: GZDoom will abort with a "Self pointer used in ambiguous context" error.

As an example, let's look at this version of the Plasma Rifle with an overheat/cooldown mechanic. Instead of showing a "cooldown" PLSGB0 sprite unconditionally, like the vanilla Plasma Rifle does, it shows it only if the `heatCounter` value reaches 40:

```csharp
class OverheatingPlasmaRifle : PlasmaRifle
{
    int heatCounter; //this holds how much heat is accumulated

    States
    {
    Ready:
        PLSG A 10
        {
            A_WeaponReady();
            // While we're not firing, the heat will decay at the rate
            // of 1 per 10 tics (since the frame duration is 10 tics):
            if (invoker.heatCounter > 0)
                invoker.heatCounter--;
        }
        loop;
    Fire:
        PLSG A 3 
        {
            // If we've gained too much heat, jump to Cooldown:
            if (invoker.heatCounter >= 40)
                return ResolveState("Cooldown");
            // Otherwise accumulate heat and fire:
            invoker.heatCounter++;
            A_FirePlasma();
            return ResolveState(null);
        }
        // note we're not using any cooldown animation here
        goto Ready;
    Cooldown:
        // Display a cooldown frame for 50 tics:
        PLSG B 50 
        {
            // This is meant to be a custom sound:
            A_StartSound("weapons/plasma/cool");
            // Reset the heat counter:
            invoker.heatCounter = 0;
        }
        goto Ready;
    }
}
```

Note that whenever `heatCounter` is referenced in a weapon state, it has to be prefixed with `invoker.` to tell the game it's a variable on the weapon. This happens because, as stated earlier, weapon states interact both with the weapon and with the player carrying it, and as a result the context has to be specified explicitly.

### Accessing data from the weapon's virtual functions

If you want to access data on the weapon or on the player pawn *outside* of a state—i.e. from a virtual function override—the rules are the same as with regular Inventory items:

* For weapon's variables, use their names directly.

* For the player pawn's variables you will need to use the `owner` prefix.

If you take the Plasma Rifle described above and decide to let the gained heat stacks decay at *all* times instead of just the Ready state sequence, you can do it in `DoEffect()`, where you will not need `invoker` to check the variable:

```csharp
class OverheatingPlasmaRifle2 : PlasmaRifle
{
    int heatCounter;

    override void DoEffect()
    {
        super.DoEffect();
        // Using the modulo operator we can call this block
        // every 10 tics:
        if (level.time % 10 == 0)
        {
            // No 'invoker' required here:
            if (heatCounter > 0)
                heatCounter--;
        }
    }

    // 'invoker' is still required in the states:
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

> *Note:* `%` is a modulo operator, you can read about it in the [Arithmetic operators section of the Flow Control chapter](A1_Flow_Control.md#arithmetic-operators).

And, as mentioned, if you want to do something to the player pawn from `DoEffect()`, just use the `owner` pointer like you would in a regular item:

```csharp
// This pistol will give 1 HP to its owner every second:
class HealingPistol : Pistol
{
    override void DoEffect()
    {
        super.DoEffect();
        // Null-check the owner pointer and call the code every 35 tics:
        if (owner && level.time % 35 == 0)
            owner.GiveBody(1); //heal 1 HP
    }
}
```

> *Note*: `Health` property should not be modified directly. [`GiveBody()`](https://zdoom.org/wiki/GiveBody) is the one and only function that should be used for healing.

### Checking current weapon

It's important to remember that `DoEffect()` is called every tic when an item is in somebody's inventory. This means that if you add something to a weapon's `DoEffect()` override, that stuff will be called even when that weapon isn't selected.

The currently selected weapon can be accessed via the `player.ReadyWeapon`  pointer (in a virtual function it'll also require the `owner` prefix).

Here's a slight modification of the healing pistol mentioned earlier:

```csharp
// This pistol will give 1 HP to its owner every second
// but only while it's equipped:
class HealingPistol : Pistol
{
    override void DoEffect()
    {
        super.DoEffect();
        // Null-check the owner and make sure it's a player:
        if (!owner || !owner.player)
            return;
        // Do nothing if the player has no weapon selected (e.g. is dead)
        // or the selected weapon is different from this one:
        if (!owner.player.ReadyWeapon || owner.player.ReadyWeapon != self)
            return;
        // Heal the owner once a second:
        if (level.time % 35 == 0)
            owner.GiveBody(1);
    }
}
```

### When to use Tick()

You may wonder at this point why I haven't mentioned the `Tick()` function. Do weapons have it?

Yes, they do, like all actors. However, you probably won't use it very often, since most of the stuff the weapons need to do they do while in the player's inventory—and for that you'd be better off using `DoEffect()`.

But it's imaginable you may want to add some visual effects or something to the weapon while it's lying on the floor. Just remember one thing: `Tick()` is called *every tic*, it doesn't stop being called when the weapon is picked up. So, for effects that should be applied to weapons that haven't been picked up yet, you should only apply the effects when the weapon doesn't have an owner.

With that out of the way, let's make a simple example. This BFG will emit swirling green particles in a flame-like manner until it's picked up:

```csharp
class BurningBFG : BFG9000
{
    override void Tick()
    {
        super.Tick();
        // If it has an owner, return and do nothing:
        if (owner)
            return;
        A_SpawnParticle
        (
            "00FF00",
            SPF_FULLBRIGHT|SPF_RELVEL|SPF_RELACCEL,
            lifetime:random(50,90), 
            size:frandom(2,5),
            angle:frandom(0,359),
            xoff:frandom(-radius,radius), yoff:frandom(-radius,radius), zoff:frandom(height,height+9),
            velx:frandom(0.5,1.5), velz:frandom(1,2),
            accelx:frandom(-0.05,-0.2), accelz:-0.1,
            startalphaf:0.9,
            sizestep:-0.2
        );
    }
}
```

> *Note:* The way the function above is formatted may seem unusual, but since [`A_SpawnParticle`](https://zdoom.org/wiki/A_SpawnParticle) is a very long function, I'm splitting it into multiple lines and utilizing [named arguments](https://zdoom.org/wiki/ZScript_named_arguments) to be able to clearly see (and show) which arguments I'm defining where.

And this shotgun will try to run away from you:

```csharp
class RunawayShotgun : Shotgun
{
    Default
    {
        +FRIGHTENED // Runs away from you, not towards you
        speed 5; // Can't move without speed
    }
    override void Tick()
    {
        super.Tick();
        if (owner)
            return;
        // A_Chase required a valid target,
        // so find it first, if there isn't one:
        if (!target)
            LookForPlayers(true);
        A_Chase();
    }
}
```

> *Note:* `LookForPlayers` is one of the many "look" functions available to actors in ZScript. If the first argument is true, like here, it'll look all around the actor (similarly to calling `A_Look` with `LOOKALLAROUND` flag on the actor). In contrast to A_Look* it doesn't imply any state jumps.

## PSprite and overlays

PSprite (short for "player sprite") is a special class that handles drawing sprites on player's screen. The sprites themselves are defined within Weapon/CustomInventory but drawn on the screen with the help of PSprite. If multiple sprite layers are used, a separate PSprite instance is created for every layer.

> *Note:* The terms "PSprite" and "overlay" are somewhat interchangeable. "PSprite" refers to either the PSprite class itself, or a specific PSprite instance (i.e. a sprite layer that is currently being handled by PSprite). The latter can also be called an "overlay", in reference to the A_Overlay* functions.

Like regular sprites, PSprites have duration in tics, offsets (those define their position on the screen), and as of GZDoom 4.5.0 they can also be rotated and scaled. You can even use the same images as PSprite and as an actor sprite, although normally this won't work well because different offsets are used, but in principle its doable.

The main differences between PSprites and regular actor sprites are:

* PSprites are drawn on the screen, just below the HUD.
* PSprites can be drawn in multiple layers, over and under each other, while still being part of the same weapon or CustomInventory. In contrast, actor sprites can't have layers.
* PSprites contain a lot of data that can be read and modified: duration, offsets, scale, rotation angle, the index of the layer the sprite is being drawn on.
* While you can access an actor's current sprite via its `sprite` field, accessing the weapon's PSprite requires `FindPSprite()` or `GetPSprite()` functions that return a pointer to the PSprite of a specific layer (more on that below).

It's also important to note that *any* state sequence defined in a Weapon (aside from Spawn) can be drawn as PSprite. While `PSP_Weapon` (aka layer 1) is used by default and has to exist for the weapon to function, any other sequence can be drawn on any other layer. 

Moreover, *the same* state sequences can be drawn multiple times over multiple layers. For example, if you're creating an akimbo weapon, like dual pistols, you can draw the sprites of one pistol, then draw the same sequence on two different layers. 

## PSprite manipulation

As mentioned, PSprites can be drawn in multiple layers. By default weapon sprites are drawn on layer 1, which also has an alias of `PSP_Weapon` (i.e. writing `PSP_Weapon` is the same as writing `1`).

Vanilla Doom used layers in a very limited manner: most of the weapon sprites were drawn on the same layer (`PSP_Weapon`), and only muzzle flashes were placed on a separate layer, so that they could be made fullbright without making the whole weapon fullbright. This was achieved via `A_GunFlash`, which is a simple function that draws a predefined state sequence (either `Flash` or `AltFlash`, depending the function was called in `Fire` or `AltFire`) on the `PSP_Flash` layer (which is layer 1000). `A_GunFlash` doesn't allow choosing the layer; layers created by it are always drawn on layer index 1000, which also uses an alias `PSP_Flash`.

GZDoom, however, offers functions that allow drawing any state sequence on any layer, allowing mod authors to create weapons with however many layers they want, and control those layers in various ways:

* There's a number of `A_Overlay*` functions that can be found among the [list of weapon functions on the ZDoom wiki](https://zdoom.org/wiki/Category:Decorate_Weapon_functions). Most of them are available both in ZScript and DECORATE.

* There are also ZScript-only PSprite methods: a selection of player functions that can manipulate PSprites. For example, it's possible to get a pointer to a specific PSprite via `player.FindPSprite` or `player.GetPSprite` and manipulate its state and properties directly. 

In this subsection we'll be taking a look at both approaches in parallel.

### Creating PSprites

##### Basic functions

The main overlay function is `A_Overlay(<layer>, <state label>, <override>)`. Historically an expanded version of `A_GunFlash`, this is the function that creates overlays: more specifically, it creates a new PSPrite on a specified layer, and draws the specific state sequence on that layer, independently from PSP_Weapon.

It's important to note that muzzle flashes in vanilla Doom could only be drawn above the weapon layer (since `A_GunFlash` draws on layer 1000). This approach requires cutting out the shape of a barrel from the muzzle flash sprite, which can be annoying. Let's say you want to draw your muzzle flash *under* the weapon sprite. This can be easily achieved by using negative layer numbers:

```csharp
class PistolTest : Pistol
{
    States
    {
    Fire:
        PISG A 4;
        PISG B 6 
        {
            A_FireBullets(5.6, 0, 1, 5);
            A_PlaySound("weapons/pistol", CHAN_WEAPON);
            A_Overlay(-2, "Flash");
        }
        PISG C 4;
        PISG B 5 A_ReFire;
        goto Ready;
    Flash:
        PISF A 6 bright A_Light1;
        goto Lightdone;
    }
}
```

> *Note:* `LightDone` is a state sequence defined in the base `DoomWeapon` class; it simply calls [`A_Light0`](https://zdoom.org/wiki/A_Light0) and then destroys the layer by calling `stop`. Strictly speaking, it's not necessary to use it, but do remember that `A_Light1` and `A_Light2`, the vanilla functions used to create weapon illumination effects, actually illuminate *the whole level*, and if you don't call `A_Light0` afterwards, the light level of the level will remain permanently raised. You're not required to use these functions, however; when designing your own weapons, you could opt to use some other options available in GZDoom, e.g. dynamic lights.

The third argument of `A_Overlay` is a boolean value by default set to `false`. If it's set to `true`, the overlay will not be created if that layer is already occupied by a PSprite. If `false`, the overlay will be created unconditionally, and if any animation was already active on that layer, it'll be destroyed first.

##### ZScript functions

A ZScript-only player function that behaves similarly to `A_Overlay` is `SetPSprite`. The syntax is:

```csharp
player.SetPSprite(<layer number>, <state pointer>);
// 'Layer' is an integer number defining the
// number of the sprite layer to be created.
// 'State' is a state pointer.
```

It has to be called with the `player` prefix if called from a weapon state. Also, instead of a state label it takes a state pointer as a 2nd argument, so if you want to feed it a state label, you need to use `FindState`. Other than that it can be used as a direct analog of `A_Overlay`:

```csharp
class PistolTest : Pistol
{
    States
    {
    Fire:
        PISG A 4;
        PISG B 6 
        {
            A_FireBullets(5.6, 0, 1, 5);
            A_PlaySound("weapons/pistol", CHAN_WEAPON);
            player.SetPSprite(-2, FindState("Flash"));
        }
        PISG C 4;
        PISG B 5 A_ReFire;
        goto Ready;
    Flash:
        PISF A 6 bright A_Light1;
        goto Lightdone;
    }
}
```

##### PSprite pointers

Once a PSprite has been created, you can modify its properties. For that you can either utilize the native A_Overlay* functions, or get pointers to them and use ZScript functions. To use the latter approach you first need to know how to get those pointers.

There are two functions that can do that:

* `FindPSprite(<layer number>)` — checks if the specified sprite layer exists; if it does, returns a pointer to it. Otherwise returns null.

* `GetPSprite(<layer number>)` — checks if the specified sprite layer exists; if it doesn't, creates it and then returns a pointer to it.

Just like `SetPSprite`, these will need a `player` prefix if used in a state. In other contexts you'll also need a pointer to the player pawn first, so, for example, from a weapon's virtual function the prefix will be `owner.player`.

Most of the time you'll be using `FindPSprite`, to get access to the PSprite. This is done pretty much the same way as any other [pointer casting](08_Pointers_and_casting.md#casting-and-custom-pointers):

```csharp
// Get a pointer to the PSprite of layer 1000,
// normally used by the "Flash" sequence:
let psp = player.FindPSprite(PSP_Flash);

// Get a pointer to the PSprite of layer 1,
// the main weapon layer:
let psp = player.FindPSprite(PSP_Weapon);

// Get a pointer to the PSprite of the current
// layer (i.e. the layer used by the state
// where this is called from):
let psp = player.FindPSprite(OverlayID());
```

> *Note:* As with all casting, the name of the pointer can be anything. However, it's fairly common practice to make pointer names something similar to what they're pointing to, so `psp` is a commonly used name for a PSprite pointer. You can use whatever works for you.

Once you establish a pointer to a PSprite, you can use that pointer to modify all properties on it (more examples of that in the further subsections).

Note, you can use [`InStateSequence`](https://zdoom.org/wiki/InStateSequence) with a PSprite pointer to check which state sequence a specific PSprite is in. In this case we need to use `psp.curstate` to get access to the current state of the PSprite, and then check if it's in the specified state sequence. As an example, let's take our overheating plasma rifle we used earlier and make sure that its heat dissipates only while it is in the "Ready" sequence (so that the heat stacks won't decay while you're actually firing):

```csharp
class OverheatingPlasmaRifle3 : PlasmaRifle
{
    int heatCounter;

    override void DoEffect()
    {
        super.DoEffect();
        // In our earlier example we let heat stacks decay only
        // once 10 tics. We do the same here, but we invert the
        // check and move it up for performance reasons: this
        // is the simplest check in the chain, so it makes sense
        // to start with it:
        if (level.time % 10 != 0)
            return;
        // Get a pointer to the PSprite that is handling layer 1:
        let psp = owner.player.FindPSprite(PSP_Weapon);
        // Always null-check pointers. For example, if the player
        // is dead, its PSP_Weapon layer will be null, so we need
        // to do nothing in this case:
        if (!psp)
            return;
        // Now check that psp.curstate (the current state of the
        // PSprite we found) is in the "Ready" sequence. If it's
        // not, return and do nothing else:
        if (!InStateSequence(psp.curstate, FindState("Ready"))
            return;
        // And only after all of this we let the heat stacks
        // decay:
        if (heatCounter > 0)
            heatCounter--;
    }

    // The states block remains unchanged:
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

If you absolutely need to make sure that the specified layer actually exists, `GetPSprite` should be used instead of `FindPSprite`, because `GetPSprite` will always create the specified PSprite, so it never returns null. However, `FindPSprite` is useful when you actually need to check whether PSprite exists or not: e.g. in the example above we null-check `PSP_Weapon` because it can be null if the player is dead (since the current weapon gets deselected in that case).

##### Layer numbers

Every sprite layer handled by a PSprite instance has a number. Some of these numbers have aliases:

- `PSP_Weapon` — same as `1`, this is the main weapon layer. All weapons need it to function, and it can only be null if the player has no weapons at all or is dead. Do not try to destroy or recreate this layer; use regular state jumps to change it.

- `PSP_STRIFEHANDS` — same as `-1`, used by [`A_ItBurnsItBurns`](https://zdoom.org/wiki/A_ItBurnsItBurns) function from Strife, to show the player's burning hands. This function has special behavior tied to it, where it will display a specific "FireHands" state sequence defined on the *player pawn* rather than on any of the player's weapon or custom inventory objects; the activator of the function will also be set to the player rather than the weapon. In short, it's best not to touch this layer either.

- `PSP_Flash` — same as `1000`, used by the `A_GunFlash` in the vanilla Doom weapons to draw muzzle flashes separately from the weapon sprite. Normally there's no reason to use it.

These aliases are constants, they always point to the same numbers. It's also recommend to avoid them when creating new layers, and stick to numbers -2 and below, as well as 2 and above.

It is, however, not recommended to use numbers literally. If your weapon has several layers, it's very easy to lose track of them in a range of numbers, and also it'll be very hard to change the numbers if you realize that you need to squeeze a new layer between existing ones.

### PSprite flags

`A_OverlayFlags` can be used to set or unset flags of a PSprite. A full list of those flags can be found [on the wiki](https://zdoom.org/wiki/A_OverlayFlags). For example, if you want to make the muzzle flash partly translucent, you can use `PSPF_FORCEALPHA` flag to enable alpha settings of a PSprite, and then [`A_OverlayAlpha`](https://zdoom.org/wiki/A_OverlayAlpha) can be used to modify alpha: 

```csharp
Fire:
    PISG A 4;
    PISG B 6 
    {
        A_FirePistol();
        A_Overlay(-1, "Flash");
        // This will make the muzzle flash 20% translucent:
        A_OverlayFlags(-1, PSPF_FORCEALPHA, true);
        A_OverlayAlpha(-1, 0.8);
    }
    PISG C 4;
    PISG B 5 A_ReFire;
Flash:
    PISF A 6 bright A_Light1;
    goto Lightdone;    
```

> *Note:* Technically, `PSPF_ALPHA` flag should also be applicable here, however, among other things, PSprites can have different renderstyles (much like actors), and many of those renderstyles force their own alpha values that can not be overridden unless you use `PSPF_FORCEALPHA`. For all intents and purposes, I find it easier to simply use `PSPF_FORCEALPHA` in all cases.

Note that A_Overlay* functions can be called from anywhere in this weapon; the only thing that matters is the layer index, the first argument. Very often it's more convenient to modify the properties of an overlay from the overlay's state sequence itself. In that case, instead of using a numeric index, it's better to use `OverlayID()`, which automatically returns the number of the layer that the current state sequence is being drawn from. For example:

```csharp
Fire:
    PISG A 4;
    PISG B 6 
    {
        A_FirePistol();
        A_Overlay(-1, "Flash"); // Draw muzzle flash on layer -1
    }
    PISG C 4;
    PISG B 5 A_ReFire;
Flash:
    PISF A 2 bright 
    {
        A_Light1();
        // Enable alpha modification of the current layer:
        A_OverlayFlags(OverlayID(), PSPF_FORCEALPHA, true);
    }
    PISF A 2 bright A_OverlayAlpha(OverlayID(), 0.8); // Reduce the alpha of the muzzle flash
    PISF A 2 bright A_OverlayAlpha(OverlayID(), 0.5); // Reduce the alpha of the muzzle flash
    goto Lightdone;    
```

In the example above the muzzle flash will fade out in a couple of steps, which may look pretty cool for some weapons. (Just remember that, realistically, muzzle flashes on small arms are seen for extremely short periods.)

Note, while the term "overlay" usually refers to PSPrites *other* than PSP_Weapon, i.e. to sprites drawn over or under the main weapon layer, this doesn't mean that the A_Overlay* functions are limited to those overlays. It's possible to call A_OverlayFlags (as well as other overlay functions) on the main layer.

### PSprite offsets

All weapon sprites can be moved around and offset. These offsets are added on top of the offsets embedded into the sprite itself, which can be edited with SLADE.

Before modifying offsets it's important to remember a simpl

The basic way to do that is by using the `offset` keyword, as it is used, for example, in the [Fighter's Fist from Hexen](https://zdoom.org/wiki/Classes:FWeapFist):

```csharp
// This sequence is entered after every 3rd punch,
// gradually moving the fist sprite down and to the right:
    Fire2:
        FPCH DE 4 Offset (5, 40);
        FPCH E 1 Offset (15, 50);
        FPCH E 1 Offset (25, 60);
        FPCH E 1 Offset (35, 70);
        FPCH E 1 Offset (45, 80);
        FPCH E 1 Offset (55, 90);
        FPCH E 1 Offset (65, 100);
        FPCH E 10 Offset (0, 150);
        Goto Ready;
```

However, a much more flexible method to do that is [`A_WeaponOffset`](https://zdoom.org/wiki/A_WeaponOffset): this function allows modifying offsets more smoothly, and also allows doing it additively.

`A_OverlayOffset` basically works almost the same way as [`A_WeaponOffset`](https://zdoom.org/wiki/A_WeaponOffset), except it allows offsetting any sprite layer (whereas `A_WeaponOffset` only interacts with PSP_Weapon).

There are some basic rules to take into account when using it:

* By default, overlays automatically follow the offets of the main weapon layer, meaning `A_OverlayOffset`'s offsets will be added on top of PSP_Weapon's offsets. This also means that by default `A_WeaponOffset` will not only move the main layer, but also all overlays. This behavior can be changed by setting `PSPF_AddWeapon` flag to false by calling `A_OverlayFlags` on the relevant layer. 

* Note that the base offsets of a ready-to-fire weapon is not (0, 0) but (0, 32). This is because 32 is the height of statusbar in vanilla Doom, and the (0, 0) offsets are actually used for weapons that are not selected (i.e. at the start of the `Select` sequence, or at the end of `Deselect`). As such, if you set `PSPF_AddWeapon` flag to false on an overlay, the overlay will be moved down, to the (0, 0) offsets, and if you want it to line up with PSP_Weapon at that point, you'll have to call `A_OverlayOffset(<layer>, 0, 32)` first.

* Another thing to keep in mind is that PSP_Weapon layer will also bob while the weapon is calling `A_WeaponReady` and the player is moving. Overlays will follow the same bob by default, which can be changed by setting `PSPF_AddBob` flag to false via `A_OverlayFlags`. Bob and offsets are separate and unrelated values.

Keeping in mind the facts above, `A_OverlayOffset` can be used exactly the same way as `A_WeaponOffset`.

### Overlay scale, rotate and pivot

As of GZDoom 4.5.0, `A_OverlayRotate` and `A_OverlayScale` are available, which can be used to rotate and scale PSprite. 



*To be completed*

------

🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Event Handlers](11_Event_Handlers.md)        🔵 [>> Next: Arrays](13_Arrays.md)
