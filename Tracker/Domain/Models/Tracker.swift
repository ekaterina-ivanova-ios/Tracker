import UIKit

struct Tracker: Identifiable {
    let id: UUID
    let label: String
    let emoji: String
    let color: UIColor
    let completedDaysCount: Int
    let schedule: [Weekday]?
    let pinned: Bool
    let category: TrackerCategory?
    
    init(id: UUID = UUID(),
         label: String,
         emoji: String,
         color: UIColor,
         completedDaysCount: Int,
         schedule: [Weekday]?,
         pinned: Bool,
         category: TrackerCategory) {
        self.id = id
        self.label = label
        self.emoji = emoji
        self.color = color
        self.completedDaysCount = completedDaysCount
        self.schedule = schedule
        self.pinned = pinned
        self.category = category
    }

    init(data: Data) {
        guard let emoji = data.emoji, let color = data.color else { fatalError() }
        
        self.id = UUID()
        self.label = data.label
        self.emoji = emoji
        self.color = color
        self.completedDaysCount = data.completedDaysCount
        self.schedule = data.schedule
        self.pinned = data.pinned
        self.category = data.category
    }
    
    var data: Data {
        Data(label: label,
             emoji: emoji,
             color: color,
             completedDaysCount: completedDaysCount,
             schedule: schedule,
             pinned: pinned,
             category: category)
    }
}

extension Tracker {
    struct Data {
        var label: String = ""
        var emoji: String? = nil
        var color: UIColor? = nil
        var completedDaysCount: Int = 0
        var schedule: [Weekday]? = nil
        var pinned: Bool = false
        var category: TrackerCategory?
    }
}

enum Weekday: Int, CaseIterable, Comparable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thurshday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var shortForm: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thurshday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    var russianForm: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thurshday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        guard
            let first = Self.allCases.firstIndex(of: lhs),
            let second = Self.allCases.firstIndex(of: rhs)
        else { return false }
        
        return first < second
    }
}

