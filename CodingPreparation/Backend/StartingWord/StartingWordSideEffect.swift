import Foundation

func startingWordSideEffect() -> SideEffect {
    return { action, dispatch, getState in
        switch action {
        case AppDelegateAction.didFinishLaunching:
            guard
                let startingWordsPath = Bundle.main.path(forResource: "starting_words", ofType: "txt"),
                let startingWordsString = try? String(contentsOfFile: startingWordsPath)
            else {
                return
            }
            let startingWords = startingWordsString.components(separatedBy: .whitespaces)
            let startingWord = startingWords.randomElement()!
            dispatch(WordSelectionAction.select(startingWord))

        default:
            return
        }
    }
}
