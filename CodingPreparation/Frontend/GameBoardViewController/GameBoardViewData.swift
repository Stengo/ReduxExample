import Foundation

enum GameBoardViewData: ViewDataType {
    struct StateFragment: Equatable {
        let dictionaryDefinition: DictionaryDefinitionState
    }

    static func fragment(of appState: AppState) -> StateFragment {
        return StateFragment(
            dictionaryDefinition: appState.dictionaryDefinition
        )
    }

    case loading
    case failure
    case success(String)

    init(for fragment: StateFragment) {
        switch fragment.dictionaryDefinition {
        case let .success(entries):
            self = .success(entries.asString)
        case .failure:
            self = .failure
        case .loading:
            self = .loading
        }
    }
}

private extension Array where Element == DictionaryClient.Entry {
    var asString: String {
        return map { entry in
            let meaningsString = entry.meanings
                .map { meaning -> String in
                    let definitionsString = meaning.definitions
                        .map { definition in
                            "\t\(definition.definition)"
                        }
                        .joined(separator: "\n")
                    return "\(meaning.partOfSpeech)\n\(definitionsString)"
                }
                .joined(separator: "\n")
            return "\(entry.word):\n\n\(meaningsString)"
        }.joined(separator: "\n\n")
    }
}
