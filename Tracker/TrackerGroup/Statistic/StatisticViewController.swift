import UIKit

final class StatisticController: UIViewController {
    
    // MARK: - Layout elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Статистика"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Resources.Images.Error.errorStatistic
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "Анализировать пока нечего"
        label.textColor = .black
        return label
    }()
    
    private let emptyStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
        setupConstraints()
    }
    
}

// MARK: - Layout methods
private extension StatisticController {
    func setupContent() {
        view.backgroundColor = .yaWhite
        view.addSubview(titleLabel)
        view.addSubview(emptyStack)
        
        emptyStack.addArrangedSubview(emptyImageView)
        emptyStack.addArrangedSubview(emptyLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // titleLabel
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            //emptyStack
            emptyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

