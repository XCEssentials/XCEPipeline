/*

 MIT License

 Copyright (c) 2018 Maxim Khatskevich

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 */

public
extension Optional {
    /// Performs an operation on the wrapped value without changing the optional.
    ///
    /// The handler is not called when this optional is `nil`.
    ///
    /// - Parameter handler: An operation that observes the wrapped value.
    /// - Returns: This optional, unchanged.
    /// - Throws: The error thrown by `handler`.
    func inspect<E: Error>(_ handler: (Wrapped) throws(E) -> Void) throws(E) -> Self {
        guard case .some(let wrapped) = self else { return self }
        try handler(wrapped)
        return self
    }

    /// Mutates the wrapped value when one is present.
    ///
    /// - Parameter handler: A mutation applied to the wrapped value as `inout`.
    /// - Returns: The optional containing the mutated value, or `nil` when this
    ///   optional is `nil`.
    /// - Throws: The error thrown by `handler`.
    func mutate<E: Error>(_ handler: (inout Wrapped) throws(E) -> Void) throws(E) -> Self {
        guard case .some(var wrapped) = self else { return self }
        try handler(&wrapped)
        return .some(wrapped)
    }

    /// Keeps the wrapped value only when it satisfies a predicate.
    ///
    /// The predicate is not called when this optional is `nil`.
    ///
    /// - Parameter shouldKeep: A predicate evaluated with the wrapped value.
    /// - Returns: This optional when the predicate returns `true`; otherwise,
    ///   `nil`.
    /// - Throws: The error thrown by `shouldKeep`.
    func filter<E: Error>(_ shouldKeep: (Wrapped) throws(E) -> Bool) throws(E) -> Self {
        guard case .some(let wrapped) = self else { return self }
        return try shouldKeep(wrapped) ? self : nil
    }
}
