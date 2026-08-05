// MARK: - Throw

extension Pipeline {
    /// Unwraps an optional or throws a caller-supplied error.
    ///
    /// - Parameters:
    ///   - input: The optional value to unwrap.
    ///   - getError: A closure that creates the error if `input` is `nil`. The
    ///     function calls it only when the error is needed.
    /// - Returns: The wrapped value of `input`.
    /// - Throws: The error produced by `getError` when `input` is `nil`.
    static
    func unwrapOrThrow<T, E: Error>(
        _ input: T?,
        _ getError: () -> E
    ) throws(E) -> T {

        if
            let input = input {
            return input
        } else {
            throw getError()
        }
    }

    /// Requires a Boolean value to be `true` or throws a caller-supplied error.
    ///
    /// - Parameters:
    ///   - input: The Boolean value to validate.
    ///   - getError: A closure that creates the error if `input` is `false`. The
    ///     function calls it only when the error is needed.
    /// - Throws: The error produced by `getError` when `input` is `false`.
    static
    func throwIfFalse<E: Error>(
        _ input: Bool,
        _ getError: () -> E
    ) throws(E) {

        guard
            input
        else {
            throw getError()
        }
    }

    /// Unwraps a nonempty optional collection or throws a caller-supplied error.
    ///
    /// - Parameters:
    ///   - input: The optional collection to validate and unwrap.
    ///   - getError: A closure that creates the error if `input` is `nil` or
    ///     empty. The function calls it only when the error is needed.
    /// - Returns: The nonempty collection wrapped by `input`.
    /// - Throws: The error produced by `getError` when `input` is `nil` or empty.
    static
    func throwIfEmpty<T, E: Error>(
        _ input: T?,
        _ getError: () -> E
    ) throws(E) -> T where T: Collection {

        if
            let input = input,
            !input.isEmpty {
            return input
        } else {
            throw getError()
        }
    }
}
