#if canImport(Combine)

import Foundation
import Combine

//---

private final class FirstResultState<Output: Sendable>: @unchecked Sendable
{
    typealias Continuation = CheckedContinuation<Output, Error>

    enum StateError: Error
    {
        case continuationNotInstalled
        case subscriptionAlreadyInstalled
    }

    enum Resolution
    {
        case wonBeforeSubscription(Continuation)
        case won(Continuation, AnyCancellable)
        case alreadyResolved

        func resume(returning output: Output)
        {
            switch self
            {
                case .wonBeforeSubscription(let continuation):
                    continuation.resume(returning: output)

                case .won(let continuation, let cancellable):
                    continuation.resume(returning: output)
                    cancellable.cancel()

                case .alreadyResolved:
                    break
            }
        }

        func resume(throwing error: Error)
        {
            switch self
            {
                case .wonBeforeSubscription(let continuation):
                    continuation.resume(throwing: error)

                case .won(let continuation, let cancellable):
                    continuation.resume(throwing: error)
                    cancellable.cancel()

                case .alreadyResolved:
                    break
            }
        }
    }

    enum Cancellation
    {
        case recorded
        case resolve(Resolution)
        case alreadyResolved

        func execute()
        {
            if case .resolve(let resolution) = self
            {
                resolution.resume(throwing: CancellationError())
            }
        }
    }

    private enum Phase
    {
        case awaitingContinuation
        case cancelledBeforeContinuation
        case awaitingSubscription(Continuation)
        case subscribed(Continuation, AnyCancellable)
        case resolved
    }

    private let lock = NSLock()
    private var phase = Phase.awaitingContinuation

    func install(_ continuation: Continuation) -> Bool
    {
        lock.lock()
        defer { lock.unlock() }

        switch phase
        {
            case .awaitingContinuation:
                phase = .awaitingSubscription(continuation)
                return true

            case .cancelledBeforeContinuation:
                phase = .resolved
                return false

            case .awaitingSubscription, .subscribed, .resolved:
                return false
        }
    }

    func install(
        _ cancellable: AnyCancellable
    ) throws(StateError) -> Bool
    {
        lock.lock()
        defer { lock.unlock() }

        switch phase
        {
            case .awaitingSubscription(let continuation):
                phase = .subscribed(continuation, cancellable)
                return true

            case .resolved:
                return false

            case .subscribed:
                throw .subscriptionAlreadyInstalled

            case .awaitingContinuation, .cancelledBeforeContinuation:
                throw .continuationNotInstalled
        }
    }

    func resolve() -> Resolution
    {
        lock.lock()
        defer { lock.unlock() }

        switch phase
        {
            case .awaitingSubscription(let continuation):
                phase = .resolved
                return .wonBeforeSubscription(continuation)

            case .subscribed(let continuation, let cancellable):
                phase = .resolved
                return .won(continuation, cancellable)

            case .awaitingContinuation, .cancelledBeforeContinuation, .resolved:
                return .alreadyResolved
        }
    }

    func cancel() -> Cancellation
    {
        lock.lock()
        defer { lock.unlock() }

        switch phase
        {
            case .awaitingContinuation:
                phase = .cancelledBeforeContinuation
                return .recorded

            case .awaitingSubscription(let continuation):
                phase = .resolved
                return .resolve(.wonBeforeSubscription(continuation))

            case .subscribed(let continuation, let cancellable):
                phase = .resolved
                return .resolve(.won(continuation, cancellable))

            case .cancelledBeforeContinuation, .resolved:
                return .alreadyResolved
        }
    }
}

public
extension Just
{
    /// Call this for **SYNC** only streams
    /// (those that start with `Just(...)`),
    /// whole chain will be executed immediately
    /// and released immediately.
    func executeNow()
    {
        _ = sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
    }
}

public
extension Publisher
{
    /// Convenience adapter for async/await workflow.
    ///
    /// Resumes with the **first** value emitted by the publisher, or throws:
    /// - the publisher's own error on failure, or
    /// - `CancellationError` if the waiting task is cancelled, or
    /// - ``Pipeline/CompletedWithoutValue`` if the publisher completes
    ///   without emitting any value.
    ///
    /// Credits:
    /// https://medium.com/geekculture/from-combine-to-async-await-c08bf1d15b77
    func waitForFirstResult() async throws -> Output where Output: Sendable
    {
        let state = FirstResultState<Output>()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                guard state.install(continuation) else
                {
                    continuation.resume(throwing: CancellationError())
                    return
                }

                let cancellable = self
                    .sink { result in
                        let resolution = state.resolve()

                        switch result
                        {
                            case .finished:
                                resolution.resume(throwing: Pipeline.CompletedWithoutValue())

                            case .failure(let error):
                                resolution.resume(throwing: error)
                        }
                    }
                    receiveValue: {
                        state.resolve().resume(returning: $0)
                    }

                do
                {
                    guard try state.install(cancellable) else
                    {
                        cancellable.cancel()
                        return
                    }
                }
                catch
                {
                    let resolution = state.resolve()
                    resolution.resume(throwing: error)
                    cancellable.cancel()
                }
            }
        } onCancel: {
            state.cancel().execute()
        }
    }
    
    /// Simple shortcut to connect multiple invocations
    /// upstream and initiate the chain.
    func observe() -> AnyCancellable
    {
        sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
    }
    
    func ensureMainThread() -> Publishers.ReceiveOn<Self, DispatchQueue>
    {
        receive(on: DispatchQueue.main)
    }
    
    /// Convert a `Result` producing mapping into
    /// a `Future`.
    func flatMap<T>(
        _ body: @escaping (Output) -> Result<T, Failure>
    ) -> AnyPublisher<T, Failure> {
        
        flatMap { input in
            Future { resolver in
                input
                    ./ body
                    ./ resolver
            }
        }
        .eraseToAnyPublisher()
    }
    
    func mutate(
        _ body: @escaping (inout Output) -> Void
    ) -> AnyPublisher<Output, Failure> {
        
        return self
            .map {
                $0 .+ body
            }
            .eraseToAnyPublisher()
    }
    
    func tryMutate(
        _ body: @escaping (inout Output) throws -> Void
    ) -> AnyPublisher<Output, Error> {
        
        return self
            .tryMap {
                try $0 .+ body
            }
            .eraseToAnyPublisher()
    }
    
    func tryMutate(
        errorMapping: @escaping (Error) -> Failure,
        _ body: @escaping (inout Output) throws -> Void
    ) -> AnyPublisher<Output, Failure> {
        
        flatMap { input in
            
            do
            {
                return try input
                    .+ body
                    ./ Result<Output, Failure>.success
            }
            catch
            {
                return error
                    ./ errorMapping
                    ./ Result<Output, Failure>.failure
            }
        }
    }
    
    /// Inspect the upstream value and pass it downstream.
    func inspectValue(
        _ body: @escaping (Output) -> Void
    ) -> AnyPublisher<Output, Failure> {
        
        return self
            .handleEvents(
                receiveOutput: body
            )
            .eraseToAnyPublisher()
    }
    
    /// Inspect the upstream value and pass it downstream
    /// or trigger failure by throwing error.
    func tryInspectValue(
        _ body: @escaping (Output) throws -> Void
    ) -> AnyPublisher<Output, Error> {
        
        return self
            .tryMap {
                
                try body($0)
                return $0
            }
            .eraseToAnyPublisher()
    }
    
    /// Inspect the upstream error and pass it downstream.
    func inspectError(
        _ body: @escaping (Failure) -> Void
    ) -> AnyPublisher<Output, Failure> {
        
        return self
            .handleEvents(
                receiveCompletion: { completion in
                    
                    switch completion
                    {
                        case .failure(let error):
                            body(error)
                            
                        default:
                            break
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}

#endif
