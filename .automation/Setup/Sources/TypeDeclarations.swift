typealias PerPlatform<T> = (
    iOS: T,
    watchOS: T,
    tvOS: T,
    macOS: T
)

typealias PerPlatformAndCommon<T> = (
    common: T,
    iOS: T,
    watchOS: T,
    tvOS: T,
    macOS: T
)

typealias PerPlatformAndCommonTst<T> = (
    common: T,
    iOS: T,
    // NO tests for .watchOS
    tvOS: T,
    macOS: T
)

typealias PerTarget<M, T> = (
    main: M,
    tst: T
)
