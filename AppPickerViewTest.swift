//
//  PickerViewTest.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 2/18/25.
//
/*
import SwiftUI
import FamilyControls
import ManagedSettings

struct AppPickerView: View {
    @StateObject var usageManager = UsageManager()

    @State private var discouragedSelection = FamilyActivitySelection()
    @State private var encouragedSelection = FamilyActivitySelection()
    @State private var isDiscouragedPickerPresented = false
    @State private var isEncouragedPickerPresented = false

    @State private var resolvedApps: [ApplicationToken: Application] = [:]

    var body: some View {
        VStack {
            // Discouraged Apps Picker
            Button("Select Discouraged Apps") {
                discouragedSelection.applicationTokens = usageManager.discouragedApps
                isDiscouragedPickerPresented = true
            }
            .familyActivityPicker(isPresented: $isDiscouragedPickerPresented, selection: $discouragedSelection)
            .onChange(of: discouragedSelection) { newSelection in
                usageManager.discouragedApps = newSelection.applicationTokens
                usageManager.saveSelectedApps(selection: discouragedSelection)
            }

            // Encouraged Apps Picker
            Button("Select Encouraged Apps") {
                encouragedSelection.applicationTokens = usageManager.encouragedApps
                isEncouragedPickerPresented = true
            }
            .familyActivityPicker(isPresented: $isEncouragedPickerPresented, selection: $encouragedSelection)
            .onChange(of: encouragedSelection) { newSelection in
                Task {
                    usageManager.encouragedApps = newSelection.applicationTokens
                    for token in newSelection.applicationTokens {
                        if resolvedApps[token] == nil {
                            if let app = await token.resolveApp() {
                                DispatchQueue.main.async {
                                    resolvedApps[token] = app  // 🔹 Store resolved app info
                                }
                            }
                        }
                    }
                }
            }


            // Time Selection Per Encouraged App
            List(Array(usageManager.encouragedApps), id: \.self) { token in
                if let app = resolvedApps[token] {
                    HStack {
                        Text(app.bundleIdentifier ?? "Unknown App")
                        Spacer()
                        Picker("Minutes", selection: Binding(
                            get: { usageManager.appTimeThresholds[token, default: 10] },
                            set: { usageManager.appTimeThresholds[token] = $0 }
                        )) {
                            ForEach(5..<61, id: \.self) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                    }
                }
            }
        }
    }
}
*/
