
enum WordSelectionState: Hashable {
    case starting
    case selected(String)

    static var initial: WordSelectionState {
        return .starting
    }
}
