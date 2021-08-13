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
infix operator ?/ : CompositionPrecedence // pass through unwrapped

infix operator +/ : CompositionPrecedence // pass through for editing

infix operator .* : CompositionPrecedence // pass & stop chain
infix operator ?* : CompositionPrecedence // pass unwrapped  & stop chain

infix operator ?! : NilCoalescingPrecedence // check and throw if not OK
infix operator !! : NilCoalescingPrecedence // rethrow with FORCE error typecast

// MARK: - Implementation

/// Passes `input` value into `body` as is and returns whatever
/// `body` returns to continue the pipeline.
public
//infix
func ./ <T, U>(
    input: T,
    body: (T) throws -> U
    ) rethrows -> U
{
    return try Pipeline.take(input, map: body)
}

/// Passes unwrapped `input` value into `body` if it's non-nil,
/// or does nothing otherwise. Returns whatever `body` supposed
/// to return (or `nil`) as optional to continue the pipeline.
/// Analogue of `map(...)` function of `Optional` type.
public
//infix
func ?/ <T, U>(
    input: T?,
    body: (T) throws -> U
    ) rethrows -> U?
{
    return try Pipeline.take(optional: input, map: body)
}

/**
 Mutates `input` even if it's a `let` instance of value type with
 a throwing closure, so the whole expression throws if the closure
 throws.
 
 NOTE: for reference type it will return same input instance with
 given mutations, but for value type it will return a copy of
 `input` instance with given mutations.
 */
public
//infix
func +/ <T>(
    input: T,
    _ body: @escaping (inout T) throws -> Void
    ) throws -> T
{
    var tmp = input
    try body(&tmp)
    return tmp
}

/**
 Mutates `input` even if it's a `let` instance of value type.
 
 NOTE: for reference type it will return same input instance with
 given mutations, but for value type it will return a copy of
 `input` instance with given mutations.
 */
public
//infix
func +/ <T>(
    input: T,
    _ body: @escaping (inout T) -> Void
    ) -> T
{
    var tmp = input
    body(&tmp)
    return tmp
}

/// Passes `input` value into `body` as is. Returns nothing.
/// Typically defines final step in pipeline. Alternatively
/// can be used to "restart" pipeline — continue chain with
/// next step taking no input (Void).
public
//infix
func .* <T, U>(
    input: T,
    body: (T) throws -> U
    ) rethrows
{
    try Pipeline.take(input, end: body)
}

/// Passes unwrapped `input` value into `body` if it's non-nil,
/// or does nothing otherwise. Returns nothing anyway.
/// Typically defines final step in pipeline. Alternatively
/// can be used to "restart" pipeline — continue chain with
/// next step taking no input (Void).
public
//infix
func ?* <T, U>(
    input: T?,
    body: (T) throws -> U
    ) rethrows
{
    try Pipeline.take(optional: input, end: body)
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

/// Pass the result of `inputClosure` or catch
/// the `error` thrown by `inputClosure`, FORCE type cast it
/// into `E` and rethrow result error.
///
/// WARNING: it will crash in case the `error` is not of expected type!
public
func !! <T, E: Error>(
    _ inputClosure: @autoclosure () throws -> T,
    _ : E.Type
    ) rethrows -> T
{
    do
    {
        return try inputClosure()
    }
    catch
    {
        throw error as! E
    }
}

/// Pass the result of `inputClosure` or catch
/// the `error` thrown by `inputClosure`, FORCE type cast it
/// into `E` and rethrow result error.
///
/// WARNING: it will crash in case the `error` is not of expected type!
public
func !! <T, E: Error, U: Error>(
    _ inputClosure: @autoclosure () throws -> T,
    _ errorMapping: (E) -> U
    ) rethrows -> T
{
    do
    {
        return try inputClosure()
    }
    catch
    {
        throw errorMapping(error as! E)
    }
}

/// Pass the result of `inputClosure` or catch
/// the `error` thrown by `inputClosure`, FORCE type cast it
/// into `E` and rethrow result error.
///
/// WARNING: it will crash in case the `error` is not of expected type!
public
func !! <T, E: Error>(
    _ inputClosure: @autoclosure () throws -> T,
    _ errorMapping: (Error) -> E?
    ) rethrows -> T
{
    do
    {
        return try inputClosure()
    }
    catch
    {
        throw errorMapping(error)!
    }
}
