import Foundation

func startingWordSideEffect() -> SideEffect {
    return SideEffect {[
        *\.wordSelection
    ]} newFragmentCallback: { fragment in
        if
            fragment.containsChanges(for: \.wordSelection),
            fragment.wordSelection == .starting
        {
            guard
                let startingWordsPath = Bundle.main.path(forResource: "starting_words", ofType: "txt"),
                let startingWordsString = try? String(contentsOfFile: startingWordsPath)
            else {
                return
            }
            let startingWords = startingWordsString.components(separatedBy: .whitespaces)
            let startingWord = startingWords.randomElement()!
            stateContainer.mutate { appState in
                appState.wordSelection = .selected(startingWord)
            }
        }
    }
}

func restartGame(_ appState: inout AppState) {
    appState.wordSelection = .starting
}
