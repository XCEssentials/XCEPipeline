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
func take<T>(_ value: T?) -> T?
{
    value
}

public
func take<T>(_ value: T) -> SimpleWrapper<T>
{
    .init(value)
}

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
    func map<R>(via handler: (T) throws -> R) rethrows -> SimpleWrapper<R>
    {
        try .init(handler(value))
    }
    
    public
    func inspect(via handler: (T) throws -> Void) rethrows -> Self
    {
        try handler(value)
        return self
    }
    
    public
    func mutate(via handler: (inout T) throws -> Void) rethrows -> Self
    {
        var tmp = value
        try handler(&tmp)
        return .init(tmp)
    }
}

extension SimpleWrapper: Equatable where T: Equatable {}
