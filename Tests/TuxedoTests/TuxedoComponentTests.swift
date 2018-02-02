@testable import Tuxedo
import XCTest

class TuxedoComponentTests: XCTestCase {
    func testComplexExample() {
        XCTAssertEqual(Tuxedo().evaluate(
"""
{% if greet %}Hello{% else %}Bye{% endif %} {{ name }}!
{% set works = true %}
{% for i in [1,3,2].sort.reverse %}{{ i }}, {% endfor %}go!

This template engine {% if !works %}does not {% endif %}work{% if works %}s{% endif %}!
""", variables: ["greet": true, "name": "Laszlo"]),
"""
Hello Laszlo!

3, 2, 1, go!

This template engine works!
""")
    }
}
