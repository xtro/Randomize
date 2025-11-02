import Foundation
import CoreGraphics
#if canImport(UIKit)
import UIKit
import SwiftUI
#endif

extension Optional: Randomizable where Wrapped: Randomizable {
    public static func random() -> Self {
        .some(Wrapped.random())
    }
}
extension Array: Randomizable where Element: Randomizable {
    public static func random() -> Self {
        .init(repeating: Element.random(), count: Int.random(in: 0..<10))
    }
    public static func random(count: Int) -> Self {
        (0...count).map { _ in
            Element.random()
        }
    }
}

#if canImport(UIKit)
@available(iOS 15.0, *)
extension ButtonRole: Randomizable {
    public static func random() -> Self {
        .destructive
    }
}
#endif

extension Date: RandomizableInRange {
    public static func random(in range: Range<Self>) -> Self {
        let delta = range.upperBound.timeIntervalSince1970 - range.lowerBound.timeIntervalSince1970
        let randomOffset = TimeInterval.random(in: 0..<delta)
        return Date(timeIntervalSince1970: range.lowerBound.timeIntervalSince1970 + randomOffset)
    }
}
extension Date: Randomizable {
    public static func random() -> Self {
        Date.random(in: Date().addingTimeInterval(-1_000_000)..<Date().addingTimeInterval(1_000_000))
    }
}
extension Decimal: Randomizable {
    public static func random() -> Self {
        // Generate a random Decimal in a reasonable range with random sign
        let magnitude = Double.random(in: 0...1_000_000)
        let sign: Double = Bool.random() ? 1 : -1
        return Decimal(magnitude * sign)
    }
}
extension Decimal: RandomizableInRange {
    public static func random(in range: Range<Self>) -> Self {
        // Convert Decimal bounds to Double, generate a random Double in range, then convert back to Decimal
        let lower = (range.lowerBound as NSDecimalNumber).doubleValue
        let upper = (range.upperBound as NSDecimalNumber).doubleValue
        let value = Double.random(in: lower..<upper)
        return Decimal(value)
    }
}

extension URL: Randomizable {
    public static func random() -> URL {
        URL(string: "https://source.unsplash.com/random/300x300")!
    }
}

#if canImport(UIKit)
extension UIImage: Randomizable {
    public static func random() -> Self {
        guard let data = try? Data(contentsOf: URL.random()) else {
            return Self()
        }
        return Self(data: data) ?? Self()
    }
}
extension Image: Randomizable {
    public static func random() -> Self {
        return Self(uiImage: UIImage.random())
    }
}

#endif

extension Int: Randomizable {
    public static func random() -> Int {
        Int.random(in: 0...1)
    }
}
extension Range where Bound == Int {
    public func random() -> Int {
        Bound.random(in: self)
    }
}

extension Double: Randomizable {
    public static func random() -> Double {
        Double.random(in: 0...1)
    }
}
extension Range where Bound == Double {
    public func random() -> Double {
        Double.random(in: self)
    }
}

extension Float: Randomizable {
    public static func random() -> Float {
        Float.random(in: 0...1)
    }
}
extension Range where Bound == Float {
    public func random() -> Float {
        Float.random(in: self)
    }
}

extension CGFloat: Randomizable {
    public static func random() -> CGFloat {
        CGFloat.random(in: 0...1)
    }
}
extension Range where Bound == CGFloat {
    public func random() -> CGFloat {
        CGFloat.random(in: self)
    }
}

extension String: RandomizableInRange {
    public static func random(in range: Range<Self>) -> Self {
        let minLen = range.lowerBound.count
        let maxLen = range.upperBound.count
        guard minLen < maxLen else { return range.lowerBound }
        let len = Int.random(in: minLen..<maxLen)
        let chars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var result = String()
        result.reserveCapacity(len)
        for _ in 0..<len {
            if let c = chars.randomElement() {
                result.append(c)
            }
        }
        return result
    }
    public static func random(in range: Range<Int>) -> Self {
        let minLen = range.lowerBound
        let maxLen = range.upperBound
        let len = Int.random(in: minLen..<maxLen)
        let chars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var result = String()
        result.reserveCapacity(len)
        for _ in 0..<len {
            if let c = chars.randomElement() {
                result.append(c)
            }
        }
        return result
    }
}
extension String: Randomizable {
    public static func random() -> String {
        String.random(in: 3..<10)
    }
}
extension Range where Bound == Int {
    public func random() -> String {
        String.random(in: self)
    }
}

extension CGSize: @retroactive Comparable {
    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        (lhs.width*lhs.height) < (rhs.width*rhs.height)
    }
}

extension CGSize: RandomizableInRange {
    public static func random(in range: Range<Self>) -> Self {
        let wMin = range.lowerBound.width
        let wMax = range.upperBound.width
        let hMin = range.lowerBound.height
        let hMax = range.upperBound.height
        let wRange = wMin..<wMax
        let hRange = hMin..<hMax
        return CGSize(width: CGFloat.random(in: wRange), height: CGFloat.random(in: hRange))
    }
}
extension CGSize: Randomizable {
    public static func random() -> CGSize {
        CGSize.random(in: CGSize(width: 10, height: 10)..<CGSize(width: 300, height: 300))
    }
}
extension Range where Bound == CGSize {
    public func random() -> CGSize {
        CGSize.random(in: self)
    }
}

extension CGPoint: @retroactive Comparable {
    public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        (lhs.x*lhs.y) < (rhs.x*rhs.y)
    }
}

extension CGPoint: RandomizableInRange {
    public static func random(in range: Range<Self>) -> Self {
        let xMin = range.lowerBound.x
        let xMax = range.upperBound.x
        let yMin = range.lowerBound.y
        let yMax = range.upperBound.y
        let xRange = xMin..<xMax
        let yRange = yMin..<yMax
        return CGPoint(x: CGFloat.random(in: xRange), y: CGFloat.random(in: yRange))
    }
}
extension CGPoint: Randomizable {
    public static func random() -> CGPoint {
        CGPoint.random(in: CGPoint(x: 10, y: 10)..<CGPoint(x: 300, y: 300))
    }
}
extension Range where Bound == CGPoint {
    public func random() -> CGPoint {
        CGPoint.random(in: self)
    }
}

extension CaseIterable {
    public static func random() -> Self {
        allCases[Int.random(in: 0 ..< allCases.count) as! Self.AllCases.Index]
    }
}
