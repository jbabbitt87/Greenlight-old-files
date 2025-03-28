//
//  UsageTimerAttributes.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 2/17/25.
//
/*
import Foundation
import ActivityKit
import SwiftUI
import UserNotifications

struct UsageTimerAttributes: ActivityAttributes, Codable {
    var taskListModel: TaskListModel
    struct ContentState: Codable, Hashable {
        var elapsedTime: TimeInterval
        var goalTime: TimeInterval
        var appName: String
}
    // Manually implementing decoding if taskListModel is not decodable
       enum CodingKeys: String, CodingKey {
           case taskListModel
       }

       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           
           // Decode the taskListModel manually if necessary
           taskListModel = try container.decode(TaskListModel.self, forKey: .taskListModel)
       }
   

    func startUsageTimer(for task: DailyTask) {
        guard let taskData = taskListModel.dailyTasks.first(where: { $0.appName == task.appName }) else {
                print("Error: Task not found in TaskListModel")
                return
            }

            let remainingTime = getRemainingTime(for: taskData)

            guard remainingTime > 0 else {
                print("Task already completed!")
                return
            }

            let attributes = UsageTimerAttributes(taskListModel: taskListModel) // Pass model reference
        let contentState = UsageTimerAttributes.ContentState(elapsedTime: 0, goalTime: Double(taskData.appUsageTime ?? 0), appName: taskData.appName)

            do {
                let activity = try Activity<UsageTimerAttributes>.request(
                    attributes: attributes,
                    contentState: contentState,
                    pushType: nil
                )
                print("Live Activity started for \(taskData.appName), needs \(remainingTime) min")
            } catch {
                print("Error starting Live Activity: \(error)")
            }
        }

    func openTrackedApp(task: DailyTask) {
        // Find the correct DailyTask in taskListModel
        guard let selectedTask = taskListModel.dailyTasks.first(where: { $0.appName == task.appName }) else {
            print("Error: Task not found in TaskListModel")
            return
        }
        
        // Start usage timer for the selected task
        startUsageTimer(for: selectedTask)
        
        // Open deep link if available
        if let url = URL(string: selectedTask.appDeepLink ?? ""), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    func updateUsageTimer() {
        for activity in Activity<UsageTimerAttributes>.activities {
            Task {
                var newElapsedTime = activity.content.elapsedTime + 60 // Add 1 min
                let goalTime = activity.content.goalTime // Task's required usage time
                
                // Find the corresponding DailyTask from TaskListModel
                guard let task = taskListModel.dailyTasks.first(where: { $0.appName == activity.contentState.appName }) else {
                    print("Error: Task not found in TaskListModel for app \(activity.contentState.appName)")
                    return
                }

                if newElapsedTime >= goalTime {
                    newElapsedTime = goalTime // Prevent exceeding goal
                    
                    await sendGoalReachedNotification(for: task.appName) // ✅ Use task.appName
                    await stopUsageTimer(activity: activity) // ✅ Stop the Live Activity
                } else {
                    await activity.update(using: UsageTimerAttributes.ContentState(
                        elapsedTime: newElapsedTime,
                        goalTime: Double(task.appUsageTime) ?? 0,
                        appName: task.appName // ✅ Now correctly passing appName
                    ))
                }
            }
        }
    }
    func sendGoalReachedNotification(for appName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Goal Reached!"
        content.body = "You've reached your goal in \(appName)! Return to complete your task."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "\(appName)-goal", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    func stopUsageTimer(activity: Activity<UsageTimerAttributes>) async {
        let finalTime = activity.content.elapsedTime

        // Find the corresponding DailyTask from TaskListModel
        guard let task = taskListModel.dailyTasks.first(where: { $0.appName == activity.content.appName }) else {
            print("Error: Task not found in TaskListModel for app \(activity.content.appName)")
            return
        }

        // Store the final elapsed time in UserDefaults
        storeTimeInUserDefaults(for: task.appName, time: finalTime)

        // End the Live Activity
        await activity.end()
    }


    func storeTimeInUserDefaults(for appName: String, time: TimeInterval) {
        let defaults = UserDefaults.standard
        let currentTime = defaults.double(forKey: appName) // Get previously stored time
        defaults.set(currentTime + time, forKey: appName)  // Add new tracked time
    }
    func getRemainingTime(for task: DailyTask) -> TimeInterval {
        let loggedTime = UserDefaults.standard.double(forKey: task.appName) // Stored time
        return max(Double(task.appUsageTime ?? 0) - loggedTime, 0) // Remaining time needed
    }

        
    
}
*/
