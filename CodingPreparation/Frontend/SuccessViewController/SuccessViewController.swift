import UIKit

class SuccessViewController: SubscriberViewController<SuccessViewData> {
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var restartButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(didSelectRestart), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view?.backgroundColor = .white
        view.addSubview(label)
        view.addSubview(restartButton)
        configureConstraints()
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            restartButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            restartButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            restartButton.topAnchor.constraint(equalTo: label.bottomAnchor),
        ])
    }

    override func update(with viewData: SuccessViewData) {
        label.text = viewData.text
        restartButton.setTitle(viewData.restart, for: .normal)
    }

    @objc private func didSelectRestart() {
        stateContainer.mutate(through: restartGame)
        dismiss(animated: true, completion: nil)
    }
}


