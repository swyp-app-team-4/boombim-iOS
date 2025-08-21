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
    let isRead: Bool
}

struct NoticeItem: Hashable {
    let id = UUID()
    let image: UIImage
    let title: String
    let date: String
    let isRead: Bool
}

struct AlarmItem: Decodable {
    let alarmReId: Int
    let title: String
    let alarmType: String
    let deliveryStatus: String
    let alarmTime: String
}
