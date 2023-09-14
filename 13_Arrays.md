🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Weapons, overlays and PSprite](12_Weapons_Overlays_PSprite.md)    🔵 [>> Next: Flow Control](A1_Flow_Control.md)

------

# Arrays and linked lists

- [Overview](#overview)
- [Static constant arrays](#static-constant-arrays)
  * [Data access](#data-access)
- [Dynamic arrays](#dynamic-arrays)
  * [Note on data types](#note-on-data-types)
- [Dynamic array methods](#dynamic-array-methods)
- [Fixed-size arrays](#fixed-size-arrays)
- [Linked lists](#linked-lists)

## Overview

An **array** is a [variable](07_Variables_and_data_types.md) that can hold multiple pieces of data instead of one. In essence, arrays are lists.

The main terms related to arrays are:

* **Storage class**: colloquially also referred to as an "array type"; in ZScript arrays can be **fixed** (aka fixed-size), **dynamic** or **static constant**.
* **Data type (not to be confused with storage class)**: arrays support the same data types as [variables](07_Variables_and_data_types.md#data-types). All data in the array is of the same data type.
* **Element** or **item**: an entry in an array that contains some data.
* **Index**: the position of an element in an array. Indexes start at 0.
* **Size**: how many indexes there are in the array.

A **linked list** is another type of list-like structure that functions similarly to array but requires different syntax to iterate through them.

## Static constant arrays

> *Note:* I'm starting with a static constant array not because it's the most commonly used type but because it's arguably the simplest one to explain. In practice you'll be using dynamic arrays most of the time, described further in this chapter.

A static constant array is basically a simple list of values. They're defined as follows:

```csharp
//pseudocode:
static const type arrayName[] = 
{
    element1,
    element2,
    element3, //you can have any number of elements
    element4 //note the lack of comma after the last element
}; //semicolon is required
```

Here `type` is the [data type](07_Variables_and_data_types.md#data-types) and `arrayName` is the name for your array. 

In the example below a static array is used to set the actor's sprite randomly:

```csharp
Class RandomTallTorch : RedTorch 
{
    static const name torchSprite[] = 
    {
        "TRED",
        "TBLU",
        "TGRN"
    };
    override void PostBeginPlay() 
    {
        super.PostBeginPlay();
        sprite = GetSpriteIndex( torchSprite[random(0,2)] ); //randomly returns either 'TRED', or 'TBLU', or 'TGRN'
    }
    States 
    {
    Spawn:
        #### ABCD 4 bright;
        loop;
    }
}
```

This actor will randomly look like a Red Torch, or a Green Torch, or a Blue Torch from Doom. Using `####` allows us to use the sprite that was set in `PostBeginPlay()`, and since all of these sprite sets have ABCD frames, it'll work without issues.

You can access any entry in an array using `arrayName[index]` where `index` is the number of the entry. <u>Indexes always begin at 0</u>, so in the example above index 0 is "TRED", index 1 is "TBLU" and index 2 is "TGRN". So, for example, if we wanted to set the `sprite` to something specific, we could do `sprite = torchSprite[2]` to set the current sprite to "TGRN". By doing `sprite = torchSprite[random(0,2)]` instead of set `sprite` to a random index from 0 to 2, which allows us to randomize the sprite.

**Note:** obviously, you should never try to access an index that doesn't actually exist in an array—that'll cause an "out of bounds" error.

We can take the actor above to the next level by also attaching a random dynamic light:

```csharp
Class RandomTallTorchWithALight : RedTorch 
{
    static const name torchSprite[] = 
    {
        "TRED",
        "TBLU",
        "TGRN"
    };
    static const name torchLight[] = 
    {
        "BIGREDTORCH",
        "BIGBLUETORCH",
        "BIGGREENTORCH"
    };
    override void PostBeginPlay() 
    {
        super.PostBeginPlay();
        int i = random(0,2); //get a random number
        sprite = GetSpriteIndex( torchSprite[i] ); //set the sprite
        A_AttachLightDef("0",torchLight[i]); //attach the corresponding light
    }
    States 
    {
    Spawn:
        #### ABCD 4 bright;
        loop;
    }
}
```

[`A_AttachLightDef`](https://zdoom.org/wiki/A_AttachLightDef) is a function that allows attaching light definitions as defined in GLDEFS or DOOMDEFS lump. As such, remember that the code above will only work if you have `lights.pk3` in your load order, because `gzdoom.pk3` itself doesn't define any dynamic lights.

### Data access

Note that static arrays are static—meaning, they're available everywhere in the code, at all times. You can use the name of the class they're defined in as a prefix in order to read their values. In the example above `RandomTallTorchWithALight.torchSprite` will be readable from everywhere.

This is only true for static arrays.

## Dynamic arrays

Dynamic arrays are arguably the most frequently used type of arrays. A dynamic array is an array that gets filled with data at runtime (i.e. during the game). You can dynamically add or remove its elements—hence it's "dynamic." In contrast to a static array, when a dynamic array is defined it's always empty and has to be filled with data at runtime.

A dynamic array is defined as follows:

```csharp
//pseudocode:
array <type> arrayName; //< and > are required

//real code example:
array <Actor> traps;
```

One very common application of dynamic arrays is storing [pointers](08_Pointers_and_casting.md) to multiple actors. 

Let's say we want to make a stationary turret that continuously fires at us, but once we destroy it we want all of the projectiles it fired to disappear. We *could* just make the projectiles die when `if (target.health <= 0)` is true (since, as we remember, when it comes to projectiles, their `target` field is whoever or whatever shot them, in this case our turret). But there are cases when it may not work for us. What if we don't want or can't modify the projectiles? What if we're making it use existing vanilla projectiles, or projectiles from another mod, or something else? What if we just want to make the code shorter?

Here's how this can be achieved:

```csharp
//This turret uses TLMP sprites, so it looks like a tall lamp from Doom:
Class ImpBallTurret : Actor 
{
    array <Actor> projectiles; //this will contain pointers to fired projectiles
    Default 
    {
        monster;
        health 300;
        height 56;
        radius 16;
        translation "0:255=%[0.00,0.00,0.00]:[2.00,0.49,0.49]"; //just for fun, we'll alter its colors
        +NOBLOOD
        +DONTTHRUST //it shouldn't be moveable by damage
    }
    States 
    {
    // Since it doesn't need to walk around, we just check if it can see 
    // a player to kill, and just jump to Missile state if it can:
    Spawn:
        TLMP C 10; 
        TNT1 A 0 
        {
            A_LookEx(LOF_NOSOUNDCHECK|LOF_NOJUMP,fov:360);
            if (target && CheckSight(target))
                SetStateLabel("Missile");
        }
        loop;
    Missile:
        TLMP CBA 1;
        TLMP A 2 
        {
            A_FaceTarget();
            // Instead of just spawning a projectile, we first
            // cast it  to a pointer:
            let proj = A_SpawnProjectile("DoomImpBall");
            // Ff that pointer is valid, we use Push to add it 
            // to the array we defined earlier:
            if (proj)
                projectiles.Push(proj);
        }
        TLMP BC 2;
        TNT1 A 0 
        {
            //continue firing if the turret still sees its victim:
            if (target && CheckSight(target))
                SetStateLabel("Missile");
        }
        goto Spawn;
    Death:
        TNT1 A 0 
        {
            // When the turret dies, use a for loop to iterate
            // through all the indexes of the projectiles array:
            for (int i = 0; i < projectiles.Size(); i++) 
            {
                // Double-check the pointer isn't null, then stop                 
                // the projectile and play its Death sequence:
                if (projectiles[i]) 
                {
                    projectiles[i].A_Stop();
                    projectiles[i].SetStateLabel("Death");
                }
            }
        }
        MISL ABCDE 5 bright;
        stop;
    }
}
```

The process is simple:

* When spawning a projectile, the turret will first cast it to a local `proj` pointer.
* It then uses `projectiles.Push` to push (add) that pointer into the array. See [Flow Control](A1_Flow_Control.md#for) on how to use for loops and see below to find a detailed description of `Push`.
* When the turret is killed, it uses a `for` loop to iterate through the array. It then double-checks that the desired array index indeed contains a valid pointer by doing `if (projectiles[i])`, and then calls `A_Stop` on the found projectile and moves it to its Death state sequence.

For a more in-depth example of using arrays let's define a system that limits the total maximum number of Lost Souls that can exist in a map. This is done using an [event handler](11_Event_Handlers.md):

```csharp
//Note: don't forget to add the event handler using MAPINFO

Class LostSoulNumberControl : EventHandler 
{
    Array <Actor> lostsouls;
    //clear the array upon map start
    override void WorldLoaded(WorldEvent e) 
    {
        lostsouls.Clear();
    }
    //add a thing into a corresponding array when it gets spawned
    override void WorldThingSpawned(WorldEvent e) 
    {
        if (e.thing && e.thing is "LostSoul") 
        {
            lostsouls.Push(e.thing);
        }
    }
    //remove the LostSoul from the array when it's removed
    override void WorldThingDestroyed(WorldEvent e) 
    {
        if (e.thing && e.thing is "LostSoul") 
        {
            lostsouls.Delete(lostsouls.Find(a));    
        }
    }
    //continuously check if the number of actors is bigger than allowed. if true, destroy the oldest actors
    override void WorldTick() 
    {
        //I chose 50 as a maximum number for this example
        while (lostsouls.Size() > 50) 
        {
            if (lostsouls[0])
                lostsouls[0].Destroy(); //0 is always the index if the oldest actor
        }
    }
}
```

Here you can see a few extra array methods being used:

* `Delete` removes an element from the array. This does not destroy the actor, it simply removes a pointer to the actor from the array. In the example above we do this when a Lost Soul is killed naturally, since we don't need to keep pointers to dead actors in the array.
* `Find` allows us to find a specific *pointer* inside an array. We're calling `Delete` with `Find` because we need to delete the specific Lost Souls that died from the array.

### Note on data types

While all the examples of dynamic arrays I provided are arrays of actor pointers, arrays *can* in fact contain data of almost any type—because ultimately arrays are just fancy variarbles. All of these are valid:

```csharp
array <int> numberlist; //an array of numbers
array <Class<Actor> > classlist; //this doesn't contain pointers, instead it contains class names. Note the space.
array <SpriteID> spriteList; //an array of sprite IDs

//and so on...
```

The only exception to this is vectors. Unfortunately, ZScript arrays currently don't support `vector2` or `vector3` types.

**Note:** when you're making a an array of class names, you need a space between `<` and `>`:

```csharp
//this is valid:
array <Class<Actor> > classlist;
//this is also commonly used:
array < Class<Actor> > classlist;

//THIS WILL NOT WORK!
array <Class<Actor>> classlist;
```

## Dynamic array methods

The full list of methods (such as `Find`, `Delete`, etc.) is described on [ZDoom Wiki](https://zdoom.org/wiki/Dynamic_arrays). I'll only briefly cover the most basic ones and add some notes to them.

>  *Note:* All array methods are called with `arrayname.Method()`.

* `arrayName[index]` allows you to do something with the data inside the array. For example, `lostsouls[0]` in the example above gives us access to the very first element (i.e. a pointer to the oldest Lost Soul in the map) in the `lostsouls` array. By calling `lostsouls[0].Destroy()` we destroy the actor with that pointer.
  
  * **Note:** indexes can contain null data. Always perform a null-check before doing something with an array index.
  * Also remember that you can unintentionally specify an index that is outside of the array's bounds. If your array only contains 3 elements but you try to do `arrayName[10]`, you'll get an out of bounds error and GZDoom will close with a VM abort. That's another reason for checking indexes.
  * You can also directly *set* index values. Note that whatever was contained in that index previously will be removed from the array.

* `Size()` returns the current size of the array (i.e. how many elements it has). Can be used both on const and dynamic arrays.
  
  * **Note:** array's size will always be larger than the last index in the array by 1. For example, if you have an array that only contains 1 element, its size will be 1 but the index of that element will be 0. If there are 10 Lost Souls in the `lostsouls` array in the example above, the first Lost Soul will have an index of 0, while the last Lost Soul will have an index of 9, while the size of the array will be 10.

* `Find(item)` method tries to find `item`, i.e. a specific piece of data (such as actor), inside the array. If found, it'll return the **index** of that item (not a pointer).
  
  * **Note:** IMPORTANT AND EXTREMELY UNINTUITIVE! When `Find` can't find the object, it does not return `null` or `false` (because it's supposed to return a number); instead it returns an integer value that is equal to the array's size. So, if you want to make sure a piece of data actually **exists** in your array, you need to check for it as follows:
    
    ```csharp
    if (arrayName.Find(pointer) != arrayName.Size()) 
    {
      //'pointer' has been found in the array
    }
    else 
    {
      //'pointer' has NOT been found in the array
    }
    ```

* `Push(item)` pushes the `item` into the array. This means that the item will be added to the array, it'll receive a new index and the array's size will increase by 1. In contrast to doing `arrayname[index] = pointer`, this will never override any of the previously existing elements.

* `Pop()` removes the **last** item from the array and reduces the array's size by 1.

* `Delete(index)` deletes an item with the specified index from the array. 
  
  * **Note:** If you don't know the index and instead want to find an actor in the array and then delete it from it, you need to combine this with `Find`, like in the Lost Soul example above: `arrayName.Delete(arrayName.Find(pointer))`.
  * If you have an array of actor pointers, deleting a pointer from the array doesn't do anything to object: the object doesn't get destroyed or otherwise modified, the array just loses a pointer to it.

* `Clear()` removes all items from the array and shrinks its size to 0. Just like `Delete`, if you have an array of actor pointers, clearing that array doesn't do anything to the objects it was pointing to: the objects don't get destroyed or otherwise modified, the array just loses pointers to them.

## Fixed-size arrays

Fixed-size arrays, sometimes also called fixed arrays, are a variant of dynamic arrays that always have a fixed size. That means they always have the same number of indexes allocated, even if those indexes contain no data.

Fixed-size arrays are defined as follows:

```csharp
//pseudocode:
type arrayName[size]; //'size' defines the number of elements

//real code example:
Class<Actor> traps[5];
```

Fixed-size arrays are similar to dynamic arrays in the sense that their contents can be change dynamically. However, they don't have access to any of the dynamic array methods except `Size()`. You can't use `Pop()`, `Push()`, `Clear()` and other methods, since they all implying changing the array's size, which is obviously not an option with a fixed-size array. Instead, your only option to set and clear data is using `arrayName[index] = value`.

## Linked lists

Linked lists are somewhat similar to arrays but are used much more rarely. The main reason for this is that you can't define custom linked lists in ZScript. There are several places where they're used and exposed to ZScript, but those linked lists themselves are defined in the C++ side of the engine.

In essence, linked lists are similar to arrays, except an array lets you access each element individually, with a numeric index. A linked list is structured in such a way that each element of the list has a *pointer* to the next element in the list. As a result, there are no indexes/numbers, instead you just get a pointer to an element of the list and keep iterating as long as there's a valid pointer from the current element to the next one.

The most common linked list you might come across is inventory — not the `Inventory` class (the base class for all items), but the actual inventory of an actor. An inventory is a linked lists containing pointers to all items the actor is carrying. The inventory linked list is defined in the base `Actor` class as `native Inventory inv`; here `inv` is the name of the list, while `Inventory` is the data type. `Native`, as usual, points to the fact that this variable is defined and filled in C++, but ZScript can still read the data in it.

The basics of a linked list, using inventory as an example, work like this:

* Every actor that can carry items has an `Inv` pointer that points to the *first item* in their inventory.

* Every *item* in the list also has an `Inv` pointer, which points to the *next item* in the same list.

Thus, to iterate through an actor's inventory, you'd begin with an actor whose inventory you want to check, and then you'd move from each item to the next in that list.

Iterating through an inventory linked list looks like this:

```csharp
for (let iitem = <pointer>.Inv; iitem != null; iitem = iitem.Inv)
{
    // do something with 'iitem'
}
```

In this example `<pointer>` is a pointer to an actor who is holding some items, and `<pointer>.Inv` is a pointer to the first item in their inventory. 

This iteration functions as a FOR loop, but the syntax may look a bit unusual. As explained in [Appendix 1: Flow Control](A1_Flow_Control.md), FOR loops function as follows:

```
for (<initial values>; <condition to check against at the start of each loop>; <what to do at the end of each loop>)
```

In case of linked lists it works as follows:

* `let iitem = <pointer>.Inv` begins the iteration. This declares variable `iitem`, which is an `Inventory`-type pointer. We begin iteration by casting `<pointer>.Inv` to it, i.e. the first item in the desired actor's inventory.

* `iitem != null` is a condition checked at the start of each loop. In this case it's a simple null-check: we check that `iitem` is not null. If it is null, that means we've reached the end of this linked list, and it's time to abort the loop.

* `iitem = iitem.Inv` is what we do after each loop. Once we've successfully cast `iitem` and did whatever we wanted with it, we need to move on to the next item: this is done by reading the current item's `Inv` pointer, which pointers to the next item in the same list (meaning, in the same actor's inventory), and casting it to `iitem`, thus obtaining the value of `iitem`. After that it goes back to the null-check, and, if it passes, loops again.

As an example of using this iteration, here's an item that will give the toucher maximum ammo for all weapons they're currently carrying:

```csharp
class AmmoRefiller : Inventory
{
    Default
    {
        // This flag makes sure this item will call
        // its Use() function as soon as it's received:
        +INVENTORY.AUTOACTIVATE
        Inventory.pickupmessage "Refilled ammo for all weapons";
    }

    // This will be called upon receiving this item:
    override bool Use(bool pickup)
    {
        // null-check the owner first:
        if (owner)
        {
            // Iterate through the owner's inventory:
            for (let iitem = owner.Inv; iitem != null; iitem = iitem.Inv)
            {
                // Try casting the current item as weapon:
                let weap = Weapon(iitem);
                // If the cast succeeded, this means it's indeed
                // a Weapon. If not, the iteration will move on
                // to the next loop:
                if (weap)
                {
                    // Null-check this weapon's `ammo1` pointer.
                    // If it's valid, set its amount to its maxamount:
                    if (weap.ammo1)
                        weap.ammo1.amount = weap.ammo1.maxamount;
                    // Same for ammo2:
                    if (weap.ammo2)
                        weap.ammo2.amount = weap.ammo2.maxamount;
                }
            }
        }
        // Returning true will unconditionally consume this item:
        return true;
    }

    // For simplicity, this item uses Doom Backpack sprites:
    States {
    Spawn:
        BPAK A -1;
        stop;
    }
}
```

------

🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Weapons, overlays and PSprite](12_Weapons_Overlays_PSprite.md)    🔵 [>> Next: Constants](14_Constants.md)
