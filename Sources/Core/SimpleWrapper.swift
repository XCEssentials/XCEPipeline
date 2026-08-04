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

/// Convenience wrapper that enables chain operations
/// similar to `Optional` & `Collection`.
public
struct SimpleWrapper<T>
{
    public
    let value: T
 
    init(_ value: T)
    {
        self.value = value
    }
 
    public
    func map<R, E: Error>(_ handler: (T) throws(E) -> R) throws(E) -> SimpleWrapper<R>
    {
        try .init(handler(value))
    }

    public
    func inspect<E: Error>(_ handler: (T) throws(E) -> Void) throws(E) -> Self
    {
        try handler(value)
        return self
    }

    public
    func mutate<E: Error>(_ handler: (inout T) throws(E) -> Void) throws(E) -> Self
    {
        var tmp = value
        try handler(&tmp)
        return .init(tmp)
    }

    public
    func map<R, E: Error>(_ handler: (T) async throws(E) -> R) async throws(E) -> SimpleWrapper<R>
    {
        try await .init(handler(value))
    }

    public
    func inspect<E: Error>(_ handler: (T) async throws(E) -> Void) async throws(E) -> Self
    {
        try await handler(value)
        return self
    }

    public
    func mutate<E: Error>(_ handler: (inout T) async throws(E) -> Void) async throws(E) -> Self where T: Sendable
    {
        var tmp = value
        try await handler(&tmp)
        return .init(tmp)
    }
}

extension SimpleWrapper: Equatable where T: Equatable {}
extension SimpleWrapper: Hashable where T: Hashable {}
extension SimpleWrapper: Codable where T: Codable {}
extension SimpleWrapper: Sendable where T: Sendable {}
