
class SideEffect: StateSubscriber {
    typealias State = AppState

    private let newFragmentCallback: (Fragment<State>) -> ()

    init(
        selections: () -> [Selection<AppState>],
        newFragmentCallback: @escaping (Fragment<State>) -> ()
    ) {
        self.newFragmentCallback = newFragmentCallback
        stateContainer.subscribe(self, selections)
    }

    func new(fragment: Fragment<State>) {
        newFragmentCallback(fragment)
    }
}

let sideEffects: [SideEffect] = [
    startingWordSideEffect(),
    dictionaryDefinitionSideEffect(),
    viewControllerPresentationSideEffect(),
]
