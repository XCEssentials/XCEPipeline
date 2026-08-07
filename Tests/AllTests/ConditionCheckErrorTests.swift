import XCTest

@testable import XCEPipeline

final class ConditionCheckErrorTests: XCTestCase {
    private enum TestError: Error, Equatable {
        case first
        case second
    }

    func test_equatableConformance() {
        XCTAssertEqual(
            ConditionCheckError<TestError>.conditionCheckFailed,
            .conditionCheckFailed
        )
        XCTAssertEqual(
            ConditionCheckError<TestError>.predicateBodyError(.first),
            .predicateBodyError(.first)
        )
        XCTAssertNotEqual(
            ConditionCheckError<TestError>.predicateBodyError(.first),
            .predicateBodyError(.second)
        )
        XCTAssertNotEqual(
            ConditionCheckError<TestError>.conditionCheckFailed,
            .predicateBodyError(.first)
        )
    }

    func test_sendableConformanceIsInferred() {
        func requireSendable<T: Sendable>(_: T.Type) {}

        requireSendable(ConditionCheckError<TestError>.self)
    }
}
