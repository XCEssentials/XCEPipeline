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

/// Passes a value through a transforming closure and continues the pipeline.
infix operator ./ : CompositionPrecedence
/// Unwraps an optional, passes its value through a transforming closure, and continues the pipeline.
infix operator .? : CompositionPrecedence

/// Passes a mutable copy of a value to an `inout` closure and continues with the resulting value.
infix operator .+ : CompositionPrecedence
/// Inspects a value without replacing it and passes the original value through the pipeline.
infix operator .- : CompositionPrecedence

/// Passes a value to a closure and ends the pipeline.
infix operator .* : CompositionPrecedence
/// Unwraps an optional, passes its value to a closure, and ends the pipeline.
infix operator .?* : CompositionPrecedence

/// Verifies a condition and passes the value through when the condition succeeds.
infix operator .! : CompositionPrecedence
/// Validates an optional, Boolean, or optional collection and throws the supplied error on failure.
infix operator ?! : NilCoalescingPrecedence

// MARK: - Implementation

/// Asynchronously passes `input` to a closure and returns the closure's result.
///
/// - Parameters:
///   - input: The value to transform.
///   - body: An asynchronous transformation to apply to `input`.
/// - Returns: The value returned by `body`.
/// - Throws: Any error thrown by `body`.
public
func ./ <T, U>(
    input: T,
    body: (T) async throws -> U
) async rethrows -> U {

    try await Pipeline.take(input, mapAsync: body)
}

/// Synchronously passes `input` to a closure and returns the closure's result.
///
/// - Parameters:
///   - input: The value to transform.
///   - body: A transformation to apply to `input`.
/// - Returns: The value returned by `body`.
/// - Throws: Any error thrown by `body`.
public
func ./ <T, U>(
    input: T,
    body: (T) throws -> U
) rethrows -> U {
        
    try Pipeline.take(input, map: body)
}

/// Asynchronously transforms the wrapped value of an optional.
///
/// This operator behaves like `Optional.flatMap`: it calls `body` only when
/// `input` is non-`nil` and returns `nil` otherwise.
///
/// - Parameters:
///   - input: The optional value to transform.
///   - body: An asynchronous transformation that can return `nil`.
/// - Returns: The result of `body`, or `nil` when `input` is `nil`.
/// - Throws: Any error thrown by `body`.
public
func .? <T, U>(
    input: T?,
    body: (T) async throws -> U?
) async rethrows -> U? {
        
    try await Pipeline.take(optional: input, flatMapAsync: body)
}

/// Synchronously transforms the wrapped value of an optional.
///
/// This operator behaves like `Optional.flatMap`: it calls `body` only when
/// `input` is non-`nil` and returns `nil` otherwise.
///
/// - Parameters:
///   - input: The optional value to transform.
///   - body: A transformation that can return `nil`.
/// - Returns: The result of `body`, or `nil` when `input` is `nil`.
/// - Throws: Any error thrown by `body`.
public
func .? <T, U>(
    input: T?,
    body: (T) throws -> U?
) rethrows -> U? {
        
    try Pipeline.take(optional: input, flatMap: body)
}

/// Asynchronously passes a mutable copy of `input` to `body` and returns it.
///
/// The `inout` parameter allows `body` to mutate the value or replace it with
/// another value, including another reference-type instance.
///
/// - Parameters:
///   - input: The value to mutate.
///   - body: An asynchronous mutation applied to the value as `inout`.
/// - Returns: The value produced after applying `body`.
/// - Throws: Any error thrown by `body`.
public
func .+ <T>(
    input: T,
    _ body: (inout T) async throws -> Void
) async rethrows -> T {
    
    try await Pipeline.mutate(input, body)
}

/// Synchronously passes a mutable copy of `input` to `body` and returns it.
///
/// The `inout` parameter allows `body` to mutate the value or replace it with
/// another value, including another reference-type instance.
///
/// - Parameters:
///   - input: The value to mutate.
///   - body: A mutation applied to the value as `inout`.
/// - Returns: The value produced after applying `body`.
/// - Throws: Any error thrown by `body`.
public
func .+ <T>(
    input: T,
    _ body: (inout T) throws -> Void
) rethrows -> T {
    
    try Pipeline.mutate(input, body)
}

/// Asynchronously passes `input` to `body` and then returns the same value.
///
/// The closure can't replace `input`, but it can mutate state owned by a
/// reference-type value.
///
/// - Parameters:
///   - input: The value to inspect.
///   - body: An asynchronous operation that observes `input`.
/// - Returns: The original `input` value.
/// - Throws: Any error thrown by `body`.
public
func .- <T>(
    input: T,
    _ body: (T) async throws -> Void
) async rethrows -> T {
    
    try await Pipeline.inspect(input, body)
}

/// Synchronously passes `input` to `body` and then returns the same value.
///
/// The closure can't replace `input`, but it can mutate state owned by a
/// reference-type value.
///
/// - Parameters:
///   - input: The value to inspect.
///   - body: An operation that observes `input`.
/// - Returns: The original `input` value.
/// - Throws: Any error thrown by `body`.
public
func .- <T>(
    input: T,
    _ body: (T) throws -> Void
) rethrows -> T {
    
    try Pipeline.inspect(input, body)
}

/// Asynchronously verifies a condition and returns `input` when it succeeds.
///
/// - Parameters:
///   - input: The value to validate.
///   - condition: An asynchronous predicate evaluated with `input`.
/// - Returns: `input` when `condition` returns `true`.
/// - Throws: ``Pipeline/FailedConditionCheck`` when `condition` returns `false`,
///   or any error thrown by `condition`.
public
func .! <T>(
    input: T,
    condition: (T) async throws -> Bool
) async throws -> T {
    
    try await Pipeline.ensure(input, condition)
}

/// Synchronously verifies a condition and returns `input` when it succeeds.
///
/// - Parameters:
///   - input: The value to validate.
///   - condition: A predicate evaluated with `input`.
/// - Returns: `input` when `condition` returns `true`.
/// - Throws: ``Pipeline/FailedConditionCheck`` when `condition` returns `false`,
///   or any error thrown by `condition`.
public
func .! <T>(
    input: T,
    condition: (T) throws -> Bool
) throws -> T {
    
    try Pipeline.ensure(input, condition)
}

/// Asynchronously passes `input` to a closure and discards its result.
///
/// Use this operator for a terminal pipeline step. Because the expression
/// returns `Void`, it can also be followed by a step that accepts `Void`.
///
/// - Parameters:
///   - input: The value to pass to `body`.
///   - body: An asynchronous terminal operation.
/// - Throws: Any error thrown by `body`.
public
func .* <T, U>(
    input: T,
    body: (T) async throws -> U
) async rethrows {
    
    try await Pipeline.take(input, endAsync: body)
}

/// Synchronously passes `input` to a closure and discards its result.
///
/// Use this operator for a terminal pipeline step. Because the expression
/// returns `Void`, it can also be followed by a step that accepts `Void`.
///
/// - Parameters:
///   - input: The value to pass to `body`.
///   - body: A terminal operation.
/// - Throws: Any error thrown by `body`.
public
func .* <T, U>(
    input: T,
    body: (T) throws -> U
) rethrows {
    
    try Pipeline.take(input, end: body)
}

/// Asynchronously passes a wrapped optional value to a closure and ends the pipeline.
///
/// The operator calls `body` only when `input` is non-`nil` and always returns
/// `Void`.
///
/// - Parameters:
///   - input: The optional value whose wrapped value is passed to `body`.
///   - body: An asynchronous terminal operation.
/// - Throws: Any error thrown by `body`.
public
func .?* <T, U>(
    input: T?,
    body: (T) async throws -> U
) async rethrows {
    
    try await Pipeline.take(optional: input, endAsync: body)
}

/// Synchronously passes a wrapped optional value to a closure and ends the pipeline.
///
/// The operator calls `body` only when `input` is non-`nil` and always returns
/// `Void`.
///
/// - Parameters:
///   - input: The optional value whose wrapped value is passed to `body`.
///   - body: A terminal operation.
/// - Throws: Any error thrown by `body`.
public
func .?* <T, U>(
    input: T?,
    body: (T) throws -> U
) rethrows {
    
    try Pipeline.take(optional: input, end: body)
}

/// Unwraps an optional or throws a caller-supplied error.
///
/// - Parameters:
///   - input: The optional value to unwrap.
///   - getError: The error to create if `input` is `nil`. The expression is
///     evaluated lazily only when the error is needed.
/// - Returns: The wrapped value of `input`.
/// - Throws: The error produced by `getError` when `input` is `nil`.
public
func ?! <T>(
    input: T?,
    getError: @autoclosure () -> Swift.Error // lazy initialization
) throws -> T {
    
    try Pipeline.unwrapOrThrow(input, getError)
}

/// Requires a Boolean value to be `true` or throws a caller-supplied error.
///
/// - Parameters:
///   - input: The Boolean value to validate.
///   - getError: The error to create if `input` is `false`. The expression is
///     evaluated lazily only when the error is needed.
/// - Throws: The error produced by `getError` when `input` is `false`.
public
func ?! (
    input: Bool,
    getError: @autoclosure () -> Swift.Error // lazy initialization
) throws {
    
    try Pipeline.throwIfFalse(input, getError)
}

/// Unwraps a nonempty optional collection or throws a caller-supplied error.
///
/// - Parameters:
///   - input: The optional collection to validate and unwrap.
///   - getError: The error to create if `input` is `nil` or empty. The
///     expression is evaluated lazily only when the error is needed.
/// - Returns: The nonempty collection wrapped by `input`.
/// - Throws: The error produced by `getError` when `input` is `nil` or empty.
public
func ?! <T>(
    input: T?,
    getError: @autoclosure () -> Swift.Error // lazy initialization
) throws -> T where T: Collection {
    
    try Pipeline.throwIfEmpty(input, getError)
}
