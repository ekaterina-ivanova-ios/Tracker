import UIKit

enum Resources {
    
    enum Strings {
        enum TabBar {
            static var statistic = "Статистика"
            static var tracker = "Трекеры"
        }
    }
    
    enum Images {
        enum TabBar {
            static var statistic = UIImage(named: "Statistic")
            static var tracker = UIImage(named: "Tracker")
        }
        enum Error {
            static var errorTracker = UIImage(named: "errorTracker")
            static var errorStatistic = UIImage(named: "errorStatistic")
        }
        enum Empty {
            static var emptyTracker = UIImage(named: "Star")
        }
    }
}

