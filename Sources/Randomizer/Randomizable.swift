import Foundation

public protocol Randomizable {
    static func random() -> Self
}

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
