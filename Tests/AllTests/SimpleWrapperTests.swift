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

import XCTest

//@testable
import XCEPipeline

//---

class SimpleWrapperTests: XCTestCase
{
    private enum SpecificError: Error, Equatable
    {
        case expected(value: Int)
    }

    func test_take_withOptional()
    {
        let result = take(Optional(1))
            .map { $0 + 1 }
            
        //---
        
        XCTAssertEqual(result, Optional.some(2))
    }
    
    func test_take_forNonOptional()
    {
        let result = take(1)
            .map { $0 + 1 }
            
        //---
        
        XCTAssertEqual(result, take(2))
    }

    func test_asyncMutate_sendableValue() async
    {
        let result = await take(1)
            .mutate { value in
                await Task.yield()
                value += 1
            }

        //---

        XCTAssertEqual(result, take(2))
    }

    func test_nonthrowingHandlersInferNever()
    {
        let mapped = take(1).map { $0 + 1 }
        let inspected = mapped.inspect { XCTAssertEqual($0, 2) }
        let mutated = inspected.mutate { $0 += 1 }

        XCTAssertEqual(mutated, take(3))
    }

    func test_synchronousHandlersPreserveTypedError()
    {
        let thrownValue: SpecificError = .expected(value: 17)
        let map: (Int) throws(SpecificError) -> Int = { _ throws(SpecificError) in throw thrownValue }
        let inspect: (Int) throws(SpecificError) -> Void = { _ throws(SpecificError) in throw thrownValue }
        let mutate: (inout Int) throws(SpecificError) -> Void = { _ throws(SpecificError) in throw thrownValue }

        do { _ = try take(1).map(map); XCTFail("Expected map to throw") }
        catch let caught { XCTAssertEqual(caught, thrownValue) }

        do { _ = try take(1).inspect(inspect); XCTFail("Expected inspect to throw") }
        catch let caught { XCTAssertEqual(caught, thrownValue) }

        do { _ = try take(1).mutate(mutate); XCTFail("Expected mutate to throw") }
        catch let caught { XCTAssertEqual(caught, thrownValue) }
    }

    func test_asyncHandlersPreserveTypedError() async
    {
        let thrownValue: SpecificError = .expected(value: 23)
        let map: (Int) async throws(SpecificError) -> Int = { _ async throws(SpecificError) in throw thrownValue }
        let inspect: (Int) async throws(SpecificError) -> Void = { _ async throws(SpecificError) in throw thrownValue }
        let mutate: (inout Int) async throws(SpecificError) -> Void = { _ async throws(SpecificError) in throw thrownValue }

        do { _ = try await take(1).map(map); XCTFail("Expected map to throw") }
        catch let caught { XCTAssertEqual(caught, thrownValue) }

        do { _ = try await take(1).inspect(inspect); XCTFail("Expected inspect to throw") }
        catch let caught { XCTAssertEqual(caught, thrownValue) }

        do { _ = try await take(1).mutate(mutate); XCTFail("Expected mutate to throw") }
        catch let caught { XCTAssertEqual(caught, thrownValue) }
    }
}
