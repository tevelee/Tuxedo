import Foundation

public extension DateFormatter {
    convenience init(with format: String) {
        self.init()
        self.calendar = Calendar(identifier: .gregorian)
        self.dateFormat = format
    }
}

extension Character: Strideable {
    public typealias Stride = Int

    var value: UInt32 {
        return unicodeScalars.first?.value ?? 0
    }

    public func distance(to other: Character) -> Int {
        return Int(other.value) - Int(self.value)
    }

    public func advanced(by offset: Int) -> Character {
        let advancedValue = offset + Int(self.value)
        guard let advancedScalar = UnicodeScalar(advancedValue) else {
            fatalError("\(String(advancedValue, radix: 16)) does not represent a valid unicode scalar value.")
        }
        return Character(advancedScalar)
    }
}

extension String {
    static let enc: [Character: String] =
        [" ": "&emsp;", " ": "&ensp;", " ": "&nbsp;", " ": "&thinsp;", "‾": "&oline;", "–": "&ndash;", "—": "&mdash;",
         "¡": "&iexcl;", "¿": "&iquest;", "…": "&hellip;", "·": "&middot;", "'": "&apos;", "‘": "&lsquo;", "’": "&rsquo;",
         "‚": "&sbquo;", "‹": "&lsaquo;", "›": "&rsaquo;", "‎": "&lrm;", "‏": "&rlm;", "­": "&shy;", "‍": "&zwj;", "‌": "&zwnj;",
         "\"": "&quot;", "“": "&ldquo;", "”": "&rdquo;", "„": "&bdquo;", "«": "&laquo;", "»": "&raquo;", "⌈": "&lceil;",
         "⌉": "&rceil;", "⌊": "&lfloor;", "⌋": "&rfloor;", "〈": "&lang;", "〉": "&rang;", "§": "&sect;", "¶": "&para;",
         "&": "&amp;", "‰": "&permil;", "†": "&dagger;", "‡": "&Dagger;", "•": "&bull;", "′": "&prime;", "″": "&Prime;",
         "´": "&acute;", "˜": "&tilde;", "¯": "&macr;", "¨": "&uml;", "¸": "&cedil;", "ˆ": "&circ;", "°": "&deg;",
         "©": "&copy;", "®": "&reg;", "℘": "&weierp;", "←": "&larr;", "→": "&rarr;", "↑": "&uarr;", "↓": "&darr;",
         "↔": "&harr;", "↵": "&crarr;", "⇐": "&lArr;", "⇑": "&uArr;", "⇒": "&rArr;", "⇓": "&dArr;", "⇔": "&hArr;",
         "∀": "&forall;", "∂": "&part;", "∃": "&exist;", "∅": "&empty;", "∇": "&nabla;", "∈": "&isin;", "∉": "&notin;",
         "∋": "&ni;", "∏": "&prod;", "∑": "&sum;", "±": "&plusmn;", "÷": "&divide;", "×": "&times;", "<": "&lt;", "≠": "&ne;",
         ">": "&gt;", "¬": "&not;", "¦": "&brvbar;", "−": "&minus;", "⁄": "&frasl;", "∗": "&lowast;", "√": "&radic;",
         "∝": "&prop;", "∞": "&infin;", "∠": "&ang;", "∧": "&and;", "∨": "&or;", "∩": "&cap;", "∪": "&cup;", "∫": "&int;",
         "∴": "&there4;", "∼": "&sim;", "≅": "&cong;", "≈": "&asymp;", "≡": "&equiv;", "≤": "&le;", "≥": "&ge;", "⊄": "&nsub;",
         "⊂": "&sub;", "⊃": "&sup;", "⊆": "&sube;", "⊇": "&supe;", "⊕": "&oplus;", "⊗": "&otimes;", "⊥": "&perp;",
         "⋅": "&sdot;", "◊": "&loz;", "♠": "&spades;", "♣": "&clubs;", "♥": "&hearts;", "♦": "&diams;", "¤": "&curren;",
         "¢": "&cent;", "£": "&pound;", "¥": "&yen;", "€": "&euro;", "¹": "&sup1;", "½": "&frac12;", "¼": "&frac14;",
         "²": "&sup2;", "³": "&sup3;", "¾": "&frac34;", "á": "&aacute;", "Á": "&Aacute;", "â": "&acirc;", "Â": "&Acirc;",
         "à": "&agrave;", "À": "&Agrave;", "å": "&aring;", "Å": "&Aring;", "ã": "&atilde;", "Ã": "&Atilde;", "ä": "&auml;",
         "Ä": "&Auml;", "ª": "&ordf;", "æ": "&aelig;", "Æ": "&AElig;", "ç": "&ccedil;", "Ç": "&Ccedil;", "ð": "&eth;",
         "Ð": "&ETH;", "é": "&eacute;", "É": "&Eacute;", "ê": "&ecirc;", "Ê": "&Ecirc;", "è": "&egrave;", "È": "&Egrave;",
         "ë": "&euml;", "Ë": "&Euml;", "ƒ": "&fnof;", "í": "&iacute;", "Í": "&Iacute;", "î": "&icirc;", "Î": "&Icirc;",
         "ì": "&igrave;", "Ì": "&Igrave;", "ℑ": "&image;", "ï": "&iuml;", "Ï": "&Iuml;", "ñ": "&ntilde;", "Ñ": "&Ntilde;",
         "ó": "&oacute;", "Ó": "&Oacute;", "ô": "&ocirc;", "Ô": "&Ocirc;", "ò": "&ograve;", "Ò": "&Ograve;", "º": "&ordm;",
         "ø": "&oslash;", "Ø": "&Oslash;", "õ": "&otilde;", "Õ": "&Otilde;", "ö": "&ouml;", "Ö": "&Ouml;", "œ": "&oelig;", "Œ": "&OElig;", "ℜ": "&real;", "š": "&scaron;", "Š": "&Scaron;", "ß": "&szlig;", "™": "&trade;", "ú": "&uacute;",
         "Ú": "&Uacute;", "û": "&ucirc;", "Û": "&Ucirc;", "ù": "&ugrave;", "Ù": "&Ugrave;", "ü": "&uuml;", "Ü": "&Uuml;",
         "ý": "&yacute;", "Ý": "&Yacute;", "ÿ": "&yuml;", "Ÿ": "&Yuml;", "þ": "&thorn;", "Þ": "&THORN;", "α": "&alpha;",
         "Α": "&Alpha;", "β": "&beta;", "Β": "&Beta;", "γ": "&gamma;", "Γ": "&Gamma;", "δ": "&delta;", "Δ": "&Delta;",
         "ε": "&epsilon;", "Ε": "&Epsilon;", "ζ": "&zeta;", "Ζ": "&Zeta;", "η": "&eta;", "Η": "&Eta;", "θ": "&theta;",
         "Θ": "&Theta;", "ϑ": "&thetasym;", "ι": "&iota;", "Ι": "&Iota;", "κ": "&kappa;", "Κ": "&Kappa;", "λ": "&lambda;",
         "Λ": "&Lambda;", "µ": "&micro;", "μ": "&mu;", "Μ": "&Mu;", "ν": "&nu;", "Ν": "&Nu;", "ξ": "&xi;", "Ξ": "&Xi;",
         "ο": "&omicron;", "Ο": "&Omicron;", "π": "&pi;", "Π": "&Pi;", "ϖ": "&piv;", "ρ": "&rho;", "Ρ": "&Rho;",
         "σ": "&sigma;", "Σ": "&Sigma;", "ς": "&sigmaf;", "τ": "&tau;", "Τ": "&Tau;", "ϒ": "&upsih;", "υ": "&upsilon;",
         "Υ": "&Upsilon;", "φ": "&phi;", "Φ": "&Phi;", "χ": "&chi;", "Χ": "&Chi;", "ψ": "&psi;", "Ψ": "&Psi;",
         "ω": "&omega;", "Ω": "&Omega;", "ℵ": "&alefsym;"]

    var html: String {
        var html = ""
        for character in self {
            if let entity = String.enc[character] {
                html.append(entity)
            } else {
                html.append(character)
            }
        }
        return html
    }
}

internal func isNilOrWrappedNil(value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    if mirror.displayStyle == .optional {
        if let first = mirror.children.first {
            return isNilOrWrappedNil(value: first.value)
        } else {
            return true
        }
    }
    return false
}
