import UIKit

protocol AlertViewModelProtocol {
    var title: String? { get }
    var message: String { get }
    var preferredStyle: UIAlertController.Style { get }
    var firstAlertActionModel: AlertActionModel? { get }
    var secondAlertActionModel: AlertActionModel? { get }
}

final class AlertViewModel {
    var title: String?
    var message: String
    var preferredStyle: UIAlertController.Style
    var firstAlertActionModel: AlertActionModel?
    var secondAlertActionModel: AlertActionModel?
    
    init(title: String?,
         message: String,
         preferredStyle: UIAlertController.Style,
         firstAlertActionModel: AlertActionModel?,
         secondAlertActionModel: AlertActionModel?) {
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        self.firstAlertActionModel = firstAlertActionModel
        self.secondAlertActionModel = secondAlertActionModel
    }
}

extension AlertViewModel: AlertViewModelProtocol {}
