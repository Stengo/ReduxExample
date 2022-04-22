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
    private var subscriptions: [(subscriber: TypeErasedStateSubscriber, selector: Selector<State>)] = []

    init(initialState: State) {
        state = initialState
    }

    func mutate(through mutationClosure: (inout State) -> Void) {
        let previousState = state
        mutationClosure(&state)
        subscriptions.forEach { subscription in
            let previousFragment = Fragment<State>(value: previousState, selector: subscription.selector)
            let newFragment = Fragment<State>(value: state, selector: subscription.selector)
            guard subscription.subscriber._areEqual(newFragment, previousFragment) == false else {
                return
            }
            subscription.subscriber._new(fragment: newFragment)
        }
    }

    func subscribe<Subscriber: StateSubscriber>(
        _ subscriber: Subscriber,
        selector: Selector<State>
    ) where Subscriber.State == State {
        subscriptions.append((subscriber, selector))
        subscriber.new(fragment: Fragment<State>(value: state, selector: selector))
    }

    func unsubscribe<Subscriber: StateSubscriber>(_ subscriber: Subscriber) {
        subscriptions.removeAll { subscription in
            subscription.subscriber === subscriber
        }
    }
}

struct Selector<State>: Equatable {
    private(set) var keyPaths: [PartialKeyPath<State>]

    private init(keyPaths: [PartialKeyPath<State>]) {
        self.keyPaths = keyPaths
    }

    init() {
        self.keyPaths = []
    }

    func appending<T: Hashable>(_ keyPath: KeyPath<State, T>) -> Self {
        Selector(keyPaths: keyPaths + [keyPath])
    }

    func contains(_ keyPath: PartialKeyPath<State>) -> Bool {
        keyPaths.contains(keyPath)
    }
}

@dynamicMemberLookup
struct Fragment<State>: Equatable {
    private let value: State
    private let selector: Selector<State>

    init(value: State, selector: Selector<State>) {
        self.value = value
        self.selector = selector
    }

    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        if selector.contains(keyPath) == false {
            print("WARNING: Accessing property that is not part of your observed values. You could be missing updates.")
        }
        return value[keyPath: keyPath]
    }

    static func == (lhs: Fragment<State>, rhs: Fragment<State>) -> Bool {
        guard lhs.selector == rhs.selector else {
            return false
        }
        for keyPath in lhs.selector.keyPaths {
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
        stateContainer.subscribe(
            self,
            selector: Selector<State>()
                .appending(\.name)
                .appending(\.inner)
        )
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
