import UIKit

struct StatisticCellViewModel {
    let title: String
    let value: String
}

extension StatisticCell {
    enum Layout {
        static let gradientViewHorizontalOffset: CGFloat = 16
        static let gradientViewVerticalOffset: CGFloat = 6
        static let valueLabelTopOffset: CGFloat = 12
        static let contentHorizontalOffset: CGFloat = 12
        static let titleLabelTopOffset: CGFloat = 12
        static let titleLabelBottomOffset: CGFloat = 12
    }
}

final class StatisticCell : UITableViewCell {
    
    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let whiteLayer = CALayer()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupInitial()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.layer.sublayers?.forEach {
            if $0 is CAGradientLayer {
                $0.removeFromSuperlayer()
            }
        }
        
        gradientLayer.frame = gradientView.bounds
        whiteLayer.frame = CGRect(
            x: 1,
            y: 1,
            width: gradientView.bounds.width - 2,
            height: gradientView.bounds.height - 2
        )
        setupGradientView()
    }
    
    func update(with viewModel: StatisticCellViewModel) {
        titleLabel.text = viewModel.title
        valueLabel.text = viewModel.value
    }
}

private extension StatisticCell {
    func setupInitial() {
        
        contentView.addSubview(gradientView)
        contentView.backgroundColor = .yaWhite
        gradientView.addSubview(valueLabel)
        gradientView.addSubview(titleLabel)
        
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        valueLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                              constant: Layout.gradientViewVerticalOffset),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                 constant: -Layout.gradientViewVerticalOffset),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                   constant: -Layout.gradientViewHorizontalOffset),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                  constant: Layout.gradientViewHorizontalOffset),
            
            valueLabel.topAnchor.constraint(equalTo: gradientView.topAnchor,
                                            constant: Layout.valueLabelTopOffset),
            valueLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor,
                                                constant: Layout.contentHorizontalOffset),
            
            titleLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor,
                                               constant: -Layout.titleLabelBottomOffset),
            titleLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor,
                                                constant: Layout.contentHorizontalOffset)
        ])
    }
    
    func setupGradientView() {
        let colors = [UIColor(hexString: "#FD4C49"),
                      UIColor(hexString: "#46E69D"),
                      UIColor(hexString: "#007BFA")].compactMap { $0?.cgColor }
        
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5) // Левая точка градиента
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5) // Правая точка градиента
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        whiteLayer.backgroundColor = UIColor.yaWhite.cgColor
        whiteLayer.masksToBounds = true
        whiteLayer.cornerRadius = 15
        gradientView.layer.insertSublayer(whiteLayer, at: 1)
        
        gradientView.layer.cornerRadius = 16
        gradientView.layer.masksToBounds = true
    }
}


