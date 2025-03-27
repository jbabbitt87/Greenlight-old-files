//
//  AppUsageView.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 2/4/25.
//
/*
import SwiftUI

struct AppUsageView: View {
    @ObservedObject var taskListModel: TaskListModel
    @ObservedObject var appUsageManager = AppUsageManager.shared

    var body: some View {
        VStack {
            Text("App Usage Progress")
                .font(.headline)
                .padding()

            List {
                ForEach(filteredTasks) { task in
                    if let goalTime = task.appUsageTime {
                        let currentUsage = appUsageManager.getUsageTime(for: task.appName)
                        let isCompleted = currentUsage >= goalTime

                        HStack {
                            // App Icon
                            if let icon = getAppIcon(for: task.appName) {
                                Image(uiImage: icon)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "app.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            }

                            VStack(alignment: .leading) {
                                Text(task.appName)
                                    .font(.headline)

                                ProgressView(value: Double(currentUsage), total: Double(goalTime))
                                    .progressViewStyle(LinearProgressViewStyle(tint: isCompleted ? .green : .blue))
                                    .frame(height: 10)

                                Text("\(currentUsage)/\(goalTime) minutes")
                                    .font(.subheadline)
                                    .foregroundColor(isCompleted ? .green : .primary)
                            }

                            Spacer()

                            // Green checkmark if completed
                            if isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .imageScale(.large)
                                    .padding(.trailing, 10)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
    }

    // Filter tasks based on type and current day
    private var filteredTasks: [DailyTask] {
        let currentWeekday = Calendar.current.component(.weekday, from: Date()) // 1 = Sunday, ..., 7 = Saturday
        return taskListModel.dailyTasks.filter { task in
            task.type == .appUsage && task.days.contains(where: { Int($0) == currentWeekday })
        }
    }


    // Helper function to get app icon (you may need to adjust this based on your data source)
    private func getAppIcon(for appName: String) -> UIImage? {
        let bundleID = appName // Assuming appName is the bundle ID
        return UIImage(named: bundleID) // Replace with actual method to get the icon
    }
}

*/
