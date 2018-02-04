---
id: variables
title: Variables
---

A variable - as in regular programming languages - represents a named and stored instance of a given data type. 

There are two way to deal with variables in Tuxedo: 
- Feed them from the outside (caller side)
- Define them inside the expressions

### Providing variables from the outside

The way to inject them into the system, is the following. 
They can either be global variables (injected into every single expression that is processed with the given Tuxedo instance), or local variables, that are specific to certain expressions. See the examples:
```swift
let templateEngine = Tuxedo(globalVariables: ["variableName": variableValue]) // global
let result : String = templateEngine.evaluate("Hello {{ name }}!", variables: ["name": "John"]) // local
```

The dictionary must have string keys. As for the values, they need to be instances of the supported data types. 
The interpreter won't crash when it finds unrecognised values, it just won't process them, and leave the surrounding expressions unprocessed.

*One important note: since numeric types are represented with Swift doubles, any integers within the variables dictionary will be automatically converted to doubles.*

### Variables inside expressions

There is a simple way to define variables using the `set` tag:
```swift
templateEngine.evaluate("{% set name = 'John' %}")
```
It allows setting every kind of instance out of the supported data types, even process expressions and use previously declared variables:
```swift
templateEngine.evaluate("{% set result = 2 * value %}")
```

And you can use them later in other expressions, such as `print`, `set`, `if`, `for`, and so on:
```swift
templateEngine.evaluate("{{ name }}") // print
templateEngine.evaluate("{% if name == 'John' %}Hi John{% endif %}")
```

It's worth noting that `for` and `macro` tags create local variables to use when processing their bodies:
```swift
templateEngine.evaluate("{% macro concat(a, b) %}a + b{% endmacro %}")
templateEngine.evaluate("{% for i in 1 ... 5 %} {{ i * 2 }} {% endfor %}")
```