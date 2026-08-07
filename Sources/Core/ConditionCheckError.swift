import Foundation

/// An error produced by the `.!` operator while evaluating a condition.
public enum ConditionCheckError<E: Error>: Error {
    /// The predicate returned `false`.
    case conditionCheckFailed

    /// The predicate threw an error.
    case predicateBodyError(E)
}

extension ConditionCheckError: Equatable where E: Equatable {}

extension ConditionCheckError: LocalizedError {
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
