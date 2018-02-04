---
id: getting-started
title: Getting started
sidebar_label: Getting started
---

Let's take a look at how to use and add elements to the Tuxedo library. You can initialise the component as simply as 

```swift
let templateEngine = Tuxedo(globalVariables: ["variableName": variableValue])
or
let templateEngine = Tuxedo() //if there are no global variables set
```

This, by default, uses the elments defined by the Standard Library. It makes it easy for you to extend the language with new functions, data types or tags: just feed a different array or extend the ones provided by the Standard Library.

```swift
let templateEngine = Tuxedo(dataTypes: StandardLibrary.dataTypes,
							functions: StandardLibrary.functions,
							tags: StandardLibrary.tags,
							globalVariables: ["variableName": variableValue])
```


---

Once the Tuxedo instance has been created, it uses the registered elements to evaluate the expressions.
```swift
let result : String = templateEngine.evaluate("a template with {% tags %}")
or
let result : String = templateEngine.evaluate("a template with {{ variable }}", variables: ["variable": "tags"])
```

There's also a way to read templates from file:
```swift
let result : String = templateEngine.evaluate(template: "index.template", variables: ["name": "Tuxedo"])
```

Each of these methods read the input, replace the evaluated value of the recognised tags, and returns the output after the replacement.

In order to try out these features, the author created a [Playground project](https://github.com/tevelee/Tuxedo/tree/master/Tuxedo.playground) in the repository, which you can play with after you [clone the repository](xcode://clone?repo=https%3A%2F%2Fgithub.com%2Ftevelee%2FTuxedo).

--- 

Let's take a look at a few examples:

```swift
Tuxedo().evaluate("{% if greeting %}Hello{% else %}Bye{% endif %} {{ name }}!", variables: ["greeting": false, "name": "John"]) // Bye John!
```

```swift
Tuxedo().evaluate("{% for i in [1,2,3] %}{{i * 2}}{% if i is not last %}, {% endif %}{% endfor %}") // 2, 4, 6
```

```swift
Tuxedo().evaluate("{% macro duplicate(value) %}value * 2{% endmacro %}{{ duplicate(4) }}") // 8
```
