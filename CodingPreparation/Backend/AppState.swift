import ReSwift

struct AppState: Equatable {
    let wordSelection: WordSelectionState
    let dictionaryDefinition: DictionaryDefinitionState

    static var initial: AppState {
        return AppState(
            wordSelection: .initial,
            dictionaryDefinition: .initial
        )
    }
}

func appReducer(action: Action, state: AppState?) -> AppState {
    let state = state ?? .initial

    return AppState(
        wordSelection: wordSelectionReducer(action: action, state: state.wordSelection),
        dictionaryDefinition: dictionaryDefinitionReducer(action: action, state: state.dictionaryDefinition)
    )
}
