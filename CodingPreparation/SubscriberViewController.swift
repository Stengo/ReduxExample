import UIKit

class SubscriberViewController<ViewData: ViewDataType>: UIViewController, StateSubscriber {
    typealias State = AppState

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        stateContainer.subscribe(self, ViewData.selections)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stateContainer.unsubscribe(self)
    }

    func new(fragment: Fragment<AppState>) {
        DispatchQueue.main.async { [weak self] in
            self?.update(with: ViewData(for: fragment))
        }
    }

    func update(with _: ViewData) {}
}

protocol ViewDataType {
    static var selections: () -> [Selection<AppState>] { get }

    init(for fragment: Fragment<AppState>)
}
