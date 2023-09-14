🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Arrays and linked lists](13_Arrays.md)

---

# Constants

## Overview

Constants are values that are similar to [variables](07_Variables_and_data_types.md) in the way they're defined, but are the opposite in principle: these values are—you guessed it—*constant*, i.e. it can't be changed.

The other features of constants are:

* Constants can be defined inside classes, like variables, but can also be defined outside of  classes, completely independently.

* All constants are static, meaning they're accessible at all times, everywhere in the code. If a constant is defined outside of a class, it can be accessed by its name. If defined within a class, it can be accessed by using the class name as a prefix.

Constants are defined as follows:

```csharp
//pseudocode:
const CONSTANTNAME = <value>;

//real code example:
const PK_TEXTSCALE = 1.2;
```

> *Note:* It's not a requirement, but it's somewhat common to write constant names in all caps.

## Constant data types

As you can see in the example definition above, constant declarations don't contain a [data type](07_Variables_and_data_types.md#data-types) in their definition (as opposed to variables). This is because a constant's data type is inferred from the provided value, and the possible types are limited to **integers, doubles** and **strings**.

As such, valid definitions for constants would look like this:

```csharp
// Defines an integer constant:
const MYINTEGERCONSTANT = 5;

// Defines a double constant:
const MYDOUBLECONSTANT = 1.5;

// Defines a string constant:
const MYSTRINGCONSTANT = "Foo";
```

## Defining constants

As mentioned, constants can be defined both inside classes and outside of them:

```csharp
const MYGLOBALVALUE = 1.2;
```

In this example `MYGLOBALVALUE` will be available everywhere and will be equal to using `1.2`. As you can imagine, in this case it's recommended to make the constant's name as unique and clear as possible to minimize the chances of constant name conflicts if your project is run alongside other mods or uses script libraries.

You can also do this:

```csharp
class ExampleClass : Actor
{
    const MYCONSTANT = 10;
}
```

Defined like this, `MYCONSTANT` can be accessed by all classes inheriting from `ExampleClass` direclty, or by any other class by using `ExampleClass.MYCONSTANT`.

### Operators

Constant values don't always have to be literal; they can also reference other constant values and contain certain expressions.

For example, one constant can be defined as an equal to another:

```csharp
const MYCONST1 = 15;
const MYCONST2 = MYCONST1; //also equals 15
```

In this example `MYCONST2` will also be equal 15, effectively becoming an alias for `MYCONST1`.

It works on strings too:

```csharp
const MYSTRCONST1 = "Foo";
const MYSTRCONST2 = MYSTRCONST1; //also equals "Foo"
```

If the constants in questions are numeric, they also support various operators. For example, you can use [arithmetic operators](A1_Flow_Control.md#arithmetic-operators):

```csharp
const CONST_INT1 = 5;
const CONST_INT2 = 10;
const CONST_DOUBLE = 0.5;

const MYCONST1 = CONST_INT1 + CONST_INT2; // 15
const MYCONST2 = CONST_INT1 - CONST_INT2; // -5
const MYCONST3 = CONST_INT1 / CONST_INT2; // 0
const MYCONST4 = CONST_INT1 * CONST_INT2; // 50
const MYCONST5 = CONST_INT1 + CONST_DOUBLE; // 5.5
const MYCONST6 = CONST_INT1 - CONST_DOUBLE; // 4.5
const MYCONST7 = CONST_INT1 / CONST_DOUBLE; // 10
const MYCONST8 = CONST_INT1 * CONST_DOUBLE; // 2.5
```

> *Note:* The results of these operationrs follow the same logic as everywhere else: an integer number divided by an integer number will produce an integer number as well, with its decimal part automatically truncated (hence 5 / 15 = 0, not 0.333...). To receive a decimal number, at least one of the values in the expression has to be a double.

Constant declarations also support [bitwise operators](A1_Flow_Control.md#bitwise-operators), which is useful if you're using constants as aliases for flags:

```csharp
const FLAG1 = 1;
const FLAG2 = 2;
const FLAG3 = 4;
const FLAG4 = 8;
const ALLFLAGS = FLAG1|FLAG2|FLAG3|FLAG4;
```

In this example the value of `ALLFLAGS` will combine the value of all the other flags with the help of the bitwise OR operator. It works the same way as combining function flags with the help of `|`.

## Enums

An `enum` (short for "enumeration") is a way to define multiple constants of the same type at once. Just like constants, they can be defined independently or inside a class. The syntax for enums looks like this:

```csharp
enum EnumName
{
    CONSTANT1 = value,
    CONSTANT2 = value,
    CONSTANT3 = value //Putting a comma after the last element is optional
}; //This semicolon is also optional
```

At first glance enums may appear similar to [static constant arrays](13_Arrays.md#static-constant-arrays) but they're different for multiple reasons:

* Static constant arrays can't be defined outside of classes.

* Static constant arrays support many more data types (such as `name`, `Class<Actor>` and such).

* When working with arrays, you need to use their names to work with their elements. Enum names, on the other hands, are not referenced at all and can be pretty much anything (as long as they don't coincide with the name of another enum).

In short, enums are just lists of constants, nothing more; they're not so much data containers but just a way to arrange data.

GZDoom defines a lot of its own enums, primarily used as lists of flags for functions. They can be found in gzdoom.pk3/zscript/constants.zs. For example, this enum defines flags used in `A_FireBullets`:

```csharp
// Flags for A_FireBullets
enum EFireBulletsFlags
{
    FBF_USEAMMO = 1,
    FBF_NORANDOM = 2,
    FBF_EXPLICITANGLE = 4,
    FBF_NOPITCH = 8,
    FBF_NOFLASH = 16,
    FBF_NORANDOMPUFFZ = 32,
    FBF_PUFFTARGET = 64,
    FBF_PUFFMASTER = 128,
    FBF_PUFFTRACER = 256,
};
```

Enums are also used to give names to weapon sprite layers or to sound channels. For example, [here](https://github.com/coelckers/gzdoom/blob/254da4b7699cc4d3abd964c9f4f0e2bf31f8bb20/wadsrc/static/zscript/engine/base.zs#L3) you can look find an enum that lists all sound channels *and* flags for the `A_StartSound` function.

## Application of constants

The use of constants is a matter of convenience; technically, you could just use the values directly, but there are many reasons why constants are preferable:

* If the same number is used in many places in the code (e.g. a sprite layer number in a weapon code) and then you realize you need to change that value, it's becomes much easier if that number is defined as a constant, because then you can just change it one place (the constant definition).

* A constant lets you give your static value a nice, sensible name. For example, you can give your sprite layers in a multi-layered weapon descriptive names, such as `PSP_LEFTGUN` instead of `5`. This is especially important in case of bitfields and function flags, since using descriptive names, such as `FBF_USEAMMO` and `FBF_NOFLASH` is much better than just using numbers.

---

🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Arrays and linked lists](13_Arrays.md)
