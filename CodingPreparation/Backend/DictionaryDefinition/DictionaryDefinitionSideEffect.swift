import Foundation

func dictionaryDefinitionSideEffect() -> SideEffect {
    return SideEffect {[
        *\.wordSelection
    ]} newFragmentCallback: { fragment in
        if
            fragment.containsChanges(for: \.wordSelection),
            case let .selected(word) = fragment.wordSelection
        {
            stateContainer.mutate { appState in
                appState.dictionaryDefinition = .loading
            }
            _ = DictionaryClient.entries(for: word) { result in
                switch result {
                case let .success(entries):
                    stateContainer.mutate { appState in
                        appState.dictionaryDefinition = .success(entries)
                    }
                case .failure:
                    stateContainer.mutate { appState in
                        appState.dictionaryDefinition = .failure
                    }
                }
            }
        }
    }
}
