// MARK: - Mutate

extension Pipeline {
    /// Asynchronously passes a mutable copy of `input` to `body` and returns it.
    ///
    /// The `inout` parameter allows `body` to mutate the value or replace it with
    /// another value, including another reference-type instance.
    ///
    /// - Parameters:
    ///   - input: The value to mutate.
    ///   - body: An asynchronous mutation applied to the value as `inout`.
    /// - Returns: The value produced after applying `body`.
    /// - Throws: Any error thrown by `body`.
    static
    func mutate<T, E: Error>(
        _ input: T,
        _ body: (inout T) async throws(E) -> Void
    ) async throws(E) -> T {

        var tmp = input
        try await body(&tmp)
        return tmp
    }

    /// Synchronously passes a mutable copy of `input` to `body` and returns it.
    ///
    /// The `inout` parameter allows `body` to mutate the value or replace it with
    /// another value, including another reference-type instance.
    ///
    /// - Parameters:
    ///   - input: The value to mutate.
    ///   - body: A mutation applied to the value as `inout`.
    /// - Returns: The value produced after applying `body`.
    /// - Throws: Any error thrown by `body`.
    static
    func mutate<T, E: Error>(
        _ input: T,
        _ body: (inout T) throws(E) -> Void
    ) throws(E) -> T {

        var tmp = input
        try body(&tmp)
        return tmp
    }
}
