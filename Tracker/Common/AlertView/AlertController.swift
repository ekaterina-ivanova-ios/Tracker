import UIKit

final class AlertController {
    
    private let viewModel: AlertViewModelProtocol
    
    init(viewModel: AlertViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func presentAlert(animated: Bool, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: viewModel.title,
                                                message: viewModel.message,
                                                preferredStyle: viewModel.preferredStyle)
        
        if let firstAlertActionViewModel = viewModel.firstAlertActionModel {
            let action = UIAlertAction(title: firstAlertActionViewModel.title,
                                       style: firstAlertActionViewModel.style,
                                       handler: firstAlertActionViewModel.handler)
                                       
            alertController.addAction(action)
        }
        
        if let secondAlertActionViewModel = viewModel.secondAlertActionModel {
            let action = UIAlertAction(title: secondAlertActionViewModel.title,
                                       style: secondAlertActionViewModel.style,
                                       handler: secondAlertActionViewModel.handler)
                                       
            alertController.addAction(action)
        }
        let viewController = UIViewController()
        viewController.present(alertController, animated: animated, completion: completion)
    }
}

