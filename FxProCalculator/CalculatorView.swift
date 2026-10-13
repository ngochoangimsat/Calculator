import SwiftUI

private enum Palette {
    static let bg = Color(red: 0.075, green: 0.10, blue: 0.14)
    static let screen = Color(red: 0.78, green: 0.85, blue: 0.73)
    static let key = Color(red: 0.21, green: 0.27, blue: 0.34)
    static let accent = Color(red: 0.95, green: 0.61, blue: 0.23)
    static let secondary = Color(red: 0.34, green: 0.44, blue: 0.54)
}

struct CalculatorView: View {
    @State private var programmerMode = false
    @State private var scientificInput = ""
    @State private var scientificOutput = "0"
    @State private var ans = 0.0
    @State private var degrees = true
    @State private var memory = 0.0
    @State private var showHistory = false
    @State private var history: [String] = []
    @State private var prog = ProgrammerEngine()
    @State private var bitPage = 0

    private let scientificRows: [[String]] = [
        ["sin", "cos", "tan", "(", ")"],
        ["ln", "log", "√", "x²", "xʸ"],
        ["π", "e", "n!", "1/x", "%"],
        ["AC", "⌫", "7", "8", "9"],
        ["M+", "M−", "4", "5", "6"],
        ["MR", "MC", "1", "2", "3"],
        ["+/−", ".", "0", "×", "÷"],
        ["Ans", "−", "+", "=", "DEG"]
    ]
    private let programmerRows: [[String]] = [
        ["A", "B", "C", "AND", "OR"],
        ["D", "E", "F", "XOR", "NOT"],
        ["7", "8", "9", "<<", ">>"],
        ["4", "5", "6", "+", "−"],
        ["1", "2", "3", "×", "÷"],
        ["AC", "0", "⌫", "MOD", "="]
    ]

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("FX PRO").font(.system(size: 25, weight: .heavy, design: .rounded)).tracking(2)
                            Text("SCIENTIFIC • PROGRAMMER").font(.system(size: 9, weight: .medium)).tracking(1.6)
                        }
                        Spacer()
                        Button { showHistory = true } label: {
                            Image(systemName: "clock.arrow.circlepath").font(.title3)
                        }.accessibilityLabel("Lịch sử")
                    }.foregroundStyle(.white)

                    Picker("Chế độ", selection: $programmerMode) {
                        Text("Khoa học").tag(false)
                        Text("HEX / BIN").tag(true)
                    }
                    .pickerStyle(.segmented)

                    if programmerMode { programmerScreen } else { scientificScreen }

                    if programmerMode {
                        programmerKeyboard
                        bitEditor
                    } else { scientificKeyboard }

                    Text("FX PRO • iOS calculator")
                        .font(.system(size: 10)).foregroundStyle(.white.opacity(0.4))
                }
                .padding(14)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geo.size.height, alignment: .top)
            }
            .background(Palette.bg.ignoresSafeArea())
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showHistory) {
            NavigationStack {
                List(history.reversed(), id: \.self) { item in Text(item).font(.system(.body, design: .monospaced)) }
                    .navigationTitle("Lịch sử")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) { Button("Xóa") { history.removeAll() } }
                        ToolbarItem(placement: .navigationBarTrailing) { Button("Đóng") { showHistory = false } }
                    }
            }
        }
    }

    private var scientificScreen: some View {
        VStack(alignment: .trailing, spacing: 10) {
            HStack {
                Text(degrees ? "DEG" : "RAD")
                Spacer()
                Text(memory == 0 ? "" : "M")
            }.font(.system(size: 12, weight: .bold, design: .monospaced))
            Text(scientificInput.isEmpty ? "0" : scientificInput)
                .font(.system(size: 21, design: .monospaced))
                .lineLimit(2).minimumScaleFactor(0.5).frame(maxWidth: .infinity, alignment: .trailing)
            Text(scientificOutput)
                .font(.system(size: 35, weight: .semibold, design: .monospaced))
                .lineLimit(1).minimumScaleFactor(0.38).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .foregroundStyle(Color.black.opacity(0.88))
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Palette.screen, in: RoundedRectangle(cornerRadius: 13))
    }

    private var programmerScreen: some View {
        VStack(spacing: 7) {
            HStack {
                Text("UINT64").font(.system(size: 11, weight: .bold, design: .monospaced))
                Spacer()
                Text(prog.operation.map { "OP: \($0)" } ?? "64-BIT")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
            ForEach(ProgrammerEngine.Radix.allCases) { r in
                Button {
                    prog.radix = r; prog.fresh = true
                } label: {
                    HStack(spacing: 10) {
                        Text(r.label).font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .frame(width: 36, alignment: .leading)
                        Text(prog.render(r)).font(.system(size: r == .bin ? 13 : 17, weight: .medium, design: .monospaced))
                            .lineLimit(r == .bin ? 2 : 1).minimumScaleFactor(0.55)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .foregroundStyle(prog.radix == r ? Color(red: 0.05, green: 0.32, blue: 0.20) : .black)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 7)
                    .background(prog.radix == r ? Color.black.opacity(0.10) : .clear, in: RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            if let error = prog.error { Text(error).font(.caption).foregroundStyle(.red) }
        }
        .padding(13)
        .background(Palette.screen, in: RoundedRectangle(cornerRadius: 13))
    }

    private var scientificKeyboard: some View {
        VStack(spacing: 7) {
            ForEach(scientificRows.indices, id: \.self) { index in
                HStack(spacing: 7) {
                    ForEach(scientificRows[index], id: \.self) { key in
                        keypadButton(key, compact: true) { sciPress(key) }
                    }
                }
            }
        }
    }

    private var programmerKeyboard: some View {
        VStack(spacing: 7) {
            ForEach(programmerRows.indices, id: \.self) { index in
                HStack(spacing: 7) {
                    ForEach(programmerRows[index], id: \.self) { key in
                        keypadButton(key, compact: true, disabled: isDisabled(key)) { progPress(key) }
                    }
                }
            }
        }
    }

    private func keypadButton(_ title: String, compact: Bool, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        let special = ["=", "+", "−", "×", "÷", "AND", "OR", "XOR", "NOT", "<<", ">>", "MOD"].contains(title)
        let clearing = ["AC", "⌫"].contains(title)
        return Button(action: action) {
            Text(title)
                .font(.system(size: title.count > 3 ? 13 : 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: compact ? 43 : 52)
                .foregroundStyle(disabled ? Color.white.opacity(0.2) : .white)
                .background(disabled ? Palette.key.opacity(0.5) : (clearing ? Palette.secondary : (special ? Palette.accent : Palette.key)), in: RoundedRectangle(cornerRadius: 9))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private func isDisabled(_ key: String) -> Bool {
        if let d = UInt64(key, radix: 16) { return d >= UInt64(prog.radix.rawValue) }
        return false
    }

    private var bitEditor: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("BIT EDITOR • nhấn để đảo bit")
                    .font(.system(size: 11, weight: .bold))
                Spacer()
                Button(bitPage == 0 ? "Bits 63–32" : "Bits 31–0") { bitPage = 1 - bitPage }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Palette.accent)
            }
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<8, id: \.self) { col in
                        let bit = (bitPage == 0 ? 63 : 31) - row * 8 - col
                        let on = (prog.value & (UInt64(1) << bit)) != 0
                        Button { prog.toggle(bit) } label: {
                            VStack(spacing: 3) {
                                Text("\(bit)").font(.system(size: 9, design: .monospaced))
                                Text(on ? "1" : "0").font(.system(size: 16, weight: .bold, design: .monospaced))
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 5)
                            .background(on ? Palette.accent : Palette.key, in: RoundedRectangle(cornerRadius: 4))
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
        .foregroundStyle(.white).padding(10)
        .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 12))
    }

    private func sciPress(_ key: String) {
        switch key {
        case "AC": scientificInput = ""; scientificOutput = "0"
        case "⌫": if !scientificInput.isEmpty { scientificInput.removeLast() }
        case "DEG": degrees.toggle()
        case "=":
            do {
                let v = try ScientificEngine.calculate(scientificInput, degrees: degrees, ans: ans)
                ans = v; scientificOutput = printNumber(v)
                history.append("\(scientificInput) = \(scientificOutput)")
                scientificInput = scientificOutput
            } catch { scientificOutput = "Math ERROR" }
        case "M+": memory += (Double(scientificOutput) ?? 0)
        case "M−": memory -= (Double(scientificOutput) ?? 0)
        case "MR": scientificInput += printNumber(memory)
        case "MC": memory = 0
        case "Ans": scientificInput += "Ans"
        case "√": scientificInput += "sqrt("
        case "x²": scientificInput += "^2"
        case "xʸ": scientificInput += "^"
        case "n!": scientificInput += "!"
        case "1/x": scientificInput += "1÷("
        case "+/−": scientificInput = "-(" + scientificInput + ")"
        case "−": scientificInput += "-"
        case "sin", "cos", "tan", "ln", "log": scientificInput += key + "("
        default: scientificInput += key
        }
    }

    private func progPress(_ key: String) {
        if key.count == 1 && (UInt64(key, radix: 16) != nil) { prog.append(key); return }
        switch key {
        case "AC": prog.clear()
        case "⌫": prog.backspace()
        case "NOT": prog.invert()
        case "=":
            let before = prog.lhs.map { String($0) } ?? ""
            let op = prog.operation ?? ""
            let rhs = prog.value
            prog.equals()
            if !op.isEmpty && prog.error == nil { history.append("\(before) \(op) \(rhs) = \(prog.value) [DEC]") }
        default: prog.select(key)
        }
    }
}
