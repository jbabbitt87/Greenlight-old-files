//
//  TaskViewModel.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 1/31/25.
//

import Foundation

import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var taskListModel = TaskListModel()
    @Published var selectedTask: DailyTask?
    
    // State variables for sheet presentation
    @Published var isPresentingDailyTasksSettingsView = false
    @Published var isPresentingAppUsageTasksSettingsView = false
    @Published var isPresentingSelfReportedTasksSettingsView = false

    func showSettings(for task: DailyTask) {
        selectedTask = task
        switch task.type {
        case .appSpecific:
            isPresentingDailyTasksSettingsView = true
        case .appUsage:
            isPresentingAppUsageTasksSettingsView = true
        case .selfReported:
            isPresentingSelfReportedTasksSettingsView = true
        default:  // Handles future unknown cases
                print("Unhandled task type: \(task.type)")
        }
    }
    
    func dismissSheet() {
        isPresentingDailyTasksSettingsView = false
        isPresentingAppUsageTasksSettingsView = false
        isPresentingSelfReportedTasksSettingsView = false
    }
    
    func addOrUpdateTask(_ task: DailyTask) {
        if let index = taskListModel.dailyTasks.firstIndex(where: { $0.id == task.id }) {
            taskListModel.dailyTasks[index] = task
        } else {
            taskListModel.addOrUpdateTask(task)
        }
    }
}
