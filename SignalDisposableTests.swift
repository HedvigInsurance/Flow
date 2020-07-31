//
//  SignalDisposableTests.swift
//  Flow
//
//  Created by sam on 31.7.20.
//  Copyright © 2020 iZettle. All rights reserved.
//

import Foundation
import XCTest
import Flow

class SignalDisposableTests: XCTestCase {
    func testDisposal() {
        let expectation = self.expectation(description: "Does dispose")

        let disposer = Disposer {
            expectation.fulfill()
        }
        
        let signal = ReadWriteSignal(false).hold(disposer)
        
        let bag = DisposeBag()

        bag += signal.atOnce().onValue { _ in }
        bag += signal.atOnce().onValue { _ in }
        
        bag.dispose()

        waitForExpectations(timeout: 10) { error in
            bag.dispose()
        }
    }
    
    func testRefCount() {
        let expectation = self.expectation(description: "Does keep refcount")
        var hasBeenCalled = false

        let disposer = Disposer {
            if !hasBeenCalled {
                XCTFail()
            }
        }
        
        let signal = ReadWriteSignal(false).hold(disposer)
        
        let bagOne = DisposeBag()
        let bagTwo = DisposeBag()

        bagOne += signal.atOnce().onValue { _ in }
        bagTwo += signal.onValue { _ in
            hasBeenCalled = true
            expectation.fulfill()
        }
        
        bagOne.dispose()
        
        signal.value = true

        waitForExpectations(timeout: 10) { error in
            bagOne.dispose()
            bagTwo.dispose()
        }
    }
}
