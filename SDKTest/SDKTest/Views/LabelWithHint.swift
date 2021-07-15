import Foundation
import UIKit

/**
 Visual helper class to show a 2 row element with a value and below smaller with an explanation
 */
class LabelWithHint: UIView {

    private let value: UILabel = UILabel()
    private let hint: UILabel = UILabel()

    init(_ withDivider: Bool) {
        super.init(frame: .zero)
        self.createViews(withDivider)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViews(_ withDivider: Bool) {
        
        self.value.textAlignment = .center
        self.value.textColor = .white
        self.value.font = UIFont.systemFont(ofSize: 16)
        
        self.hint.textAlignment = .center
        self.hint.textColor = .gray
        self.hint.font = UIFont.systemFont(ofSize: 12)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 5
        
        stackView.addArrangedSubview(self.value)
        stackView.addArrangedSubview(self.hint)
        
        self.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        if (withDivider) {
            let divider = UIView()
            divider.backgroundColor = .gray
            divider.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview(divider)
            
            divider.leadingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
            divider.heightAnchor.constraint(equalTo: self.hint.heightAnchor).isActive = true
            divider.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            divider.widthAnchor.constraint(equalToConstant: 1).isActive = true
            divider.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            
            return
        }
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

    }

    func updateValue(value: String) {
        self.value.text = value
    }

    func updateHint(hint: String) {
        self.hint.text = hint
    }
}
