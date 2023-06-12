import UIKit

struct AlertActionModel {
    let title: String
    let style: UIAlertAction.Style
    let handler: ((UIAlertAction) -> Void)?
    let titleTextColor: UIColor
    
    init(title: String,
         style: UIAlertAction.Style,
         titleTextColor: UIColor = .systemBlue,
         handler: ((UIAlertAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.titleTextColor = titleTextColor
        self.handler = handler
    }
}
