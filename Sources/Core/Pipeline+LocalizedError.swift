// MARK: - LocalizedError conformance

import Foundation

extension Pipeline.ConditionCheckError: LocalizedError {
    /// A human-readable description of the condition or predicate failure.
    public var errorDescription: String? {
        switch self {
        case .conditionCheckFailed:
            "Pipeline condition check failed."
        case .predicateBodyError(let error):
            "Pipeline predicate body failed: \(error.localizedDescription)"
        }
    }
}
