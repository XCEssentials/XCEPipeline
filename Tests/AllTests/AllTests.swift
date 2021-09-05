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

import XCERequirement

//@testable
import XCEPipeline

//---

class AllTests: XCTestCase
{
    enum The: Error
    {
        case error
    }
    
    func test_takeMap()
    {
        let val1: Int = 21
        let val2: Int? = 21
        
        func f1(_ input: Int)
        {
            XCTAssert(input == 21)
        }
        
        func f2(_ input: Int?)
        {
            XCTAssert(input == 21)
        }
        
        func f3(_ input: Int) -> Int
        {
            return input + 1
        }
        
        func f4(_ input: Int?) -> Int?
        {
            return input.map{ $0  + 1 }
        }
        
        XCTAssert(Pipeline.take(val1, map: f1) == ())
        XCTAssert(Pipeline.take(val1, map: f2) == ())
        XCTAssert(Pipeline.take(val1, map: f3) == val1+1)
        XCTAssert(Pipeline.take(val1, map: f4) == val1+1)
        
        XCTAssert(Pipeline.take(val2, map: f2) == ())
        XCTAssert(Pipeline.take(val2, map: f4) == val2.map{ $0 + 1 })
        
        
        XCTAssert(Pipeline.take(optional: val2, map: f1)! == ())
        XCTAssert(Pipeline.take(optional: val2, map: f2)! == ())
        XCTAssert(Pipeline.take(optional: val2, map: f3) == val2.map{ $0 + 1 })
        XCTAssert(Pipeline.take(optional: val2, map: f4) == val2.map{ $0 + 1 })
        
        XCTAssert((val1 ./ f1) == ())
        XCTAssert((val1 ./ f2) == ())
        XCTAssert((val1 ./ f3) == val1+1)
        XCTAssert((val1 ./ f4) == val1+1)
        
        XCTAssert((val2 ?/ f1)! == ())
        XCTAssert((val2 ?/ f2)! == ())
        XCTAssert((val2 ?/ f3) == val2.map{ $0 + 1 })
        XCTAssert((val2 ?/ f4) == val2.map{ $0 + 1 })
    }
    
    func test_takeEnd()
    {
        let val1: Int = 21
        let val2: Int? = 21
        
        func f1(_ input: Int)
        {
            XCTAssert(input == 21)
        }
        
        func f2(_ input: Int?)
        {
            XCTAssert(input == 21)
        }
        
        func f3(_ input: Int) -> Int
        {
            XCTAssert(input == 21)
            return input
        }
        
        func f4(_ input: Int?) -> Int?
        {
            XCTAssert(input == 21)
            return input
        }
        
        Pipeline.take(val1, end: f1)
        Pipeline.take(val1, end: f2)
        Pipeline.take(val1, end: f3)
        Pipeline.take(val1, end: f4)
        
        Pipeline.take(val2, end: f2)
        Pipeline.take(val2, end: f4)
        
        Pipeline.take(optional: val2, end: f1)
        Pipeline.take(optional: val2, end: f2)
        Pipeline.take(optional: val2, end: f3)
        Pipeline.take(optional: val2, end: f4)
        
        val1 .* f1
        val1 .* f2
        val1 .* f3
        val1 .* f4
        
        val2 ?* f1
        val2 ?* f2
        val2 ?* f3
        val2 ?* f4
    }

    func testBasics()
    {
        XCTAssert((22 ./ { "\($0)" }) == "22")
        22 ./ { "\($0)" } ./ { XCTAssert($0 == "22") }
    }

    func testOptionals()
    {
        Optional(22) ./ { String(describing: $0) } ./ { XCTAssert($0 == "Optional(22)") }
        Optional(22) ?/ { "\($0)" } ./ { XCTAssert($0 == "22") }
        Optional(22) ?/ { "\($0)" } ?/ { XCTAssert($0 == "22") }
        Optional(22) ?/ { XCTAssert(type(of: $0) == Int.self) }
        Optional(22) ./ { XCTAssert(type(of: $0) == Optional<Int>.self) }
        Optional<Int>.none ./ { XCTAssert($0 == nil) }
        Optional<Int>.none ?/ { _ in XCTFail("Should never get here!") }
        Optional<Int>.none ?* { _ in XCTFail("Should never get here!") }
    }

    func testMutate()
    {
        22 ./ Pipeline.mutate{ $0 += 1 } ./ { XCTAssert($0 == 23) }
        
        struct ValueObject
        {
            var note: String
        }
        
        let val3 = ValueObject(note: "Hello")
        
        XCTAssert(val3.note == "Hello")
        val3 .+ { $0.note = "World" } ./ { XCTAssert($0.note == "World") }
        
        class ReferenceObject
        {
            var note: String = "Hello"
        }

        let val4 = ReferenceObject()

        XCTAssert(val4.note == "Hello")
        val4 .+ { $0.note = "World" } ./ { XCTAssert($0.note == "World") }
    }

    func testUse()
    {
        22 ./ Pipeline.use{ XCTAssert($0 == 22) } ./ { XCTAssert($0 == 22) }
    }
    
    func test_unwrapOrThrow()
    {
        do
        {
            try Optional<Int>.none
                ./ Pipeline.unwrapOrThrow(The.error)
                ./ { _ in XCTFail("Should never get here!") }
        }
        catch The.error
        {
            // okay
        }
        catch
        {
            XCTFail("Should never get here!")
        }
        
        //---
        
        do
        {
            try Optional(22)
                ./ Pipeline.unwrapOrThrow(The.error)
                ./ { XCTAssert($0 == 22) }
        }
        catch
        {
            XCTFail("Should never get here!")
        }
    }
    
    func test_throwIfNil()
    {
        do
        {
            try Optional<Int>.none
                ./ Pipeline.throwIfNil(The.error)
                ./ { XCTFail("Should never get here!") }
        }
        catch The.error
        {
            // okay
        }
        catch
        {
            XCTFail("Should never get here!")
        }
        
        //---
        
        do
        {
            try Optional(22)
                ./ Pipeline.throwIfNil(The.error)
        }
        catch
        {
            XCTFail("Should never get here!")
        }
    }
    
    func test_throwIfFalse()
    {
        do
        {
            try false
                ./ Pipeline.throwIfFalse(The.error)
                ./ { _ in XCTFail("Should never get here!") }
        }
        catch The.error
        {
            // okay
        }
        catch
        {
            XCTFail("Should never get here!")
        }
        
        //---
        
        do
        {
            try true
                ./ Pipeline.throwIfFalse(The.error)
                ./ { /* it was TRUE */ }
        }
        catch
        {
            XCTFail("Should never get here!")
        }
    }
    
    func test_throwIfEmpty()
    {
        do
        {
            try Array<Int>()
                ./ Pipeline.throwIfEmpty(The.error)
                ./ { _ in XCTFail("Should never get here!") }
        }
        catch The.error
        {
            // okay
        }
        catch
        {
            XCTFail("Should never get here!")
        }
        
        //---
        
        do
        {
            try [22]
                ./ Pipeline.throwIfEmpty(The.error)
                ./ { XCTAssert($0[0] == 22) }
        }
        catch
        {
            XCTFail("Should never get here!")
        }
    }

    func testEnsure()
    {
        do
        {
            try 22
                ./ Pipeline.ensure{ _ in throw The.error }
                ./ { _ in XCTFail("Should never get here!") }
        }
        catch The.error
        {
            // okay
        }
        catch
        {
            XCTFail("Should never get here!")
        }

        //---

        do
        {
            try 22
                ./ Pipeline.ensure("Equal to 22"){ $0 == 22 }
                ./ { XCTAssert($0 == 22) }
        }
        catch
        {
            XCTFail("Should never get here!")
        }

        //---

        do
        {
            try 22
                ./ Pipeline.ensure("Must be 1"){ $0 == 1 }
                ./ { _ in XCTFail("Should never get here!") }
        }
        catch let error as UnsatisfiedRequirement
        {
            XCTAssert(error.requirement == "Must be 1")
            XCTAssert((error.input as! Int) == 22)
            XCTAssert(error.context.function == "testEnsure()")
        }
        catch
        {
            XCTFail("Should never get here!")
        }
    }
    
    func test_forceCastError_nonThrowing()
    {
        struct TheError: Error {}
        func nonThrowingFunc() throws -> String { "OK" }
        
        let sut = { try nonThrowingFunc() !! TheError.self }
        
        XCTAssertNoThrow(try sut())
        XCTAssertEqual(try! sut(), "OK")
    }
    
    func test_forceCastError_throwing()
    {
        struct TheError: Error {}
        func throwingFunc() throws { throw TheError() }
        
        let sut = { try throwingFunc() !! TheError.self }
        
        XCTAssertThrowsError(try sut()) { error in
            switch error
            {
                case is TheError:
                    break // as expected
                    
                default:
                    XCTFail("Thrown unexpected error!")
            }
        }
    }
}
