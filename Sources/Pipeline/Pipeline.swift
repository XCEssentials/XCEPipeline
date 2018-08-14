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

// MARK: - Operators

precedencegroup CompositionPrecedence {
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
    associativity: left
}

infix operator ./ : CompositionPrecedence // pass through
infix operator .| : CompositionPrecedence // pass & stop chain
infix operator ?/ : CompositionPrecedence // pass through unwrapped optional
infix operator ?| : CompositionPrecedence // pass through unwrapped optional & stop chain

// MARK: - Operators implementation

public
//infix
func ./ <T, U>(
    input: T,
    body: (T) throws -> U
    ) rethrows -> U
{
    return try body(input)
}

public
//infix
func .| <T>(
    input: T,
    body: (T) throws -> Void
    ) rethrows
{
    return try body(input)
}

public
//infix
func ?/ <T, U>(
    input: T?,
    body: (T) throws -> U
    ) rethrows -> U?
{
    return try input.map(body)
}

public
//infix
func ?| <T>(
    input: T?,
    body: (T) throws -> Void
    ) rethrows
{
    try input.map(body)
}

// MARK: - Mutate

/**
 Special global-level helper that's intended to be used
 for easy inline mutation of value-type instances. THROWS!
 */
public
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
public
func mutate<T>(
    _ body: @escaping (inout T) -> Void
    ) -> (T) -> T
{
    return { var tmp = $0; body(&tmp); return tmp }
}

// MARK: - Use

/**
 Special global-level helper that's intended to be used
 for easy inline mutation of reference-type instances or
 observation (read-only) access to value type instances.
 THROWS!
 */
public
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
public
func use<T>(
    _ body: @escaping (T) -> Void
    ) -> (T) -> T
{
    return { body($0); return $0 }
}

// MARK: - Ensure

/**
 Special global-level helper that's intended to be used
 for easy inline checking some conditions about provided input.
 THROWS!
 */
public
func ensure<T>(
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
public
func ensure<T>(
    file: String = #file,
    line: Int = #line,
    function: String = #function,
    _ description: String? = nil,
    _ body: @escaping (T) -> Bool
    ) -> (T) throws -> T
{
     return {

        if
            body($0)
        {
            return $0
        }
        else
        {
            throw PipelineError.conditionFailed(
                context: (file, line, function),
                description
            )
        }
    }
}

public
func extend<T0, X>(
    with anotherValue: X
    ) -> (T0) -> (T0, X)
{
    return { ($0, anotherValue) }
}

//swiftlint:disable large_tuple

public
func extend<T0, T1, X>(
    with anotherValue: X
    ) -> (T0, T1) -> (T0, T1, X)
{
    return { ($0, $1, anotherValue) }
}

public
func extend<T0, T1, T2, X>(
    with anotherValue: X
    ) -> (T0, T1, T2) -> (T0, T1, T2, X)
{
    return { ($0, $1, $2, anotherValue) }
}

public
func extend<T0, T1, T2, T3, X>(
    with anotherValue: X
    ) -> (T0, T1, T2, T3) -> (T0, T1, T2, T3, X)
{
    return { ($0, $1, $2, $3, anotherValue) }
}

public
func extend<T0, T1, T2, T3, T4, X>(
    with anotherValue: X
    ) -> (T0, T1, T2, T3, T4) -> (T0, T1, T2, T3, T4, X)
{
    return { ($0, $1, $2, $3, $4, anotherValue) }
}

public
func extend<T0, T1, T2, T3, T4, T5, X>(
    with anotherValue: X
    ) -> (T0, T1, T2, T3, T4, T5) -> (T0, T1, T2, T3, T4, T5, X)
{
    return { ($0, $1, $2, $3, $4, $5, anotherValue) }
}

//swiftlint:enable large_tuple
