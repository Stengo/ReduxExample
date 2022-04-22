import Foundation

struct SuccessViewData: ViewDataType {
    static let selections: () -> [Selection<AppState>] = {[]}

    let text: String
    let restart: String

    init(for fragment: Fragment<AppState>) {
        text = "You did it!"
        restart = "restart"
    }
}
