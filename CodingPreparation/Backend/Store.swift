import ReSwift

let store = Store<AppState>(
    reducer: appReducer,
    state: .initial,
    middleware: [
        sideEffectsMiddleware,
    ]
)
