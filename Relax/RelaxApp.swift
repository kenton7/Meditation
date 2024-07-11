//
//  RelaxApp.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import SwiftUI
import FirebaseCore
import CoreData
import AVFoundation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        setupAudioSession()
        return true
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure AVAudioSession in AppDelegate: \(error.localizedDescription)")
        }
    }
}

@main
struct RelaxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthWithEmailViewModel()
    @StateObject private var playerViewModel = PlayerViewModel.shared
    @StateObject private var nightStoriesVM = NightStoriesViewModel()
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(playerViewModel)
                .environmentObject(nightStoriesVM)
                .environment(\.colorScheme, .light)
        }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}

