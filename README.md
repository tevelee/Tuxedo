# Tuxedo

[![Travis CI status](https://travis-ci.org/tevelee/Tuxedo.svg?branch=master)](https://travis-ci.org/tevelee/Tuxedo)
[![Framework version](https://img.shields.io/badge/Version-1.1.1-yellow.svg)]()
[![Swift version](https://img.shields.io/badge/Swift-4.2-orange.svg)]()
[![Code Test Coverage](https://codecov.io/gh/tevelee/Tuxedo/branch/master/graph/badge.svg)](https://codecov.io/gh/tevelee/Tuxedo)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20Linux-blue.svg)]()
[![Lincese](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://github.com/tevelee/Tuxedo/tree/master/LICENSE.txt)

##### Dependency Managers

[![CocoaPods compatible](https://img.shields.io/badge/CococaPods-Compatible-blue.svg)](http://cocoapods.org/pods/Tuxedo)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-Compatible-red.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)

---

- [👨🏻‍💻 About](#-about)
- [📈 Getting Started](#-getting-started)
- [🙋 Contribution](#-contribution)
- [👤 Author](#-author)
- [⚖️ License](#%EF%B8%8F-license)

## 👨🏻‍💻 About

**Tuxedo** is a template language for Swift. It allows you to separate the UI and rendering layer of your application from the business logic. Smart templates working with raw data allow the frontend to be handled and developed separately from other parts of the application, so processing, layouting and formatting your output can be defined in very simple template formats.

Why the name? It dresses up your static output with elegant dynamic templates, using control statements, and high level operators.

The project was built upon my lightweight interpreter framework, [Eval](https://github.com/tevelee/Eval), and served as an example application of what is possible using this evaluator. 

Soon, the template language example turned out to be a really useful project on its own, so I extracted it to live as a separate library and be used by as many projects as possible. I see the possibility of applications most valuable especially in **server-side Swift projects**, but there are a lot of other areas where template parsing fits well.

The project - though most of its featureset is already available - is still having its early days, there is a lot of work needed to be done around open-sourcing activities, such as CI, contribution guidelines and extensive documentation. At this stage, if you're interested in what is already possible using **Tuxedo**, I encourage you to [check out the unit tests](https://github.com/tevelee/Tuxedo/tree/master/Tests/TuxedoTests/TuxedoUnitTests.swift) and see the use-cases there until the documentation gets ready, or see some of the examples below. 
Please stay tuned for updates!

The inspiration was the excellent PHP template engine, [Twig](https://twig.symfony.com), and the fact that there is no existing, comprehensive-enough templating library available for the Swift language and platform.

## 👀 Getting Started

You can evaluate basic expressions ...

```swift
let result = Tuxedo().evaluate("Hello {{ name }}!", variables: ["name": "Tuxedo"]) // Hello Tuxedo!
```

... or even complex ones ...

```swift
let result = Tuxedo().evaluate("""
The results are: 
	{% for item in results.sort.reverse %}
		{% if item is not first %}, {% endif %}
		{% if item is last %} and {% endif %}
		{{ item * 2 }}
	{% endfor %}
""", variables: ["results": [3, 1, 2]]) // The results are: 6, 4 and 2
```

... define macros ...

```swift
let templateEngine = Tuxedo()
let _ = templateEngine.evaluate("{% macro concat(a, b) %}a + b{% endmacro %}")
let result = templateEngine.evaluate("{{ concat('Hello ', 'World!') }}") // Hello World!
```

... or blocks ...

```swift
let templateEngine = Tuxedo()
let result = templateEngine.evaluate("""
<html>
	<head>
		<title>
			{% block title %}Website{% endblock %}
		</title>
	</head>
	<body>
		{% block body %}{% endblock %}
	</body>
</html>
""")
```

... and override them later ...

```
{% block title %} {{ parent() }} - Subpage {% endblock %}
{% block body %} Content {% endblock %}
```

Tuxedo handles all kinds of expressions you can imagine. It works with numeric types, strings, booleans, dates, arrays and dictionaries. 

You can perform all sorts of operations with functions and operators, such as numeric and logical operations, string manupulation, date formatting, higher level array and dictionary operations, and so on.

It works with hard-coded string inputs and also template files written from disk.

## 🙋 Contribution

Anyone is more than welcomed to contribute to this great project! Just fire up an issue or pull request to get the conversation started!

## 👤 Author

I am Laszlo Teveli, software engineer, iOS evangelist. In my free time I like to work on my hobby projects and open sourcing them 😉

Feel free to reach out to me anytime via `tevelee [at] gmail [dot] com`, or `@tevelee` on Twitter.

## ⚖️ License

**Tuxedo** is available under the Apache 2.0 licensing rules. See the [LICENSE](https://github.com/tevelee/Tuxedo/tree/master/LICENSE.txt) file for more information.
