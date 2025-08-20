//
//  SeparatorView.swift
//  BoomBim
//
//  Created by 조영현 on 8/20/25.
//

import UIKit

final class SeparatorView: UICollectionReusableView {
    static let elementKind = "separator-kind"
    static let identifier = "SeparatorView"
    
    private let lineView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)
        
        NSLayoutConstraint.activate([
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(){
        lineView.backgroundColor = .grayScale3
    }
}
