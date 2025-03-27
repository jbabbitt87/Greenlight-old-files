//
//  TaskSectionView.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 1/31/25.
//
import SwiftUI

struct TaskSectionView: View {
    var title: String
    var tasks: [DailyTask]
    let onTaskTap: (DailyTask) -> Void
    let onTaskDelete: (DailyTask) -> Void
    let onAddTaskTapped: (String) -> Void // Closure to handle add task navigation
    let onMarkAsCompleted: (DailyTask) -> Void // Closure to handle marking tasks as completed

    let rows = [GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    LazyHGrid(rows: rows, spacing: 20) {
                        ForEach(tasks, id: \.id) { task in
                            TaskIconView(
                                task: task,
                                onTap: { onTaskTap(task) },
                                onDelete: { onTaskDelete(task) },
                                onMarkAsCompleted: {
                                    if task.type == .selfReported {
                                        onMarkAsCompleted(task)
                                    }
                                }
                            )
                        }
                        VStack {
                            ZStack {
                                Button(action: {
                                    // Trigger the add task navigation
                                    onAddTaskTapped(title) // Pass section title (App-Specific, etc.)
                                }) {
                                    Rectangle()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        .opacity(0.75)
                                        .foregroundStyle(Color.gray)
                                        .overlay(
                                            Image(systemName: "plus")
                                                .foregroundColor(.white)
                                                .opacity(0.8)
                                                .font(.system(size: 32))
                                        )
                                }
                                .buttonStyle(PlainButtonStyle()) // To remove default button styling
                            }
                                Text("Add Task")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.white)
                            
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(height: 150)
        }
    }
}
