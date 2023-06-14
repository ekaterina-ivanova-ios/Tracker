import Foundation

protocol CategoriesViewModelDelegate: AnyObject {
    func didUpdateCategories()
    func didSelectCategory(_ category: TrackerCategory)
}

protocol CategoriesViewModelProtocol {
    var delegate: CategoriesViewModelDelegate? { get set }
    var categories: [TrackerCategory] { get }
    var selectedCategory: TrackerCategory? { get }
    
    func loadCategories()
    
    func deleteCategory(_ category: TrackerCategory)
    
    func selectCategory(at indexPath: IndexPath)
    
    func handleCategoryFormConfirm(data: TrackerCategory.Data)
    
    func makeDeleteAlertModel(category: TrackerCategory) -> AlertViewModelProtocol
}

final class CategoriesViewModel {
    
    // MARK: - Properties
    
    weak var delegate: CategoriesViewModelDelegate?
    
    private var trackerCategoryStore: TrackerCategoryStoreProtocol
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            delegate?.didUpdateCategories()
        }
    }
    private(set) var selectedCategory: TrackerCategory? = nil {
        didSet {
            guard let selectedCategory else { return }
            delegate?.didSelectCategory(selectedCategory)
        }
    }
    
    // MARK: - Lifecycle
    
    init(selectedCategory: TrackerCategory?,
         trackerCategoryStore: TrackerCategoryStoreProtocol) {
        self.selectedCategory = selectedCategory
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerCategoryStore.delegate = self
    }
    
    // MARK: - Private
    
    private func getCategoriesFromStore() -> [TrackerCategory] {
        do {
            let categories = try trackerCategoryStore.categoriesCoreData.map {
                try trackerCategoryStore.makeCategory(from: $0)
            }
            return categories
        } catch {
            return []
        }
    }
    
    private func addCategory(with label: String) {
        do {
            try trackerCategoryStore.makeCategory(with: label)
            loadCategories()
        } catch {}
    }
    
    private func updateCategory(with data: TrackerCategory.Data) {
        do {
            try trackerCategoryStore.updateCategory(with: data)
            loadCategories()
        } catch {}
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate() {
        categories = getCategoriesFromStore()
    }
}

// MARK: - CategoriesViewModelProtocol

extension CategoriesViewModel: CategoriesViewModelProtocol {
    func loadCategories() {
        categories = getCategoriesFromStore()
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        do {
            try trackerCategoryStore.deleteCategory(category)
            loadCategories()
            if category == selectedCategory {
                selectedCategory = nil
            }
        } catch {}
    }
    
    func selectCategory(at indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
    }
    
    func handleCategoryFormConfirm(data: TrackerCategory.Data) {
        if categories.contains(where: { $0.id == data.id }) {
            updateCategory(with: data)
        } else {
            addCategory(with: data.label)
        }
    }
    
    func makeDeleteAlertModel(category: TrackerCategory) -> AlertViewModelProtocol {
        let firstAlertActionModel = AlertActionModel(title: "Отменить",
                                                     style: .cancel)
        let secondAlertActionModel = AlertActionModel(title: "Удалить",
                                                      style: .destructive) { [weak self] _ in
            self?.deleteCategory(category)
        }
        let alertViewModel = AlertViewModel(title: nil,
                                            message: "Эта категория точно не нужна?",
                                            preferredStyle: .actionSheet,
                                            firstAlertActionModel: firstAlertActionModel,
                                            secondAlertActionModel: secondAlertActionModel)
        return alertViewModel
    }
}
