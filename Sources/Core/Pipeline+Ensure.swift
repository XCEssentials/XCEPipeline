// MARK: - Ensure

extension Pipeline {
    /// Asynchronously verifies a condition and returns `input` when it succeeds.
    ///
    /// - Parameters:
    ///   - input: The value to validate.
    ///   - condition: An asynchronous predicate evaluated with `input`.
    /// - Returns: `input` when `condition` returns `true`.
    /// - Throws: ``ConditionCheckError/conditionCheckFailed`` when
    ///   `condition` returns `false`, or
    ///   ``ConditionCheckError/predicateBodyError(_:)`` wrapping the
    ///   error thrown by `condition`.
    static
    func ensure<T, E: Error>(
        _ input: T,
        _ condition: (T) async throws(E) -> Bool
    ) async throws(ConditionCheckError<E>) -> T {

        let conditionPassed: Bool
        do {
            conditionPassed = try await condition(input)
        } catch let error {
            throw ConditionCheckError.predicateBodyError(error)
        }

        guard conditionPassed else {
            throw ConditionCheckError.conditionCheckFailed
        }

        return input
    }

    /// Synchronously verifies a condition and returns `input` when it succeeds.
    ///
    /// - Parameters:
    ///   - input: The value to validate.
    ///   - condition: A predicate evaluated with `input`.
    /// - Returns: `input` when `condition` returns `true`.
    /// - Throws: ``ConditionCheckError/conditionCheckFailed`` when
    ///   `condition` returns `false`, or
    ///   ``ConditionCheckError/predicateBodyError(_:)`` wrapping the
    ///   error thrown by `condition`.
    static
    func ensure<T, E: Error>(
        _ input: T,
        _ condition: (T) throws(E) -> Bool
    ) throws(ConditionCheckError<E>) -> T {

        let conditionPassed: Bool
        do {
            conditionPassed = try condition(input)
        } catch let error {
            throw ConditionCheckError.predicateBodyError(error)
        }

        guard conditionPassed else {
            throw ConditionCheckError.conditionCheckFailed
        }

        return input
    }
}
