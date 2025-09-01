//
//  PlaceListViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/1/25.
//

import UIKit

final class PlaceListViewController: UIViewController {
    let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        view.addSubview(tableView)
        tableView.frame = view.bounds
        // FloatingPanel: 내부적으로 감지하지만, 필요시 fpc.track(scrollView:) 호출
    }
}
