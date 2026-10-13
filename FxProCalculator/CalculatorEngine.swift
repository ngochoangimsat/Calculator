import Foundation

enum CalcError: Error { case syntax, divisionByZero, domain }

struct ScientificEngine {
    static func calculate(_ input: String, degrees: Bool, ans: Double) throws -> Double {
        var parser = Parser(input, degrees, ans)
        let result = try parser.expression()
        guard parser.pos == parser.tokens.count, result.isFinite else { throw CalcError.syntax }
        return result
    }
    private struct Parser {
        let tokens: [String]
        var pos = 0
        let degrees: Bool
        let ans: Double
        init(_ input: String, _ degrees: Bool, _ ans: Double) {
            let pattern = #"(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?|[A-Za-zπ]+|[+\-×÷^()!%]"#
            let re = try! NSRegularExpression(pattern: pattern)
            let str = input.replacingOccurrences(of: " ", with: "")
            let ns = str as NSString
            let matches = re.matches(in: str, range: NSRange(location: 0, length: ns.length))
            let found = matches.map { ns.substring(with: $0.range) }
            tokens = found.joined() == str ? found : []
            self.degrees = degrees; self.ans = ans
        }
        mutating func take(_ t: String) -> Bool {
            if pos < tokens.count && tokens[pos] == t { pos += 1; return true }
            return false
        }
        mutating func expression() throws -> Double {
            var n = try term()
            while pos < tokens.count {
                if take("+") { n += try term() }
                else if take("-") { n -= try term() }
                else { break }
            }
            return n
        }
        mutating func term() throws -> Double {
            var n = try unary()
            while pos < tokens.count {
                if take("×") { n *= try unary() }
                else if take("÷") {
                    let divisor = try unary()
                    guard divisor != 0 else { throw CalcError.divisionByZero }
                    n /= divisor
                } else { break }
            }
            return n
        }
        mutating func unary() throws -> Double {
            if take("-") { return -(try unary()) }
            if take("+") { return try unary() }
            return try exponent()
        }
        mutating func exponent() throws -> Double {
            let n = try postfix()
            return take("^") ? pow(n, try unary()) : n
        }
        mutating func postfix() throws -> Double {
            var n = try primary()
            while pos < tokens.count {
                if take("%") { n /= 100 }
                else if take("!") {
                    guard n >= 0, n <= 170, n.rounded() == n else { throw CalcError.domain }
                    let v = Int(n)
                    n = v <= 1 ? 1 : (2...v).reduce(1.0) { $0 * Double($1) }
                } else { break }
            }
            return n
        }
        mutating func primary() throws -> Double {
            if take("(") {
                let n = try expression()
                guard take(")") else { throw CalcError.syntax }
                return n
            }
            guard pos < tokens.count else { throw CalcError.syntax }
            let t = tokens[pos]; pos += 1
            if let n = Double(t) { return n }
            if t == "π" { return .pi }
            if t == "e" { return exp(1) }
            if t == "Ans" { return ans }
            guard ["sin","cos","tan","asin","acos","atan","ln","log","sqrt","abs","exp"].contains(t), take("(") else { throw CalcError.syntax }
            let x = try expression()
            guard take(")") else { throw CalcError.syntax }
            let rad = degrees ? x * .pi / 180 : x
            let angleFactor = degrees ? 180 / Double.pi : 1
            let n: Double
            switch t {
            case "sin": n = sin(rad)
            case "cos": n = cos(rad)
            case "tan": n = tan(rad)
            case "asin": n = asin(x) * angleFactor
            case "acos": n = acos(x) * angleFactor
            case "atan": n = atan(x) * angleFactor
            case "ln": n = log(x)
            case "log": n = log10(x)
            case "sqrt": n = sqrt(x)
            case "abs": n = abs(x)
            default: n = exp(x)
            }
            guard n.isFinite else { throw CalcError.domain }
            return n
        }
    }
}

func printNumber(_ number: Double) -> String {
    if number == 0 { return "0" }
    return String(format: "%.12g", number)
}

struct ProgrammerEngine {
    enum Radix: Int, CaseIterable, Identifiable {
        case hex = 16, dec = 10, oct = 8, bin = 2
        var id: Int { rawValue }
        var label: String { switch self { case .hex: "HEX"; case .dec: "DEC"; case .oct: "OCT"; case .bin: "BIN" } }
    }
    var value: UInt64 = 0
    var radix: Radix = .dec
    var lhs: UInt64?
    var operation: String?
    var fresh = true
    var error: String?
    mutating func append(_ digit: String) {
        guard let d = UInt64(digit, radix: 16), d < UInt64(radix.rawValue) else { return }
        let initial = fresh ? 0 : value
        let (a, overflowA) = initial.multipliedReportingOverflow(by: UInt64(radix.rawValue))
        let (b, overflowB) = a.addingReportingOverflow(d)
        guard !overflowA && !overflowB else { error = "Vượt giới hạn 64 bit"; return }
        value = b; fresh = false; error = nil
    }
    mutating func backspace() { value /= UInt64(radix.rawValue); fresh = false }
    mutating func clear() { value = 0; lhs = nil; operation = nil; fresh = true; error = nil }
    mutating func select(_ op: String) {
        if let operation, let lhs, !fresh { execute(operation, lhs, value) }
        lhs = value; operation = op; fresh = true
    }
    mutating func equals() {
        guard let operation, let lhs else { return }
        execute(operation, lhs, value)
        self.operation = nil; self.lhs = nil; fresh = true
    }
    mutating func execute(_ op: String, _ a: UInt64, _ b: UInt64) {
        error = nil
        switch op {
        case "AND": value = a & b
        case "OR": value = a | b
        case "XOR": value = a ^ b
        case "<<": value = b >= 64 ? 0 : a << Int(b)
        case ">>": value = b >= 64 ? 0 : a >> Int(b)
        case "+": value = a &+ b
        case "−": value = a &- b
        case "×": value = a &* b
        case "÷": if b == 0 { error = "Chia cho 0" } else { value = a / b }
        case "MOD": if b == 0 { error = "Chia cho 0" } else { value = a % b }
        default: break
        }
    }
    mutating func invert() { value = ~value; fresh = true }
    mutating func toggle(_ bit: Int) { value ^= UInt64(1) << bit; fresh = true }
    func render(_ r: Radix) -> String { String(value, radix: r.rawValue, uppercase: true) }
}
