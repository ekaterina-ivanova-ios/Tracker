import UIKit

final class NavBarController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
    }
    
    private func  configure() {
        view.backgroundColor = .yaWhite
        navigationBar.isTranslucent = false
        
    }
    
    
}
