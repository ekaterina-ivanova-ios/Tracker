import UIKit

final class StatisticController: UIViewController {
    
    // MARK: - Layout elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("statistics.title",
                                       tableName: "Localizable",
                                       comment: "statistics.title")
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
        label.text = NSLocalizedString("stubTitleStatistics",
                                       tableName: "Localizable",
                                       comment: "stubTitleStatistics")
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
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.bounces = false
        return tableView
    }()
    
    private var viewModel: StatisticViewModelProtocol
    
    // MARK: - Lifecycle
    
    init(viewModel: StatisticViewModelProtocol) {
        self.viewModel  = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
        setupConstraints()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
    
}

extension StatisticController: StatisticViewModelDelegate {
    func viewModelsUpdated() {
        if viewModel.cellViewModels.isEmpty {
            tableView.isHidden = true
            emptyStack.isHidden = false
        } else {
            tableView.isHidden = false
            emptyStack.isHidden = true
            tableView.reloadData()
        }
    }
}

// MARK: - Layout methods
private extension StatisticController {
    func setupContent() {
        view.backgroundColor = .yaWhite

        view.addSubview(titleLabel)
        view.addSubview(emptyStack)
        view.addSubview(tableView)
        
        emptyStack.addArrangedSubview(emptyImageView)
        emptyStack.addArrangedSubview(emptyLabel)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .yaWhite
        tableView.register(StatisticCell.self, forCellReuseIdentifier: "StatisticCell")
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // titleLabel
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // tableView
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 71),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            //emptyStack
            emptyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension StatisticController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticCell") as? StatisticCell else {
            return UITableViewCell()
        }
        let viewModel = viewModel.cellViewModels[indexPath.row]
        cell.update(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       102
    }
}

