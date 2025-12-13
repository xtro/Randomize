import Foundation

public protocol Randomizable {
    static func random() -> Self
}

public extension Randomizable {
    static func random() -> Self {
        fatalError("Randomizable.random() not implemented for \(Self.self)")
    }}

public protocol RandomizableInRange: Comparable {
    static func random(in range: Range<Self>) -> Self
}

public extension Randomizable {
    static func sample(_ count: Int = 10) -> [Self] {
        count.instance(Self.random())
    }
}
private extension Int {
    func instance<Type>(_ of: @autoclosure () -> Type) -> [Type] {
        (0 ... self).map { _ in
            of()
        }
    }
}
public struct RandomizationStrategy<Value> {
    public init(_ value: @escaping () -> Value) {
        self.value = value
    }
    public var value: () -> Value
    public func random() -> Value {
        value()
    }
}
