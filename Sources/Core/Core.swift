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

/**
 Set of helpers for chainable value transformations, pipeline-style.

 Inspiration:
 - https://blog.mariusschulz.com/2014/09/13/implementing-a-custom-forward-pipe-operator-for-function-chains-in-swift

 Examples:
 - https://github.com/gilesvangruisen/Pipeline
 - https://github.com/pauljeannot/SwiftyBash
 - https://github.com/patgoley/Pipeline/blob/master/Pipeline/Operators.swift
 - https://github.com/danthorpe/Pipe (outdated!)
 - https://github.com/jarsen/Pipes (outdated!)
 */

public
enum Pipeline {} // scope

//---

public
extension Pipeline
{
    /**
     Takes `input` and passes it into `body` and returns result.
     */
    static
    func take<T, U>(
        _ input: T,
        map body: (T) throws -> U
        ) rethrows -> U
    {
        return try body(input)
    }

    /**
     Takes `input` and passes its unwrapped value into `body` and
     returns result, or returns `nil` otherwise. Analogue of
     `Optional.map(...)` function.
     */
    static
    func take<T, U>(
        _ input: T?,
        map body: (T) throws -> U
        ) rethrows -> U?
    {
        return try input.map(body)
    }

    /**
     Takes `input` and passes it into `body`, returns nothing.
     Typically defines final step in pipeline. Alternatively
     can be used to "restart" pipeline — continue chain with
     next step taking no input (Void).
     */
    static
    func take<T>(
        _ input: T,
        end body: (T) throws -> Void
        ) rethrows
    {
        try body(input)
    }

    /**
     Takes `input` and passes its unwrapped value into `body`,
     or does nothing if `input` is `nil. Returns nothing anyway.
     Typically defines final step in pipeline. Alternatively
     can be used to "restart" pipeline — continue chain with
     next step taking no input (Void).
     */
    static
    func take<T>(
        _ input: T?,
        end body: (T) throws -> Void
        ) rethrows
    {
        try input.map(body)
    }
}
