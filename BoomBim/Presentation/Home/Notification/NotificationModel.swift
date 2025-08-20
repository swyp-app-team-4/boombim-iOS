//
//  NotificationModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/8/25.
//

import UIKit

struct NewsItem: Hashable {
    let id = UUID()
    let image: UIImage
    let title: String
    let date: String
    let isNoti: Bool
}

struct NoticeItem: Hashable {
    let id = UUID()
    let image: UIImage
    let title: String
    let date: String
}
