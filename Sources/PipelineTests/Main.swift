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
