import Foundation

protocol StateSubscriber: TypeErasedStateSubscriber {
    associatedtype State: Hashable

    func new(fragment: Fragment<State>)
}

protocol TypeErasedStateSubscriber: AnyObject {
    func _new(fragment: Any)
    func _areEqual(_ lhs: Any, _ rhs: Any) -> Bool
}

extension StateSubscriber {
    func _new(fragment: Any) {
        new(fragment: fragment as! Fragment<State>)
    }

    func _areEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        return lhs as! Fragment<State> == rhs as! Fragment<State>
    }
}

class StateContainer<State: Hashable> {
    private(set) var state: State
    private var subscriptions: [(subscriber: TypeErasedStateSubscriber, selector: [PartialKeyPath<State>])] = []

    init(initialState: State) {
        state = initialState
    }

    func mutate(through mutationClosure: (inout State) -> Void) {
        let previousState = state
        mutationClosure(&state)
        subscriptions.forEach { subscription in
            let previousFragment = Fragment<State>(value: previousState, selectedKeyPaths: subscription.selector)
            let newFragment = Fragment<State>(value: state, selectedKeyPaths: subscription.selector)
            guard subscription.subscriber._areEqual(newFragment, previousFragment) == false else {
                return
            }
            subscription.subscriber._new(fragment: newFragment)
        }
    }

    func subscribe<Subscriber: StateSubscriber>(
        _ subscriber: Subscriber,
        selector: [PartialKeyPath<State>]
    ) where Subscriber.State == State {
        subscriptions.append((subscriber, selector))
        subscriber.new(fragment: Fragment<State>(value: state, selectedKeyPaths: selector))
    }

    func unsubscribe<Subscriber: StateSubscriber>(_ subscriber: Subscriber) {
        subscriptions.removeAll { subscription in
            subscription.subscriber === subscriber
        }
    }
}

@dynamicMemberLookup
struct Fragment<State>: Equatable {
    private let value: State
    private let selectedKeyPaths: [PartialKeyPath<State>]

    // needs assurance that value is hashable
    init(value: State, selectedKeyPaths: [PartialKeyPath<State>]) {
        self.value = value
        self.selectedKeyPaths = selectedKeyPaths
    }

    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        if selectedKeyPaths.contains(keyPath) == false {
            print("WARNING: Accessing property that is not part of your observed values.")
        }
        return value[keyPath: keyPath]
    }

    static func == (lhs: Fragment<State>, rhs: Fragment<State>) -> Bool {
        guard lhs.selectedKeyPaths == rhs.selectedKeyPaths else {
            return false
        }
        for keyPath in lhs.selectedKeyPaths {
            let lhsValue = lhs.value[keyPath: keyPath] as! AnyHashable
            let rhsValue = rhs.value[keyPath: keyPath] as! AnyHashable
            guard lhsValue == rhsValue else {
                return false
            }
        }
        return true
    }

    private static func areEqual<T: Equatable>(lhs: T, rhs: T) -> Bool {
        return lhs == rhs
    }
}

struct ApplicationState: Equatable, Hashable {
    var name: String
    var number: Int
    var isTheCase: Bool
    var inner: InnerStruct

    struct InnerStruct: Equatable, Hashable {
        var description: String
    }
}

let stateContainer = StateContainer(
    initialState: ApplicationState(
        name: "Initial Name",
        number: 1,
        isTheCase: true,
        inner: ApplicationState.InnerStruct(description: "Initial description")
    )
)

class ApplicationSubscriber: StateSubscriber {
    typealias State = ApplicationState

    init() {
        stateContainer.subscribe(self, selector: [
            \.name,
            \.inner,
        ])
        changeStuff()
    }

    func new(fragment: Fragment<State>) {
        // previous + new fragment
        // easy way to check what changed
        print(fragment.inner.description)
        print(fragment.isTheCase)
    }

    func changeStuff() {
        stateContainer.mutate { applicationState in
            applicationState.isTheCase = false
            applicationState.inner.description = "new description"
        }
    }
}
