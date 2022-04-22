import UIKit

class GameBoardViewController: SubscriberViewController<GameBoardViewData> {
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 24)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.startAnimating()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        return loadingIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnTextView))
        textView.addGestureRecognizer(tapGesture)

        view.backgroundColor = .white
        view.addSubview(textView)
        view.addSubview(loadingIndicator)
        configureConstraints()
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            loadingIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }

    override func update(with viewData: GameBoardViewData) {
        switch viewData {
        case .failure:
            loadingIndicator.isHidden = true
            textView.isHidden = false
            textView.text = "Something went wrong"
        case .loading:
            loadingIndicator.isHidden = false
            textView.isHidden = true
        case let .success(text):
            loadingIndicator.isHidden = true
            textView.isHidden = false
            textView.text = text
        }
    }

    @objc private func didTapOnTextView(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let point = tapGestureRecognizer.location(in: textView)
        guard
            let textPosition = textView.closestPosition(to: point),
            let selectedRange = textView.tokenizer.rangeEnclosingPosition(
                textPosition,
                with: .word,
                inDirection: UITextDirection.layout(.right)
            ),
            let selectedWord = textView.text(in: selectedRange)
        else {
            return
        }
        stateContainer.mutate { appState in
            appState.wordSelection = .selected(selectedWord)
        }
    }
}
