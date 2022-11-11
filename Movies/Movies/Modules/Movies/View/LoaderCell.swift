//
//  IndicatorCell.swift
//  Movies
//
//  Created by Евгений  on 05/11/2022.
//

import UIKit

final class LoaderCell: BaseCollectionViewCell {
 
    //MARK: - Properties
    private let titleFontSize: CGFloat = 26
    private let labelHeigth: CGFloat = 50
    private let spacing: CGFloat = 15
    private let labelTitle: String = "Loading..."
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: .zero,
                                          y: labelHeigth / 2,
                                          width: frame.width,
                                          height: labelHeigth))
        label.attributedText = NSAttributedString(
            string: labelTitle,
            attributes: [.font: UIFont(name: Constants.appFont, size: titleFontSize) as Any,
                         .foregroundColor: Constants.appColor as Any]
        )
        label.textAlignment = .center
        return label
    }()
    
    private lazy var activityInidicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.center = contentView.center
        indicator.style = .medium
        indicator.color = Constants.appColor
        return indicator
    }()
    
    //MARK: - Methods
    func configure() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(activityInidicator)
        activityInidicator.startAnimating()
    }
    
}
