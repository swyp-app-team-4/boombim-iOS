//
//  UserPlaceDetailViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/5/25.
//

import UIKit

final class UserPlaceDetailViewController: BaseViewController {
    private let viewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        label.textAlignment = .center
        label.text = "place.detail.label.title".localized()
        
        return label
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconUnselectedFavorite, for: .normal)
        button.setImage(.iconSelectedFavorite, for: .selected)
        button.contentMode = .scaleAspectFit
        
        return button
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        
        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        
        return label
    }()

    private let congestionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let spacingView: UIView = {
        let view = UIView()
        view.backgroundColor = .viewDivider
        
        return view
    }()
}
