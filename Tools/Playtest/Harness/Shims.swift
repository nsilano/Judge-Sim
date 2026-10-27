import Foundation

// Stand-ins for the SwiftUI and Combine pieces the engine touches. Nothing here draws; it only lets the engine run.
protocol ObservableObject: AnyObject {}

@propertyWrapper
struct Published<Value> {
    var wrappedValue: Value
    init(wrappedValue: Value) { self.wrappedValue = wrappedValue }
}

struct Animation {
    static let easeInOut = Animation()
    static let snappy = Animation()
    static let `default` = Animation()
}

@discardableResult
func withAnimation<Result>(_ animation: Animation? = nil, _ body: () throws -> Result) rethrows -> Result { try body() }

// From Views/ExhibitLooks.swift, which the engine's receipts use.
extension String {
    var stableHash: Int { unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) & 0xFFFFF } }
}

struct Binding<Value> {
    let get: () -> Value
    let set: (Value) -> Void
    init(get: @escaping () -> Value, set: @escaping (Value) -> Void) { self.get = get; self.set = set }
    var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
}
