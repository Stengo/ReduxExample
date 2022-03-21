import ReSwift

struct WordSelectionState: Equatable {
    let selectedWord: String

    static var initial: WordSelectionState {
        return WordSelectionState(selectedWord: "")
    }
}

enum WordSelectionAction: Action {
    case select(String)
}

func wordSelectionReducer(action: Action, state: WordSelectionState) -> WordSelectionState {
    switch action {
    case let WordSelectionAction.select(word):
        return WordSelectionState(selectedWord: word)

    default:
        return state
    }
}
