//
//  AlarmStore.swift
//  BoomBim
//
//  Created by 조영현 on 10/22/25.
//

import Foundation

protocol AlarmStoring {
    var currentAlarmState: Bool? { get }
    func setCurrentAlarmState(_ provider: Bool)
    func resetAlarmState()
    
    var pendingEnableAfterPermission: Bool { get set }
}

final class AlarmStore: AlarmStoring {
    static let shared = AlarmStore()
    
    private let key = UserDefaultsKeys.Alarm.alarm
    private let pendingKey = UserDefaultsKeys.Alarm.pendingEnableAfterPermission
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var currentAlarmState: Bool? {
        guard defaults.object(forKey: key) != nil else { return nil }
        
        return defaults.bool(forKey: key)
    }

    func setCurrentAlarmState(_ state: Bool) {
        defaults.set(state, forKey: key)
    }

    func resetAlarmState() {
        defaults.set(true, forKey: key)
    }
    
    var pendingEnableAfterPermission: Bool {
        get { defaults.bool(forKey: pendingKey) }
        set { defaults.set(newValue, forKey: pendingKey) }
    }
}

