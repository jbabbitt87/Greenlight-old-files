//
//  ExerciseTasksSettingsView 2.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 3/4/25.
//


import SwiftUI
import Foundation

struct HealthTasksSettingsView: View {
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
    @State private var goalValue: String = "" // New state variable for goal value

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
    var filteredApps: [TaskApplication] {
        ApplicationData.appList.filter { app in
            app.availableTasks.contains { $0.type == .health }
        }
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
                Text("Select Application")
                    .font(.headline)
                AppIconSelectionView(apps: filteredApps, selectedApplication: $selectedApplication)
                        .onChange(of: selectedApplication) { newValue in
                            if newValue == "Fitbit" {
                                checkFitbitAuthorization()
                            } else if newValue == "Whoop" {
                                checkWhoopAuthorization()
                            } else if newValue == "Apple Fit" {
                                checkHealthKitAuthorization()
                            }

                            if let app = earnApp.first(where: { $0.name == newValue }) {
                                selectedApp = app
                                selectedTaskOption = app.availableTasks.first
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
                Text("Select a Daily Task")
                    .font(.headline)
                if let app = selectedApp {
                    Picker("Select Task", selection: $selectedTaskOption) {
                        ForEach(app.availableTasks.filter { $0.type == .health }, id: \.name) { task in
                            Text(task.name).tag(task as TaskOption?)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding(.vertical)
                }
            }
            // Goal Value Input (Only for Whoop and Apple Fit for now, should add fitbit for continuity between choices
            if selectedApplication == "Whoop" || selectedApplication == "Apple Fit" {
                VStack(alignment: .leading) {
                    Text("Enter Goal Value")
                        .font(.headline)

                    TextField("Goal Value", text: $goalValue)
                        .keyboardType(.numberPad) // Only allow numeric input
                        .padding()
                        .border(Color.gray)
                        .cornerRadius(8)
                        .padding(.bottom)
                }
                .padding(.vertical)
                .onTapGesture {
                    // This dismisses the keyboard when tapping outside the TextField
                    UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
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
                let goal = Double(goalValue) ?? 0 // Use default value of 0 if input is invalid
                let newTask = DailyTask(
                    
                    name: selectedTaskOption?.name ?? "Unnamed Task",
                    type: .health, // Change this if needed for different task types
                    appName: selectedApp?.name ?? "Unknown App",
                    days: daysSelected.filter { $0.value }.map { $0.key }, // Convert selected days back to an array
                    isCompleted: false,
                    isEnabled: true,
                    goalValue: goal // Include goal value here
                    
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
            isEnabled: taskToEdit.isEnabled,
            goalValue: taskToEdit.goalValue
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
    

    // Check if Fitbit is authorized, if not start authorization process
    private func checkFitbitAuthorization() {
        let fitbitToken = KeychainManager.shared.loadFitbitAccessToken()
        print("Fitbit access token: \(fitbitToken ?? "None")") // Debug print
        
        if fitbitToken == nil {
            FitbitAuthManager.shared.startAuthorization()
        }
    }
    private func checkWhoopAuthorization() {
        let whoopToken = KeychainManager.shared.loadWhoopAccessToken()
        print("Whoop access token (CheckAuthorization): \(whoopToken ?? "None")")

        if whoopToken == nil {
            WhoopAuthorizationManager.shared.refreshWhoopAccessToken()
        }
    }
    private func checkHealthKitAuthorization() {
        let isHealthKitAuthorized = KeychainManager.shared.loadHealthKitAuthorization()

        if isHealthKitAuthorized {
            print("HealthKit is authorized")
            // Continue with HealthKit data retrieval, etc.
        } else {
            print("HealthKit is not authorized")
            // Request authorization if not already granted
            HealthKitManager.shared.requestAuthorization { success, error in
                if success {
                    print("HealthKit authorization granted")
                } else {
                    print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    private func getCurrentDayOfWeek() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: Date())
        }
}



struct HealthTasksSettingsView_Previews: PreviewProvider {
    @State static var isPresented = true

    static var previews: some View {
        HealthTasksSettingsView(
            earnApp: ApplicationData.appList,
            isPresented: $isPresented, taskToEdit: DailyTask(
                name: "Steps Goal",
                type: .health,
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
