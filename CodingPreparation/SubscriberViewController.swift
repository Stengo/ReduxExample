import ReSwift
import UIKit

class SubscriberViewController<ViewData: ViewDataType>: UIViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = ViewData.StateFragment

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        store.subscribe(self) { subscription in
            subscription
                .select(ViewData.fragment(of:))
                .skipRepeats()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        store.unsubscribe(self)
    }

    func newState(state: ViewData.StateFragment) {
        DispatchQueue.main.async { [weak self] in
            self?.update(with: ViewData(for: state))
        }
    }

    func update(with _: ViewData) {}
}

protocol ViewDataType {
    associatedtype StateFragment: Equatable

    static func fragment(of appState: AppState) -> StateFragment

    init(for fragment: StateFragment)
}
