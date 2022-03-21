import ReSwift

enum DictionaryDefinitionState: Equatable {
    case loading
    case failure
    case success([DictionaryClient.Entry])

    static var initial: DictionaryDefinitionState {
        return .loading
    }
}

func dictionaryDefinitionReducer(action: Action, state: DictionaryDefinitionState) -> DictionaryDefinitionState {
    switch action {
    case WordSelectionAction.select:
        return .loading
    case DictionaryDefinitionAction.failure:
        return .failure
    case let DictionaryDefinitionAction.success(entries):
        return .success(entries)
    default:
        return state
    }
}
