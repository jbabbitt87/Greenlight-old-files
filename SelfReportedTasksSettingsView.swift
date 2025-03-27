//
//  SelfReportedTasksSettingsView.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 1/31/25.
//


import SwiftUI
import Foundation

struct SelfReportedTasksSettingsView: View {
    var earnApp: [TaskApplication]
    var onSave: (DailyTask) -> Void
    @Binding var isPresented: Bool
    var taskToEdit: DailyTask?
    @ObservedObject var taskListModel = TaskListModel()  // Use the model to update tasks
    @ObservedObject private var shieldingManager = AppShieldingManager.shared // To update shielding state

    // State variables
    @State private var daysSelected: [String: Bool] = [
        "Sunday": false,
        "Monday": false,
        "Tuesday": false,
        "Wednesday": false,
        "Thursday": false,
        "Friday": false,
        "Saturday": false
    ]
    @State private var isTaskEnabled: Bool = false
    @State private var isCompleted: Bool = false
    @State private var selectedApplication: String = ""
    @State private var selectedTask: String = ""
    @State private var selectedApp: TaskApplication? // Track selected App
    @State private var selectedTaskOption: TaskOption? // Track selected Task

    // Computed properties
    var applicationList: [String] {
        earnApp.map { $0.name }
    }

    var availableTasks: [String] {
        if let selectedApp = earnApp.first(where: { $0.name == selectedApplication }) {
            return selectedApp.availableTasks.map { $0.name }
        }
        return []
    }

    // Updated init
    init(
        earnApp: [TaskApplication],
        isPresented: Binding<Bool>,
        taskToEdit: DailyTask?, // 👈 No longer a Binding
        onSave: @escaping (DailyTask) -> Void,
        taskListModel: TaskListModel
    ) {
        self.earnApp = earnApp
        self._isPresented = isPresented
        self.taskToEdit = taskToEdit // 👈 Regular variable, not a Binding
        self.onSave = onSave
        self.taskListModel = taskListModel

        // Extract values safely before initializing @State properties
        let app = earnApp.first(where: { $0.name == taskToEdit?.appName })
        let taskOption = app?.availableTasks.first(where: { $0.name == taskToEdit?.name })
        let initialDaysSelected = Dictionary(
            uniqueKeysWithValues: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                .map { ($0, taskToEdit?.days.contains($0) ?? false) }
        )

        _selectedApp = State(initialValue: app)
        _selectedTaskOption = State(initialValue: taskOption)
        _daysSelected = State(initialValue: initialDaysSelected)
        _selectedApplication = State(initialValue: taskToEdit?.appName ?? "") // Set initial value correctly
    }


    var body: some View {
        VStack {
            // Title with close button
            HStack {
                Text(taskToEdit == nil ? "New Daily Task" : "Edit Daily Task")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                        .font(.title)
                }
            }
            .padding()

            // Application Picker
            VStack(alignment: .leading) {
                Text("Select Category")
                    .font(.headline)
                Picker("Select App", selection: $selectedApplication) {
                    ForEach(ApplicationData.appList.filter { app in
                        app.availableTasks.contains { $0.type == .selfReported }
                    }, id: \.name) { app in
                        Text(app.name).tag(app.name)
                    }
                }
                .pickerStyle(WheelPickerStyle())

                .onChange(of: selectedApplication) { newValue in
                    
                    
                    // Find the new selected app
                        if let app = earnApp.first(where: { $0.name == newValue }) {
                            selectedApp = app
                            selectedTaskOption = app.availableTasks.first // Auto-select first task option
                        } else {
                            selectedApp = nil
                            selectedTaskOption = nil
                        }
                    
                }
                .pickerStyle(WheelPickerStyle())
                .padding(.vertical)
            }

            // Task Picker
            VStack(alignment: .leading) {
                Text("Select a Task")
                    .font(.headline)
                if let app = selectedApp {
                    Picker("Select Task", selection: $selectedTaskOption) {
                        ForEach(app.availableTasks.filter { $0.type == .selfReported }, id: \.name) { task in
                            Text(task.name).tag(task as TaskOption?)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding(.vertical)
                }
            }
            Spacer()

            // Day Buttons
            VStack {
                Text("Select Days")
                    .font(.title2)
                HStack {
                    ForEach(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], id: \.self) { day in
                        Button(action: {
                            daysSelected[day]?.toggle()
                        }) {
                            ZStack {
                                Rectangle()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(25)
                                    .foregroundColor(daysSelected[day] == true ? .blue : .gray)
                                Text(day.prefix(2))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding()

                // Group Buttons
                HStack {
                    Button(action: toggleWeekdays) {
                        GroupButtonView(label: "Weekdays")
                    }
                    Button(action: toggleWeekends) {
                        GroupButtonView(label: "Weekends")
                    }
                    Button(action: toggleAllDays) {
                        GroupButtonView(label: "All Days")
                    }
                }
            }

            Spacer()

            // Save Button
            Button("Save") {
                let newTask = DailyTask(
                    
                    name: selectedTaskOption?.name ?? "Unnamed Task",
                    type: .appSpecific, // Change this if needed for different task types
                    appName: selectedApp?.name ?? "Unknown App",
                    days: daysSelected.filter { $0.value }.map { $0.key }, // Convert selected days back to an array
                    isCompleted: false,
                    isEnabled: true
                    
                )
                // Check if a task for today is being added
                if newTask.days.contains(getCurrentDayOfWeek()) {
                    // Turn shielding back on for the selected apps if the task is for today
                    shieldingManager.shieldApps(shieldingManager.shieldedApps)
                }
                onSave(newTask) // Pass the updated task back to TaskView2
                
                $isPresented.wrappedValue = false // Dismiss the settings view
            }
        }
        .padding()
    }

    private func saveTask() {
        guard let taskToEdit = taskToEdit else { return }
        
        // Create a new task or update the existing one
        let updatedTask = DailyTask(
            name: selectedTaskOption?.name ?? "",
            type: taskToEdit.type,
            appName: selectedApp?.name ?? "",
            days: Array(daysSelected.keys.filter { daysSelected[$0] == true }),
            isCompleted: taskToEdit.isCompleted,
            isEnabled: taskToEdit.isEnabled
        )

        // Update the task in taskListModel
        if let existingTaskIndex = taskListModel.dailyTasks.firstIndex(where: { $0.id == taskToEdit.id }) {
            taskListModel.dailyTasks[existingTaskIndex] = updatedTask // Update existing task
        } else {
            taskListModel.dailyTasks.append(updatedTask) // Add the new task
        }
        
        taskListModel.saveTasks()
        isPresented = false
    }

    private func toggleWeekdays() {
        for day in ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"] {
            daysSelected[day] = true
        }
        for day in ["Saturday", "Sunday"] {
            daysSelected[day] = false
        }
    }

    private func toggleWeekends() {
        for day in ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"] {
            daysSelected[day] = false
        }
        for day in ["Saturday", "Sunday"] {
            daysSelected[day] = true
        }
    }

    private func toggleAllDays() {
        for day in daysSelected.keys {
            daysSelected[day] = true
        }
    }
    
    private func getCurrentDayOfWeek() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: Date())
        }
}



struct selfReportedTasksSettingsView_Previews: PreviewProvider {
    @State static var isPresented = true

    static var previews: some View {
        DailyTasksSettingsView(
            earnApp: ApplicationData.appList,
            isPresented: $isPresented, taskToEdit: DailyTask(
                name: "Steps Goal",
                type: .appSpecific,
                appName: "Fitbit",
                days: ["Monday", "Wednesday", "Friday"],
                isCompleted: false,
                isEnabled: true
            ), // ✅ Editing an existing task,
            onSave: { newTask in
                print("Saved Task: \(newTask.name)")
            }, taskListModel: TaskListModel()
        )
    }
}
