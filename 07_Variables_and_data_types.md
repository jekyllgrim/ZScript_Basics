🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Anonymous functions](06_Anonymous_functions.md)    🔵 [>> Next: Pointers and casting](08_Pointers_and_casting.md)

------

# Variables and data types

* [Overview](#overview)
* [Turning variables into actor properties](#turning-variables-into-actor-properties)
* [Access modifiers](#access-modifiers)
* [Accessing variables from weapon states](#accessing-variables-from-weapon-states)
* [Data types](#data-types)

## Overview

If you’ve used ACS, you’re probably familiar with variables. Variables can be defined and used in ZScript in a similar manner, but there are more **data types** that they can hold.

A variable is a piece of data that holds some information — a number, a string of text, coordinates, etc. When declaring variables, you give them names which you can use to reference them later. 

Usually custom variables look like this:

```csharp
string foo; //creates a variable 'foo' that holds a text string
int bar; //creates a variable 'bar' that holds an integer number
bool tobeornot; //creates a variable 'tobeornot' that holds a 'true' or 'false' value
```

Here’s a simple example of declaring a variable in a class and using it:

```csharp
class SpeedyImp : DoomImp 
{
    int speedups;    //creates a variable that can hold an integer number

    Default 
    {
        health 300;
    }

    States 
    {
    Pain:
        TNT1 A 0 
        {
            if (speedups < 5)    //check if the value is less than 5
            {
                speedups += 1;    //if so, increase the value by one
                speed *= 1.2;    //and multiply imp's speed by 1.2
            }
        }
        goto super::Pain;        // go to the normal Pain state
    }
}
```

> *Note*: speed is the default speed [actor property](https://zdoom.org/wiki/Actor_properties#Behavior), not a custom variable, you can just read and change it directly.

Whenever this Imp is hurt, it'll increase its speed by x1.2. But this will only happen as long as `speedups` is less than 5—so, no more than 5 times.

A variable like that can be declared anywhere in the class but *not* inside the `Default` or `States` blocks. You can access it from anywhere in the class, as well as classes that inherit from `SpeedyImp`. This type of variables is known as **fields**.

A different method is declaring a variable inside an anonymous function. If you do that, that variable will exist only within that anonymous function:

```csharp
class WeirdImp : DoomImp
{
    int speedups;            //this variable is available anywhere in the class

    Default 
    {
        health 500;
    }

    States 
    {
    Pain:
        TNT1 A 0 
        {
            if (speedups < 10) 
            {
                speedups++;            //++ is the same as +=1
                // Create a temporary variable 'foo' that holds 
                // a random value between 0.8 and 1.2:
                double foo = frandom(0.8, 1.2);    
                speed *= foo;        // multiply speed by that value
                scale /= foo;        // divide scale by the same value
            }
        }
        goto super::Pain;
    }
}
```

This weird Imp will randomly change its `speed` and `scale` (inversely related) when being hit, up to 10 times. Notice that `speed` is multiplied and `scale` is divided always by the same value: so, *first* a random value between 0.8 and 1.2 is selected, and *then*, after it's chosen, the multiplication and division happen. So, when it's damaged, it either becomes faster and smaller, or slower and bigger.

Variable `foo` in this example exists only inside that anonymous function and isn't available anywhere else. This is a **local** variable.

Let's summarize the differences between these two types:

**Class-scope variables aka fields:**

- Fields by default can be changed from anywhere (this class, inheriting classes, even other classes if they get access to it — the latter will be covered in the [Pointers and Casting](#08_Pointers_and_casting.md) chapter).
- Fields can’t be declared with a value. When you declare them, they receive a default value (for `int` this is 0, for `string` it's an empty string), and then you have to modify it somewhere (for example, inside an actor state). In the example above `speedups` is initially equal to 0 and it’s increased by 1 when the Imp enters its Pain state for the first time and calls `speedups++`.
- Fields keep their value while the class exists. That’s why every time we do `speedups += 1` (or `speedups++`, which is the same), it increases by 1 and will keep that value throughout whatever the Imp does.
- Since fields can be accessed from multiple places, it’s a good idea to give them a sensible and understandable name.

**Local variables:**

- Local variables are declared inside a code block (such as an anonymous function) and are available only within that code block. 
- They can be declared with a value.
- Obviously, whenever the function is executed again, this variable will be re-declared and receive the value again. That’s why `double foo = frandom(0.8, 1.2)` will create a temporary variable `foo` equal to a random value between 0.8 and 1.2 *every* time the Pain state sequence is entered. (Note that actors can enter the Pain state multiple times per tic when hit by multiple attacks, such as a shotgun blast.)
- Their names aren’t that important, since they won’t exist after the function stops executing. Usually something very short is used.

## Turning variables into actor properties

You can turn a variable into a custom actor property using this syntax:

```csharp
//pseudocode:
type varname;
property propname : varname;
```

An actual example:

```csharp
class WeirdImp : DoomImp 
{
    int speedups;                    //defines variable 'speedups'
    property speedups : speedups;    //assigns the variable to a property with the same name

    Default 
    {
        WeirdImp.speedups 10;        //defines the default value for the variable
    }
}
```

Notes on the example:

- This allows you to easily provide a default value for your custom field, which is otherwise impossible.
- Once you define a property, you need to give it a value in the `Default {}` block (since you're giving it a *default* value).
- All custom properties need to be prefixed with the name of the class where they are defined: hence we're using `WeirdImp.speedups` and not just `speedups` in the `Default {}` block.

This property will be available to the WeirdImp class, as well as to all classes inheriting from it. If you're planning to have a lot of custom properties for all the actors in your mod, it's a good idea to define a custom version of the Actor class, define all properties in it, and then use it as a base class for all your custom classes.

## Access modifiers

Usually variables are declared according to the following syntax:

```csharp
//pseudocode:
accessmodifier type variablename;

//actual example:
private int myspecialnumber;
protected string myspecialtext;
```

Access modifier lets you restrict access to the variable, defining what can read and change its value. The available options are:

- `protected` — this variable can be changed only from this class and classes inheriting from it but it can’t be changed from anywhere else
- `private` — this variable is only available to this class and nothing else
- If left unspecified, the variable will be public—i.e. readable and changeable from anywhere in the game, provided you have a pointer to the class that contains it (see [Pointers and Casting](08_Pointers_and_casting.md))

It's usually not something you need to worry about, but in general if you *know* that you're declaring a variable that will never be (and shouldn't be) changeable from any other class, it's a good idea to make it `private` (or `protected` if you want it to be accessible to child classes, but not to other classes). This approach is known as [encapsulation](https://en.wikipedia.org/wiki/Encapsulation_(computer_programming)), and the gist of it is: sometimes it's important to be *sure* that this data doesn't get changed accidentally from somewhere else, so better protect it.

## Accessing variables from weapon states

If you've defined a variable in a weapon, to access it from the weapon's state you will need to use the `invoker` prefix:

```csharp
class MyPlasma : Weapon
{
    int heatCounter; //this will hold the amount of heat accumulated by the weapon

    States
    {
    Ready:
        WEAP A 1
        {
            A_WeaponReady();
            invoker.heatCounter = 0; //reset the heat to 0 in Ready state
        }
        loop;
    Fire:
        WEAP B 1
        {
            A_FireProjectile("Plasmaball");
            invoker.heatCounter++; //accumulate heat when firing
            //if the heat is too high, jump to Cooldown sequence:
            if (invoker.heatCounter >= 50)
            {
                return ResolveState("Cooldown");
            }
            //otherwise continue to the next state as normal:
            return ResolveState(null);
        }
    [...] //the rest of the weapon's code
    }
}
```

This is required to clearly differentiate a variable defined on the weapon from variables defined on the player. Player variables, on the other hand, can be accessed by using the variable's name directly:

```csharp
//this weapon has a zoom function which slows the player down by 20%:
Zoom:
    WEAP A 1
    {
        speed = default.speed * 0.8;
        A_ZoomFactor(1.3);
    }
```

This is only true for the weapon states, however. If you access a variable from the weapon's virtual function, this rule doesn't apply.

You will find more information on accessing and manipulating data in weapon context in the [Weapons, overlays and PSprite](12_Weapons_Overlays_PSprite.md) chapter.

## Data types

Of course, `int` isn't the only existing variable type. It's important to have a general understanding of these data types, since actor properties and function arguments in Doom are also essentially variables and they also hold data of various types. 

Hence here's a list of various data types. You don't need to immediately learn them by heart, but rather use it as a reference. This list might not be exhaustive.

- **`int`** — holds an integer number (such as 1, 2, 3, 10, 500, etc.)
  - Many existing properties are also integer values, for example `damage` and `health`. That’s why projectiles can’t deal 2.5 points of damage, only 2 or 3.
- **`double`** — holds a float-point number (such as 2.5). Note that `float` is also an existing type, but `double` is used in ZScript instead because it’s essentially the same thing but it has higher precision. That’s usually not something you need to worry about as a user, just remember that a float-point number should be stored in a `double` variablle.
  - There’s a whole lot of values in GZDoom that are doubles. For example, actors' `angle`, `height`, `radius`, `speed`, `alpha`, `bouncefactor` are all doubles.
- **`bool`** — a boolean variable holds a `true`/`false` value. You can set and check it against true and false, such as `if (foo == true)` (to check if it's true) and `foo = false`; (to set foo to true).
  - The most common example of a bool is actor flags. While flags in the Default block are a special case, since you can set them with + and -, those flags are internally connected to boolean variables named `bFLAGNAME`. You can change the majority of flags on the fly by using those names; for example, you can do `bSHOOTABLE = false;` to suddenly make an actor unshootable.
    - A shorthand for `if (foo == true)` is simply `if (foo)`. And `if (foo == false)` can be replaced with `if (!foo)` (`!` means "not" and inverts any check).
  - No quotation marks! `"True"` is a string holding the text "True", while `true` is a boolean value.
  - Internally boolean values are also numbers, where 0 is considered `false`, while a non-zero value is `true`. However, while `if (mybool > 0)` is technically correct, you shouldn't use this syntax because you'll just confuse yourself (and others who might be reading your code). Whenever possible, always use variables in such a way that their type is obvious from just looking at them.
- **`String`** — holds *case-sensitive* text (such as "Adam")
  - Setting and changing it requires using double quotation marks: `string foo = "Bar";` creates a variable foo that holds the text "Bar". 
- **`name`** — holds *case-insensitive* text (i.e. 'adam', 'Adam' and 'ADAM' are all the same)
  - In contrast to strings, setting and changing `name`s is possible with *single* quotation marks. You can still use double quotes, but it’s a good idea not to do that, so that when you look at the variable, you’ll immediately know it’s a `name` and not a `string` (same as you should do `if (mybool == true)` not `if (mybool > 0)`. In fact, for custom variables in the majority of cases it’s better to use a name than a string, since there are relatively few applications for case-sensitive text.
  - A bunch of stuff in GZDoom are names, for example class names and values of properties such as `Bouncetype`.
- **`Vector2`** — holds two float-point values that are accessible with `.x` and `.y` postfixes. So, if you declare `vector2 foo`, you can read its components with `foo.x` and `foo.y`. Vector2 type is used for things like position or velocity in 2D space (i.e. `pos.x` and `pos.y` or `vel.x` and `vel.y` respectively). The contents of this type of variable is two float-point values enclosed in parentheses, such as `(15.0, 14.2)`. 
- **`Vector3`** — similar to vector2, but holds 3 values accessible with postfixes `.x`, `.y` and `.z`. Actors use vector3 `pos` to store their XYZ position in a map, and vector3 `vel` to store their velocity alongside XYZ axes.
  - If you have only a vague understanding of how coordinates work and why they’re called "vectors", it’s very simple: every map has an origin point with coordinates of (0, 0, 0). Any object within a map has coordinates *relative* to that origin point; for example, if an actor is positioned at `(15, 12.3, 0)` that means it’s located 15 units to the east, 12.3 units to the north and 0 units vertically away from the map's origin point. Since all coordinates are *relative* to that (0,0,0) origin, this makes all coordinates *vectors*; a vector in this context is basically a line that starts at (0,0,0) and ends wherever the object is.
  - Similarly, velocity is just how quickly an object is changing position per tic (1/35 of a second). If an actor’s velocity is `(15, 0, 1.2)`, every tic it moves 15 units north, 0 units east/west and 1.2 units upward. Basically, actor movement is their vector3 of velocity being constantly added to their vector3 position.
- **`class<Actor>`** — a variable that holds a actor class name. 
  - The `<Actor>` part can be substituted for something else, if you want to limit this variable to being able to hold a name of a specific subclass, for example `Class<Ammo>`.
  - Note that while it holds a name, it's not the same as a `name`. `Class<Actor>` isn't just a line of text; it also contains information that tells the game that this is, in fact, an existing actor class. In contrast, a `name` simply contains text and nothing else.
- **`Actor`** — a variable that holds an instance of an actor (i.e. a pointer to it). It’s not a name of an actor class, but a *pointer* to a *specific* actor that exists in the level. Learn more in [Pointers and Casting](08_Pointers_and_casting.md).
- **`StateLabel`** — holds a reference to the name of a state sequence, aka state label, such as "Ready", "Fire", etc. Note, state labels are not strings, they're a special type of data, and in fact strings can't be converted to state labels or vice versa. `StateLabel` type is commonly used as function arguments: for example, in the [`A_Jump`](https://zdoom.org/wiki/A_Jump) function the first argument is an integer number defining the jump chance, while the second argument is a state label that tells the state machine which state sequence to go to.
- **`state`** — holds a reference to a state. Not to be confused with state sequences or state labels. (See [State control](A1_Flow_Control.md#state-control) for details on the differences.) For example, doing `state st = FindState("Ready"),` creates a variable `st` that holds a pointer to the first state in the `Ready` sequence.
  - One commonly used state-type variable used in actors is `curstate`: it holds a pointer to the state the actor is currently in. It can be used in combination with [`InStateSequence`](https://zdoom.org/wiki/InStateSequence) function to check which state *sequence* the actor is in with `if ( InStateSequence(pointer.curstate, pointer.FindState("Label") )`, where `poitner` is a pointer to actor and "Label" is a state label.
  - Another native actor state variable is `SpawnState` which holds a pointer to the first state in the Spawn sequence.
- **`SpriteID`** — holds a reference to a sprite. All actors have `sprite`, which is a `SpriteID`-type variable that always holds their current sprite; you can use it to make one actor copy the appearance of another by doing `pointer1.sprite = pointer2.sprite`. (Note that "appearance" includes many more characteristics, such as scale, alpha, renderstyle, etc.)
  - Note that `SpriteID` isn't a sprite *name*; instead it's a special internal identifier of a sprite. Converting a sprite name to a SpriteID requires `GetSpriteIndex()` function. E.g.: `sprite = GetSpriteIndex("BAL1")` will set the current actor's sprite to BAL1, the sprite used by Imp's fireballs. Note that you can also modify `frame` to modify the frame letter of a sprite, where `0` is `A`, `1` is `B` and so on.
  - You can also get a pointer to the sprite used in any state simply by having a pointer to that state. For example, normally you can check `SpawnState.sprite` in any actor to get the first sprite used in the actor's Spawn state sequence. In this sense `sprite` is identical to `curstate.sprite`.
- **`TextureID`** — holds a reference to an image (any kind of image that exists in the loaded archive), but not a sprite that can be used in an actor (in contrast to SpriteID). Similarly to SpriteID, this isn't a name of the texture but rather an internal identifier. You normally won't need this in actors; instead this is commonly used in UI and HUDs.

Elements of the map itself can also be interacted with in ZScript, and as such you can get pointers to them. One commonly used way to do that is the [`LineTrace`](https://zdoom.org/wiki/LineTrace) function that fires an invisible ray and returns a pointer to what it hits (an actor, a sector, a linedef, etc.). Also, actors contain a number of native fields that are meant to hold pointers to map elements; some of these a mentioned below.

Some of the data types that can contain pointers to map elements are:

- **Line** — holds a pointer to a linedef. Actors have a `line`-type `BlockingLine` pointer that contains a pointer to a linedef the actor crosses or hits (for example, projectiles get it when they explode due to hitting a wall).
- **Sector** — holts a pointer to a sector. All actors have a `sector` type variable `cursector`, which holds the sector the actor is currently in.
- **F3DFloor** — holds a pointer to a 3D floor.
- **SecPlane** — holds a pointer to a plane (a floor or a ceiling). Any sector has two native `SecPlane`-type variables: `floorplane` and `ceilingplane`. 3D floors, similarly, have `bottom` and `top` pointers to their bottom and top planes.

------

🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Anonymous functions](06_Anonymous_functions.md)    🔵 [>> Next: Pointers and casting](08_Pointers_and_casting.md)
