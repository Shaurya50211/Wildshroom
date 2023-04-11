//
//  WildshroomApp.swift
//  Wildshroom
//
//  Created by Shaurya on 2023-04-10.
//

import SwiftUI

@main
struct WildshroomApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(appDelegate)
        }
    }
}
