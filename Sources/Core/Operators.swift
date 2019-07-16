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

// MARK: - Precedence

precedencegroup CompositionPrecedence {
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
    associativity: left
}

// MARK: - Declaration

infix operator ./ : CompositionPrecedence // pass through
infix operator .| : CompositionPrecedence // pass & stop chain
infix operator ?/ : CompositionPrecedence // pass through unwrapped optional
infix operator ?| : CompositionPrecedence // pass unwrapped optional & stop chain

infix operator ?! : NilCoalescingPrecedence // check and throw if not OK

// MARK: - Implementation

public
//infix
func ./ <T, U>(
    input: T,
    body: (T) throws -> U
    ) rethrows -> U
{
    return try Pipeline.take(input, map: body)
}

public
//infix
func ?/ <T, U>(
    input: T?,
    body: (T) throws -> U
    ) rethrows -> U?
{
    return try Pipeline.take(input, map: body)
}

public
//infix
func .| <T>(
    input: T,
    body: (T) throws -> Void
    ) rethrows
{
    try Pipeline.take(input, end: body)
}

public
//infix
func .| <T, U>(
    input: T,
    body: (T) throws -> U
    ) rethrows
{
    try Pipeline.take(input, end: { _ = try body($0) })
}

public
//infix
func ?| <T>(
    input: T?,
    body: (T) throws -> Void
    ) rethrows
{
    try Pipeline.take(input, end: body)
}

public
//infix
func ?! <T>(
    input: T?,
    error: Swift.Error
    ) throws -> T
{
    if
        let input = input
    {
        return input
    }
    else
    {
        throw error
    }
}

public
//infix
func ?! (
    input: Bool,
    error: Swift.Error
    ) throws
{
    if
        !input
    {
        throw error
    }
}

public
//infix
func ?! <T>(
    input: T?,
    error: Swift.Error
    ) throws -> T
    where
    T: Collection
{
    if
        let input = input,
        !input.isEmpty
    {
        return input
    }
    else
    {
        throw error
    }
}
