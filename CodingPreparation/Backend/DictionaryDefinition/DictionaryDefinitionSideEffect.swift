import Foundation
import ReSwift

func dictionaryDefinitionSideEffect() -> SideEffect {
    return { action, dispatch, getState in
        switch action {
        case let WordSelectionAction.select(word):
            _ = DictionaryClient.entries(for: word) { result in
                switch result {
                case let .success(entries):
                    dispatch(DictionaryDefinitionAction.success(entries))
                case .failure:
                    dispatch(DictionaryDefinitionAction.failure)
                }
            }
        default:
            return
        }
    }
}

enum DictionaryDefinitionAction: Action {
    case failure
    case success([DictionaryClient.Entry])
}
