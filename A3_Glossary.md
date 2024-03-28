🟢 [<<< BACK TO START](README.md)

---

*This section is a work-in-progress. Contents to be revised/corrected/expanded.*

# Appendix 3: Glossary

### Actor

A base class in GZDoom (the inheritance chain is Object→Thinker→Actor). The classes based on `Actor` are also referred to as "actors." The absolute majority of objects that can be spawned in the game's world (such as monsters, weapons, decorations) are actors. The base `Actor` class contains all actor logic (such as gravity, velocity, collision) and all native actor functions.

### Anonymous function

A series of commands placed inside a single code block attached to a single actor state. See: [Anonymous Functions](06_Anonymous_functions.md).

### Array

A type of variable that can contain a list of values rather than a single value. Arrays can be static (their contents are defined explicitly and can't be changed at runtime) and dynamic (initially empty, but can be filled with data at runtime). Dynamic arrays can also be fixed-size (the data can be changed dynamically, but the number of indexes can't).

### Argument

A variable that is a part of a [function](#function). Arguments of a function are defined in parentheses, right after the name of the function. Arguments can be optional (in which case they have a default value that will be used unless a different value is specified) or non-optional (they don't have a default value; the value has to be defined when the function is called). See: [Custom Functions](09_Custom_functions.md).

### Class

The main type of object in ZScript that can hold fields (class-scope variables), methods (class functions), constants, enums and other data. See: [Defining ZScript classes](02_Defining_ZScript_classes.md).

### Code block

Function calls, expressions and declarations placed within a single pair of curly braces (`{ }`).

### Constant

A piece of data that has a fixed value that can't be changed at runtime. Constants are used to give fixed values a nice name. Common examples of constants are flags used as function arguments are names of sound channels (such as `CHAN_BODY`) or PSprite layer numbers (such as `PSP_Weapon`). Constants can be defined within a class or on their own. See: [Constants and enums](14_Constants.md).

### Context

The environment of in which a specific piece of code is executed. The meaning is somewhat situational. For example, a virtual function, a weapon state, an event and such can be contexts, since they determine how specific things should be handled (e.g. the available pointers, how the code is executed, etc.).

### Default block

An [Actor](#actor)-specific block that contains actor properties and flags that determine the actor's default behavior (i.e. the behavior it'll exhibit on spawning). The definition of the block begins with a `Default` header.

### Enum

A list of [constants](#constant) of the same type. See: [Constants and enums](14_Constants.md).

### Event

A virtual function of an event handler that is automatically triggered by specific things happening in the game (such as the map being loaded, the player connecting, an actor being spawned/damaged/destroyed/resurrected, and other). See: [Event Handlers](11_Event_Handlers.md).

### Field

A class-scope [variable](#variable) (a variable that is defined at the top of the class—outside of any other code block—and is thus available anywhere in the class). See: [Variables and data types](07_Variables_and_data_types.md).

### Flag

1. In an Actor: A type of a boolean Actor property that can be set or unset by using `+<FLAGNAME>` or `-<FLAGNAME>` in the actor's Default block or by setting `bFLAGNAME` to true or false on an actor pointer. Flags are internally defined as a bit field.

2. In a function: A bitfield that functions as an argument of a function so that it can combine multiple values. The flags are integer numbers that normally receive "nice names" by being defined as constants. Flags can be set, unset and combined with bitwise operators. See: [Flow Control](A1_Flow_Control.md).

### Function

A set of instructions united under a single name that can be called by referencing that name. Functions support arguments that they can utilize. Functions can be of various types: regular, virtual, action, static. They can also be void or have a return value. See: [Custom Functions](09_Custom_functions.md).

### Inventory (class)

One of the base native classes. Classes based on Inventory can function as items: they can be attached to other actors' inventories, gaining the `owner` pointer to those actors. Inventory comes with a number of custom properties and flags, as well as virtual functions, such as `DoEffect()`, `TryPickup()`, `HandlePickup()` and others.

### Inventory (linked list)

A list of items (Inventory-derived classes) attached to a specific actor. A linked list is a specific data structure, somewhat similar to an array, that has limited use in ZScript.

### Method

A function defined within a class. See: [Custom Functions](09_Custom_functions.md). In ZScript, all functions are either methods, or anonymous.

### Property

Properties are [variables](#variable) that were made accessible in the Default block of an actor. When defined as a property, variables can be given default values with the help of the Default block. See: [Turning variables into actor properties](#turning-variables-into-actor-properties).

### Return value

A value that can be obtained by calling a function. All functions that aren't `void` have a return value. 

### Scope

A general context where a specific piece of data, object or function is defined and/or can be called. ZScript supports 3 scopes: `play` (used by any class that exists in the map, i.e. classes based on Thinker; stores and modifies data that exists in the playsim), `ui` (used by HUDs and menus; can read `play` data but not modify it) and `data` (used by default by all classes based on Object; is used to store readonly values). The `clearscope` access modifier defines the piece of data to be readable in all scopes.

In a narrower sense, "scope" can refer to the context within which specific data is available. For example, a [variable](#variable) defined at the top of a class (a field) can be described as a "class-scope variable."

### State

A single instruction in a States block. Only classes based on Actor can have states. A graphic, a duration and a function call can be attached to a state. See: [State Control](A1_Flow_Control.md#state-control).

Not to be confused with a state label.

### State label

A header for a series of states inside a States block. Headers can be obtained via `FindState()` and `ResolveState()`,  and jumped to with `goto`. State labels only exist in the uncompiled ZScript as a matter of convenience; internally states are just a list. If there's no `goto`, `loop` or another state control instruction at the end of a specific state sequence, the machine will just fall through to the next sequence. See: [State Control](A1_Flow_Control.md#state-control).

State labels are often referred to as just "states", which is incorrect: for example, a "Spawn" state label is specifically the *name* "Spawn" given to the spawn sequence, whereas a "Spawn state" would be only the first actual state of that sequence.

### Value

A piece of data, such as a number, a text string, a pointer, or any other possible data type. Values can be obtained (e.g. via functions), stored (in variables) and manually set.

### Variable

A piece of data of specific type, with a specific name. The value of that data can be not only read but also changed dynamically—hence it's "variable". Variables can be defined at the top of the class (or, more specifically, at any place in the class outside of any code block), which makes them a field (available anywhere within the class), or within a code block (which makes them a local variable, available only within that code block). See: [Variables and data types](07_Variables_and_data_types.md).

---

🟢 [<<< BACK TO START](README.md)
