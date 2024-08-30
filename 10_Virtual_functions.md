🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Custom functions and function types](09_Custom_functions.md)    🔵 [>> Next: Event Handlers](11_Event_Handlers.md)

------

# Virtual functions

* [Overview](#overview)
* [Overriding ZScript Virtual Functions](#overriding-zscript-virtual-functions)
* [Common ZScript virtual functions](#common-zscript-virtual-functions)

## Overview

`Virtual` is a keyword that makes a function overridable. You can add it before the type of the function when defining it:

```csharp
virtual void MyVirtualFunction()
```

There are two primary uses for it. First, a child class can override its parent's virtual function and make it do something else:

```csharp
class CacoSingleDad : Cacodemon 
{
    Actor baby;

    virtual void SpawnBaby() 
    {
        baby = Spawn("Cacodemon",pos,NO_REPLACE);
        if (baby) 
        {
            baby.Warp(self,64,0,0);
            baby.A_SetHealth(800);
            baby.A_SetSize(16,30);
            baby.speed = 12;
            baby.floatspeed = 6;
            baby.A_SetScale(0.5);
            baby.A_SetTranslation("BabyCalm");
        }
    }
}

class SomeOtherCaco : CacoSingleDad 
{
    override void SpawnBaby() 
    {
        actor a = Spawn("Cacodemon",pos,NO_REPLACE);
        if (a)
        {
            a.master = self;
        }
    }
}
```

**SomeOtherCaco** above completely redefines `SpawnBaby` function to do something else: it also spawns a Cacodemon but it doesn't attach it to `baby` pointer; instead assigns SomeOtherCaco as the spawned Caco's master. So, SomeOtherCaco can still call the same function, but the effect of the function will be entirely different.

However, this doesn't seem especially useful, does it?

What is done more commonly with virtual functions is that they're overridden not to *replace* their contents, but rather to *add* some stuff to what they normally do:

```csharp
class CacoSingleDad : Cacodemon 
{
    Actor baby;

    virtual void SpawnBaby() 
    {
        baby = Spawn("Cacodemon",pos,NO_REPLACE);
        if (baby) 
        {
            baby.Warp(self,64,0,0);
            baby.A_SetHealth(800);
            baby.A_SetSize(16,30);
            baby.speed = 12;
            baby.floatspeed = 6;
            baby.A_SetScale(0.5);
            baby.A_SetTranslation("BabyCalm");
        }
    }
}

class SomeOtherCaco : CacoSingleDad 
{
    override void SpawnBaby() 
    {
        super.SpawnBaby();            //calls the original SpawnBaby() first
        if (baby) 
        {
            baby.A_SetScale(0.4);
            baby.master = self;
        }
    }
}
```

`Super` is a pointer to the parent class, and using it like that makes it call the parent's version of the function. As a result, in the example above SomeOtherCaco *first* does everything the original `SpawnBaby()` function does, and after that it adds some changes: it modifies the spawned baby's `scale` and sets itself as the baby's `master`.

## Overriding ZScript Virtual Functions

While **virtual** is just a type of function, the one that you can even use yourself (as described above), much more often you'll be using the existing virtual functions by **overriding** them.

The base `Actor` class has a lot of virtual functions attached to it which it calls under certain conditions *outside* of states. Overriding them allows to add a bunch of effects to your actors that don't have to (or can't) be bound to a specific state.

One of the most common virtuals you'll be using this way is `Tick()`: a virtual function that is called by all actors every game tic. It performs everything actors need to do continuously: changes positions, velocity, checks for collision and a bunch of other things. You can add your own behavior into that function:

```csharp
class TemporaryZombieman : Zombieman 
{
    Default 
    {
        renderstyle 'Translucent';
    }

    override void Tick() 
    {
        super.Tick();    //don't forget to call this! otherwise your actor will be frozen and won't interact with the world
        A_FadeOut(0.01);
    }
}
```

This Zombieman will continuously (and relatively quickly) fade out as it exists. Notice that we don't need to redefine any states for this effect. Neat!

Remember that `Tick()` is called even when the actor is frozen, so normally you need to add a check for that:

```csharp
class TemporaryZombieman : Zombieman 
{
    Default 
    {
        renderstyle 'Translucent';
    }

    override void Tick() 
    {
        super.Tick();
        if (!isFrozen())
        {
            A_FadeOut(0.01);
        }
    }
}
```

Notes:

- `IsFrozen()` is a ZScript bool that returns `true` if the actor that calls it is currently frozen, which can happen when:
  - "freeze" cheat has been entered in the console;
  - the player has a PowerTimeFreezer powerup and the actor in question does *not* have a NOTIMEFREEZE flag;
  - any other custom scripts that for whatever reason freeze actors or the level.
- Boolean checks such as `if (bool == true)` can be shortened to `if (bool)`. And `!` means "not" and can be used to invert any check. `if (!isFrozen())` is the same as `if (isFrozen() == false)`. See [Flow Control, Statements](A1_Flow_Control.md#statements) for more information.

There's a ton of things you can do this way. A common example when using `Tick()` is convenient is when your actor needs to continuously spawn some sort special effect every tick (such as a trail or an after-image). Here's a handy example of doing an after-image this way:

```csharp
class BlurryCacoBall : CacoDemonBall 
{
    override void Tick() 
    {
        super.Tick();
        if (isFrozen())        //check if the actor is frozen
            return;            //if so, we stop here and don't do anything else

        // Spawn after-image and cast it to a local pointer:
        actor img = Spawn("CacoBall_AfterImage",pos);
        // Ttransfer current actor's alpha, renderstyle and 
        // sprite frame to the spawned after-image:
        if (img) 
        {
            img.A_SetRenderstyle(alpha,GetRenderstyle());
            img.sprite = sprite;  //sprite is the current sprite, such as "BAL2"
            img.frame = frame;    //frame is a frame letter, such as A, B, C
        }
    }
}

class CacoBall_AfterImage : Actor 
{
    Default 
    {
        +NOINTERACTION //makes this actor non-interactive (no gravity or collision)
    }

    States 
    {
    Spawn:
        // '#### #' means "use previous sprite & frame" 
        // (as set by BlurryCacoBall earlier):
        #### # 1 
        {
            A_FadeOut(0.05);
            scale *= 0.95;
        }
        loop;
    }
}
```

The result is a pretty cool trail that is very easy to implement: notice, we didn't have to edit the states of BlurryCacoBall *at all*. 

This principle applies to most virtual functions. Here's another example with `PostBeginPlay()`, a function that is called as soon as the actor is spawned and placed in the world but before its Spawn state starts:

```csharp
//pseudocode:
class MyActor : Actor 
{
    int myvalue;
    override void PostBeginPlay() 
    {
        super.PostBeginPlay();
        myvalue = 10;
    }
}
```

As explained earlier, when you declare class-scope variables, like `myvalue` above, you can't immediately give them a value. You either have to turn it into a property, or set that value somewhere — `PostBeginPlay()` is a good place to do the latter. Notice that `PostBeginPlay()` is not like `Tick()`: it's called only once, so there's no need to check if the actor is frozen. If your actor has some sort of an attached "companion" actor (for example, a fireball that spawns an actor-based light flare around itself), it's also a good place to spawn them.

There are many, many other virtual functions that you will need to override. And remember: you won't always need to call **super** on them; sometimes you'll need to completely fill in what the function does, without calling its original version. Let's take a quick look at `ModifyDamage()` — an **Inventory** function used by items that modify incoming or outgoing damage, such as `PowerDamage` and `PowerProtection` . This function gets the damage that is supposed to be dealt to or by the owner of the item, and then uses `newdamage` argument to tell the game how much damage to actually deal:

```csharp
class CustomProtection : Inventory 
{
    override void ModifyDamage (int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags) 
    {
        // First check that the passive argument is true,
        // which means it's modifying *incoming* damage.
        // If it's false, we stop here and do nothing else:
        if (!passive)
        {
            return;
        }

        // Check if the inflictor exists and has a MISSILE flag:
        if (inflictor && inflictor.bMISSILE) 
        {
            newdamage = damage * 0.5;
        }
        // otherwise check if the damage was dealt by the monster directly (i.e. it's a melee attack)
        // if so, check if the monster is alive and is hostile to the owner of this item:
        else if (inflictor.bISMONSTER && inflictor.isHostile(owner) && inflictor.health > 0) 
        {
            newdamage = damage * 0.1;
        }
    }
}
```

The overridden `ModifyDamage()` above first checks what dealt the damage: whether it a missile or a monster itself (i.e. a monster's melee attack). For missiles the damage will be cut in half, while for monsters (melee attacks) it'll be reduced by 90%.

`ModifyDamage()` gets a bunch of pointers, and we use them to decide what to do. `Inflictor` is a pointer to the actor that dealt the damage directly (projectile, puff or, if it was an enemy melee attack, it'll be the enemy).

Notice that both `Tick()` and `PostBeginPlay()` are **void** functions (they have no return value) and they have no arguments. In contrast, `ModifyDamage()` has arguments but it's also a void function. But that's not true for all virtual functions. 

A good example of that is `SpecialMissileHit()` — an integer function that is called by projectiles when they collide with an actor. When a projectile collides with an actor, it calls `SpecialMissileHit()`, which returns an integer number that tells the projectile what to do: 

- `MHIT_DEFAULT` (or `-1` in GZDoom versions before 4.12) will make the projectile do what it would normally do in accordance with its properties and flags (i.e. explode, or die, or rip through if it has +RIPPER flag, etc.);
- `MHIT_PASS` (or `1` in pre-4.12) will make the projectile unconditionally pass through the actor without colliding (+RIPPER or other flags aren't required for that; in fact, they are ignored in this case);
- `MHIT_DESTROY` (or `0` in pre-4.12) will unconditionally destroy the projectile (remove it completely without doing anything else; it won't be put into its Death sequence either).

This function is used in Hexen by [MageStaffFX2](https://github.com/ZDoom/gzdoom/blob/master/wadsrc/static/zscript/actors/hexen/magestaff.zs#L220)—a homing projectile fired by Bloodscourge, the most powerful Mage weapon:

```csharp
//you can find this code in gzdoom.pk3/zscript/actors/hexen/magestaff.zs

override int SpecialMissileHit (Actor victim)
{
    if (victim != target && !victim.player && !victim.bBoss)
    {
        victim.DamageMobj (self, target, 10, 'Fire');
        return MHIT_PASS;    // Keep going
    }
    return MHIT_DEFAULT;
}
```

Notice that `SpecialMissileHit()` also gets a pointer `victim` of type actor: this is a pointer to the actor that the projectile touches (and then the virtual function decides whether it should explode or do something else). 

In the example above the projectile does the following:

1. Checks that the `victim` isn't the `target` (shooter of the projectile*), or a player (any player) or a boss (has +BOSS flag)
   * If you wonder why you need to check if the projectile didn't hit the shooter—it's because when spawned, projectiles basically spawn inside the actor that shot them, and they *will* collide with them, unless this check is added.
2. If all checks pass, it deals damage to the victim by calling the `DamageMobj()` function (see below) and keeps going.
3. Otherwise (i.e. If the victim is the shooter, *or* a player, *or* a boss), the projectile explodes.

As you can see, virtual functions are already attached to actors and called automatically, so you can mix your own stuff into them to add various effects. However, some of them can also be *called* just like you call regular actor functions. A common example of a function that you may often need to both override and call is `DamageMobj()`:

```csharp
int DamageMobj (Actor inflictor, Actor source, int damage, Name mod, int flags = 0, double angle = 0)
```

It's called by the actor whenever it takes damage.

- `inflictor` - The pointer to the actor that deals the damage. Missiles are used here, with their owners being the *source*.
- `source` - The pointer to the actor which claims responsibility for the damage, responsible for causing infighting.
- `damage` - The amount of damage to deal out.
- `mod` - The 'means of death', or the damagetype.

(See the rest [on ZDoom wiki](https://zdoom.org/wiki/ZScript_virtual_functions#Actor))

The function is called on actors when they would receive damage (but before it's actually dealt). It gets a bunch of information, including the pointers to actors that deal the damage, and the raw damage value (as `damage`) before it's modified by various resistances.

When the base `DamageMobj()` is called, it'll *deal* the damage. You can override `DamageMobj()` on an actor to change the behavior of how they receive damage.

Apart from dealing damage, it also *returns* an integer number: normally it should be the same as the amount of damage dealt.

Here's an example of how this override is used:

```csharp
class ZombieTroopman : Zombieman 
{
    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle) 
    {
        if (source && source is "Zombieman")
        {
            return 0;
        }
        return super.DamageMobj(inflictor, source, Damage, mod, flags, angle);        
    }
}
```

This version of Zombieman checks whether the `source` of the attack was another Zombieman (or an actor inheriting from Zombieman). If so, it *doesn't* call `super.DamageMobj` and returns 0. In all other cases it deals damage normally and returns the amount of damage that was dealt.

Here's another example of a neat use of `DamageMobj`: you can handle headshot damage by comparing the puff or missile position to the monster's height:

```csharp
class HeadshottableZombieman : Zombieman 
{
    override int DamageMobj (Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
    {
        if (inflictor && (inflictor.pos.z - floorz) >= (height * 0.75))
        {
            damage *= 2.0;
        }
        return super.DamageMobj(inflictor, source, damage, mod, flags, angle);
    }
}
```

In this example if the inflictor's position is in the top 25% range of the monster's height, the damage will be doubled!

As mentioned above, you can also *call* `DamageMobj` to—you guessed it—damage an actor. You can even do it from a `DamageMobj` override:

```csharp
class RetaliatingZombieman : Zombieman 
{
    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle) 
    {
        if (source)
        {
            source.DamageMobj(self, self, damage, 'normal'); //deals damage to whatever damaged it
        }
        return super.DamageMobj(inflictor, source, Damage, mod, flags, angle);        
    }    
}
```

This annoying Zombieman calls `DamageMobj` on the actor that dealt damage to them (such as the player), and deals exactly the same amount of damage. Notice that, since there are no projectiles involved, both `inflictor` and `source` in this call are `self`, i.e. the Zombieman itself.

`DamageMobj` can be called from anywhere; in fact, it's actually probably the most common basic function used to deal damage.

Let's say you want to create a projectile that can pierce enemies and damage them, but don't want to use +RIPPER flag, since with this flag projectile will damage the enemy continuously, as it's flying through them. Instead, you want the projectile to always damage the enemy once and only once. That can be achieved with `SpecialMissileHit` we just talked about, and `DamageMobj`:

```csharp
class PenetratingBullet : FastProjectile 
{
    Actor hitvictim; //this custom pointer will store the last actor hit by the projectile

    Default 
    {
        speed 85;
        radius 2;
        height 2;
        scale 0.2;
        obituary "%o was shot down.";
    }    
    override int SpecialMissileHit(actor victim) 
    {
        // check that the victim (the actor hit) is shootable
        // and is NOT the same actor as hitvictim (last actor hit):
        if (victim && victim.bSHOOTABLE && target && victim != target && victim != hitvictim)
        {    
            victim.DamageMobj(self, target, 10, 'normal'); //deal exactly 10 damage to victim
            hitvictim = victim;            //store the vicitm we just damaged as 'hitvictim'
        }
        return MHIT_PASS;                  //keep flying
    }
    States            //we're just reusing Rocket sprites
    {
    Spawn:
        MISL A 1;
        loop;
    Death:
        TNT1 A 1;
        stop;
    }
}
```

Thanks to `SpecialMissileHit` we don't even need RIPPER. Instead of `10` you can, of course, supply any random expression you like as damage, for example `5*random(1,8)` will make it behave similarly to Doom, where projectiles deal randomized damage multiplied between 1 and 8.

Notice, that the `inflictor` in this case is `self` (the projectile itself), while the `source` is `target`— that is the projectile's `target`, which, as we remember is whoever shot the projectile.

You can also add other conditions. For example, if you don't want to let this bullet penetrate actors with the DONTRIP flags, do this:

```csharp
    override int SpecialMissileHit(actor victim)
    {
        if (victim)
        {    
            // deal damage if applicable:
            if (victim.bSHOOTABLE && target && victim != target && victim != hitvictim)
            {
                victim.DamageMobj(self, target, 10, 'normal');
                hitvictim = victim;
            }
            // if victim has DONTRIP, use default 
            // coollision rules (go to Death state):
            if (victim.bDONTRIP)
            {
                return MHIT_DEFAULT;
            }
        }
        // otherwise keep going:
        return MHIT_PASS;
    }
```

## Common ZScript virtual functions

A non-comprehensive of some of the most common virtual functions you'll be overriding in your mods:

**Actor:**

- [`int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags = 0, double angle = 0)`](https://zdoom.org/wiki/DamageMobj) — Called when the actor is about to receive damage.
- [`void Tick()`](https://zdoom.org/wiki/Tick) — Called by all actors every tic to handle collision, movement and everything else.
- [`void BeginPlay()`](https://zdoom.org/wiki/BeginPlay) — Called after the actor is created, before any default properties are established. Can be used to set default values to custom variables. Do NOT destroy actors here!
- [`void PostBeginPlay()`](https://zdoom.org/wiki/PostBeginPlay) — Called after the actor is been created but before the first tic is played or any state called. A good place to do stuff like spawning another accompanying actors nearby (e.g. a lamp and a light halo), and anything else you'd normally do in the first frame of Spawn.
- [`bool CanCollideWith (Actor other, bool passive)`](https://zdoom.org/wiki/CanCollideWith) — Called when two actors collide, depending on who ran into whom.
- [`int SpecialMissileHit (Actor victim)`](https://zdoom.org/wiki/SpecialMissileHit) — Called by projectiles whenever they collide with an actor (including the shooter of the projectile!).

**Inventory:**

- [`void DoEffect()`](https://zdoom.org/wiki/DoEffect) — Called every tic by inventory items that are inside an actor's inventory. Use it instead of Tick() to continuously do stuff on items.
- [`void AttachToOwner(Actor other)`](https://zdoom.org/wiki/AttachToOwner) — Called by items when they are placed in an actor's inventory. After this call the `other` (the actor the item gets attached to) becomes `owner`, and the item can use the `owner` pointer.
- [`void DetachFromOwner()`](https://zdoom.org/wiki/DetachFromOwner) — Called anytime the item is fully removed from owner's inventory, whether by being tossed, destroyed or taken away entirely.
- [`void ModifyDamage (int damage, Name damageType, out int newdamage, bool passive, Actor inflictor = null, Actor source = null, int flags = 0)`](https://zdoom.org/wiki/ModifyDamage) — Called by items capable of modifying the owner's incoming damage, such as PowerProtection.

A more detailed list can be found on the [ZDoom Wiki](https://zdoom.org/wiki/ZScript_virtual_functions#Actor).

------

🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Custom functions and function types](09_Custom_functions.md)    🔵 [>> Next: Event Handlers](11_Event_Handlers.md)
