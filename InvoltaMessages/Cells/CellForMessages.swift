//
//  CellForMessages.swift
//  InvoltaMessages
//
//  Created by Dany on 17.05.2022.
//

import UIKit
import SkeletonView

class CellForMessages: UICollectionViewCell {
    let identifier = "CellID"
    let modeLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 25, weight: .light)
        return label
    }()
    
    //MARK: Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super .init(coder: coder)
    }
    
    //MARK: Methods
    
    func setUpViews() {
        contentView.isSkeletonable = true
        modeLabel.isSkeletonable = true
        contentView.backgroundColor = .white
        contentView.addSubview(modeLabel)
        contentView.layer.cornerRadius = 20
    }
    
    func setupLayout() {
        let constraints = [
            modeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            modeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            modeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            modeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
