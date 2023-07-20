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

//import XCERequirement

@testable
import XCEPipeline

//---

class OperatorsAsyncTests: XCTestCase
{
    enum The: Error
    {
        case error
    }
}

// MARK: - Tests

extension OperatorsAsyncTests
{
    @MainActor // this is necessary to avoid warnings/errors
    func test_operator_onMainActor_context()
    {
        @MainActor class TheActor { func doSomething(_ : Int) {} }
        
        //---
        
        /// If NOT on main actor context, then following error happens:
        ///
        /// ```
        /// Converting function value of type '@MainActor (Int) -> ()'
        /// to '(Int) throws -> ()' loses global actor 'MainActor'
        /// ```
        1 ./ TheActor().doSomething(_:)
    }
    
    func test_takeMap() async
    {
        actor TheActor { func doSomething(_ : Int) {} }
        
        //---
        
        await 1
            ./ { await TheActor().doSomething($0) }
    }
    
    func test_takeOptionalFlatMap_some() async
    {
        let valMaybe: Int? = 1
        
        actor TheActor
        {
            func inc(_ val: Int) -> Int?
            {
                val + 1
            }
        }
        
        //---
        
        await valMaybe
            .? { await TheActor().inc($0) }
            .? {
                XCTAssertEqual($0, 2)
                XCTAssertEqual("\(type(of: $0))", "Int")
            }
        
        await valMaybe
            .? { await TheActor().inc($0) }
            ./ {
                XCTAssertEqual($0, 2)
                XCTAssertEqual("\(type(of: $0))", "Optional<Int>")
            }
    }
    
    func test_takeOptionalFlatMap_none() async
    {
        let valMaybe: Int? = nil
        
        actor TheActor { func inc(_: Int) {} }
        
        //---
        
        await valMaybe
            .? { await TheActor().inc($0) }
            .? { XCTFail("Should never get here!") }
    }
    
    func test_takeEnd() async
    {
        actor TheActor { func doSomething(_ : Int) -> Int { 0 } }
        
        //---
        
        await 1
            .* { await TheActor().doSomething($0) }
    }
    
    func test_takeOptionalEnd_some() async
    {
        let valMaybe: Int? = 1
        
        actor TheActor
        {
            func inc(_ val: Int) -> Int?
            {
                val + 1
            }
        }
        
        //---
        
        await valMaybe
            .?* { await TheActor().inc($0) }
    }
    
    func test_takeOptionalEnd_none() async
    {
        let valMaybe: Int? = nil
        
        actor TheActor { func inc(_: Int) {} }
        
        //---
        
        await valMaybe
            .?* { await TheActor().inc($0); XCTFail("Should never get here!") }
    }
    
    func test_mutate() async
    {
        actor TheActor
        {
            func inc(_ val: inout Int)
            {
                val += 1
            }
        }
        
        //---
        
        await 1
            .+ { await TheActor().inc(&$0) }
            ./ {
                XCTAssertEqual($0, 2)
                XCTAssertEqual("\(type(of: $0))", "Int")
            }
    }
    
    func test_inspect() async
    {
        actor TheActor { func inspect(_ val: Int) {} }
        
        //---
        
        await 1
            .- { await TheActor().inspect($0) }
            ./ {
                XCTAssertEqual($0, 1)
                XCTAssertEqual("\(type(of: $0))", "Int")
            }
    }
    
    func test_ensure_true() async throws
    {
        actor TheActor { func ensure(_: Int) -> Bool { true } }
        
        //---
        
        try await 1
            .! { await TheActor().ensure($0) }
            ./ {
                XCTAssertEqual($0, 1)
                XCTAssertEqual("\(type(of: $0))", "Int")
            }
    }
    
    func test_ensure_false() async throws
    {
        actor TheActor { func ensure(_: Int) -> Bool { false } }
        
        //---
        
        do
        {
            _ = try await 1
                .! { await TheActor().ensure($0) }
        }
        catch _ as Pipeline.FailedConditionCheck
        {
            // ✅ ok
        }
        catch
        {
            XCTFail("Should never get here!")
        }
    }
}
