import UIKit

final class Button: UIButton {
    convenience init(color: UIColor = .yaBlack, titleColor: UIColor = .yaWhite, title: String) {
        self.init(type: .system)
        
        setTitle(title, for: .normal)
        backgroundColor = color
        
        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        layer.cornerRadius = 24
    }
    
    static func danger(title: String) -> Self {
        let button = self.init(color: .clear, title: title)
        
        button.setTitleColor(.red, for: .normal)
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        
        return button
    }
}

