import Foundation

protocol StatisticViewModelProtocol {
    var cellViewModels: [StatisticCellViewModel] { get }
    var delegate: StatisticViewModelDelegate? { get set }
    func viewWillAppear()
}

protocol StatisticViewModelDelegate: AnyObject {
    func viewModelsUpdated()
}

final class StatisticViewModel {
    
    private(set) var cellViewModels = [StatisticCellViewModel]() {
        didSet {
            delegate?.viewModelsUpdated()
        }
    }

    private let trackerStore: TrackerStoreProtocol
    private var countOfFinishedTrackers = 0
    private var bestPeriod = 0
    private var perfectDays = 0
    private var averageValue = 0
    weak var delegate: StatisticViewModelDelegate?
    
    init(trackerStore: TrackerStoreProtocol) {
        self.trackerStore = trackerStore
    }
    
    // MARK: - Private
    
    private func makeCellViewModels() {
        
        guard let allTrackers = try? trackerStore.loadAllTrackers(),
              !allTrackers.isEmpty else {
            cellViewModels = []
            return
        }
        
        self.countOfFinishedTrackers = allTrackers.filter { $0.completedDaysCount > 0 }.count

        cellViewModels = [
            StatisticCellViewModel(title: "Лучший период", value: "\(bestPeriod)"),
            StatisticCellViewModel(title: "Идеальные дни", value: "\(perfectDays)"),
            StatisticCellViewModel(title: "Трекеров завершено", value: "\(countOfFinishedTrackers)"),
            StatisticCellViewModel(title: "Среднее значение", value: "\(averageValue)")
        ]
    }
}

// MARK: - StatisticViewModelProtocol

extension StatisticViewModel: StatisticViewModelProtocol {
    func viewWillAppear() {
        makeCellViewModels()
    }
}

