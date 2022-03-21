import Foundation

struct GameBoardViewData: ViewDataType {
    struct StateFragment: Equatable {
        let wordSelection: WordSelectionState
    }

    static func fragment(of appState: AppState) -> StateFragment {
        return StateFragment(
            wordSelection: appState.wordSelection
        )
    }

    let text: String

    init(for fragment: StateFragment) {
        text = fragment.wordSelection.selectedWord
    }
}
