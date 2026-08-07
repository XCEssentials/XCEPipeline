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

/// Wraps a value to start a fluent chain.
///
/// This is the public construction entry point for ``SimpleWrapper``.
///
/// - Parameter value: The initial value.
/// - Returns: A wrapper containing `value`.
public
func take<T>(_ value: T) -> SimpleWrapper<T> {
    .init(value)
}

/// Returns an optional unchanged so optional and nonoptional chains can share
/// a consistent `take` entry point.
///
/// Unlike the nonoptional `take(_:)` overload, this function does not create a
/// ``SimpleWrapper``. Use Optional's `map`, ``Optional/inspect(_:)``,
/// ``Optional/mutate(_:)``, and ``Optional/filter(_:)`` to continue the
/// chain.
///
/// - Parameter value: The optional value with which to start the chain.
/// - Returns: `value`, unchanged.
public
func take<T>(_ value: T?) -> T? {
    value
}
