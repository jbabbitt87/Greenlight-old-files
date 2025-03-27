//
//  HomePlusView.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 1/21/25.
//
import SwiftData
import SwiftUI


struct HomeView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
  //  @AppStorage("hasRequestedScreenTime") private var hasRequestedScreenTime: Bool = true
    @ObservedObject var taskListModel: TaskListModel // Observes user-updated task model
    @State private var showUsageOverlay = false
    @State private var showTaskOverlay = false
    @State private var showStreakOverlay = false
    @State private var showScreenTimeOverlay = false
    @State private var showProgressOverlay = false
    
    var body: some View {
        if isFirstLaunch {
            WelcomeView()
    //    } else if !hasRequestedScreenTime {
      //      RequestScreenTimeView(isPresented: $showScreenTimeOverlay)
        } else {
            TabView {
                // Home Tab
                NavigationStack {
                    VStack {
                        // Daily Streak ZStack
                        StreakButtonView(taskListModel: taskListModel)
                            .onTapGesture {
                                showStreakOverlay = true // Show the streak overlay when tapped
                            }
                        // Daily Tasks Progress ZStack
                        DailyTaskButtonView(taskListModel: taskListModel)
                            .onTapGesture {
                                showTaskOverlay = true // Show the task overlay when tapped
                            }
                        AppProgressButtonView()
                            .onTapGesture {
                                showProgressOverlay = true
                            }
                        AppUsageButtonView()
                            .onTapGesture {
                                showUsageOverlay = true
                            }
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.mint.opacity(1.0), Color.mint.opacity(0.75)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    .onAppear {
                        TaskListModel.shared.loadTasks()
                        TaskListModel.shared.checkAllTasksCompletion()
                        taskListModel.checkNewDay() // think i fixed this/ was resetting the completed tasks
                        // ✅ Check task completion when view appears
                    }
                    .alert(isPresented: $taskListModel.showStreakAlert) {
                        Alert(
                            title: Text("Streak Warning"),
                            message: Text(taskListModel.streakAlertMessage),
                            primaryButton: .default(Text("Use Streak Save")) {
                                taskListModel.useStreakSave()
                            },
                            secondaryButton: .destructive(Text("Don't Use Save")) {
                                taskListModel.resetStreak()
                            }
                        )
                    }
                  //  .onReceive(NotificationCenter.default.publisher(for: .appUsageUpdated)) { _ in
                        // ✅ Update tasks when app usage updates
                    }// these are maybe redundant given the appusagebuttonview etc, can possibly place this login within those views.
                    .sheet(isPresented: $showUsageOverlay) {
                        ExtensionReportView(isPresented: $showUsageOverlay) //was familypickerview
                    }
                    .sheet(isPresented: $showProgressOverlay) {
                        TaskProgressView(isPresented: $showProgressOverlay)
                    }
                    .sheet(isPresented: $showTaskOverlay) {
                        DailyTaskView(isPresentedAsSheet: true, isPresented: $showTaskOverlay, taskListModel: taskListModel)
                    }
                    .sheet(isPresented: $showStreakOverlay) {
                        StreakView(taskListModel: taskListModel, isPresented: $showStreakOverlay)
                    }
                }
                
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                // Daily Tasks Tab
               // TaskView2(taskListModel: taskListModel, earnApp: ApplicationData.appList)
                    .tabItem {
                        Label("Daily Tasks", systemImage: "checklist")
                    }
                // was blocked Apps Tab/ now slections for both discouraged and encouraged apps tab.
            TaskOverview(taskListModel: TaskListModel.shared) //was appshieldingview2
                    .tabItem {
                        Label("Tracking", systemImage: "lock.shield")
                    }}}}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let taskListModel = TaskListModel()
        taskListModel.loadTasks()
        return HomeView(
            
            taskListModel: taskListModel)
    }
}

