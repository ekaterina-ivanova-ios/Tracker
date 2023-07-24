import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerStoreProtocol: AnyObject {
    var delegate: TrackerStoreDelegate? { get set }
    var numberOfTrackers: Int { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func headerLabelInSection(_ section: Int) -> String?
    func tracker(at indexPath: IndexPath) -> Tracker?
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws
    func updateTracker(_ tracker: Tracker, with data: Tracker.Data) throws
    func deleteTracker(_ tracker: Tracker) throws
    func togglePin(for tracker: Tracker) throws
    func getTrackerCoreData(by id: UUID) throws -> TrackerCoreData?
    func makeTracker(from coreData: TrackerCoreData) throws -> Tracker
    func loadFilteredTrackers(date: Date, searchString: String) throws
    func loadCompletedTrackers() throws -> [Tracker]
    func loadAllTrackers() throws -> [Tracker]
}

final class TrackerStore: NSObject {
    // MARK: - Properties
    
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerCategoryStore = TrackerCategoryStore()
    private let uiColorMarshalling = UIColorMarshalling()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.createdAt, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.createdAt, ascending: true)
        ]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
        fetchRequest.fetchBatchSize = 10
       
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    // MARK: - Lifecycle
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Methods
    
    func makeTracker(from coreData: TrackerCoreData) throws -> Tracker {
        guard
            let idString = coreData.trackerId,
            let id = UUID(uuidString: idString),
            let label = coreData.label,
            let emoji = coreData.emoji,
            let colorHEX = coreData.colorHEX,
            let categoryCoreData = coreData.category,
            let category = try? trackerCategoryStore.makeCategory(from: categoryCoreData)
        else {
            throw StoreError.decodeError }
        let color = uiColorMarshalling.color(from: colorHEX)
        var schedule: [Weekday]? = nil
        if let scheduleFormCoreData = coreData.schedule as? [String] {
            schedule = scheduleFormCoreData.compactMap { Weekday(rawValue: $0) }
        }
  
        return Tracker(
            id: id,
            label: label,
            emoji: emoji,
            color: color,
            completedDaysCount: Int(coreData.completedDaysCount),
            schedule: schedule,
            pinned: coreData.pinned,
            finished: coreData.finished,
            category: category
        )
    }
    
    func getTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.trackerId), id.uuidString
        )
        try fetchedResultsController.performFetch()
        guard let tracker = fetchedResultsController.fetchedObjects?.first else { throw StoreError.fetchTrackerError }
        fetchedResultsController.fetchRequest.predicate = nil
        try fetchedResultsController.performFetch()
        return tracker
    }
    
    func loadFilteredTrackers(date: Date, searchString: String) throws {
        var predicates = [NSPredicate]()
        
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let iso860WeekdayIndex = weekdayIndex > 1 ? weekdayIndex - 2 : weekdayIndex + 5
        
        var regex = ""
        for index in 0..<7 {
            if index == iso860WeekdayIndex {
                regex += "1"
            } else {
                regex += "."
            }
        }
        
        predicates.append(NSPredicate(
            format: "%K == nil OR ANY %K MATCHES[c] %@",
            #keyPath(TrackerCoreData.schedule),
            #keyPath(TrackerCoreData.schedule),
            regex
        ))
        
        if !searchString.isEmpty {
            predicates.append(NSPredicate(
                format: "%K CONTAINS[cd] %@",
                #keyPath(TrackerCoreData.label), searchString
            ))
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        try fetchedResultsController.performFetch()
        
        delegate?.didUpdate()
    }
    
    func loadAllTrackers() throws -> [Tracker] {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackersCoreData = try? context.fetch(request)
        
        guard let trackersCoreData else { throw StoreError.fetchTrackerError }
        return trackersCoreData.compactMap { try? makeTracker(from: $0) }
    }


    private var pinnedTrackers: [Tracker] {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return [] }
        let trackers = fetchedObjects.compactMap { try? makeTracker(from: $0) }
        return trackers.filter { $0.pinned }
    }
    
    private var sections: [[Tracker]] {
        guard let sectionsCoreData = fetchedResultsController.sections else { return [] }
        var sections: [[Tracker]] = []
        
        if !pinnedTrackers.isEmpty {
            sections.append(pinnedTrackers)
        }
        
        sectionsCoreData.forEach { section in
            var trackers = [Tracker]()
            section.objects?.forEach { object in
                if let trackerCoreData = object as? TrackerCoreData,
                   let tracker = try? makeTracker(from: trackerCoreData),
                   !tracker.pinned
                { trackers.append(tracker) }
            }
            if !trackers.isEmpty {
                sections.append(trackers)
            }
        }
        return sections
    }

}

extension TrackerStore {
    enum StoreError: Error {
        case decodeError, fetchTrackerError, deleteError, pinError, saveError
    }
}

// MARK: - TrackerStoreProtocol

extension TrackerStore: TrackerStoreProtocol {
    var numberOfTrackers: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    var numberOfSections: Int {
        sections.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        sections[section].count
    }
    
    func headerLabelInSection(_ section: Int) -> String? {
        if !pinnedTrackers.isEmpty && section == 0 {
            return "Закрепленные"
        }
        guard let category = sections[section].first?.category else { return nil }
        return category.label
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let tracker = sections[indexPath.section][indexPath.item]
        return tracker
    }
    
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: category.id)
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerId = tracker.id.uuidString
        trackerCoreData.createdAt = Date()
        trackerCoreData.label = tracker.label
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHEX = uiColorMarshalling.makeHEX(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule?.map { $0.rawValue } as AnyObject?
        trackerCoreData.category = categoryCoreData
        trackerCoreData.pinned = tracker.pinned
        trackerCoreData.finished = false
        trackerCoreData.completedDaysCount = 0
        try context.save()
    }
    
    func loadCompletedTrackers() throws -> [Tracker] {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "finished == %@", NSNumber(value: true))
        let trackersCoreData = try? context.fetch(request)
        
        guard let trackersCoreData else { throw StoreError.fetchTrackerError }
        return trackersCoreData.compactMap { try? makeTracker(from: $0) }
    }
    
    func updateTracker(_ tracker: Tracker, with data: Tracker.Data) throws {
        guard
            let emoji = data.emoji,
            let category = data.category
        else { return }
        
        let trackerCoreData = try getTrackerCoreData(by: tracker.id)
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: category.id)
        trackerCoreData?.label = data.label
        trackerCoreData?.emoji = emoji
        trackerCoreData?.colorHEX = uiColorMarshalling.makeHEX(from: data.color ?? .yaBlack)
        if let schedule = data.schedule?.map({ $0.rawValue }) {
            trackerCoreData?.schedule = schedule as AnyObject
        }
        trackerCoreData?.category = categoryCoreData
        if let finished = data.finished {
            trackerCoreData?.finished = finished
        }
        trackerCoreData?.completedDaysCount = Int32(data.completedDaysCount)
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker) throws  {
        guard let trackerToDelete = try getTrackerCoreData(by: tracker.id) else { throw StoreError.deleteError }
        context.delete(trackerToDelete)
        try context.save()
    }
    
    func togglePin(for tracker: Tracker) throws  {
        guard let trackerToToggle = try getTrackerCoreData(by: tracker.id) else {
            throw StoreError.pinError
        }
        trackerToToggle.pinned.toggle()

        try context.save()
    }

}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}

