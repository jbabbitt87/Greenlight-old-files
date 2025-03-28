//
//  TaskOverview.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 3/3/25.
//


import SwiftUI

struct TaskOverview: View {
    @ObservedObject var taskListModel: TaskListModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.mint.opacity(1.0), Color.mint.opacity(0.25)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    
                    // switch these to: Application Tasks, Self-Reported Tasks, Location Tasks(can i make this a function of daily?), usasge tasks(encouragedAppSeleciton)
                    NavigationLink(destination: ExerciseGridView(taskListModel: TaskListModel.shared, onTaskDelete: { task in TaskListModel.shared.deleteTask(task) })) {
                        TaskOverviewButtonView(title: "Exercise Tasks", systemImage: "figure.run.circle")
                    }
                    
                    NavigationLink(destination: WorkoutGridView(taskListModel: TaskListModel.shared, onTaskDelete: { task in TaskListModel.shared.deleteTask(task) })) {
                        TaskOverviewButtonView(title: "Workout Tasks", systemImage: "figure.jumprope.circle")
                    }
                    
                    NavigationLink(destination: HealthGridView(taskListModel: TaskListModel.shared, onTaskDelete: { task in TaskListModel.shared.deleteTask(task) })) {
                        TaskOverviewButtonView(title: "Health Tasks", systemImage: "cross.case.circle")
                    }
                    
                    NavigationLink(destination: LearnGridView(taskListModel: TaskListModel.shared, onTaskDelete: { task in TaskListModel.shared.deleteTask(task) })) {
                        TaskOverviewButtonView(title: "Learning Tasks", systemImage: "book.circle")
                    }
                    
                    NavigationLink(destination: ChoresGridView(taskListModel: TaskListModel.shared, onTaskDelete: { task in TaskListModel.shared.deleteTask(task) })) {
                        TaskOverviewButtonView(title: "Self-Reported Tasks", systemImage: "person.crop.circle.badge.checkmark")
                    }
                  /*  NavigationLink(destination: UsageGridView(taskListModel: TaskListModel.shared, onTaskDelete: { task in TaskListModel.shared.deleteTask(task) })) {
                        TaskOverviewButtonView(title: "Usage Tasks", systemImage: "timeline.selection")
                    } */
                }
                .padding()
            }
        }
    }
}

struct TaskOverviewButtonView: View {
    var title: String
    var systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .padding()
            
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding()
            
            Spacer()
        }
        .frame(width: 300, height: 80)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
