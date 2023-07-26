import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerViewControllerTests: XCTestCase {
    
    var viewController: TrackerController!
    
    override func setUpWithError() throws {
        viewController = TrackerController(trackerStore: StubTrackerStore())
    }
    
    override func tearDownWithError() throws {
        viewController = nil
    }
    
    func testTrackersViewControllerSnapshot() throws {
        let vc = TrackerController(trackerStore: StubTrackerStore())
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackersViewControllerDarkSnapshot() throws {
        let vc = TrackerController(trackerStore: StubTrackerStore())
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
    
}

extension TrackerViewControllerTests {
    private class StubTrackerStore: TrackerStoreProtocol {
        func loadFilteredTrackers(date: Date, searchString: String?) throws {
        }
        
        
        weak var delegate: TrackerStoreDelegate?
        
        private let category = TrackerCategory(label: "Cleaning")
        
        private lazy var trackers: [[Tracker]] = [
            [Tracker(label: "Washing the dishes",
                     emoji: "🙌",
                     color: .selection[4],
                     completedDaysCount: 0,
                     schedule: nil,
                     pinned: true,
                     category: category)],
            
            [Tracker(label: "Vacuuming",
                     emoji: "😪",
                     color: .selection[2],
                     completedDaysCount: 2,
                     schedule: [.friday],
                     pinned: false,
                     category: category),
             
             Tracker(label: "Finish house painting",
                     emoji: "🥇",
                     color: .selection[1],
                     completedDaysCount: 2,
                     schedule: [.friday, .sunday],
                     pinned: false,
                     category: category)]
            
        ]
        
        var numberOfTrackers: Int = 3
        
        var numberOfSections: Int = 2
        
        func numberOfRowsInSection(_ section: Int) -> Int {
            switch section {
            case 0: return 1
            case 1: return 2
            default: return 0
            }
        }
        
        func headerLabelInSection(_ section: Int) -> String? {
            switch section {
            case 0: return "Закрепленные"
            case 1: return category.label
            default: return nil
            }
        }
        
        func tracker(at indexPath: IndexPath) -> Tracker? {
            let tracker = trackers[indexPath.section][indexPath.item]
            return tracker
        }
        
        func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {}
        
        func updateTracker(_ tracker: Tracker, with data: Tracker.Data) throws {}
        
        func deleteTracker(_ tracker: Tracker) throws {}
        
        func togglePin(for tracker: Tracker) throws {}
        
        func getTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
            return nil
        }
        
        func makeTracker(from coreData: TrackerCoreData) throws -> Tracker {
            Tracker(label: "Finish house painting",
                    emoji: "🥇",
                    color: .selection[1],
                    completedDaysCount: 2,
                    schedule: [.friday, .sunday],
                    pinned: false,
                    category: category)
        }
        
        func loadAllTrackers() throws -> [Tracker] {
            return []
        }
        
    }
}

