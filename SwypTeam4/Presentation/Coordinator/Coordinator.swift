//
//  Coordinator.swift
//  SwypTeam4
//
//  Created by 조영현 on 8/1/25.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}
