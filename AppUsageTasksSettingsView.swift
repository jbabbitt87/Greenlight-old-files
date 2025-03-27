//
//  AppUsageTasksSettingsView.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 1/31/25.
//
import SwiftUI
import Foundation

struct AppUsageTasksSettingsView: View {
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
    @State private var navigateToAppSelection = false
    @State private var isTaskEnabled: Bool = false
    @State private var isCompleted: Bool = false
    @State private var selectedApplication: String = ""
    @State private var selectedApp: TaskApplication? // Track selected App
    @State private var selectedAppUsageTime: Int = 15  // Default to 15 minutes
    
    let usageTimeOptions = [15, 30, 45, 60]  // Available time options
    
    // Computed properties
    var applicationList: [String] {
        earnApp.map { $0.name }
    }
    
    // Updated init
    init(
        earnApp: [TaskApplication],
        isPresented: Binding<Bool>,
        taskToEdit: DailyTask?, //  No longer a Binding
        onSave: @escaping (DailyTask) -> Void,
        taskListModel: TaskListModel
    ) {
        self.earnApp = earnApp
        self._isPresented = isPresented
        self.taskToEdit = taskToEdit //  Regular variable, not a Binding
        self.onSave = onSave
        self.taskListModel = taskListModel
        
        // Extract values safely before initializing @State properties
        let app = earnApp.first(where: { $0.name == taskToEdit?.appName })
        let initialDaysSelected = Dictionary(
            uniqueKeysWithValues: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                .map { ($0, taskToEdit?.days.contains($0) ?? false) }
        )
        
        _selectedApp = State(initialValue: app)
        _selectedAppUsageTime = State(initialValue: taskToEdit?.appUsageTime ?? 15)
        _daysSelected = State(initialValue: initialDaysSelected)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Title with close button
                HStack {
                    Text(taskToEdit == nil ? "New Daily Task" : "Edit Daily Task")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                   /* NavigationLink(destination: AppTrackingView()) {
                            Text("Track")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
                        }*/
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.title)
                    }
                }
                .padding()
                
                // Application Picker
                VStack(alignment: .leading) {
                    Text("Select an Application")
                        .font(.headline)
                    Picker("Select Application", selection: $selectedApp) {
                        ForEach(ApplicationData.appList.filter { app in
                            app.availableTasks.contains { $0.type == .appUsage }
                        }, id: \.name) { app in
                            Text(app.name).tag(app as TaskApplication?)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding(.vertical)
                }
                
                // App Usage Time Picker
                VStack(alignment: .leading) {
                    Text("Select App Usage Time")
                        .font(.headline)
                    Picker("Select Time", selection: $selectedAppUsageTime) {
                        ForEach(usageTimeOptions, id: \.self) { time in
                            Text("\(time) minutes").tag(time)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding(.vertical)
                }
                
                Spacer()
                
                // Day Selection
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
                        name: "Use \(selectedApp?.name ?? "App")",
                        type: .appUsage,
                        appName: selectedApp?.name ?? "Unknown App",
                        days: daysSelected.filter { $0.value }.map { $0.key },
                        isCompleted: false,
                        isEnabled: true,
                        appUsageTime: selectedAppUsageTime  // Save the selected app usage time
                    )
                    if newTask.days.contains(getCurrentDayOfWeek()) {
                        // Turn shielding back on for the selected apps if the task is for today
                        shieldingManager.shieldApps(shieldingManager.shieldedApps)
                    }
                    
                    onSave(newTask) // Pass the updated task back to TaskView2
                    
                    isPresented = false // Dismiss the settings view
                }
            }}
        
        .padding()
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


struct AppUsageTasksSettingsView_Previews: PreviewProvider {
    @State static var isPresented = true

    static var previews: some View {
        AppUsageTasksSettingsView(
            earnApp: ApplicationData.appList,
            isPresented: $isPresented,
            taskToEdit: DailyTask(
                name: "App Usage Task",
                type: .appUsage,
                appName: "Duolingo",
                days: ["Monday", "Wednesday", "Friday"],
                isCompleted: false,
                isEnabled: true
            ),
            onSave: { newTask in
                print("Saved Task: \(newTask.name)")
            }, taskListModel: TaskListModel()
        )
    }
}

