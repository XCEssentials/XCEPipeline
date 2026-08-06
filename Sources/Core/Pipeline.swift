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

/// A namespace for the functions that implement XCEPipeline's operators.
///
/// Most callers use the operators directly. The public `take` functions on
/// this type provide named equivalents for mapping and terminating pipelines.
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
    /// An error produced by the `.!` operator while evaluating a condition.
    public enum ConditionCheckError<E: Error>: Error {
        /// The predicate returned `false`.
        case conditionCheckFailed

        /// The predicate threw an error.
        case predicateBodyError(E)
    }

}
