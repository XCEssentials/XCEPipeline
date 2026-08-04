#if canImport(Combine)

import Foundation
import Combine

//---

private final class FirstResultState: @unchecked Sendable
{
    enum StateError: Error
    {
        case subscriptionAlreadyInstalled
    }

    enum Installation
    {
        case installed
        case alreadyResolved
    }

    enum Resolution
    {
        case wonBeforeSubscription
        case won(AnyCancellable)
        case alreadyResolved

        var won: Bool
        {
            switch self
            {
                case .wonBeforeSubscription, .won:
                    true

                case .alreadyResolved:
                    false
            }
        }

        func cancelSubscription()
        {
            if case .won(let cancellable) = self
            {
                cancellable.cancel()
            }
        }
    }

    private enum Phase
    {
        case awaitingSubscription
        case subscribed(AnyCancellable)
        case resolved
    }

    private let lock = NSLock()
    private var phase = Phase.awaitingSubscription

    func install(
        _ cancellable: AnyCancellable
    ) throws(StateError) -> Installation
    {
        lock.lock()
        defer { lock.unlock() }

        switch phase
        {
            case .awaitingSubscription:
                phase = .subscribed(cancellable)
                return .installed

            case .resolved:
                return .alreadyResolved

            case .subscribed:
                throw .subscriptionAlreadyInstalled
        }
    }

    func resolve() -> Resolution
    {
        lock.lock()
        defer { lock.unlock() }

        switch phase
        {
            case .awaitingSubscription:
                phase = .resolved
                return .wonBeforeSubscription

            case .subscribed(let cancellable):
                phase = .resolved
                return .won(cancellable)

            case .resolved:
                return .alreadyResolved
        }
    }
}

public
extension Publisher
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
    
    /// Convenience adapter for async/await workflow.
    ///
    /// Resumes with the **first** value emitted by the publisher, or throws:
    /// - the publisher's own error on failure, or
    /// - ``Pipeline/CompletedWithoutValue`` if the publisher completes
    ///   without emitting any value.
    ///
    /// Credits:
    /// https://medium.com/geekculture/from-combine-to-async-await-c08bf1d15b77
    func waitForFirstResult() async throws -> Output where Output: Sendable
    {
        try await withCheckedThrowingContinuation { continuation in
            let state = FirstResultState()

            let cancellable = self
                .sink { result in
                    let resolution = state.resolve()
                    guard resolution.won else { return }

                    switch result
                    {
                        case .finished:
                            continuation.resume(throwing: Pipeline.CompletedWithoutValue())

                        case .failure(let error):
                            continuation.resume(throwing: error)
                    }

                    resolution.cancelSubscription()
                }
                receiveValue: {
                    let resolution = state.resolve()
                    guard resolution.won else { return }

                    continuation.resume(returning: $0)

                    resolution.cancelSubscription()
                }

            do
            {
                if case .alreadyResolved = try state.install(cancellable)
                {
                    cancellable.cancel()
                }
            }
            catch
            {
                let resolution = state.resolve()

                if resolution.won
                {
                    continuation.resume(throwing: error)
                    resolution.cancelSubscription()
                }

                cancellable.cancel()
            }
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
