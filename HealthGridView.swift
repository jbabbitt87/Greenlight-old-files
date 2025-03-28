//
//  HealthGridView.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 3/3/25.
//


import SwiftUI

struct HealthGridView: View {

        @ObservedObject var taskListModel: TaskListModel
        @State private var selectedTask: DailyTask? = nil
        @State private var isPresented = false
        let onTaskDelete: (DailyTask) -> Void
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

        var healthTasks: [DailyTask] {
            taskListModel.dailyTasks.filter { $0.type == .health }
        }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Health Tasks")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        // Display Existing Exercise Tasks
                        ForEach(healthTasks) { task in
                            Button(action: {
                                selectedTask = task // Set task to edit
                                isPresented = true  // Open modal
                            }) {
                                TaskGridItemView(task: task, onDelete: { onTaskDelete(task) })
                            }
                        }

                        // New Add Task Button Style
                        VStack {
                            ZStack {
                                Button(action: {
                                    selectedTask = nil  // Creating a new task
                                    isPresented = true
                                }) {
                                    Rectangle()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(15)
                                        .opacity(0.75)
                                        .foregroundStyle(Color.gray)
                                        .overlay(
                                            Image(systemName: "plus")
                                                .foregroundColor(.white)
                                                .opacity(0.8)
                                                .font(.system(size: 32))
                                        )
                                }
                                .buttonStyle(PlainButtonStyle()) // Remove default button styling
                            }
                            Text("Add Task")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.white)
                        }
                    }
                    .padding()
                }
            }.background(LinearGradient(
                gradient: Gradient(colors: [Color.mint.opacity(1.0), Color.mint.opacity(0.25)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            )
            
        }
            // Present DailyTasksSettingsView2 as a modal sheet
            .sheet(isPresented: $isPresented) {
                HealthTasksSettingsView(
                    earnApp: ApplicationData.appList, // Default to .exercise if nil
                    isPresented: $isPresented,
                    taskToEdit: selectedTask,
                    onSave: { updatedTask in
                        if let _ = selectedTask {
                            taskListModel.updateTask(updatedTask) // Update existing task
                        } else {
                            taskListModel.addTask(updatedTask) // Add new task
                        }
                        isPresented = false // Close modal after saving
                    },
                    taskListModel: taskListModel
                )
            }
        }
    }

    #Preview {
        HealthGridView(taskListModel: TaskListModel.shared, onTaskDelete: { task in TaskListModel.shared.deleteTask(task) })
    }
