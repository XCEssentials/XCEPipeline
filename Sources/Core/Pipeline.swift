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

/// Set of helpers for chainable value transformations, pipeline-style.
///
/// Inspiration:
/// - https://blog.mariusschulz.com/2014/09/13/implementing-a-custom-forward-pipe-operator-for-function-chains-in-swift
///
/// Examples:
/// - https://github.com/gilesvangruisen/Pipeline ⚠️ autoformat
/// - https://github.com/pauljeannot/SwiftyBash
/// - https://github.com/patgoley/Pipeline/blob/master/Pipeline/Operators.swift
/// - https://github.com/danthorpe/Pipe (outdated!)
/// - https://github.com/jarsen/Pipes (outdated!)

public
enum Pipeline { // scope
    /// An error produced while evaluating a pipeline condition.
    public enum ConditionCheckError<E: Error>: Error {
        /// The predicate returned `false`.
        case conditionCheckFailed

        /// The predicate threw an error.
        case predicateBodyError(E)
    }

}

// MARK: - LocalizedError conformance

import Foundation

extension Pipeline.ConditionCheckError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .conditionCheckFailed:
            "Pipeline condition check failed."
        case .predicateBodyError(let error):
            "Pipeline predicate body failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Core

public
extension Pipeline {
    /// Asynchronously passes `input` to a closure and returns the closure's result.
    ///
    /// - Parameters:
    ///   - input: The value to transform.
    ///   - body: An asynchronous transformation to apply to `input`.
    /// - Returns: The value returned by `body`.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        _ input: T,
        mapAsync body: (T) async throws(E) -> U
    ) async throws(E) -> U {

        try await body(input)
    }

    /// Synchronously passes `input` to a closure and returns the closure's result.
    ///
    /// - Parameters:
    ///   - input: The value to transform.
    ///   - body: A transformation to apply to `input`.
    /// - Returns: The value returned by `body`.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        _ input: T,
        map body: (T) throws(E) -> U
    ) throws(E) -> U {

        try body(input)
    }

    /// Asynchronously transforms the wrapped value of an optional.
    ///
    /// This function behaves like `Optional.flatMap`: it calls `body` only when
    /// `input` is non-`nil` and returns `nil` otherwise.
    ///
    /// - Parameters:
    ///   - input: The optional value to transform.
    ///   - body: An asynchronous transformation that can return `nil`.
    /// - Returns: The result of `body`, or `nil` when `input` is `nil`.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        optional input: T?,
        flatMapAsync body: (T) async throws(E) -> U?
    ) async throws(E) -> U? {

        guard
            let input = input
        else {
            return nil
        }

        return try await body(input)
    }

    /// Synchronously transforms the wrapped value of an optional.
    ///
    /// This function behaves like `Optional.flatMap`: it calls `body` only when
    /// `input` is non-`nil` and returns `nil` otherwise.
    ///
    /// - Parameters:
    ///   - input: The optional value to transform.
    ///   - body: A transformation that can return `nil`.
    /// - Returns: The result of `body`, or `nil` when `input` is `nil`.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        optional input: T?,
        flatMap body: (T) throws(E) -> U?
    ) throws(E) -> U? {

        try input.flatMap(body)
    }

    /// Asynchronously passes `input` to a closure and discards its result.
    ///
    /// Use this function for a terminal pipeline step. Because the function
    /// returns `Void`, it can also be followed by a step that accepts `Void`.
    ///
    /// - Parameters:
    ///   - input: The value to pass to `body`.
    ///   - body: An asynchronous terminal operation.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        _ input: T,
        endAsync body: (T) async throws(E) -> U
    ) async throws(E) {

        _ = try await body(input)
    }

    /// Synchronously passes `input` to a closure and discards its result.
    ///
    /// Use this function for a terminal pipeline step. Because the function
    /// returns `Void`, it can also be followed by a step that accepts `Void`.
    ///
    /// - Parameters:
    ///   - input: The value to pass to `body`.
    ///   - body: A terminal operation.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        _ input: T,
        end body: (T) throws(E) -> U
    ) throws(E) {

        _ = try body(input)
    }

    /// Asynchronously passes a wrapped optional value to a closure and ends the pipeline.
    ///
    /// The function calls `body` only when `input` is non-`nil` and always
    /// returns `Void`.
    ///
    /// - Parameters:
    ///   - input: The optional value whose wrapped value is passed to `body`.
    ///   - body: An asynchronous terminal operation.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        optional input: T?,
        endAsync body: (T) async throws(E) -> U
    ) async throws(E) {

        guard
            let input = input
        else {
            return
        }

        _ = try await body(input)
    }

    /// Synchronously passes a wrapped optional value to a closure and ends the pipeline.
    ///
    /// The function calls `body` only when `input` is non-`nil` and always
    /// returns `Void`.
    ///
    /// - Parameters:
    ///   - input: The optional value whose wrapped value is passed to `body`.
    ///   - body: A terminal operation.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        optional input: T?,
        end body: (T) throws(E) -> U
    ) throws(E) {

        _ = try input.map(body)
    }
}

// MARK: - Mutate

extension Pipeline {
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
    static
    func mutate<T, E: Error>(
        _ input: T,
        _ body: (inout T) async throws(E) -> Void
    ) async throws(E) -> T {

        var tmp = input
        try await body(&tmp)
        return tmp
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
    static
    func mutate<T, E: Error>(
        _ input: T,
        _ body: (inout T) throws(E) -> Void
    ) throws(E) -> T {

        var tmp = input
        try body(&tmp)
        return tmp
    }
}

// MARK: - Inspect

extension Pipeline {
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
    static
    func inspect<T, E: Error>(
        _ input: T,
        _ body: (T) async throws(E) -> Void
    ) async throws(E) -> T {

        try await body(input)
        return input
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
    static
    func inspect<T, E: Error>(
        _ input: T,
        _ body: (T) throws(E) -> Void
    ) throws(E) -> T {

        try body(input)
        return input
    }
}

// MARK: - Ensure

extension Pipeline {
    /// Asynchronously verifies a condition and returns `input` when it succeeds.
    ///
    /// - Parameters:
    ///   - input: The value to validate.
    ///   - condition: An asynchronous predicate evaluated with `input`.
    /// - Returns: `input` when `condition` returns `true`.
    /// - Throws: ``Pipeline/ConditionCheckError/conditionCheckFailed`` when
    ///   `condition` returns `false`, or
    ///   ``Pipeline/ConditionCheckError/predicateBodyError(_:)`` wrapping the
    ///   error thrown by `condition`.
    static
    func ensure<T, E: Error>(
        _ input: T,
        _ condition: (T) async throws(E) -> Bool
    ) async throws(ConditionCheckError<E>) -> T {

        let conditionPassed: Bool
        do {
            conditionPassed = try await condition(input)
        } catch let error {
            throw ConditionCheckError.predicateBodyError(error)
        }

        guard conditionPassed else {
            throw ConditionCheckError.conditionCheckFailed
        }

        return input
    }

    /// Synchronously verifies a condition and returns `input` when it succeeds.
    ///
    /// - Parameters:
    ///   - input: The value to validate.
    ///   - condition: A predicate evaluated with `input`.
    /// - Returns: `input` when `condition` returns `true`.
    /// - Throws: ``Pipeline/ConditionCheckError/conditionCheckFailed`` when
    ///   `condition` returns `false`, or
    ///   ``Pipeline/ConditionCheckError/predicateBodyError(_:)`` wrapping the
    ///   error thrown by `condition`.
    static
    func ensure<T, E: Error>(
        _ input: T,
        _ condition: (T) throws(E) -> Bool
    ) throws(ConditionCheckError<E>) -> T {

        let conditionPassed: Bool
        do {
            conditionPassed = try condition(input)
        } catch let error {
            throw ConditionCheckError.predicateBodyError(error)
        }

        guard conditionPassed else {
            throw ConditionCheckError.conditionCheckFailed
        }

        return input
    }
}

// MARK: - Throw

extension Pipeline {
    /// Unwraps an optional or throws a caller-supplied error.
    ///
    /// - Parameters:
    ///   - input: The optional value to unwrap.
    ///   - getError: A closure that creates the error if `input` is `nil`. The
    ///     function calls it only when the error is needed.
    /// - Returns: The wrapped value of `input`.
    /// - Throws: The error produced by `getError` when `input` is `nil`.
    static
    func unwrapOrThrow<T, E: Error>(
        _ input: T?,
        _ getError: () -> E
    ) throws(E) -> T {

        if
            let input = input {
            return input
        } else {
            throw getError()
        }
    }

    /// Requires a Boolean value to be `true` or throws a caller-supplied error.
    ///
    /// - Parameters:
    ///   - input: The Boolean value to validate.
    ///   - getError: A closure that creates the error if `input` is `false`. The
    ///     function calls it only when the error is needed.
    /// - Throws: The error produced by `getError` when `input` is `false`.
    static
    func throwIfFalse<E: Error>(
        _ input: Bool,
        _ getError: () -> E
    ) throws(E) {

        guard
            input
        else {
            throw getError()
        }
    }

    /// Unwraps a nonempty optional collection or throws a caller-supplied error.
    ///
    /// - Parameters:
    ///   - input: The optional collection to validate and unwrap.
    ///   - getError: A closure that creates the error if `input` is `nil` or
    ///     empty. The function calls it only when the error is needed.
    /// - Returns: The nonempty collection wrapped by `input`.
    /// - Throws: The error produced by `getError` when `input` is `nil` or empty.
    static
    func throwIfEmpty<T, E: Error>(
        _ input: T?,
        _ getError: () -> E
    ) throws(E) -> T where T: Collection {

        if
            let input = input,
            !input.isEmpty {
            return input
        } else {
            throw getError()
        }
    }
}
