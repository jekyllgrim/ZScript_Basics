🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Variables and data types](07_Variables_and_data_types.md)        🔵 [>> Next: Custom functions](09_Custom_functions.md)

------

# Pointers and casting

One of the primary concepts you need to have a good grasp on to use ZScript efficiently is pointers. Depending on your coding experience, you may be aware of what a pointer is (DECORATE actually uses some pointers, albeit in a much more limited manner than ZScript), but for people who have no experience in the area they can be rather confusing.

### Class types vs class instances

Before we talk about pointers, however, it's important to cover another major aspect of ZScript (and object-oriented programming in general): **class types** and **class instances**. These terms are often used in the context of pointers and are generally fundamental to coding.

The idea of class types and class instances is actually fairly simple, but beginner scripters can sometimes go on for a while without a clear understanding of it. Here's how it goes:

* A **class type** is a specific class, as defined in the code, compiled and loaded into memory by GZDoom. For example, the `DoomImp` class, as defined in gzdoom.pk3, with all of its default values (such as how much health it has, what sounds it makes, etc.) is a *class type*. There can be only type of each class.

* A **class instance** is a specific manifestation of that class. Every time an object of a specific class type is created in a running game, that object is an instance of said class. For example, when you're playng GZDoom and there are ten Imps on the map, *each* of those imps is an *instance* of the `DoomImp` class. Every separate instance of a class can be in a different state (in case of Imps—they can be in different positions, with different amount of remaining health, damaged, killed, hostile, friendly, etc.). 

In real-life terms, a class type can be seen as a blueprint for something, but each *specific* object made from that blueprint is a class instance.

The process of creating an instance of a class is called **instantiation**. When we're talking about GZDoom actors, they're instantiated by **spawning** in the playable space with the use of the `Spawn()` function (which is defined in the base `Actor` class).

> *Note:* Sometimes the term "class type" is conflated with the term "class name." This is incorrect. A class name is literally the name by which the class is known, but a name is just a name—it doesn't imply any data. A class type is the class itself, it's something that exists in your computer's memory while running GZDoom, and it contains all the information relevant to that class (its default properties and flags, its states, etc.) Continuing the blueprint analogy, imagine you have a blueprint that has "Shotgun" written on it, and the schematics for a shotgun: in this case, the word "Shotgun" is the class name, but the blueprint itself with all the information it contains is the `Shotgun` class type.

Using a more GZDoom-specific example, let's say you have a weapon that calls this:

```csharp
WEAP A 1 A_FireProjectile("Rocket");
```

The "Rocket" in that function is a class type: you're telling the function what *class type* should be used as the projectile.

When the function is called, it spawns a Rocket actor—that actor is an *instance* of the `Rocket` class.

In the context of GZDoom coding and gameplay, when we talk about the `Actor` class, we're talking about a class type (the base `Actor` class). But when we say "an actor," we imply any instance of the `Actor` class (which, as we know, can be an item, an enemy, a player-controlled PlayerPawn, a projectile, etc.—all of these are actors, because they're all based on the `Actor` class, either directly on through inheritance).

This distinct terminology is going to be used throughout this chapter.

## Overview of pointers

A **pointer** is a type of [variable](07_Variables_and_data_types.md). Like any variable, a pointer is a piece of data that contains a value, and that value can change dynamically (i.e., it's variable). However, when you think of variables, you might tend to think of numeric values (like integers, float-points, vectors, etc.) or boolean values (true/false). Pointers aren't like that; instead, a pointer contains a memory address that quite literally *points* to another object. Most of the time pointers point to *Actor instances*, i.e. from one actor to another.

The **purpose** of pointers is, to put it simply, to let class instances *interact with each other*. For example:

* When a monster is chasing/attacking a player pawn actor, the monster has a pointer to that player pawn actor.

* When an actor fires a projectile, that projectile gets a pointer to whoever fired it (so that the projectile *knows* who fired it), and when said projectile eventually hits another actor, it briefly gets a pointer to the actor it hit and deals damage to it, and the damaged actor gets a pointer to the projectile that hit it *and* the shooter of the projectile, so that it knows who was responsible for the attack.

* When an item is picked up and placed in player's inventory, the item gets a pointer to the player pawn, so that it knows who its owner is.

...And so on. Whenever class instances in GZDoom interact with each other, they get pointers to each other. 

Just like variables, pointers may be class-wide, i.e. they can defined as **fields**, or they can be **local**, existing only within the context of one function, one code block, etc.

For example, monsters have a `target` field that contains a pointer to an actor the monster is chasing and/or attacking. Inventory items have an `owner` field that contains a pointer to whoever picked that item up. If there's no actor to track in those fields (for example, a monster hasn't found a suitable target yet, or an item hasn't been picked up yet), the value of those pointers will be `null`, meaning they won't point to anything.

Local pointers, just like local variables, exist only in specific context. For example, when a projectile collides with another actor, it briefly gets a `victim` pointer to it, but that pointer only exists at the moment of hit (you'll learn more about that in the [chapter on virtual functions](10_Virtual_functions.md)).

The most important aspect of pointers is that, as long as a pointer exists (for example, it's defined as an actor field), that pointer allows you to check the data, state, values, etc. of the actor it points to all the time. For example, as long as a monster actor exists and has a valid target, through its `target` pointer it'll always know where the target is, what it is doing, and so on.

## Native pointers

Just like with other variables, there are some pointers that already exist in GZDoom classes, but you also have an ability to define your own.

There are 3 pointers defined in the `Actor` class that are avaialble to all GZDoom actors (both in ZScript and DECORATE). These are actor pointers defined as fields (and you might already be familiar with them): **`target`**,  **`master`** and **`tracer`**. 

Let's cover their use briefly.

### Target

`Target` is the most commonly used native pointer and it’s primarily used by monsters and projectiles:

- In case of **monsters**, `target` is the actor they’re be chasing and attacking (if there is one). Monsters acquire a target by calling `A_Look()`, then chase it with `A_Chase()`, and they aim at the target with `A_FaceTarget()`. Here's an example from Doom's [Zombieman](https://zdoom.org/wiki/Classes:ZombieMan):
  
  ```csharp
      Spawn:
          // A_Look tries to acquire a target. 
          // If found, the actor goes to the See sequence.
          POSS AB 10 A_Look; 
          Loop;
      See:
          // A_Chase chases the target, or tries to find a new one,
          // if the current one disappears or dies.
          // Has a chance to move the actor to the Missile sequence
          // so that they can attack.
          POSS AABBCCDD 4 A_Chase;    
          Loop;
      Missile:
          POSS E 10 A_FaceTarget; // Turns the actor to face its target
          POSS F 8 A_PosAttack; // Fires a hitscan attack
          POSS E 8;
          Goto See;
  ```
  
  - If a monster is killed by another actor, that actor is *also* set as the killed monster's `target`. It doesn't matter if the monster was aware of their killer or not; even if you manage to kill a non-alerted monster, you will be set as their `target`. Yes, dead monsters still track their killers with that pointer.
* In case of **projectiles** `target` is (rather counter-intuitively) the *shooter* of the projectile. So, if a player fires a rocket, their PlayerPawn will be the rocket's `target`. Why is it important? Because the shooter has to get **kill credit**: it allows the game to track how many monsters the player killed, who killed whom in multiplayer, and print out obituary messages (such as "*Playername* stood in awe of Spider Demon"). If for some reason the projectile loses its `target` pointer (which normally shouldn’t happen), the killer won’t get the credit. There are other, more nuanced mechanics involved as well: for example, a projectile can’t hit its shooter as long as the shooter is the projectile’s `target`; that's why even if you manage outrun a rocket you fired and stand in front of it, it will just fly through you without colliding with you.

> *Note*: If you’re wondering if a projectile has any global pointers to the actors it hits—it doesn't. Projectiles don’t need such pointers, because they simply hit whatever SHOOTABLE or SOLID actor they collide with. (They do get a pointer to what they hit briefly when the hit happens, but it's a local pointer that only exists within their `SpecialMissileHit()` virtual function—more on that later).

- Similarly to projectiles, [puffs](https://zdoom.org/wiki/Puff) used by hitscan attacks also get a `target` pointer to whoever fired the attack, provided the puff has the PUFFGETSOWNER flag. (Note that Doom's default puff class, [BulletPuff](https://zdoom.org/wiki/Classes:BulletPuff), doesn't use it.)

### Tracer

The `tracer` pointer is normally only used by seeker projectiles, such as [RevenantTracer](https://zdoom.org/wiki/Classes:RevenantTracer). Projectiles use special seeking functions, such as `A_Tracer` or `A_SeekerMissile`, in order to continuously aim at their `tracer`.

### Master

The `master` pointer is not set by anything in vanilla Doom, but it can be set via [`A_SpawnItemEx`](https://zdoom.org/wiki/A_SpawnItemEx) which allows setting pointers manually with special flags (`SXF_SETMASTER` in this case). Doing that allows the use of such functions a `A_KillMaster` (kills the calling actor's `master`) or `A_KillChildren` (kills all actors that have the calling actor as their `master`) and a few other similar ones. 

### Puff pointers

Puffs used by hitscan attacks can also utilize HITTARGET, HITMASTER and HITTRACER pointers, which sets their `target`, or `master`, or `tracer` field (respectively) to the actor hit by the attack. Puffs with the PUFFGETSOWNER flag will also track whoever fired the attack with their `target` pointer.

## Custom pointers and their use in ZScript

ZScript allows you to define custom pointers, both as fields and local, and this is one of the primary features of the language.

So far we haven't quite covered how pointers are used. The most important aspect of pointers is that they give you access to another actor in the game. You already know that you can read and modify an actor's own variables and fields by using their names—for example, in [anonymous functions](06_Anonymous_functions.md). But through pointers you can read and modify values on *another* actor from the calling actor. All you need to do is use the pointer as the prefix. 

For example, calling `alpha = 0.5;` will change the translucency of the actor that calls this code, but `target.alpha = 0.5;` will change the alpha of the actor that is stored in the `target` pointer of the calling actor.

Here's a simple example:

```csharp
class GraciousImp : DoomImp
{
    States
    {
    Death:
        TNT1 A 0
        {
            // Checks that a target exists before doing anything:
            if (target != null)
            {
                target.GiveInventory("Shell",20); // Gives 20 shells to the target
            }
        }
        goto super::Death; // Continues to the default DoomImp's Death sequence
    }
}
```

This gracious Imp gives whoever killed it 20 shells (as mentioned before, when an actor is killed, its killer is set as its `target`).

Some notes on the example:

- `if (target != null)` checks if `target` exists. This is called **null-checking** (because it checks if a pointer isn't `null`), and you *have to* do it before trying to call anything on the `target`. See the next subsection for more information.
  
  - Note that this can be simplified to `if (target)` — this does the same thing as `if (target != null)`.

- `GiveInventory` is an internal ZScript version of `A_GiveInventory` and it works basically the same way.

Now let's make something more advanced. This time we'll use the `tracer` pointer that is normally not used by monsters. But first, to make it a bit more colorful, we'll create a TRNSLATE lump and add some translations:

**TRNSLATE:**

```csharp
// A desaturated color translation that tints the actor red:
BabyAngry = "0:255=%[0.85,0.00,0.00]:[2.00,1.96,1.39]" 

// A similar translation but it tints the actor blue:
BabyCalm = "0:255=%[0.05,0.01,0.84]:[1.39,1.96,2.00]"
```

 **ZSCRIPT:**

```csharp
// This is a smaller version of the Cacodemon 
// that has x2 health and is blue:
class CacoBaby : Cacodemon
{
    Default
    {
        health 800;
        radius 16;
        height 30;
        speed 12;
        floatspeed 6;
        scale 0.5;
        Translation "BabyCalm";    //translation as defined in TRNSLATE lump
    }
}

// A version of the Cacodemon that spawns CacoBaby
// when it appears, and modifies it when it dies:
class CacoDaddy : Cacodemon
{
    States 
    {
    Spawn:
        // Spawn Cacobaby and set it as CacoDaddy's tracer:
        TNT1 A 0 NoDelay A_SpawnItemEx("Cacobaby", 64, flags:SXF_ISTRACER);    
        HEAD A 10 A_Look;
        wait; //loops the previous frame instead of the whole state, in contrast to 'loop'
    Death:
        TNT1 A 0
        {
            if (tracer && tracer.health > 0) //check that tracer exists and is alive
            {
                tracer.A_StartSound("caco/active"); //play Cacodemon's "wake up" sound on the tracer
                tracer.A_SetTranslation("BabyAngry"); //change translation of the tracer
                tracer.speed *= 2; //multiply tracer's speed by 2 
                tracer.floatspeed *= 1.5; //multiply tracer's floatspeed by 1.5
                tracer.bNOPAIN = true; //set tracer's NOPAIN flag to true
            }
        }
        goto super::Death; //continue to default Cacodemon death
    }
}
```

> *Note*: Don't forget that you have to use **NoDelay** if you want to do something in the very first frame of the Spawn state. Otherwise Doom skips that function.

The daddy Caco spawns a baby Caco when it appears, and makes the baby its `tracer`. When the daddy dies, it checks if its `tracer` still exists and is still alive, and if so, does a bunch of stuff **on the** **tracer**: plays a sound, changes its `translation` and `speed`, and removes its ability to enter Pain state. The baby is out for blood.

We use `tracer.` as a prefix to execute functions on it and change its properties. As mentioned earlier, **it's very important to null-check all pointers you use** to avoid the risk of causing a VM abort. A simple example why it could happen here is that the daddy spawns its baby 64 units in front of itself; if the daddy Caco is initially placed facing some other actor or a wall, it won't spawn the baby at all (because `A_SpawnItemEx` checks for free space before spawning something).

## Null-checking pointers

Null-checking is the process of checking that specific data isn't null (i.e. it exists). This is most commonly done on pointers, and the syntax is as follows:

```csharp
if (pointer != null)
```

where `pointer` is an existing pointer, such as `target`.

It can also be shortened to this:

```csharp
if (pointer)
```

Basically, at any time when you're using a pointer, you need to null-check it before doing something with it. If you don't do the null-check and for some reason the actor doesn't exist (for example, a monster's `target` pointer will be empty if their target is already dead), the game will try to read data that doesn't exist. As a result GZDoom will close with a "Tried to read from address zero" error. A null-check tells GZDoom to first *check* if the data exists, and only do what needs to be done if the check passes.

If you need to check that a pointer *is* null, just invert the check:

```csharp
if (pointer == null)
```

This can also be simplified:

```csharp
if (!pointer)
```

`!` is a NOT operator in ZScript and other C-style languages; using it allows to invert the check. As you can guess, `==` means "equals to" while `!=` means "does not equal to."

You can learn more about operators and operands in the [Flow Control](A1_Flow_Control.md) chapter.

## Casting and custom pointers

Casting and custom pointers is where the actual fun begins. 

**Casting** is the process of defining a variable and then attaching a value to it. For example, you can define an empty pointer first, then spawn an actor and castin the resulting actor to said pointer:

```csharp
Actor myPointer = Spawn("Cacodemon", pos);
```

Doing the above will first create an actor pointer `myPointer`, then spawn a Cacodemon at the calling actor's position (`pos`) and cast the result to the `myPointer` pointer.

Note: As you know, all variables have a data type. For example, when you declare `int foo;`, you create a variable `foo` whose data type is `int`, i.e. an integer number. When it comes to actor pointers, their data type is literally `Actor`.

There are two main cases when you need to use casting:

- To create a custom pointer that doesn't take place of `master`, `target` or `tracer`. Ideally, you should avoid using these native pointers when you can, since there's a lot of implicit behavior attached to them (for example, monsters and projectiles already use `target` in their core behaviors, `tracer` is used by seeking projectiles, and so on).
- To get access to **class-specific fields**, which includes your custom variables. This concerns fields that are defined in a specific class and don't exist in the base `Actor` class. This will be explained separately.

First, let's talk about defining custom pointers.

As mentioned before, pointers can be class-scope (fields) or local (existing only within a specific ontext). Let's create a pointer field:

```csharp
class CacoDaddy : Cacodemon
{
    Actor baby; // Defines a field 'baby' (notice its type is 'Actor')

    States 
    {
    Spawn:
        TNT1 A 0 NoDelay 
        {
            // Spawn CacoBaby and cast it to 'baby':
            baby = Spawn("CacoBaby", self.pos);
        }
        HEAD A 10 A_Look;
        wait;
    Death:
        TNT1 A 0 
        {
            if (baby && baby.health > 0) 
            {
                baby.A_StartSound("caco/active");
                baby.A_SetTranslation("BabyAngry");
                baby.speed *= 2; 
                baby.floatspeed*= 1.5;
                baby.bNOPAIN = true;
            }
        }
        goto super::Death;
    }
}
```

*Notes on the example:*

- `Spawn("actorname", coordinates)` is a ZScript function that simply spawns something at the coordinates you provide. The position is a `vector3` (see [Data types](07_Variables_and_data_types.md#data-types)). 
- `pos` is a vector3 expression that simply contains the actor's own current coordinates. By passing `self.pos` as a second argument of `Spawn` we spawn CacoBaby at CacoDaddy's position.
- `self` is, as you probably guessed, a pointer to the actor itself. We're using `self.pos` in the `Spawn()` call to spawn CacyBaby at CacyDaddy's current position.

The behavior of this version isn't much different from the earlier verison we used, but we're now using a custom pointer `baby` instead of the native `tracer`. This frees up the `tracer` pointer to be used somewhere else (perhaps by one of the existing functions, who knows!). 

What exactly happens: `baby = Spawn("CacoBaby", self.pos)` spawns an actor named CacoBaby at the CacoDaddy's position and **casts** a pointer to CacoBaby to the variable `baby`. 

> *Note:* You may wonder why we're not using `A_SpawnItemEx` here. Simply put, because we don't need `A_SpawnItemEx`—it's a more complex function with a lot of values. What's more, `A_SpawnItemEx` returns multiple values, and casting through it is more difficult, so we don't really need to concern ourselves with it here. (You'll learn more about return values in the [Custom Functions](09_Custom_functions.md) chapter).

One minor downside is that `Spawn` uses global offsets, not relative (in contrast to `A_SpawnItemEx`), so we can't spawn CacoBaby 64 units in front of CacoDaddy. But that's not a problem, since we can spawn it and then immediately move it using `Warp` (a ZScript internal version of the [`A_Warp`](https://zdoom.org/wiki/A_Warp) function):

```csharp
Spawn:
    TNT1 A 0 NoDelay 
    {
        baby = Spawn("CacoBaby",pos);
        // don't forget to null-check the pointer:
        if (baby)
        {
            baby.Warp(self, 64, 0, 0); // moves the spawned baby 64 units in front of self (CacoDaddy)
        }
    }
    HEAD A 10 A_Look;
    wait;
```

> *Note*: For this simple example, we're not checking the position here at all, so if CacoDaddy was in front of a wall, the baby can end up inside a wall.

`Self`, as mentioned, is a pointer to the current actor; since we're calling this from CacoDaddy, `self` is this instance of CacoDaddy. The full syntax for `Warp` is `Warp(pointer, xoffsets, yoffsets, zoffsets)`, and the offsets are relative, just like with `A_Warp`, so we move the spawned baby 64 units in front of `self` (CacoDaddy).  (`Self` is an existing pointer, you don't need to define or cast it.)

Now, we can go even deeper. Instead of using two different actors, we can use only one and modify it on the fly to make it look different:

```csharp
class CacoSingleDad : Cacodemon replaces Cacodemon
{
    Actor baby;

    States 
    {
    Spawn:
        TNT1 A 0 NoDelay 
        {
            baby = Spawn("Cacodemon", pos);
            if (baby) 
            {
                baby.Warp(self, 64, 0, 0);
                baby.A_SetHealth(800);
                baby.A_SetSize(16, 30);
                baby.speed = 12;
                baby.floatspeed = 6;
                baby.A_SetScale(0.5);
                baby.A_SetTranslation("BabyCalm");
            }
        }
        HEAD A 10 A_Look;
        wait;
    Death:
        TNT1 A 0 
        {
            if (baby && baby.health > 0) 
            {
                baby.A_StartSound("caco/active");
                baby.A_SetTranslation("BabyAngry");
                baby.speed *= 2; 
                baby.floatspeed*= 1.5;
                baby.bNOPAIN = true;
            }
        }
        goto super::Death;
    }
}
```

> *Note*: Some properties, such as `speed` can be set directly on an actor, but others are read-only and require a "setter" function, such as `A_SetSize`. If you try to modify something but GZDoom tells you that "expression must be a modifiable value", this often means you can't modify that value directly, look for a setter function.

By doing the above, we spawn the baby Cacodemon and immediately set all of properties: `health`, `speed`, `translation`, etc. 

You may ask at this point, is it safe to have this actor replace the vanilla Cacodemon? After all, it spawns *another* Cacodemon when it appears, won't this cause an infinite chain?

Actually, no, it won't! See, `Spawn` has a third argument that determines whether the spawnee can be replaced or not. The possible values for that argument are `NO_REPLACE` and `ALLOW_REPLACE`, and `NO_REPLACE` is actually the default one. In other words, by default actors spawned with `Spawn()` are *not* subject to actor replacements.

Obviously, you do *not* want to do anything like this:

```csharp
// This will freeze the game!
class FreezeTheGameCacodemon : Cacodemon replaces Cacodemon
{
    States
    {
    Spawn:
        TNT1 A 0 NoDelay
        {
            Spawn("Cacodemon", pos, ALLOW_REPLACE);
        }
        goto super::Spawn;
    }
}
```

because that would freeze the game with an endless cycle of Cacodemons spawning each other. But then, why would you do that, right?

It's important to remember that all DECORATE spawn functions (such as `A_SpawnItemEx`) *do* allow replacement, whereas `Spawn` doesn't.

Since we're talking about `Spawn()` and its relationship with actor replacement, let's take a look at an internal function where `NO_REPLACE` is important for functioning correctly. It's a function used by the `BossBrain` class — the Romero head inside the Icon of Sin.

When you destroy the Icon of Sin, `BossBrain` uses the following function (don't worry that you don't understand all of it, it's a bit advanced):

```csharp
private static void BrainishExplosion(vector3 pos)    //defines a function for BossBrain to use
{
    Actor boom = Actor.Spawn("Rocket", pos, NO_REPLACE);    //spawns a Rocket and cast it to boom
    if (boom)
    {
        boom.DeathSound = "misc/brainexplode";    //changes rocket explosion sound
        boom.Vel.z = random[BrainScream](0, 255)/128.;    //randomizes vertical velocity
        boom.SetStateLabel ("Brainexplode");    //sets Rocket to speical Brainexplode state
        boom.bRocketTrail = false;    //disables rocket trail used in GZDoom
        boom.SetDamage(0);    //disables collision since it's not needed
        boom.tics -= random[BrainScream](0, 7);    //changes duration of the frames randomly
        if (boom.tics < 1) boom.tics = 1;    //makes sure duration isn't less than 1
    }
}
```

There's a lot of stuff in this example we haven't covered yet, like creating custom functions, but now you should be able to mostly understand what's happening: this function creates a rocket, changes its explosion sound, disables rocket trail and damage and slightly randomizes its animation speed. On the whole, Icon of Sin's death effect is more complicated than that (and it only works at specific map coordinates, by the way), but you get the gist.

### Type casting

There's one other method of casting, known as type casting. This method is used when you need a pointer whose type is more specific than just Actor.

Let's say we want to make a version of Baron of Hell that drops a big Soulsphere when it's killed: this Soulsphere should set our health to 300 instead of the standard behavior of giving 100 HP. Of course, we could create a new Soulsphere actor, but since we now know about casting, we try do this:

```csharp
// This doesn't actually work:
class PrinceOfHell : BaronOfHell 
{
    States 
    {
    Death:
        TNT1 A 0 
        {
            Actor orb = Spawn("Soulsphere",pos);
            if (orb) 
            {
                orb.amount = 300;
                orb.maxamount = 300;
                orb.scale = (1.5,1.5);
            }
        }
        goto super::death;
    }
}
```

But if you run the code above, you'll get "Unknown identifier" script errors about `amount` and `maxamount`. 

The reason is simple: we're casting Soulsphere as **actor**, but properties like `amount` and `maxamount` are *not* defined in the `Actor` class; they're actually defined in the `Inventory` class. To avoid the error that, we need to cast it explicitly as `Inventory`. And this is what's called **type casting**:

```csharp
//this will work:
class PrinceOfHell : BaronOfHell 
{
    States 
    {
    Death:
        TNT1 A 0 
        {
            Inventory orb = Inventory(Spawn("Soulsphere",pos));
            if (orb) 
            {
                orb.amount = 300;
                orb.maxamount = 300;
                orb.scale = (1.5,1.5);
            }
        }
        goto super::death;
    }
}
```

In this case inventory orb creates a variable orb of type `Inventory`, then casts it to an `Inventory` class and spawns it. You'll need to use this method whenever you're trying to get access to variables, properties and functions defined only for a specific class. 

As such, the syntax for type casing is this:

```csharp
Type pointerName = Type(<another pointer or function>);
```

You may wonder, why do we need to do `Inventory orb = Inventory(Spawn("Soulsphere", pos))`, why can't we just do `Inventory orb = Spawn("Soulsphere", pos)`? The answer is, the `Spawn()` function doesn't know beforehand what kind of actor you'll be spawning, and it doesn't know if you need to cast the spawned actor as a specific type or not, so it returns an Actor pointer to the spawned actor. That's why you need to explicitly tell the function what type of pointer you need to get.

*However*, while you have to provide the class type before `Spawn()`, you *can* skip the pointer type—or rather, you can replace it with the keyword `let` as follows:

```csharp
let orb = Inventory(Spawn("Soulsphere",pos));
```

`Let` automatically sets the variable's type to what you're casting to it: in the example above the type of `orb` will be automatically set to `Inventory`.

### Non-actor pointers

There are other pointer types besides Actor pointers. For example, you can have pointers to actor states. A state is a specific frame defined in the actor's States block (the use of states and the terminology is covered in more detail in [Appendix 1: Flow Control](A1_Flow_Control.md)).

Some of the non-Actor pointer fields you may need to be aware of:

* `curstate` — points to whatever state the actor is currently in

* `spawnstate` — points to the first state in the actor's Spawn sequence

* `cursector` — points to the sector the actor is currently in

* `floorsector` — points to the sector the actor is standing in

* `ceilingsector` — points to the sector above the actor

* `blockingline` — points to the line the actor is currently crossing/touching

* `readyWeapon` (PlayerPawn only) — points to the currently selected weapon

------

🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Variables and data types](07_Variables_and_data_types.md)        🔵 [>> Next: Custom functions](09_Custom_functions.md)
