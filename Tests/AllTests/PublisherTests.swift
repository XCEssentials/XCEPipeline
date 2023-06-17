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

import Combine

//@testable
import XCEPipeline

//---

class PublisherTests: XCTestCase
{
    var subscription: AnyCancellable?
    
    override
    func setUp()
    {
        super.setUp()
        
        //---
        
        self.subscription = nil
    }
}

extension PublisherTests
{
    func test_executeNow_executesImmediately()
    {
        let exp1 = expectation(description: "Inside 1")
        let exp2 = expectation(description: "Inside 2")
        let expFinal = expectation(description: "Final")
        
        //---
        
        Just(())
            .map {
                exp1.fulfill()
            }
            .map {
                exp2.fulfill()
            }
            .executeNow()
        
        expFinal.fulfill()
        
        //---
        
        wait(for: [exp1, exp2, expFinal], timeout: 1, enforceOrder: true)
    }
    
    func test_executeNow_doesNotRetainAsyncChains()
    {
        let exp1 = expectation(description: "Inside 1")
        exp1.isInverted = true
        
        let expFinal = expectation(description: "Final")
        
        //---
        
        Timer
            .publish(
                every: 0.01,
                on: .main,
                in: .default
            )
            .autoconnect()
            .map { _ in
                exp1.fulfill()
            }
            .executeNow()
        
        expFinal.fulfill()
        
        //---
        
        wait(for: [exp1, expFinal], timeout: 0.02, enforceOrder: true)
    }
    
    func test_observe_retainsAsyncChains()
    {
        let exp1 = expectation(description: "Outside 1")
        let exp2 = expectation(description: "Inside 2")
        
        //---
        
        subscription = Timer
            .publish(
                every: 0.01,
                on: .main,
                in: .default
            )
            .autoconnect()
            .map { _ in
                exp2.fulfill()
            }
            .observe()
        
        exp1.fulfill()
        
        //---
        
        wait(for: [exp1, exp2], timeout: 0.02, enforceOrder: true)
        subscription = nil
    }
    
    func test_ensureMainThread_executesOnCorrectThread()
    {
        let exp0 = expectation(description: "Outside 1")
        
        let exp1 = expectation(description: "Inside NOT to call")
        exp1.isInverted = true
        
        let exp2 = expectation(description: "Inside 2")
        
        let bgQueue = DispatchQueue(label: "SomeBgQueue")
        
        //---
        
        subscription = Just(())
            .subscribe(on: bgQueue)
            .map {
                if Thread.isMainThread { exp1.fulfill() }
            }
            .ensureMainThread()
            .map {
                if Thread.isMainThread { exp2.fulfill() }
            }
            .observe()
        
        exp0.fulfill()
        
        //---
        
        wait(for: [exp0, exp1, exp2], timeout: 0.02, enforceOrder: true)
        subscription = nil
    }
    
    func test_mutate()
    {
        Just(1)
            .mutate {
                $0 += 1
            }
            .map {
                XCTAssertEqual($0, 2)
            }
            .executeNow()
    }
}
