---
id: reference
title: API reference
---

## Elements

There are four fundamentally different types of data that Tuxedo framework can work with: (in the order of abstraction)
- [**Data types**](data-types.html) are the lowest level of abstraction, they represent the most basic type of data units.
- [**Variables**](variables.html) are named representation of the data type instances (values). They are also stored by the framework
- [**Functions**](functions.html) are any kind of patterns that work on those data types and variables. These include operators, regular parameterised functions, and any custom patterns that contain data types or variables.
- [**Tags**](tags.html) are global patterns that work with data types, variables, and functions as well. These are usually higher level statements, like conditions, loops, comments, macros, and blocks.

There is a documentation section dedicated to each of these elements.

## Usage

Let's take a look at how to add these elements to the Tuxedo library.

```swift
let templateEngine = Tuxedo(dataTypes: StandardLibrary.dataTypes,
							functions: StandardLibrary.functions,
							tags: StandardLibrary.tags,
							globalVariables: ["variableName": variableValue])
```

or, in short 
```swift
let templateEngine = Tuxedo(globalVariables: ["variableName": variableValue])
or
let templateEngine = Tuxedo() //if there are no variables set
```

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

## Further reading

### Adding new elements

The frameworks provides a wide variety of combinations, but in case of any special needs, it's really easy to add new elements. 
The framlibrary provides an intuitive way to add new elements.
Take a look at the [extending Tuxedo](extending-tuxedo.html) section to learn how to do that.

### Inspecting details

It's worth mentioning, that Tuxedo was built on top of the [Eval](https://github.com/tevelee/Eval) framework, which provides the technical foundation for this project. All Tuxedo does, it that it defines a set of data types, functions, and tags (as its standard library), and leaves the execution to the [Eval](https://github.com/tevelee/Eval) framework to do the heavy lifting.
It's a really generic interpreter, capable of doing all sorts of interpretation. In fact, Tuxedo started as an example app of the [Eval](https://github.com/tevelee/Eval) project, but turned out to be an awesome library on its own.

Long story short, if you're interested in the implementation details, there's a document named "[How does it work](how-does-it-work.html)" with all the details, I encourage everyone to check it out.
