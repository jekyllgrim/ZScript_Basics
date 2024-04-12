🟢 [<<< BACK TO START](README.md)

---

*This section is a work-in-progress. Contents to be revised/corrected/expanded.*

# Appendix 3: Glossary

### Action function

1. In ZScript: a function declared as `action`. Usually this is only useful for Weapon and CustomInventory classes. See: [Weapons, overlays and PSprite](12_Weapons_Overlays_PSprite.md).

2. In DECORATE: any function that can be called in an actor's [state](#State).

### Actor

A base class in GZDoom (the inheritance chain is Object→Thinker→Actor). The classes based on `Actor` are also referred to as "actors." The absolute majority of objects that can be spawned in the game's world (such as monsters, weapons, decorations) are actors. The base `Actor` class contains all actor logic (such as gravity, velocity, collision) and all native actor functions.

### Anonymous function

A series of commands placed inside a single code block attached to a single actor state. See: [Anonymous Functions](06_Anonymous_functions.md).

### Array

A type of [variable](#Variable) that can contain a list of values rather than a single value. Arrays can be static (their contents are defined explicitly and can't be changed at runtime) and dynamic (initially empty, but can be filled with data at runtime). Dynamic arrays can also be fixed-size (the data can be changed dynamically, but the number of indexes can't).

### Argument

A variable that is a part of a [function](#Function). Also known as **parameter**. Arguments of a function are defined in parentheses, right after the name of the function. Arguments can be optional (in which case they have a default value that will be used unless a different value is specified) or non-optional (they don't have a default value; the value has to be defined when the function is called). See: [Custom Functions](09_Custom_functions.md).

### Bit field

An [integer](#Integer) [variable](#Variable) that is designed to hold multiple values. The intended values are [flags](#Flag) where each flag corresponds to a specific bit value: 2, 4, 8, 16, and so on. This provides a unique opportunity to use a single integer variable to hold multiple values. For example, if the value of the field is 12, we know that it contains flags 8 and 4 because no other combination can result in the total number of 12.

Bit fields are often used as [arguments](#Argument) in [functions](#Function). See: [Flow Control - Bitwise Operators](A1_Flow_Control.md#bitwise-operators).

### Boolean

A [value](#Value) that can only be `true` or `false` (or, if expressed numerically, `1` and `0` respectively).

### Call

To call: to execute something, like a [function](#Function). For example, monsters usually **call** the `A_Chase` function to walk around and chase their targets.

The object: the object (such as a class, or an actor) that is **calling** a function. For example, when a Rocket hits something and calls `A_Explode` to deal radius damage, the Rocket is the **calling actor** in the context of that function.

### Class

The main type of object in ZScript that can hold [fields](#Field) (class-scope variables), [methods](#Method) (class functions), [constants](#Constant), [enums](#Enum) and other data. See: [Defining ZScript classes](02_Defining_ZScript_classes.md).

### Code block

A set of instructions (such as [function calls](#Function), [expressions](#Expression) or [declaration](#Declaration) of [variables](#Variable)) placed within a single pair of curly braces (`{ }`).

### Constant

A piece of data that has a fixed value that can't be changed at runtime. Constants are used to give fixed values a nice name. Common examples of constants are flags used as function arguments are names of sound channels (such as `CHAN_BODY`) or PSprite layer numbers (such as `PSP_Weapon`). Constants can be defined within a class or on their own. See: [Constants and enums](14_Constants.md).

### Context

The environment and circumstances in which something happens—for example, a specific piece of code is executed. The meaning is somewhat situational. For example, a virtual function, a weapon state, an event and such can be contexts, since they determine how specific things should be handled (e.g. the available pointers, how the code is executed, etc.).

### Curly braces

The `{` and `}` characters. Sometimes incorrectly referred to as "brackets", which is wrong, because brackets are `[` and `]`. Curly braces are used to mark the start and the end of a [code block](#Code block).

### Crash to desktop

Aka crash, CTD. When GZDoom closes unexpectedly to a "Very Fatal Error" window showing a memory address. This means that something happened that GZDoom was not able to handle properly. This is almost always a reason to make a bug report, because no matter what kind of a mistake you might've made, GZDoom *should* be able to process it correctly and lead to a [VM abort](#VM abort) with a proper error message.

### Declaration

"To declare" means to create or to define something, like a variable or a function. For example, if you do `int foo` in your code, this means a [variable](#Variable) `foo` is **declared**.

### Default block

An [Actor](#actor)-specific block that contains [actor properties](#Property) and [flags](#Flag) that determine the actor's default behavior (i.e. the behavior it'll exhibit on spawning). The definition of the block begins with a `Default` header.

### Double

A double is a decimal [value](#Value), like 1.5, 7.842, and so on. A double is very similar to a float-point number, but the difference is that it has higher precision, which basically means that it can hold more numbers after the point.

### Enum

A list of [constants](#constant) of the same type. See: [Constants and enums](14_Constants.md).

### Event

A [virtual function](#Virtual function) of an event handler class that is automatically triggered by specific things happening in the game (such as the map being loaded, the player connecting, an actor being spawned/damaged/destroyed/resurrected, and other). See: [Event Handlers](11_Event_Handlers.md).

### Field

A class-scope [variable](#variable) (a variable that is defined at the top of the class—outside of any other code block—and is thus available anywhere in the class). See: [Variables and data types](07_Variables_and_data_types.md).

### Flag

1. In an Actor: A type of a boolean Actor property that can be set or unset by using `+<FLAGNAME>` or `-<FLAGNAME>` in the actor's Default block or by setting `bFLAGNAME` to true or false on an actor pointer. Flags are internally defined as a bit field.

2. In a function: A bitfield that functions as an argument of a function so that it can combine multiple values. The flags are integer numbers that normally receive "nice names" by being defined as constants. Flags can be set, unset and combined with bitwise operators. See: [Flow Control](A1_Flow_Control.md).

### Flow

Flow is a generic term referring to code which describes the order in which certain things in the code are executed. Various statements (such as IF conditions) offer means to control the flow of the code. See [Flow Control](A1_Flow_Control.md).

### Function

A set of instructions united under a single name that can be called by referencing that name. Functions support arguments that they can utilize. Functions can be of various types: regular, virtual, action, static. They can also be void or have a return value. See: [Custom Functions](09_Custom_functions.md).

### Instance

Very literally, an instance of an [object](#Object). For example, GZDoom comes with the code for the class called `DoomImp`. Each imp that spawns in the map and starts doing stuff is an **instance** of that class. Each instance of an object can be in different states (existing, destroyed, alive, dead, etc.) and be doing different things. See: [Pointers and casting](08_Pointers_and_casting.md).

### Integer

A [value](#Value) that contains a whole number without a decimal part, like 1, 2, 5, 100, etc. 

### Instantiation

The process of creating an [instance](#Instance) of something. For example, [actors](#Actor) are instantiated by being spawned in the map. See: [Pointers and casting](08_Pointers_and_casting.md).

### Iteration

The process of going through a series of pieces of data, one by one, usually with the intent to do something with that data. For example, you can iterate over an [array](#Array) or a [linked list](#Linked list).

### Inventory

1. `Inventory` class is one of the base native classes. Classes based on Inventory can function as items: they can be attached to other actors' inventories, gaining the `owner` pointer to those actors. Inventory comes with a number of custom properties and flags, as well as virtual functions, such as `DoEffect()`, `TryPickup()`, `HandlePickup()` and others.

2. [Actors](#Actor) can hold items ([instances](#Instance) of the `Inventory` class) in their **inventory**. That inventory is a [linked list](#Linked list) that is just a list of items attached to said actor.

See: [Inventory](12.1_Inventory.md).

### Linked list

A simple data structure similar to [arrays](#Array). In contrast to arrays, elements of a linked list don't have indexes. Instead, each element has a [pointer](#Pointer) to the next element, so you can [iterate](#Iteration) over it to do something with its elements. See: [Arrays and linked lists](13_Arrays.md).

### Method

A function defined within a class. See: [Custom Functions](09_Custom_functions.md). In ZScript, all functions are either methods, or anonymous functions.

### Nesting

The practice of putting code blocks inside other code blocks, such as:

```csharp
if (condition)
{
    ...
    if (condition2)
    {
        ...
        if (condition3)
        {
            ...
```

A large number of nested blocks makes it harder to read the function and understand its intended flow. If that happens, it may be better to move some of the instructions into a separate dedicated function.

### Null-checking

The process of checking that something isn't null. Most of the time it looks like `if (<pointer> != null)` or, a shorter version, `if (<pointer>)`. This is used when you have a [pointer](#Pointer) to some [object](#Object) but that object is not guaranteed to exist. For example, you want to do something with a monster's target, but when the code is executed, you can't know if said monster has already acquired a target or not.

### Object

In ZScript: the most basic class. All classes inherit from Object. If you create a new class without a parent, it'll be implicitly inherited from Object.

In a more general sense: any more or less clearly defined unit of data, such as a class, a struct, etc.

### Parameter

Same as [argument](#Argument).

### Pointer

A [variable](#Variable) that points to another object—like an instance of another class. See: [Pointers and casting](08_Pointers_and_casting.md).

### Property

Properties are [variables](#variable) that were made accessible in the [Default block](#Default block) of an [actor](#Actor). When defined as a property, variables can be given default values with the help of the Default block. See: [Turning variables into actor properties](#turning-variables-into-actor-properties).

### Reference

A concept similar to a [pointer](#Pointer), a reference is any case where code (be it ZScript or engine code) is accessing something not directly, but through some kind of reference. For example, the functions that play sounds, like `A_StartSound`, cannot use sound file names directly. Instead, they *refer to* a sound definition made in the SNDINFO lump. That is an example of a reference.

On a purely coding level, a reference is also a way to pas a [value](#Value) indirectly. References are usually [arguments](#Argument) in [functios](#Function), and they can be defined with an `out` keyword. Compare:

```csharp
// function that returns an int:
double RandomMultiply(double val)
{
    return val * frandom(0, 10);
}

//elsewhere:
double baseval = 3.5;
baseval = RandomMultiply(baseval);
```

The same  can be done by passing a variable by reference:

```csharp
// function that modifies a value:
void RandomMultiply(out double val)
{
    val *= frandom(0, 10);
}

//elsewhere:
double baseval = 3.5;
RandomMultiply(baseval);
// baseval has now been processed by RandomMultiply()
```

The second example passes `baseval` to the argument `val` by reference, and then `RandomMultiply()` modifies whatever variable (`baseval` in this example) was passed to it.

### Return value

A [value](#Value) that can be obtained by calling a [function](#Function). All functions that aren't `void` have a return value. 

### Scope

A general [context](#Context) where a specific piece of data, object or function is defined and/or can be called. ZScript supports 3 scopes: `play` (used by any class that exists in the map, i.e. classes based on Thinker; stores and modifies data that exists in the playsim), `ui` (used by HUDs and menus; can read `play` data but not modify it) and `data` (used by default by all classes based on Object; is used to store readonly values). The `clearscope` access modifier defines the piece of data to be readable in all scopes.

In a narrower sense, "scope" can refer to the context within which specific data is available. For example, a [variable](#variable) defined at the top of a [class](#Class) (i.e. a [field](#Field)) can be described as a "class-scoped variable."

### Snippet

An exceprt containing some code from a larger piece of code/program.

### State

A single instruction in a States block. Only classes based on Actor can have states. A graphic, a duration and a function call can be attached to a state. See: [State Control](A1_Flow_Control.md#state-control).

Not to be confused with a [state label](#State label).

### State label

A header for a series of [states](#State) inside a States block. Headers can be obtained via `FindState()` and `ResolveState()`,  and jumped to with `goto`. State labels only exist in the uncompiled ZScript as a matter of convenience; internally states are just a list. If there's no `goto`, `loop` or another state control instruction at the end of a specific state sequence, the machine will just fall through to the next sequence. See: [State Control](A1_Flow_Control.md#state-control).

State labels are often referred to as just "states", which is incorrect: for example, a "Spawn" state label is specifically the *name* "Spawn" given to the spawn sequence, whereas a "Spawn state" would be only the first actual state of that sequence.

### Value

A piece of data, such as a number, a text string, a pointer, or any other possible data type. Values can be obtained (e.g. via functions), stored (in variables) and manually set.

### Variable

A piece of data of specific type, with a specific name. The value of that data can be not only read but also changed dynamically—hence it's "variable". Variables can be defined at the top of the class (or, more specifically, at any place in the class outside of any code block), which makes them a field (available anywhere within the class), or within a code block (which makes them a local variable, available only within that code block). See: [Variables and data types](07_Variables_and_data_types.md).

### Vector

In very simple terms, a vector is a line that points from one point in space to another point in space. In ZScript vectors are often used to express position and velocity of [actors](#Actor). The game's world has a point of origin with XYZ coordinates of (0, 0, 0), and every actor's position is offset from that point. Similarly, velocity is directed somewhere along those XYZ axes.

In ZScript most vectors are either 2-dimensional (only have X and Y components) or 3-dimensional (X, Y and Z).

### Virtual function

AKA **virtual method**. A [function](#Function) [declared](#Declaration) as `virtual`. These functions can be overridden in classes based on the class where the function is [declared](#Declaration).

### VM abort

A virtual machine abort or virtual machine escape. It's when GZDoom closes to the console and shows an error message. Should not be confused with a crash (which is when GZDoom is not able to show an error message). VM abort will tell you exactly what went wrong with your code and where.

### Wrapper

A [function](#Function) that is explicitly designed to call another function, usually to perform some additional setup before doing so. For example:

```csharp
void A_CustomPainSound()
{
    sound snd = "monsters/zombie/painlight";
    if (health < GetMaxHealth()*0.5)
    {
        snd = "monsters/zombie/painheavy";
    }
    A_StartSound(snd);
}
```

This function is meant to be a custom replacement for `A_Pain` (the function that plays a monster's painsound), which plays one of the two sounds depending on whether its health is above 50% or not. At the end it calls `A_StartSound`, the basic sound-playing functions. As such, `A_CustomPainSound` is a **wrapper** for `A_StartSound`.

---

🟢 [<<< BACK TO START](README.md)
