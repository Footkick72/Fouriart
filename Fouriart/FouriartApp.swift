//
//  FouriartApp.swift
//  Fouriart
//
//  Created by Daniel Long on 9/12/21.
//

import SwiftUI

@main
struct FouriartApp: App {
    init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: .main) { _ in
            curveData.load()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            curveData.save()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
