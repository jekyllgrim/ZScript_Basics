# ZScript Basics: A Guide for Non-Programmers (from a non-programmer)

This guide is a beginner-friendly introduction to ZScript, a primary coding language used to code gameplay, UI and menus in GZDoom source port.

## Important notes

1. This document was written by a person who learned to use ZScript without any prior programming experience. I strive to use the correct terminology and not dumb things down but I also may purposefully overexplain certain things or initially present them in a simplified manner for the sake of beginner-friendliness.
2. While all code examples in the guide are made to be runnable, it's *not* recommended to use them as is: many of them are purposefully inefficient, and the guide tends to iterate over them, improving various aspects while explaining new techniques. Examples are meant to be just that: examples—not ready-made solutions.
3. This document is a guide, not a wiki. As such, it's designed to be read from beginning to end. Chapters are not self-contained and often rely on information explained earlier in the guide, so it's not recommended to skip anything.

## 🔶 CHOOSE  YOUR PATH 🔶

* If you **do NOT have prior DECORATE experience** and want to learn ZScript from scratch, start here: 🔵 [>> Where to start](Where_to_start.md).

* If you **DO have prior DECORATE** experience and are considering switching to ZScript, start here: 🔵 [>> Why ZScript?](Why_ZScript.md)

## Contents

1. [Where to start](Where_to_start.md)
2. [Defining ZScript classes](Defining_ZScript_classes.md)
3. [Why ZScript?](Why_ZScript.md)
4. [Classes instead of actors](Classes_instead_of_actors.md)
5. [Anonymous functions](Anonymous_functions.md)
6. [Variables and data types](Variables_and_data_types.md)
   1. [Overview](Variables_and_data_types.md#overview)
       - [Class-scope variables aka fields](Variables_and_data_types.md#class-scope-variables-aka-fields)
       - [Local variables](Variables_and_data_types.md#local-variables)
   2. [Turning variables into actor properties](Variables_and_data_types.md#turning-variables-into-actor-properties)
   3. [Access modifiers](Variables_and_data_types.md#access-modifiers)
   4. [Accessing variables from weapon states](Variables_and_data_types.md#accessing-variables-from-weapon-states)
   5. [Data types](Variables_and_data_types.md#data-types)
7. [Pointers and casting](Pointers_and_casting.md)
   1. [Basic pointers](Pointers_and_casting.md#basic-pointers)
   2. [Using pointers in ZScript](Pointers_and_casting.md#using-pointers-in-zscript)
   3. [Casting and custom pointers](Pointers_and_casting.md#casting-and-custom-pointers)
   4. [Type casting](Pointers_and_casting.md#type-casting)
8. [Custom functions and function types](Custom_functions.md)
   1. [Defining custom functions](Custom_functions.md#defining-custom-functions)
       - [Non-void functions and return values](Custom_functions.md#non-void-functions-and-return-values)
   2. [Action functions](Custom_functions.md#action-functions)
   3. [Static functions](Custom_functions.md#static-functions)
   4. [Virtual functions](Custom_functions.md#virtual-functions)
9. [Virtual Functions](Virtual_functions.md)
   1. [Overview](Virtual_functions.md#overview)
   2. [ZScript Virtual Functions](Virtual_functions.md#zscript-virtual-functions)
   3. [Common ZScript virtual functions](Virtual_functions.md#common-zscript-virtual-functions)
10. [Event Handlers](Event_Handlers.md)
11. [Weapons, PSprite and overlays](Weapons.md) (WIP)
12. [Arrays](Arrays.md)
    1. [Static constant arrays](Arrays.md#static-constant-arrays)
    2. [Dynamic arrays](Arrays.md#dynamic-arrays)
    3. [Dynamic array methods](Arrays.md#dynamic-array-methods)
    4. [Fixed-size arrays](Arrays.md#fixed-size-arrays)
13. Constants and enums (TBA)
14. [Flow Control](Flow_Control.md)
    1. [Operators and operands](Flow_Control.md#operators-and-operands)
        * [Arithmetic operators](Flow_Control.md#arithmetic-operators)
            + [Note on placement of increment/decrement operators](Flow_Control.md#Note-on-placement-of-increment/decrement-operators)
        * [Assignment operators](Flow_Control.md#assignment-operators)
        * [Relational operators](Flow_Control.md#relational-operators)
        * [Logical operators](Flow_Control.md#logical-operators)
        * [Bitwise operators](Flow_Control.md#bitwise-operators)
        * [Miscellaneous operators](Flow_Control.md#miscellaneous-operators)
    2. [Statements](Flow_Control.md#statements)
        * [Conditional blocks](Flow_Control.md#conditional-blocks)
        * [Loop control](Flow_Control.md#loop-control)
        * [Return and return values](Flow_Control.md#return-and-return-values)
        * [Switch](Flow_Control.md#switch)
    3. [State control](Flow_Control.md#state-control)
        * [stop](Flow_Control.md#stop)
        * [loop](Flow_Control.md#loop)
        * [wait](Flow_Control.md#wait)
        * [goto](Flow_Control.md#goto)
        * [fail](Flow_Control.md#fail)
        * [Fall-through (no operator)](Flow_Control.md#Fall-through-(no-operator))
        * [State jumps](Flow_Control.md#State-jumps)
15. [Best Practices and Rules of Thumb](Best_Practices.md)
    1. [Using a consistent indentation style](Best_Practices.md#using-a-consistent-indentation-style)
    2. [Using #include](Best_Practices.md#using--include)
    3. [PK3 instead of WAD and folders instead of archives](Best_Practices.md#pk3-instead-of-wad-and-folders-instead-of-archives)
    4. [Using a consistent naming convention for your classes](Best_Practices.md#using-a-consistent-naming-convention-for-your-classes)
    5. [Using GitHub](Best_Practices.md#using-github)
