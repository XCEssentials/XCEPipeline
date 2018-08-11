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

class MainTests: XCTestCase
{
    func testBasics()
    {
        XCTAssert((22 ./ { "\($0)" }) == "22")
        22 ./ { "\($0)" } ./ { XCTAssert($0 == "22") }
    }

    func testOptionals()
    {
        Optional(22) ?/ { "\($0)" } ./ { XCTAssert($0 == "22") }
        Optional(22) ?/ { "\($0)" } ?/ { XCTAssert($0 == "22") }
        Optional(22) ?/ { XCTAssert(type(of: $0) == Int.self) }
        Optional(22) ./ { XCTAssert(type(of: $0) == Optional<Int>.self) }
    }

    func testMutate()
    {
        22 ./ mutate{ $0 += 1 } ./ { XCTAssert($0 == 23) }
    }

    func testUse()
    {
        22 ./ use{ print($0) } ./ { XCTAssert($0 == 22) }
    }

    func testEnsure()
    {
        do
        {
            try 22
                ./ ensure{ _ in throw PipelineError.unsatisfiedCondition(message: "XYZ") }
                ./ { _ in XCTFail("Should never get here!") }
        }
        catch PipelineError.unsatisfiedCondition(let message)
        {
            XCTAssert(message == "XYZ")
        }
        catch
        {
            XCTFail("Should never get here!")
        }

        //---

        do
        {
            try 22 ./ ensure{ $0 == 22 } ./ { XCTAssert($0 == 22) }
        }
        catch
        {
            XCTFail("Should never get here!")
        }

        //---

        do
        {
            try 22
                ./ ensure("Must be 1"){ $0 == 1 }
                ./ { _ in XCTFail("Should never get here!") }
        }
        catch PipelineError.unsatisfiedCondition(let message)
        {
            XCTAssert(message == "Must be 1")
        }
        catch
        {
            XCTFail("Should never get here!")
        }
    }
}
