import UIKit

final class TrackerController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("main.title", tableName: "Localizable", comment: "main.title")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .yaDatePickerColor
        picker.layer.backgroundColor = UIColor.yaWhite.cgColor
        picker.tintColor = .yaBlue
        picker.datePickerMode = .date
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar = Calendar(identifier: .iso8601)
        picker.maximumDate = Date()
        picker.overrideUserInterfaceStyle = .light
        picker.addTarget(self, action: #selector(didChangedDatePicker), for: .valueChanged)
        return picker
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(
                systemName: "plus",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 18,
                    weight: .bold
                )
            )!,
            target: self, action: #selector(didTapPlusButton))
        button.tintColor = .yaBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchField = UISearchBar()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = NSLocalizedString("search",
                                                    tableName: "Localizable",
                                                    comment: "search")
        searchField.searchBarStyle = .minimal
        searchField.delegate = self
        return searchField
    }()
    
    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .yaWhite
        view.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.identifier
        )
        view.register(
            TrackerCategoryLabel.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        return view
    }()
    
    private let notFoundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Resources.Images.Empty.emptyTracker
        return imageView
    }()
    
    private let notFoundLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = NSLocalizedString("stubTitle", tableName: "Localizable", comment: "stubTitle")
        label.textColor = .yaBlack
        return label
    }()
    
    private let notFoundStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("filters",
                                          tableName: "Localizable",
                                          comment: "filters"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.tintColor = .yaBlue
        button.backgroundColor = .yaBlue
        return button
    }()
    
    // MARK: - Properties
    
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore = TrackerCategoryStore()
    private lazy var trackerRecordStore = TrackerRecordStore(trackerStore: trackerStore)
    private let params = UICollectionView.GeometricParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        topInset: 8,
        bottomInset: 16,
        height: 148,
        cellSpacing: 10
    )
    private var categories = [TrackerCategory]()
    private var searchText = "" {
        didSet {
            try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        }
    }
    private var currentDate = Date.from(date: Date())!
    private var completedTrackers: Set<TrackerRecord> = []
    private var editingTracker: Tracker?
    
    // MARK: - Lifecycle
    
    init(trackerStore: TrackerStoreProtocol) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        setupContent()
        setupConstraints()
        setupFilterButton()
        
        trackerStore.delegate = self
        try? trackerStore.loadFilteredTrackers(date: Date(),
                                               searchString: nil)
        checkNumberOfTrackers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        YandexMetricaAnalytics.shared.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        YandexMetricaAnalytics.shared.report(event: "close", params: ["screen": "Main"])
    }
}

// MARK: - Layout methods

private extension TrackerController {
    func setupContent() {
        view.backgroundColor = .yaWhite
        view.addSubview(addButton)
        view.addSubview(titleLabel)
        view.addSubview(datePicker)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(notFoundStack)
        view.addSubview(filterButton)
        
        notFoundStack.addArrangedSubview(notFoundImageView)
        notFoundStack.addArrangedSubview(notFoundLabel)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // completeButton
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),
            addButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            // titleLabel
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 13),
            // datePicker
            datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            datePicker.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            // searchBar
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            // collectionView
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            // notFoundStack
            notFoundStack.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            notFoundStack.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            // filterButton
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func makeContextMenu(tracker: Tracker) -> UIMenu {
        let menu = UIMenu(title: "", children: [
            UIAction(title: tracker.pinned ? "Открепить" : "Закрепить",
                     state: .off) { [weak self] action in
                         self?.togglePinTracker(tracker)
                     },
            UIAction(title: "Редактировать",
                     state: .off) { [weak self] action in
                         self?.editTracker(tracker)
                     },
            UIAction(title: "Удалить",
                     attributes: [.destructive],
                     state: .off) { [weak self] action in
                         self?.deleteTracker(tracker)
                     }
        ])
        return menu
    }
    
    func editTracker(_ tracker: Tracker) {
        YandexMetricaAnalytics.shared.report(event: "click", params: [
            "screen": "Main",
            "item": "edit"
        ])
        
        let type: AddTrackerViewController.TrackerType = tracker.schedule != nil ? .habit : .irregularEvent
        editingTracker = tracker
        presentFormController(with: tracker.data, of: type, formType: .edit)
    }
    
    func setupFilterButton() {
        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
    }
    
    func presentFormController(
        with data: Tracker.Data? = nil,
        of trackerType: AddTrackerViewController.TrackerType,
        formType: TrackerFormViewController.FormType
    ) {
        let trackerFormViewController = TrackerFormViewController(type: trackerType,
                                                                  formType: formType,
                                                                  data: data)
        trackerFormViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerFormViewController)
        navigationController.isModalInPresentation = true
        present(navigationController, animated: true)
    }
    
    func togglePinTracker(_ tracker: Tracker) {
        try? trackerStore.togglePin(for: tracker)
    }
    
    func deleteRecordTracker(with tracker: Tracker) {
        if let recordToRemove = completedTrackers.first(where: { $0.date == currentDate && $0.trackerId == tracker.id }) {
            try? trackerRecordStore.remove(recordToRemove)
        }
    }
    
    func deleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: "Вы уверены, что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self else { return }
            YandexMetricaAnalytics.shared.report(event: "click", params: [
                "screen": "Main",
                "item": "delete"
            ])
            try? self.trackerStore.deleteTracker(tracker)
            deleteRecordTracker(with: tracker)
           
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func checkNumberOfTrackers() {
        if trackerStore.numberOfTrackers == 0 {
            notFoundStack.isHidden = false
            filterButton.isHidden = true
        } else {
            notFoundStack.isHidden = true
            filterButton.isHidden = false
        }
    }
    
    // MARK: - Actions
    
    @objc func didTapFilterButton() {
        YandexMetricaAnalytics.shared.report(event: "click", params: [
            "screen": "Main",
            "item": "filter"
        ])
    }
    
    @objc func didTapPlusButton() {
        YandexMetricaAnalytics.shared.report(event: "click", params: [
            "screen": "Main",
            "item": "add_track"
        ])
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc func didChangedDatePicker(_ sender: UIDatePicker) {
        currentDate = sender.date
        try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        collectionView.reloadData()
    }
    
    func hasPassed24Hours(from date: Date) -> Bool {

        let currentDate = Date()
        

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: date, to: currentDate)
        
        if let hours = components.hour, hours >= 24 {
            return true
        } else {
            return false
        }
    }
    
    func makeCompleted(for tracker: Tracker) -> Bool {
        guard let trackerRecord = try? trackerRecordStore.getTrackerRecord(trackerId: tracker.id) else { return false }
        
        if hasPassed24Hours(from: trackerRecord.date) {
            return false
        }
        
        return true
    }

}

// MARK: - UICollectionViewDataSource

extension TrackerController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let trackerCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCell.identifier,
                for: indexPath
            ) as? TrackerCell,
            let tracker = trackerStore.tracker(at: indexPath)
        else {
            return UICollectionViewCell()
        }
        
        trackerCell.configure(with: tracker,
                              days: tracker.completedDaysCount,
                              completed: makeCompleted(for: tracker))
        trackerCell.delegate = self
        trackerCell.setupContextMenuDelegate(contextMenuDelegate: self)
        return trackerCell
    }

}

extension TrackerController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard
            let location = interaction.view?.convert(location, to: collectionView),
            let indexPath = collectionView.indexPathForItem(at: location),
            let tracker = trackerStore.tracker(at: indexPath)
        else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {
            [weak self] _ in
            return self?.makeContextMenu(tracker: tracker)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let availableSpace = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableSpace / params.cellCount
        return CGSize(width: cellWidth, height: params.height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets
    {
        UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView
    {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as? TrackerCategoryLabel
        else { return UICollectionReusableView() }
        
        guard let label = trackerStore.headerLabelInSection(indexPath.section) else { return UICollectionReusableView() }
        view.configure(with: label)
        
        return view
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )

        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

// MARK: - UISearchBarDelegate

extension TrackerController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchText = ""
        collectionView.reloadData()
    }
}

// MARK: - TrackerCellDelegate

extension TrackerController: TrackerCellDelegate {
    func didTapCompleteButton(of cell: TrackerCell, with tracker: Tracker) {
        var completedDays = tracker.completedDaysCount
        
        if let trackerRecord = try? trackerRecordStore.getTrackerRecord(trackerId: tracker.id) {
            if hasPassed24Hours(from: trackerRecord.date) {
                try? trackerRecordStore.remove(trackerRecord)
                let trackerRecord = TrackerRecord(trackerId: tracker.id, date: Date())
                try? trackerRecordStore.add(trackerRecord)
                cell.increaseCount()
                cell.toggleCompletedButton(tracker: tracker, completed: true)
                completedDays += 1
  
                saveUpdatedTracker(tracker: tracker,
                                   completedDays: completedDays)
            } else if tracker.completedDaysCount > 0 && !hasPassed24Hours(from: trackerRecord.date)  {
                try? trackerRecordStore.remove(trackerRecord)
                completedDays -= 1
                cell.decreaseCount()
                cell.toggleCompletedButton(tracker: tracker, completed: false)
     
                saveUpdatedTracker(tracker: tracker,
                                   completedDays: completedDays)
            }
        } else {
            completedDays += 1
            let trackerRecord = TrackerRecord(trackerId: tracker.id, date: Date())
            try? trackerRecordStore.add(trackerRecord)
   
            saveUpdatedTracker(tracker: tracker,
                               completedDays: completedDays)
        }
    }
    
    func saveUpdatedTracker(tracker: Tracker,
                            completedDays: Int) {
        let trackerData = Tracker.Data(label: tracker.label,
                                       emoji: tracker.emoji,
                                       color: tracker.color,
                                       completedDaysCount: completedDays,
                                       schedule: tracker.schedule,
                                       pinned: tracker.pinned,
                                       category: tracker.category)
        try? trackerStore.updateTracker(tracker, with: trackerData)
    }
}

// MARK: - AddTrackerViewControllerDelegate

extension TrackerController: AddTrackerViewControllerDelegate {
    func didSelectTracker(with type: AddTrackerViewController.TrackerType) {
        dismiss(animated: true)
        presentFormController(of: type, formType: .add)
    }
}

// MARK: - TrackerFormViewControllerDelegate

extension TrackerController: TrackerFormViewControllerDelegate {
    func didAddTracker(category: TrackerCategory, trackerToAdd: Tracker) {
        dismiss(animated: true)
        do {
            try trackerStore.addTracker(trackerToAdd, with: category)
        } catch {
            assertionFailure()
        }
    }
    
    func didUpdateTracker(with data: Tracker.Data) {
        guard let editingTracker else { return }
        dismiss(animated: true)
        try? trackerStore.updateTracker(editingTracker, with: data)
        self.editingTracker = nil
    }
    
    func didTapCancelButton() {
        collectionView.reloadData()
        editingTracker = nil
        dismiss(animated: true)
    }
}

// MARK: - TrackerStoreDelegate

extension TrackerController: TrackerStoreDelegate {
    func didUpdate() {
        checkNumberOfTrackers()
        collectionView.reloadData()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackerController: TrackerRecordStoreDelegate {
    func didUpdateRecords(_ records: Set<TrackerRecord>) {
        completedTrackers = records
    }
}

