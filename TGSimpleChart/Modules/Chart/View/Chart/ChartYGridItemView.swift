import UIKit

class ChartYGridItemView: UIView, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = TGFonts.regular(ofSize: 14)
        return label
    }()
    private let lineView = UIView()
    
    var style: TGColorStyleProtocol { return styleController.style }
    private let styleController: TGStyleController
    init(string: String, styleController: TGStyleController) {
        self.styleController = styleController
        super.init(frame: .zero)
        
        setViews(string: string)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setViews(string: String) {
        titleLabel.text = string
        
        addSubviews([titleLabel, lineView])
        
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.titleLabel.textColor = sSelf.style.chartValueTitle
            sSelf.lineView.backgroundColor = sSelf.style.chartYGridLineBackground
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: lineView.topAnchor, constant: -3.5)
            ])
        
        NSLayoutConstraint.activate([
            lineView.leftAnchor.constraint(equalTo: leftAnchor),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.rightAnchor.constraint(equalTo: rightAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
            ])
    }
}
