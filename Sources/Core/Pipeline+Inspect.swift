// MARK: - Inspect

extension Pipeline {
    /// Asynchronously passes `input` to `body` and then returns the same value.
    ///
    /// The closure can't replace `input`, but it can mutate state owned by a
    /// reference-type value.
    ///
    /// - Parameters:
    ///   - input: The value to inspect.
    ///   - body: An asynchronous operation that observes `input`.
    /// - Returns: The original `input` value.
    /// - Throws: Any error thrown by `body`.
    static
    func inspect<T, E: Error>(
        _ input: T,
        _ body: (T) async throws(E) -> Void
    ) async throws(E) -> T {

        try await body(input)
        return input
    }

    /// Synchronously passes `input` to `body` and then returns the same value.
    ///
    /// The closure can't replace `input`, but it can mutate state owned by a
    /// reference-type value.
    ///
    /// - Parameters:
    ///   - input: The value to inspect.
    ///   - body: An operation that observes `input`.
    /// - Returns: The original `input` value.
    /// - Throws: Any error thrown by `body`.
    static
    func inspect<T, E: Error>(
        _ input: T,
        _ body: (T) throws(E) -> Void
    ) throws(E) -> T {

        try body(input)
        return input
    }
}
