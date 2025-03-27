//
//  ExtensionReportView.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 2/25/25.
//
/* The view that connects the total activity report from the device activity extension. I need this to display the user's usage data but only for the specific selected apps (discouragedApplications and encouragedApplications)*/
/*import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

struct ExtensionReportView: View {
    @ObservedObject var usageManager = UsageManager.shared
    @Binding var isPresented: Bool
    @State private var context: DeviceActivityReport.Context = .barGraph
    @State private var filter: DeviceActivityFilter?  // Use optional to avoid initialization errors

    var body: some View {
        VStack {
            Text("App Usage Report")
                .font(.title)
                .bold()

            // 🔍 Debugging: Display the stored apps
            VStack(alignment: .leading) {
                Text("Discouraged Apps:")
                    .font(.headline)
                if usageManager.discouragedApps.isEmpty {
                    Text("No discouraged apps selected")
                        .foregroundColor(.gray)
                } else {
                    ForEach(Array(usageManager.discouragedApps), id: \.self) { token in
                        Text("\(token)")
                    }
                }
                
                Text("Encouraged Apps:")
                    .font(.headline)
                if usageManager.encouragedApps.isEmpty {
                    Text("No encouraged apps selected")
                        .foregroundColor(.gray)
                } else {
                    ForEach(Array(usageManager.encouragedApps), id: \.self) { token in
                        Text("\(token)")
                    }
                }
            }
            .padding()

            // Check if filter is initialized
            if let filter = filter {
                DeviceActivityReport(context, filter: filter)
                    .frame(height: 300)
            } else {
                Text("Filter not initialized")
                    .foregroundColor(.red)
            }
            
            Picker("Report Type", selection: $context) {
                Text("Bar Graph").tag(DeviceActivityReport.Context.barGraph)
                Text("Pie Chart").tag(DeviceActivityReport.Context.pieChart)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
        .onAppear {
            loadSelectedApps()  // Load from UserDefaults first
        }
    }

    func loadSelectedApps() {
        print("📦 Loading Selected Apps...\(self.usageManager.encouragedApps)")

        if let dataEncouraged = UserDefaults.standard.data(forKey: "EncouragedApps") {
            do {
                let tokensEncouraged = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSSet.self, from: dataEncouraged) as? Set<ApplicationToken>
                DispatchQueue.main.async {
                    self.usageManager.encouragedApps = tokensEncouraged ?? []
                    print("📊 Loaded Encouraged Apps: \(self.usageManager.encouragedApps)")
                    self.setupFilter() // Set the filter after the apps are loaded
                }
            } catch {
                print("Error loading encouraged apps: \(error)")
            }
        }

        if let dataDiscouraged = UserDefaults.standard.data(forKey: "DiscouragedApps") {
            do {
                let tokensDiscouraged = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSSet.self, from: dataDiscouraged) as? Set<ApplicationToken>
                DispatchQueue.main.async {
                    self.usageManager.discouragedApps = tokensDiscouraged ?? []
                    print("📉 Loaded Discouraged Apps: \(self.usageManager.discouragedApps)")
                }
            } catch {
                print("Error loading discouraged apps: \(error)")
            }
        }
    }

    // 🔧 Initialize the filter correctly
    private func setupFilter() {
        let selectedApps = usageManager.encouragedApps
        print("📊 Selected Apps for Report: \(selectedApps)")

        // Make sure we have apps to track
        guard !selectedApps.isEmpty else {
            print("⚠️ No apps selected for tracking")
            return
        }

        // Set the filter
        filter = DeviceActivityFilter(
            segment: .daily(
                during: Calendar.current.dateInterval(of: .day, for: .now)!
            ),
            users: .children,
            devices: .init([.iPhone]),
            applications: selectedApps,
            categories: [],
            webDomains: []
        )
        
        print("🔧 Filter Initialized: \(String(describing: filter))")
    }
}*/
import SwiftUI
import DeviceActivity
import ManagedSettings

struct ExtensionReportView: View {
    @State private var context: DeviceActivityReport.Context = .barGraph
    @State private var filter: DeviceActivityFilter?
    @Binding var isPresented: Bool
    private let activityCenter = DeviceActivityCenter()
    private let activityName = DeviceActivityName("AllAppUsage")

    var body: some View {
        VStack {
            Text("App Usage Report")
                .font(.title)
                .bold()

            if let filter = filter {
                DeviceActivityReport(context, filter: filter)
                    .frame(height: 300)
            } else {
                Text("Loading usage data...")
                    .foregroundColor(.gray)
            }

            Picker("Report Type", selection: $context) {
                Text("Bar Graph").tag(DeviceActivityReport.Context.barGraph)
                Text("Pie Chart").tag(DeviceActivityReport.Context.pieChart)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
        .onAppear {
            startMonitoring()
        }
    }

    /// **Starts monitoring device activity for all apps**
    private func startMonitoring() {
        print("🔧 Starting monitoring for all apps...")

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

        do {
            try activityCenter.startMonitoring(activityName, during: schedule, events: events)
            print("✅ Successfully started monitoring.")
        } catch {
            print("❌ Error starting monitoring: \(error)")
        }

        setupFilter()
    }

    /// **Sets up the filter to track all apps**
    private func setupFilter() {
        print("🔧 Initializing Filter for All Apps...")

        let newFilter = DeviceActivityFilter(
            segment: .daily(
                during: Calendar.current.dateInterval(of: .day, for: .now)!
            ),
            users: .all,
            devices: .all
        )

        DispatchQueue.main.async {
            self.filter = newFilter
        }

        print("✅ Filter Initialized")
    }
}


