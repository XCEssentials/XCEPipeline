// MARK: - Core

extension Pipeline {
    /// Asynchronously passes `input` to a closure and returns the closure's result.
    ///
    /// - Parameters:
    ///   - input: The value to transform.
    ///   - body: An asynchronous transformation to apply to `input`.
    /// - Returns: The value returned by `body`.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        _ input: T,
        mapAsync body: (T) async throws(E) -> U
    ) async throws(E) -> U {

        try await body(input)
    }

    /// Synchronously passes `input` to a closure and returns the closure's result.
    ///
    /// - Parameters:
    ///   - input: The value to transform.
    ///   - body: A transformation to apply to `input`.
    /// - Returns: The value returned by `body`.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        _ input: T,
        map body: (T) throws(E) -> U
    ) throws(E) -> U {

        try body(input)
    }

    /// Asynchronously transforms the wrapped value of an optional.
    ///
    /// This function behaves like `Optional.flatMap`: it calls `body` only when
    /// `input` is non-`nil` and returns `nil` otherwise.
    ///
    /// - Parameters:
    ///   - input: The optional value to transform.
    ///   - body: An asynchronous transformation that can return `nil`.
    /// - Returns: The result of `body`, or `nil` when `input` is `nil`.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        optional input: T?,
        flatMapAsync body: (T) async throws(E) -> U?
    ) async throws(E) -> U? {

        guard
            let input = input
        else {
            return nil
        }

        return try await body(input)
    }

    /// Synchronously transforms the wrapped value of an optional.
    ///
    /// This function behaves like `Optional.flatMap`: it calls `body` only when
    /// `input` is non-`nil` and returns `nil` otherwise.
    ///
    /// - Parameters:
    ///   - input: The optional value to transform.
    ///   - body: A transformation that can return `nil`.
    /// - Returns: The result of `body`, or `nil` when `input` is `nil`.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        optional input: T?,
        flatMap body: (T) throws(E) -> U?
    ) throws(E) -> U? {

        try input.flatMap(body)
    }

    /// Asynchronously passes `input` to a closure and discards its result.
    ///
    /// Use this function for a terminal pipeline step. Because the function
    /// returns `Void`, it can also be followed by a step that accepts `Void`.
    ///
    /// - Parameters:
    ///   - input: The value to pass to `body`.
    ///   - body: An asynchronous terminal operation.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        _ input: T,
        endAsync body: (T) async throws(E) -> U
    ) async throws(E) {

        _ = try await body(input)
    }

    /// Synchronously passes `input` to a closure and discards its result.
    ///
    /// Use this function for a terminal pipeline step. Because the function
    /// returns `Void`, it can also be followed by a step that accepts `Void`.
    ///
    /// - Parameters:
    ///   - input: The value to pass to `body`.
    ///   - body: A terminal operation.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        _ input: T,
        end body: (T) throws(E) -> U
    ) throws(E) {

        _ = try body(input)
    }

    /// Asynchronously passes a wrapped optional value to a closure and ends the pipeline.
    ///
    /// The function calls `body` only when `input` is non-`nil` and always
    /// returns `Void`.
    ///
    /// - Parameters:
    ///   - input: The optional value whose wrapped value is passed to `body`.
    ///   - body: An asynchronous terminal operation.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        optional input: T?,
        endAsync body: (T) async throws(E) -> U
    ) async throws(E) {

        guard
            let input = input
        else {
            return
        }

        _ = try await body(input)
    }

    /// Synchronously passes a wrapped optional value to a closure and ends the pipeline.
    ///
    /// The function calls `body` only when `input` is non-`nil` and always
    /// returns `Void`.
    ///
    /// - Parameters:
    ///   - input: The optional value whose wrapped value is passed to `body`.
    ///   - body: A terminal operation.
    /// - Throws: Any error thrown by `body`.
    static
    func take<T, U, E: Error>(
        optional input: T?,
        end body: (T) throws(E) -> U
    ) throws(E) {

        _ = try input.map(body)
    }
}
