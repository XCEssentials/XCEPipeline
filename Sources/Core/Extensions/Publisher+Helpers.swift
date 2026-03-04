#if canImport(Combine)

import Foundation
import Combine

//---

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
    func waitForFirstResult() async throws -> Output
    {
        try await withCheckedThrowingContinuation { continuation in

            var cancellable: AnyCancellable?
            var resumed = false

            cancellable = self
                .receive(on: DispatchQueue.main)
                .sink { result in

                    switch result
                    {
                        case .finished:
                            if !resumed
                            {
                                resumed = true
                                continuation.resume(throwing: Pipeline.CompletedWithoutValue())
                            }

                        case .failure(let error):
                            if !resumed
                            {
                                resumed = true
                                continuation.resume(throwing: error)
                            }
                    }

                    cancellable?.cancel()
                    cancellable = nil
                }
                receiveValue: {
                    guard !resumed else { return }
                    resumed = true
                    continuation.resume(returning: $0)
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
