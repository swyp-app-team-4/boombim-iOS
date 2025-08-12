//
//  MapPickerViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit

final class MapPickerViewController: UIViewController {
    private let viewModel: MapPickerViewModel
    
    
    init(viewModel: MapPickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "지도 선택"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
