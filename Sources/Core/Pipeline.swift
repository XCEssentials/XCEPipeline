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
 - https://github.com/gilesvangruisen/Pipeline ⚠️ autoformat
 - https://github.com/pauljeannot/SwiftyBash
 - https://github.com/patgoley/Pipeline/blob/master/Pipeline/Operators.swift
 - https://github.com/danthorpe/Pipe (outdated!)
 - https://github.com/jarsen/Pipes (outdated!)
 */

public
enum Pipeline // scope
{
    struct FailedConditionCheck: Error {}
}

// MARK: - Core

public
extension Pipeline
{
    /// Passes `input` value into `body` as is and returns whatever
    /// `body` returns to continue the pipeline.
    @Sendable
    static
    func take<T, U>(
        _ input: T,
        mapAsync body: (T) async throws -> U
    ) async rethrows -> U {
        
        try await body(input)
    }

    /// Passes `input` value into `body` as is and returns whatever
    /// `body` returns to continue the pipeline.
    static
    func take<T, U>(
        _ input: T,
        map body: (T) throws -> U
    ) rethrows -> U {
        
        try body(input)
    }

    /// Passes unwrapped `input` value into `body` if it's non-nil,
    /// or does nothing otherwise. Returns whatever `body` supposed
    /// to return (or `nil`) as optional to continue the pipeline.
    /// Analogue of `map(...)` function of `Optional` type.
    @Sendable
    static
    func take<T, U>(
        optional input: T?,
        flatMapAsync body: (T) async throws -> U?
    ) async rethrows -> U? {
        
        guard
            let input = input
        else
        {
            return nil
        }
        
        return try await body(input)
    }

    /// Passes unwrapped `input` value into `body` if it's non-nil,
    /// or does nothing otherwise. Returns whatever `body` supposed
    /// to return (or `nil`) as optional to continue the pipeline.
    /// Analogue of `map(...)` function of `Optional` type.
    static
    func take<T, U>(
        optional input: T?,
        flatMap body: (T) throws -> U?
    ) rethrows -> U? {
        
        try input.flatMap(body)
    }

    /// Passes `input` value into `body` as is. Returns nothing.
    /// Typically defines final step in pipeline. Alternatively
    /// can be used to "restart" pipeline — continue chain with
    /// next step taking no input (Void).
    @Sendable
    static
    func take<T, U>(
        _ input: T,
        endAsync body: (T) async throws -> U
    ) async rethrows {
        
        _ = try await body(input)
    }
    
    /// Passes `input` value into `body` as is. Returns nothing.
    /// Typically defines final step in pipeline. Alternatively
    /// can be used to "restart" pipeline — continue chain with
    /// next step taking no input (Void).
    static
    func take<T, U>(
        _ input: T,
        end body: (T) throws -> U
    ) rethrows {
        
        _ = try body(input)
    }
    
    /// Passes unwrapped `input` value into `body` if it's non-nil,
    /// or does nothing otherwise. Returns nothing anyway.
    /// Typically defines final step in pipeline. Alternatively
    /// can be used to "restart" pipeline — continue chain with
    /// next step taking no input (Void).
    @Sendable
    static
    func take<T, U>(
        optional input: T?,
        endAsync body: (T) async throws -> U
    ) async rethrows {
        
        guard
            let input = input
        else
        {
            return
        }
        
        _ = try await body(input)
    }
    
    /// Passes unwrapped `input` value into `body` if it's non-nil,
    /// or does nothing otherwise. Returns nothing anyway.
    /// Typically defines final step in pipeline. Alternatively
    /// can be used to "restart" pipeline — continue chain with
    /// next step taking no input (Void).
    static
    func take<T, U>(
        optional input: T?,
        end body: (T) throws -> U
    ) rethrows {
        
        _ = try input.map(body)
    }
}

// MARK: - Mutate

extension Pipeline
{
    /**
     Special global-level helper that's intended to be used
     for easy inline mutation of value-type instances. THROWS!
     */
    @Sendable
    static
    func mutate<T>(
        _ input: T,
        _ body: (inout T) async throws -> Void
    ) async rethrows -> T {
        
        var tmp = input
        try await body(&tmp)
        return tmp
    }
    
    /**
     Special global-level helper that's intended to be used
     for easy inline mutation of value-type instances. THROWS!
     */
    static
    func mutate<T>(
        _ input: T,
        _ body: (inout T) throws -> Void
    ) rethrows -> T {
        
        var tmp = input
        try body(&tmp)
        return tmp
    }
}

// MARK: - Inspect

extension Pipeline
{
    /**
     Special global-level helper that's intended to be used
     for easy inline mutation of reference-type instances or
     inspection (read-only access) of value type instances.
     THROWS!
     */
    @Sendable
    static
    func inspect<T>(
        _ input: T,
        _ body: (T) async throws -> Void
    ) async rethrows -> T {
        
        try await body(input)
        return input
    }
    
    /**
     Special global-level helper that's intended to be used
     for easy inline mutation of reference-type instances or
     inspection (read-only access) of value type instances.
     THROWS!
     */
    static
    func inspect<T>(
        _ input: T,
        _ body: (T) throws -> Void
    ) rethrows -> T {
        
        try body(input)
        return input
    }
}

// MARK: - Ensure

extension Pipeline
{
    /**
     Special global-level helper that's intended to be used
     for easy inline checking some conditions about provided input.
     THROWS!
     */
    @Sendable
    static
    func ensure<T>(
        _ input: T,
        _ condition: (T) async throws -> Bool
    ) async throws -> T {
        
        if
            try await condition(input)
        {
            return input
        }
        else
        {
            throw Pipeline.FailedConditionCheck()
        }
    }
    
    /**
     Special global-level helper that's intended to be used
     for easy inline checking some conditions about provided input.
     THROWS!
     */
    static
    func ensure<T>(
        _ input: T,
        _ condition: (T) throws -> Bool
    ) throws -> T {
        
        if
            try condition(input)
        {
            return input
        }
        else
        {
            throw Pipeline.FailedConditionCheck()
        }
    }
}

// MARK: - Throw

extension Pipeline
{
    @Sendable
    static
    func unwrapOrThrow<T>(
        _ input: T?,
        _ getError: () -> Swift.Error
    ) throws -> T {
        
        if
            let input = input
        {
            return input
        }
        else
        {
            throw getError()
        }
    }

    @Sendable
    static
    func throwIfFalse(
        _ input: Bool,
        _ getError: () -> Swift.Error
    ) throws -> Void {
        
        guard
            input
        else
        {
            throw getError()
        }
    }

    @Sendable
    static
    func throwIfEmpty<T>(
        _ input: T?,
        _ getError: () -> Swift.Error
    ) throws -> T where T: Collection {
        
        if
            let input = input,
            !input.isEmpty
        {
            return input
        }
        else
        {
            throw getError()
        }
    }
}
