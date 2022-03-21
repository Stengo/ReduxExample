import ReSwift

struct AppState: Equatable {
    let wordSelection: WordSelectionState

    static var initial: AppState {
        return AppState(
            wordSelection: .initial
        )
    }
}

func appReducer(action: Action, state: AppState?) -> AppState {
    let state = state ?? .initial

    return AppState(
        wordSelection: wordSelectionReducer(action: action, state: state.wordSelection)
    )
}
