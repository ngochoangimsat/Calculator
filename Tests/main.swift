import Foundation
func check(_ input: String, _ expected: Double, degrees: Bool = true) throws {
    let actual = try ScientificEngine.calculate(input, degrees: degrees, ans: 42)
    precondition(abs(actual - expected) < 1e-9, "Failed: \(input), got \(actual)")
}
try check("2+3×4", 14)
try check("-2^2", -4)
try check("2^3^2", 512)
try check("sin(30)", 0.5)
try check("sqrt(9)+5!", 123)
try check("Ans÷2", 21)
for input in ["1÷0", "sqrt(-1)", "1abc", "("] {
    var rejected = false
    do { _ = try ScientificEngine.calculate(input, degrees: true, ans: 0) }
    catch { rejected = true }
    precondition(rejected, "Must reject \(input)")
}
var p = ProgrammerEngine()
p.radix = .hex
p.append("F"); p.append("F")
precondition(p.value == 255 && p.render(.bin) == "11111111")
p.select("AND"); p.append("0"); p.append("F"); p.equals()
precondition(p.value == 15)
p.execute("<<", 1, 63)
precondition(p.value == 0x8000000000000000)
p.execute("+", UInt64.max, 1)
precondition(p.value == 0)
p.execute("÷", 1, 0)
precondition(p.error != nil)
print("Calculator engine regression checks passed")
