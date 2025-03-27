//
//  BlockSelectionView.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 1/30/25.
//

import SwiftUI
import FamilyControls
import ManagedSettings


struct ShieldedAppSelectionView2: View {
    @State private var isPickerPresented = false
    @State private var selectedApps = FamilyActivitySelection()
    @ObservedObject private var shieldingManager = AppShieldingManager.shared // Ensures real-time updates
    @State private var isShieldingEnabled: Bool = !TaskListModel.shared.allTasksCompleted
    @State private var lastTaskCompletionState: Bool = TaskListModel.shared.allTasksCompleted

    var body: some View {
        VStack {
            Text("Select Apps to Block")
                .font(.title)
                .padding()

            // Toggle for enabling/disabling shielding
            Toggle("Enable App Shielding", isOn: $isShieldingEnabled)
                .padding()
                .onChange(of: isShieldingEnabled) { newValue in
                    toggleShielding(isEnabled: newValue)
                }

            // Button to open FamilyActivityPicker
            Button(action: { isPickerPresented.toggle() }) {
                Text("Select Apps")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $selectedApps)
            .onChange(of: selectedApps) { _ in
                saveSelectedApps()
            }

            // List of currently shielded apps
            List(Array(shieldingManager.shieldedApps), id: \.self) { token in
                HStack {
                    Image(getAppIcon(for: token))
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text(getAppName(for: token))
                        .font(.headline)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { shieldingManager.shieldedApps.contains(token) },
                        set: { isEnabled in
                            toggleShielding(for: token, isShielded: isEnabled)
                        }
                    ))
                    .labelsHidden()
                }
            }
        }
        .padding()
        .onAppear {
            checkForTaskCompletionChange()
        }
    }
    private func checkForTaskCompletionChange() {
           let currentTaskState = TaskListModel.shared.allTasksCompleted
           if currentTaskState != lastTaskCompletionState {
               lastTaskCompletionState = currentTaskState
               updateShieldingState() // Only update if the state has changed
           }
       }

    // Save selected apps and apply shielding
    private func saveSelectedApps() {
        let selectedTokens = selectedApps.applicationTokens
        shieldingManager.shieldApps(selectedTokens) // Directly update AppShieldingManager
        // Store the selected apps' names and icons to display in the list
        selectedApps.applicationTokens.forEach { token in
            let appName = shieldingManager.getAppName(for: token)
            let appIcon = shieldingManager.getAppIcon(for: token)
            
            // You can store this in an array to display in the list later
            // For simplicity, we'll just print the names and icons for now
            print("Selected App: \(appName) with icon: \(appIcon)")
        }
    }

    // Toggle shielding for all apps
    private func toggleShielding(isEnabled: Bool) // can update this to ForAll
    {
        if isEnabled {
            shieldingManager.shieldApps(shieldingManager.shieldedApps)
        } else {
            shieldingManager.unshieldApps()
        }
    }

    // Toggle shielding for a specific app
    private func toggleShielding(for token: ApplicationToken, isShielded: Bool) // can update this to ForApp
    {
        if isShielded {
            shieldingManager.shieldApps(shieldingManager.shieldedApps.union([token])) // Add app
        } else {
            let updatedApps = shieldingManager.shieldedApps.filter { $0 != token }
            shieldingManager.shieldApps(updatedApps) // Remove app
        }
    }

    // Update shielding state based on daily tasks
    private func updateShieldingState() {
        isShieldingEnabled = !TaskListModel.shared.allTasksCompleted
        toggleShielding(isEnabled: isShieldingEnabled)
    }

    private func getAppName(for token: ApplicationToken) -> String {
        return shieldingManager.getAppName(for: token)
    }

    private func getAppIcon(for token: ApplicationToken) -> String {
        return shieldingManager.getAppIcon(for: token)
    }
}


struct ShieldedAppSelectionView2_Previews: PreviewProvider {
    static var previews: some View {
        ShieldedAppSelectionView2()
    }
}
