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
 
    public
    init(_ value: T)
    {
        self.value = value
    }
 
    public
    func map<R>(_ handler: (T) throws -> R) rethrows -> SimpleWrapper<R>
    {
        try .init(handler(value))
    }
    
    public
    func inspect(_ handler: (T) throws -> Void) rethrows -> Self
    {
        try handler(value)
        return self
    }
    
    public
    func mutate(_ handler: (inout T) throws -> Void) rethrows -> Self
    {
        var tmp = value
        try handler(&tmp)
        return .init(tmp)
    }
}

extension SimpleWrapper: Equatable where T: Equatable {}
extension SimpleWrapper: Hashable where T: Hashable {}
extension SimpleWrapper: Codable where T: Codable {}
extension SimpleWrapper: Sendable where T: Sendable {}
