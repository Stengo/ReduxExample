import ReSwift

struct AppState: Equatable {
    static var initial: AppState {
        return AppState()
    }
}

func appReducer(action: Action, state: AppState?) -> AppState {
    let state = state ?? .initial

    return state
}
