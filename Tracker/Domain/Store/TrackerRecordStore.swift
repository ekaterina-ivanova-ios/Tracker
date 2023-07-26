import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords(_ records: Set<TrackerRecord>)
}

protocol TrackerRecordStoreProtocol: AnyObject {
    func getTrackerRecord(trackerId: UUID) throws -> TrackerRecord?
    func add(_ newRecord: TrackerRecord) throws
    func remove(_ record: TrackerRecord) throws
}

final class TrackerRecordStore: NSObject {
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStoreProtocol
    
    // MARK: - Lifecycle
    
    convenience init(trackerStore: TrackerStoreProtocol) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context, trackerStore: trackerStore)
    }
    
    init(context: NSManagedObjectContext, trackerStore: TrackerStoreProtocol) {
        self.context = context
        self.trackerStore = trackerStore
        super.init()
    }
    
    private func makeTrackerRecord(from coreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let idString = coreData.recordId,
            let id = UUID(uuidString: idString),
            let date = coreData.date,
            let trackerCoreData = coreData.tracker,
            let tracker = try? trackerStore.makeTracker(from: trackerCoreData)
        else { throw StoreError.decodeError }
        return TrackerRecord(id: id, trackerId: tracker.id, date: date)
    }
}

extension TrackerRecordStore {
    enum StoreError: Error {
        case decodeError
    }
}

extension TrackerRecordStore: TrackerRecordStoreProtocol {

    func getTrackerRecord(trackerId: UUID) throws -> TrackerRecord? {
        guard let trackerCoreData = try? trackerStore.getTrackerCoreData(by: trackerId) else {
            return nil
        }
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.tracker), trackerCoreData as TrackerCoreData)
        let recordsCoreData = try context.fetch(request)
        let records = try recordsCoreData.map { try makeTrackerRecord(from: $0) }
        return records.first
    }
    
    func add(_ newRecord: TrackerRecord) throws {
        let trackerCoreData = try trackerStore.getTrackerCoreData(by: newRecord.trackerId)
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.recordId = newRecord.id.uuidString
        trackerRecordCoreData.date = newRecord.date
        trackerRecordCoreData.tracker = trackerCoreData
        try context.save()
    }
    
    func remove(_ record: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.recordId), record.id.uuidString
        )
        let records = try context.fetch(request)
        guard let recordToRemove = records.first else { return }
        context.delete(recordToRemove)
        try context.save()
    }
}

