import Foundation

struct SuccessViewData: ViewDataType {
    struct StateFragment: Equatable {
    }

    static func fragment(of appState: AppState) -> StateFragment {
        return StateFragment()
    }

    let text: String
    let restart: String

    init(for fragment: StateFragment) {
        text = "You did it!"
        restart = "restart"
    }
}
