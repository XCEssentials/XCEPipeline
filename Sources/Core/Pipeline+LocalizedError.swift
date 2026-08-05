// MARK: - LocalizedError conformance

import Foundation

extension Pipeline.ConditionCheckError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .conditionCheckFailed:
            "Pipeline condition check failed."
        case .predicateBodyError(let error):
            "Pipeline predicate body failed: \(error.localizedDescription)"
        }
    }
}
