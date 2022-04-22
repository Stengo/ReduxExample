
struct AppState: Hashable {
    var wordSelection: WordSelectionState
    var dictionaryDefinition: DictionaryDefinitionState

    static var initial: AppState {
        return AppState(
            wordSelection: .initial,
            dictionaryDefinition: .initial
        )
    }
}
