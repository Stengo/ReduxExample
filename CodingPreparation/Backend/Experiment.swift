import Foundation

protocol StateSubscriber: TypeErasedStateSubscriber {
    associatedtype State: Hashable

    func new(fragment: Fragment<State>)
}

protocol TypeErasedStateSubscriber: AnyObject {
    func _new(fragment: Any)
}

extension StateSubscriber {
    func _new(fragment: Any) {
        new(fragment: fragment as! Fragment<State>)
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
            let fragment = Fragment<State>(value: state, previousValue: previousState, selector: subscription.selector)
            guard fragment.containsChanges() else {
                return
            }
            subscription.subscriber._new(fragment: fragment)
        }
    }

    func subscribe<Subscriber: StateSubscriber>(
        _ subscriber: Subscriber,
        selector: [PartialKeyPath<State>]
    ) where Subscriber.State == State {
        subscriptions.append((subscriber, selector))
        subscriber.new(fragment: Fragment<State>(value: state, previousValue: state, selector: selector))
    }

    func unsubscribe<Subscriber: StateSubscriber>(_ subscriber: Subscriber) {
        subscriptions.removeAll { subscription in
            subscription.subscriber === subscriber
        }
    }
}

prefix operator *
prefix func * <State, T: Hashable>(_ keyPath: KeyPath<State, T>) -> PartialKeyPath<State> {
    keyPath
}

@dynamicMemberLookup
struct Fragment<State> {
    private let value: State
    private let previousValue: State
    private let selector: [PartialKeyPath<State>]

    init(value: State, previousValue: State, selector: [PartialKeyPath<State>]) {
        self.value = value
        self.previousValue = previousValue
        self.selector = selector
    }

    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        let member = value[keyPath: keyPath]
        if selector.contains(keyPath) == false, member is AnyHashable {
            print("WARNING: Accessing property that is not part of your observed values. You could be missing updates.")
        }
        return member
    }

    func containsChanges<T: Equatable>(for keyPath: KeyPath<State, T>) -> Bool {
        value[keyPath: keyPath] != previousValue[keyPath: keyPath]
    }

    func previousValue<T>(of keyPath: KeyPath<State, T>) -> T {
        previousValue[keyPath: keyPath]
    }

    fileprivate func containsChanges() -> Bool {
        for keyPath in selector {
            let lhsValue = previousValue[keyPath: keyPath] as! AnyHashable
            let rhsValue = value[keyPath: keyPath] as! AnyHashable
            guard lhsValue == rhsValue else {
                return true
            }
        }
        return false
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
    var nonHashable: NonHashable

    struct InnerStruct: Equatable, Hashable {
        var description: String
    }

    struct NonHashable: Equatable {
        var bla: String
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(number)
        hasher.combine(isTheCase)
        hasher.combine(inner)
    }
}

let stateContainer = StateContainer(
    initialState: ApplicationState(
        name: "Initial Name",
        number: 1,
        isTheCase: true,
        inner: ApplicationState.InnerStruct(description: "Initial description"),
        nonHashable: ApplicationState.NonHashable(bla: "What")
    )
)

class ApplicationSubscriber: StateSubscriber {
    typealias State = ApplicationState

    init() {
        stateContainer.subscribe(
            self,
            selector: [
                *\.inner,
                *\.name,
            ]
        )
        changeStuff()
    }

    func new(fragment: Fragment<State>) {
        print(fragment.inner.description)
        print(fragment.isTheCase)
        print("was \(fragment.previousValue(of: \.isTheCase))")
        print("has change: \(fragment.containsChanges(for: \.isTheCase))")
        print(fragment.nonHashable.bla)
    }

    func changeStuff() {
        stateContainer.mutate { applicationState in
            applicationState.isTheCase = false
            applicationState.inner.description = "new description"
        }
    }
}
