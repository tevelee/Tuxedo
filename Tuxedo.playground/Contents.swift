//: Playground - noun: a place where people can play

import Tuxedo

let templateEngine = Tuxedo()
templateEngine.evaluate("{% if 1 < 2 %}Hello{% endif %}")
