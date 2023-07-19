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
enum Pipeline {} // scope

// MARK: - Core

public
extension Pipeline
{
    /// Passes `input` value into `body` as is and returns whatever
    /// `body` returns to continue the pipeline.
    static
    func take<T, U>(
        _ input: T,
        map body: (T) throws -> U
        ) rethrows -> U
    {
        return try body(input)
    }

    /// Passes unwrapped `input` value into `body` if it's non-nil,
    /// or does nothing otherwise. Returns whatever `body` supposed
    /// to return (or `nil`) as optional to continue the pipeline.
    /// Analogue of `map(...)` function of `Optional` type.
    static
    func take<T, U>(
        optional input: T?,
        flatMap body: (T) throws -> U?
        ) rethrows -> U?
    {
        return try input.flatMap(body)
    }

    /// Passes `input` value into `body` as is. Returns nothing.
    /// Typically defines final step in pipeline. Alternatively
    /// can be used to "restart" pipeline — continue chain with
    /// next step taking no input (Void).
    static
    func take<T, U>(
        _ input: T,
        end body: (T) throws -> U
        ) rethrows
    {
        _ = try body(input)
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
        ) rethrows
    {
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
    static
    func mutate<T>(
        _ body: @escaping (inout T) throws -> Void
        ) -> (T) throws -> T
    {
        return { var tmp = $0; try body(&tmp); return tmp }
    }

    /**
     Special global-level helper that's intended to be used
     for easy inline mutation of value-type instances.
     */
    static
    func mutate<T>(
        _ body: @escaping (inout T) -> Void
        ) -> (T) -> T
    {
        return { var tmp = $0; body(&tmp); return tmp }
    }
}

// MARK: - Use

extension Pipeline
{
    /**
     Special global-level helper that's intended to be used
     for easy inline mutation of reference-type instances or
     observation (read-only) access to value type instances.
     THROWS!
     */
    static
    func use<T>(
        _ body: @escaping (T) throws -> Void
        ) -> (T) throws -> T
    {
        return { try body($0); return $0 }
    }

    /**
     Special global-level helper that's intended to be used
     for easy inline mutation of reference-type instances or
     observation (read-only) access to value type instances.
     */
    static
    func use<T>(
        _ body: @escaping (T) -> Void
        ) -> (T) -> T
    {
        return { body($0); return $0 }
    }
}

// MARK: - Throw

extension Pipeline
{
    static
    func unwrapOrThrow<T>(
        _ error: Swift.Error
        ) -> (T?) throws -> T
    {
        return {
            try $0 ?! error
        }
    }

    static
    func throwIfNil<T>(
        _ error: Swift.Error
        ) -> (T?) throws -> Void
    {
        return {
            _ = try $0 ?! error
        }
    }

    static
    func throwIfFalse(
        _ error: Swift.Error
        ) -> (Bool) throws -> Void
    {
        return {
            _ = try $0 ?! error
        }
    }

    static
    func throwIfEmpty<T>(
        _ error: Swift.Error
        ) -> (T?) throws -> T
        where
        T: Collection
    {
        return {
            try $0 ?! error
        }
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
    static
    func check<T>(
        _ body: @escaping (T) throws -> Void
        ) -> (T) throws -> T
    {
        return { try body($0); return $0 }
    }

    /**
     Special global-level helper that's intended to be used
     for easy inline checking some conditions about provided input.
     THROWS!
     */
    static
    func ensure<T>(
        _ body: @escaping (T) throws -> Bool
        ) -> (T) throws -> T
    {
        return {
            
            if
                try body($0)
            {
                return $0
            }
            else
            {
                throw CheckFailedError.unsatisfiedCondition
            }
        }
    }
}
