@testable import Tuxedo
import XCTest

class TuxedoUnitTests: XCTestCase {
    // MARK: Statements

    func testIfElseStatement() {
        XCTAssertEqual(Tuxedo().evaluate("{% if x in [1,2,3] %}Hello{% else %}Bye{% endif %} {{ name }}!", variables: ["x": 2, "name": "Teve"]), "Hello Teve!")
    }

    func testIfStatement() {
        XCTAssertEqual(Tuxedo().evaluate("{% if true %}Hello{% endif %} {{ name }}!", variables: ["name": "Teve"]), "Hello Teve!")
    }

    func testEmbeddedIfStatement() {
        XCTAssertEqual(Tuxedo().evaluate("Result: {% if x > 1 %}{% if x < 5 %}1<x<5{% endif %}{% endif %}", variables: ["x": 2]), "Result: 1<x<5")

        XCTAssertEqual(Tuxedo().evaluate("Result: {% if x > 1 %}{% if x < 5 %}1<x<5{% endif %}{% else %}x<=1{% endif %}", variables: ["x": 2]), "Result: 1<x<5")
        XCTAssertEqual(Tuxedo().evaluate("Result: {% if x >= 5 %}x>=5{% else %}{% if x > 1 %}1<x<5{% endif %}{% endif %}", variables: ["x": 2]), "Result: 1<x<5")

        XCTAssertEqual(Tuxedo().evaluate("Result: {% if x > 1 %}{% if x < 5 %}1<x<5{% else %}x>=5{% endif %}{% else %}x<=1{% endif %}", variables: ["x": 2]), "Result: 1<x<5")
        XCTAssertEqual(Tuxedo().evaluate("Result: {% if x >= 5 %}x>=5{% else %}{% if x > 1 %}1<x<5{% else %}x<=1{% endif %}{% endif %}", variables: ["x": 2]), "Result: 1<x<5")
    }

    func testPrintStatement() {
        XCTAssertEqual(Tuxedo().evaluate("{{ x }}", variables: ["x": "Yo"]), "Yo")
        XCTAssertEqual(Tuxedo().evaluate("{{ x + 1 }}", variables: ["x": 5]), "6")
    }

    func testSetStatement() {
        let template = Tuxedo()
        _ = template.evaluate("{% set x = 4.0 %}")
        XCTAssertEqual(template.evaluate("{{ x }}"), "4")
    }

    func testSetWithBodyStatement() {
        let template = Tuxedo()
        _ = template.evaluate("{% set x %}this{% endset %}")
        XCTAssertEqual(template.evaluate("Check {{ x }} out"), "Check this out")
    }

    func testForInStatement() {
        XCTAssertEqual(Tuxedo().evaluate("{% for i in [1,2,3] %}a{% endfor %}"), "aaa")
        XCTAssertEqual(Tuxedo().evaluate("{% for i in x %}{{i*2}} {% endfor %}", variables: ["x": [1, 2, 3]]), "2 4 6 ")
        XCTAssertEqual(Tuxedo().evaluate("{% for i in [1,2,3] %}{{i * 2}} {% endfor %}"), "2 4 6 ")
        XCTAssertEqual(Tuxedo().evaluate("{% for i in [1,2,3] %}{% if i is not first %}, {% endif %}{{i * 2}}{% endfor %}"), "2, 4, 6")
        XCTAssertEqual(Tuxedo().evaluate("{% for i in [1,2,3] %}{{i * 2}}{% if i is not last %}, {% endif %}{% endfor %}"), "2, 4, 6")
        XCTAssertEqual(Tuxedo().evaluate("{% for i in [1,2,3] %}{% if i is first %}^{% endif %}{{i}}{% if i is last %}${% endif %}{% endfor %}"), "^123$")
    }

    func testCommentStatement() {
        XCTAssertEqual(Tuxedo().evaluate("Personal {# random comment #}Computer"), "Personal Computer")
    }

    func testMacroStatement() {
        XCTAssertEqual(Tuxedo().evaluate("{% macro double(value) %}value * 2{% endmacro %}{{ double(4) }}"), "8")
        XCTAssertEqual(Tuxedo().evaluate("{% macro concat(a, b) %}a + b{% endmacro %}{{ concat('Hello ', 'World!') }}"), "Hello World!")
    }

    func testBlockStatement() {
        XCTAssertEqual(Tuxedo().evaluate("Title: {% block title1 %}Original{% endblock %}."), "Title: Original.")
        XCTAssertEqual(Tuxedo().evaluate("Title: {% block title2 %}Original{% endblock %}.{% block title2 %}Other{% endblock %}"), "Title: Other.")
        XCTAssertEqual(Tuxedo().evaluate("Title: {% block title3 %}Original{% endblock %}.{% block title3 %}{{ parent() }} 2{% endblock %}"), "Title: Original 2.")
        XCTAssertEqual(Tuxedo().evaluate("Title: {% block title4 %}Original{% endblock %}.{% block title4 %}{{ parent() }} 2{% endblock %}{% block title4 %}{{ parent() }}.1{% endblock %}"), "Title: Original 2.1.")
        XCTAssertEqual(Tuxedo().evaluate("{% block title5 %}Hello {{name}}{% endblock %}{% block title5 %}{{ parent() }}!{% endblock %}", variables: ["name": "George"]), "Hello George!")
        XCTAssertEqual(Tuxedo().evaluate("{% block title6 %}Hello {{name}}{% endblock %}{% block title6 %}{{ parent(name='Laszlo') }}!{% endblock %}", variables: ["name": "Geroge"]), "Hello Laszlo!")
    }

    func testSpaceElimination() {
        XCTAssertEqual(Tuxedo().evaluate("asd   {-}   jkl"), "asdjkl")
        XCTAssertEqual(Tuxedo().evaluate("{-}   jkl"), "jkl")
        XCTAssertEqual(Tuxedo().evaluate("asd   {-}"), "asd")

        XCTAssertEqual(Tuxedo().evaluate("asd   {-}{% if true %}   Hello   {% endif %}   "), "asd   Hello      ")
        XCTAssertEqual(Tuxedo().evaluate("asd   {-}{% if true %}{-}   Hello   {% endif %}   "), "asdHello      ")
        XCTAssertEqual(Tuxedo().evaluate("asd   {% if true %}   Hello {-}  {% endif %}   "), "asd      Hello   ")
    }

    // MARK: Data types

    func testString() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'hello' }}"), "hello")
        XCTAssertEqual(Tuxedo().evaluate("{{ String(1) }}"), "1")
    }

    func testBoolean() {
        XCTAssertEqual(Tuxedo().evaluate("{{ true }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ false }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ 1 < 2 }}"), "true")
    }

    func testDate() {
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,12,13).format('dd/MM/yy') }}"), "13/12/18")
    }

    func testInteger() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 1 }}"), "1")
    }

    func testDouble() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 2.5 }}"), "2.5")
    }

    func testDictionary() {
        XCTAssertEqual(Tuxedo().evaluate("{{ {'a': 1, 'b': 2} }}"), "[a: 1, b: 2]")
        XCTAssertEqual(Tuxedo().evaluate("{{ {} }}"), "[]")
    }

    func testArray() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [1,2,3] }}"), "1,2,3")
        XCTAssertEqual(Tuxedo().evaluate("{{ [] }}"), "")
    }

    func testEmpty() {
        XCTAssertEqual(Tuxedo().evaluate("{{ null }}"), "null")
        XCTAssertEqual(Tuxedo().evaluate("{{ nil }}"), "null")
        XCTAssertEqual(Tuxedo().evaluate("{{ [].0 }}"), "null")
    }

    // MARK: Functions and operators

    func testParentheses() {
        XCTAssertEqual(Tuxedo().evaluate("{{ ( 1 + 2 ) * 3 }}"), "9")
        XCTAssertEqual(Tuxedo().evaluate("{{ ( (9/3) + 2 ) * 3 }}"), "15")
        XCTAssertEqual(Tuxedo().evaluate("{{ (((2))) }}"), "2")
    }

    func testTernary() {
        XCTAssertEqual(Tuxedo().evaluate("{{ true ? 1 : 2 }}"), "1")
        XCTAssertEqual(Tuxedo().evaluate("{{ false ? 1 : 2 }}"), "2")
    }

    func testRange() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 1...3 }}"), "1,2,3")
        XCTAssertEqual(Tuxedo().evaluate("{{ 'a'...'c' }}"), "a,b,c")
    }

    func testRangeBySteps() {
        XCTAssertEqual(Tuxedo().evaluate("{{ range(start=1, end=7, step=2) }}"), "1,3,5,7")
    }

    func testStartsWith() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'Hello' starts with 'H' }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 'Hello' starts with 'Hell' }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 'Hello' starts with 'Yo' }}"), "false")
    }

    func testEndsWith() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'Hello' ends with 'o' }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 'Hello' ends with 'ello' }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 'Hello' ends with 'Yo' }}"), "false")
    }

    func testContains() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'Partly' contains 'art' }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 'Hello' contains 'art' }}"), "false")
    }

    func testExists() {
        XCTAssertEqual(Tuxedo().evaluate("Hello {% if name exists %}{{ name }}{% else %}Anonymus{% endif %}!"), "Hello Anonymus!")
        XCTAssertEqual(Tuxedo().evaluate("Hello {% if name exists %}{{ name }}{% else %}Anonymus{% endif %}!", variables: ["name": "Teve"]), "Hello Teve!")
    }

    func testMatches() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'Partly' matches '[A-Z]art[a-z]{2}' }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 'Partly' matches '\\d+' }}"), "false")
    }

    func testConcat() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'This' + ' is ' + 'Sparta' }}"), "This is Sparta")
    }

    func testAddition() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 1 + 2 }}"), "3")
        XCTAssertEqual(Tuxedo().evaluate("{{ 1 + 2 + 3 }}"), "6")
    }

    func testSubstraction() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 5 - 2 }}"), "3")
        XCTAssertEqual(Tuxedo().evaluate("{{ 5 - 2 - 3 }}"), "0")
    }

    func testMultiplication() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 5 * 2 }}"), "10")
        XCTAssertEqual(Tuxedo().evaluate("{{ 5 * 2 * 3 }}"), "30")
    }

    func testDivision() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 5 / 5 }}"), "1")
        XCTAssertEqual(Tuxedo().evaluate("{{ 144 / 12 / 4 }}"), "3")
    }

    func testPow() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 ** 5 }}"), "32")
    }

    func testNumericPrecedence() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 4 + 2 * 3 }}"), "10")
        XCTAssertEqual(Tuxedo().evaluate("{{ 4 - 2 * 3 }}"), "-2")
        XCTAssertEqual(Tuxedo().evaluate("{{ 4 * 3 / 2 + 2 - 8 }}"), "0")
    }

    func testLessThan() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 < 3 }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 3 < 2 }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 < 2 }}"), "false")
    }

    func testLessThanOrEqual() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 <= 3 }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 3 <= 2 }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 <= 2 }}"), "true")
    }

    func testGreaterThan() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 > 3 }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ 3 > 2 }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 > 2 }}"), "false")
    }

    func testGreaterThanOrEqual() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 >= 3 }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ 3 >= 2 }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 >= 2 }}"), "true")
    }

    func testEarlier() {
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) < Date(2018,1,2) }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) < Date(2015,1,1) }}"), "false")
    }

    func testEarlierOrSame() {
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) <= Date(2018,1,2) }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) <= Date(2018,1,1) }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) <= Date(2015,1,1) }}"), "false")
    }

    func testLater() {
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,4) > Date(2018,1,2) }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) > Date(2018,1,2) }}"), "false")
    }

    func testLaterOrSame() {
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,4) >= Date(2018,1,2) }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) >= Date(2018,1,2) }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) >= Date(2018,1,1) }}"), "true")
    }

    func testEquals() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 == 3 }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 == 2 }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) == Date(2018,1,2) }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) == Date(2018,1,1) }}"), "true")
    }

    func testNotEquals() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 != 2 }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 != 3 }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) != Date(2018,1,1) }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ Date(2018,1,1) != Date(2018,1,2) }}"), "true")
    }

    func testInNumericArray() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 2 in [1,2,3] }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 5 in [1,2,3] }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ 5 not in [1,2,3] }}"), "true")
    }

    func testInStringArray() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'a' in ['a', 'b', 'c'] }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 'z' in ['a', 'b', 'c'] }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ 'a' not in ['a', 'b', 'c'] }}"), "false")
    }

    func testIncrement() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 2++ }}"), "3")
        XCTAssertEqual(Tuxedo().evaluate("{{ -1++ }}"), "0")
    }

    func testDecrement() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 7-- }}"), "6")
        XCTAssertEqual(Tuxedo().evaluate("{{ -7-- }}"), "-8")
    }

    func testNegation() {
        XCTAssertEqual(Tuxedo().evaluate("{{ not true }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ not false }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ !true }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ !false }}"), "true")
    }

    func testAnd() {
        XCTAssertEqual(Tuxedo().evaluate("{{ true and true }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ false and false }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ true and false }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ false and true }}"), "false")
    }

    func testOr() {
        XCTAssertEqual(Tuxedo().evaluate("{{ true or true }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ false or false }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ true or false }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ false or true }}"), "true")
    }

    func testIsEven() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 8 is even }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ 1 is even }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ -1 is even }}"), "false")
    }

    func testIsOdd() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 8 is odd }}"), "false")
        XCTAssertEqual(Tuxedo().evaluate("{{ 1 is odd }}"), "true")
        XCTAssertEqual(Tuxedo().evaluate("{{ -1 is odd }}"), "true")
    }

    func testMax() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [5,3,7,1].max }}"), "7")
        XCTAssertEqual(Tuxedo().evaluate("{{ max(5,3,7,1) }}"), "7")
        XCTAssertEqual(Tuxedo().evaluate("{{ [-5,-3,-7,-1].max }}"), "-1")
        XCTAssertEqual(Tuxedo().evaluate("{{ max(-5,-3,-7,-1) }}"), "-1")
    }

    func testMin() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [5,3,7,1].min }}"), "1")
        XCTAssertEqual(Tuxedo().evaluate("{{ min(5,3,7,1) }}"), "1")
        XCTAssertEqual(Tuxedo().evaluate("{{ [-5,-3,-7,-1].min }}"), "-7")
        XCTAssertEqual(Tuxedo().evaluate("{{ min(-5,-3,-7,-1) }}"), "-7")
    }

    func testCount() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [5,3,7,1].count }}"), "4")
        XCTAssertEqual(Tuxedo().evaluate("{{ [].count }}"), "0")
        XCTAssertEqual(Tuxedo().evaluate("{{ {'a': 5, 'b': 2}.count }}"), "2")
        XCTAssertEqual(Tuxedo().evaluate("{{ {}.count }}"), "0")
    }

    func testAverage() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [1,2,3,4].avg }}"), "2.5")
        XCTAssertEqual(Tuxedo().evaluate("{{ [2,2].avg }}"), "2")
        XCTAssertEqual(Tuxedo().evaluate("{{ avg(1,2,3,4) }}"), "2.5")
        XCTAssertEqual(Tuxedo().evaluate("{{ avg(2,2) }}"), "2")
    }

    func testSum() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [1,2,3,4].sum }}"), "10")
        XCTAssertEqual(Tuxedo().evaluate("{{ sum(1,2,3,4) }}"), "10")
    }

    func testSqrt() {
        XCTAssertEqual(Tuxedo().evaluate("{{ sqrt(225) }}"), "15")
        XCTAssertEqual(Tuxedo().evaluate("{{ sqrt(4) }}"), "2")
    }

    func testFirst() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [1,2,3].first }}"), "1")
        XCTAssertEqual(Tuxedo().evaluate("{{ [].first }}"), "null")
    }

    func testLast() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [1,2,3].last }}"), "3")
        XCTAssertEqual(Tuxedo().evaluate("{{ [].last }}"), "null")
    }

    func testDefault() {
        XCTAssertEqual(Tuxedo().evaluate("{{ null.default('fallback') }}", variables: ["array": []]), "fallback")
        XCTAssertEqual(Tuxedo().evaluate("{{ array.last.default('none') }}", variables: ["array": [1]]), "1")
        XCTAssertEqual(Tuxedo().evaluate("{{ array.last.default('none') }}", variables: ["array": []]), "none")
        XCTAssertEqual(Tuxedo().evaluate("{{ array.last.default(2) }}", variables: ["array": []]), "2")
    }

    func testJoin() {
        XCTAssertEqual(Tuxedo().evaluate("{{ ['1','2','3'].join('-') }}"), "1-2-3")
        XCTAssertEqual(Tuxedo().evaluate("{{ [].join('-') }}"), "")
    }

    func testSplit() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'a,b,c'.split(',') }}"), "a,b,c")
        XCTAssertEqual(Tuxedo().evaluate("{{ 'a'.split('-') }}"), "a")
    }

    func testMerge() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [1,2,3].merge([4,5]) }}"), "1,2,3,4,5")
        XCTAssertEqual(Tuxedo().evaluate("{{ [].merge([1]) }}"), "1")
    }

    func testArraySubscript() {
        XCTAssertEqual(Tuxedo().evaluate("{{ array.1 }}", variables: ["array": [1, 2, 3]]), "2")
        XCTAssertEqual(Tuxedo().evaluate("{{ [1,2,3].1 }}"), "2")
        XCTAssertEqual(Tuxedo().evaluate("{{ ['a', 'b', 'c'].1 }}"), "b")
    }

    func testArrayMap() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [1,2,3].map { i => i * 2 } }}"), "2,4,6")
    }

    func testArrayFilter() {
        XCTAssertEqual(Tuxedo().evaluate("{{ [1,2,3].filter { i => i % 2 == 1 } }}"), "1,3")
    }

    func testDictionaryFilter() {
        XCTAssertEqual(Tuxedo().evaluate("{{ {'a': 1, 'b': 2}.filter { k,v => k == 'a' } }}"), "[a: 1]")
    }

    func testDictionarySubscript() {
        XCTAssertEqual(Tuxedo().evaluate("{{ dict.b }}", variables: ["dict": ["a": 1, "b": 2]]), "2")
        XCTAssertEqual(Tuxedo().evaluate("{{ {'a': 1, 'b': 2}.b }}"), "2")
    }

    func testDictionaryKeys() {
        XCTAssertEqual(Tuxedo().evaluate("{{ {'a': 1, 'b': 2}.keys }}"), "a,b")
    }

    func testDictionaryValues() {
        XCTAssertEqual(Tuxedo().evaluate("{{ {'a': 1, 'b': 2}.values }}"), "1,2")
    }

    func testAbsolute() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 1.abs }}"), "1")
        XCTAssertEqual(Tuxedo().evaluate("{{ -1.abs }}"), "1")
    }

    func testRound() {
        XCTAssertEqual(Tuxedo().evaluate("{{ round(2.5) }}"), "3")
        XCTAssertEqual(Tuxedo().evaluate("{{ round(1.2) }}"), "1")
    }

    func testTrim() {
        XCTAssertEqual(Tuxedo().evaluate("{{ '  a  '.trim }}"), "a")
    }

    func testEscape() {
        XCTAssertEqual(Tuxedo().evaluate("{{ ' ?&:/'.escape }}"), "&nbsp;?&amp;:/")
    }

    func testUrlEncode() {
        XCTAssertEqual(Tuxedo().evaluate("{{ ' ?&:/'.urlEncode }}"), "%20%3F%26%3A%2F")
    }

    func testUrlDecode() {
        XCTAssertEqual(Tuxedo().evaluate("{{ '%20%3F%26%3A%2F'.urlDecode }}"), " ?&:/")
    }

    func testNl2br() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'a\nb'.nl2br }}"), "a<br/>b")
    }

    func testLength() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'hello there'.length }}"), "11")
    }

    func testCapitalise() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'hello there'.capitalise }}"), "Hello There")
    }

    func testUpper() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'hello there'.upper }}"), "HELLO THERE")
    }

    func testLower() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'HELLO THERE'.lower }}"), "hello there")
    }

    func testUpperFirst() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'hello there'.upperFirst }}"), "Hello there")
    }

    func testLowerFirst() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'HELLO THERE'.lowerFirst }}"), "hELLO THERE")
    }

    func testUpperCapitalise() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'hello there'.capitalise.upperFirst }}"), "Hello There")
    }

    func testLowerCapitalise() {
        XCTAssertEqual(Tuxedo().evaluate("{{ 'HELLO THERE'.capitalise.lowerFirst }}"), "hello There")
    }

    // MARK: Whitespace truncation

    func testSpacelessTag() {
        XCTAssertEqual(Tuxedo().evaluate("{% spaceless %}   {% if true %}    Hello    {% endif %}    {% endspaceless %}"), "Hello")
    }

    // MARK: Template file

    func testTemplateFile() {
        let result = try! Tuxedo().evaluate(template: Bundle(for: type(of: self)).url(forResource: "template", withExtension: "txt")!, variables: ["name": "Laszlo"])
        XCTAssertEqual(result, "Hello Laszlo!")
    }

    func testTemplateWithImportFile() {
        let result = try! Tuxedo().evaluate(template: Bundle(for: type(of: self)).url(forResource: "import", withExtension: "txt")!, variables: ["name": "Laszlo"])
        XCTAssertEqual(result, "Hello Laszlo!\nBye!")
    }
}
