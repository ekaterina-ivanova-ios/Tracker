import UIKit

enum Tabs: Int {
    case tracker
    case statistic
}

final class TabBarController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        tabBar.tintColor = .yaBlue
        tabBar.barTintColor = .yAGray
        tabBar.backgroundColor = .yaWhite
        
        tabBar.layer.borderColor = UIColor.yAGray.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.layer.masksToBounds = true
        
        let trackerviewController = TrackerController()
        let statisticviewController = StatisticController()
        
        trackerviewController.tabBarItem = UITabBarItem(title: Resources.Strings.TabBar.tracker, image: Resources.Images.TabBar.tracker, tag: Tabs.tracker.rawValue)
        statisticviewController.tabBarItem = UITabBarItem(title: Resources.Strings.TabBar.statistic, image: Resources.Images.TabBar.statistic, tag: Tabs.statistic.rawValue)
        
        let controllers = [trackerviewController,
                           statisticviewController]
        
        viewControllers = controllers
    }
    
}
