import UIKit

class GameBoardViewController: SubscriberViewController<GameBoardViewData> {
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 24)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(textView)
        configureConstraints()
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    override func update(with viewData: GameBoardViewData) {
        textView.text = viewData.text
    }
}
