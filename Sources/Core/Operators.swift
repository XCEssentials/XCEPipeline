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
infix operator .? : CompositionPrecedence // pass through unwrapped
infix operator .!/ : CompositionPrecedence // map error and pass through

infix operator ./> : CompositionPrecedence // tap one level deeper
infix operator .+ : CompositionPrecedence // pass through for editing
infix operator .- : CompositionPrecedence // pass through for inspecting

infix operator .* : CompositionPrecedence // pass & stop chain
infix operator .?* : CompositionPrecedence // pass unwrapped  & stop chain

infix operator .! : CompositionPrecedence // check and throw if not OK, pass throug otherwise
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
) rethrows -> U {
        
    try Pipeline.take(input, map: body)
}

/// Passes unwrapped `input` value into `body` if it's non-nil,
/// or does nothing otherwise. Returns whatever `body` supposed
/// to return (or `nil`) as optional to continue the pipeline.
/// Analogue of `flatMap(...)` function of `Optional` type.
public
//infix
func .? <T, U>(
    input: T?,
    body: (T) throws -> U?
) rethrows -> U? {
        
    try Pipeline.take(optional: input, flatMap: body)
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
func .+ <T>(
    input: T,
    _ body: (inout T) throws -> Void
) rethrows -> T {
    
    try Pipeline.mutate(input, body)
}

/**
 Mutates `input` even if it's a `let` instance of value type.
 
 NOTE: for reference type it will return same input instance with
 given mutations, but for value type it will return a copy of
 `input` instance with given mutations.
 */
public
//infix
func .- <T>(
    input: T,
    _ body: (T) throws -> Void
) rethrows -> T {
    
    try Pipeline.inspect(input, body)
}

public
//infix
func .! <T>(
    input: T,
    condition: (T) throws -> Bool
) throws -> T {
    
    try Pipeline.ensure(input, condition)
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
) rethrows {
    
    try Pipeline.take(input, end: body)
}

/// Passes unwrapped `input` value into `body` if it's non-nil,
/// or does nothing otherwise. Returns nothing anyway.
/// Typically defines final step in pipeline. Alternatively
/// can be used to "restart" pipeline — continue chain with
/// next step taking no input (Void).
public
//infix
func .?* <T, U>(
    input: T?,
    body: (T) throws -> U
) rethrows {
    
    try Pipeline.take(optional: input, end: body)
}

public
//infix
func ?! <T>(
    input: T?,
    getError: @autoclosure () -> Swift.Error // lazy nitialization
) throws -> T {
    
    try Pipeline.unwrapOrThrow(input, getError)
}

public
//infix
func ?! (
    input: Bool,
    getError: @autoclosure () -> Swift.Error // lazy nitialization
) throws {
    
    try Pipeline.throwIfFalse(input, getError)
}

public
//infix
func ?! <T>(
    input: T?,
    getError: @autoclosure () -> Swift.Error // lazy nitialization
) throws -> T where T: Collection {
    
    try Pipeline.throwIfEmpty(input, getError)
}
