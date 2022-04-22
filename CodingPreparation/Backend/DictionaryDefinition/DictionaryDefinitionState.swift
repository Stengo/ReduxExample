
enum DictionaryDefinitionState: Hashable {
    case loading
    case failure
    case success([DictionaryClient.Entry])

    static var initial: DictionaryDefinitionState {
        return .loading
    }
}
