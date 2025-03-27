//
//  TaskIconView.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 1/30/25.
//
import Foundation
import SwiftUI

struct TaskIconView: View {
    let task: DailyTask
    let onTap: () -> Void
    let onDelete: () -> Void
    let onMarkAsCompleted: () -> Void

    var body: some View {
        VStack {
            Image(task.appIcon)
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .contextMenu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete Task", systemImage: "trash")
                    }
                    if task.type == .selfReported {
                                            Button(action: onMarkAsCompleted) {
                                                Label("Mark as Completed", systemImage: "checkmark.circle.fill")
                                            }
                                        }
                }
                .onTapGesture {
                    onTap()
                    
                }
                Text(task.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        
    }
}
