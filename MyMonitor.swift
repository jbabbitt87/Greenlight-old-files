//
//  MyMonitor.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 2/18/25.
//

import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls
/*

class MyMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()

    // Access the shared UserDefaults for app groups
    let userDefaults = UserDefaults(suiteName: "group.com.greenlightv4.deviceactivity")

    
    // Helper function to load selected apps from UserDefaults
    func loadSelectedApps() -> (encouragedApps: Set<ApplicationToken>, discouragedApps: Set<ApplicationToken>) {
        var encouragedApps = Set<ApplicationToken>()
        var discouragedApps = Set<ApplicationToken>()

        // Load encouraged apps
        if let encodedEncouraged = userDefaults?.data(forKey: "EncouragedApps") {
            do {
                if let selectionEncouraged = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(encodedEncouraged) as? FamilyActivitySelection {
                    encouragedApps = Set(selectionEncouraged.applicationTokens)
                }
            } catch {
                print("Error loading encouraged apps: \(error)")
            }
        }

        // Load discouraged apps
        if let encodedDiscouraged = userDefaults?.data(forKey: "DiscouragedApps") {
            do {
                if let selectionDiscouraged = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(encodedDiscouraged) as? FamilyActivitySelection {
                    discouragedApps = Set(selectionDiscouraged.applicationTokens)
                }
            } catch {
                print("Error loading discouraged apps: \(error)")
            }
        }

        return (encouragedApps, discouragedApps)
    }

    // When the interval starts, shield the discouraged apps
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        let (encouragedApps, discouragedApps) = loadSelectedApps()

        // Shield discouraged apps by adding them to the store
        store.shield.applications = discouragedApps.isEmpty ? nil : discouragedApps

        // Debug log
        print("Monitoring started for discouraged apps: \(discouragedApps)")
    }

    // When the interval ends, do any necessary cleanup
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("Interval ended for activity: \(activity)")
    }

    // Handle when an event reaches its threshold
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        // Load encouraged apps to compare with the event
        let (encouragedApps, _) = loadSelectedApps()

        // Check if the event's app is one of the encouraged apps
        if encouragedApps.contains(where: { "\($0)" == event.rawValue }) {
            print("Encouraged app threshold reached for: \(event.rawValue)")

            // Handle actions when the encouraged app threshold is met
            // You could, for example, update the UI, unlock shielded apps, etc.
        }
    }
}


*/
