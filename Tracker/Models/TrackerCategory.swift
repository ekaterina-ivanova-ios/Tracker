import UIKit

struct TrackerCategory {
    let label: String
    let trackers: [Tracker]
    
    init(label: String, trackers: [Tracker]) {
        self.label = label
        self.trackers = trackers
    }
}

extension TrackerCategory {
    static let sampleData: [TrackerCategory] = [
        TrackerCategory(
            label: "Хобби",
            trackers: [
//                Tracker(
//                    label: "Спорт",
//                    emoji: "🏃‍♀️",
//                    color: UIColor(named: "Color selection 13")!,
//                    schedule: [.saturday]
//                )
            ]
        ),
       TrackerCategory(
            label: "Работа",
            trackers: [
//                Tracker(
//                    label: "Дэйлик",
//                    emoji: "📞",
//                    color: UIColor(named: "Color selection 7")!,
//                    schedule: nil
//                ),
//                Tracker(
//                    label: "Регресс",
//                    emoji: "🔍",
//                    color: UIColor(named: "Color selection 2")!,
//                    schedule: nilTrackerViewController
//                )
            ]
        )
    ]
}

