//
//  PlayerViewModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 29.06.2024.
//

import Foundation
import AVFoundation
import Combine

class PlayerViewModel: ObservableObject {
    
    static let shared = PlayerViewModel()
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var currentUrl: String?
    var timeObserver: Any?
    var endObserver: Any?
    @Published var isPlaying: Bool = false
    @Published var currentPlayingURL: String? = nil
    private var audioSession = AVAudioSession.sharedInstance()
    @Published var currentTime: CMTime = .zero
    @Published var duration: CMTime = .zero
    private var cancellables = Set<AnyCancellable>()
    private var observers: [NSKeyValueObservation] = []
    private var playlist: [Lesson] = []
    @Published var currentTrackIndex: Int = 0
    @Published var audioName = ""
    var isAudioPlaying: Bool {
        player?.rate != 0
    }
    
    private init() {
        setupNotifications()
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    deinit {
        removeTimeObserver()
        removeEndObserver()
    }
    
    func playAudio(from urlString: String, playlist: [Lesson]) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        self.playlist = playlist
        
        if currentPlayingURL != urlString {
            removeTimeObserver() // Удалить предыдущий timeObserver
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            currentPlayingURL = urlString
            currentTime = .zero
            
            setupTimeObserver()
            observePlayerItemStatus()
        }
        
        player?.play()
        isPlaying = true
    }
    
    func isPlaying(urlString: String) -> Bool {
        return player?.rate != 0 && player?.error == nil && currentPlayingURL == urlString
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
    }
    
    @objc private func playerDidFinishPlaying(notification: NSNotification) {
        isPlaying = false
        currentTime = .zero
        currentPlayingURL = nil
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch interruptionType {
        case .began:
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                play()
            }
        @unknown default:
            break
        }
    }
    
    private func setupTimeObserver() {
        guard let player = player else { return }
        timeObserver = player.addPeriodicTimeObserver(forInterval: .init(seconds: 1, preferredTimescale: 600),
                                                      queue: .main,
                                                      using: { [weak self] time in
            self?.currentTime = time
            if let duration = self?.playerItem?.duration {
                self?.duration = duration
            }
        })
    }
    
    private func removeTimeObserver() {
        if let observer = timeObserver, let player = player {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    private func removeEndObserver() {
        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
            endObserver = nil
        }
    }
    
    func formatTime(time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        guard totalSeconds.isFinite && !totalSeconds.isNaN else  {
            return "00:00"
        }
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func observePlayerItemStatus() {
        guard let playerItem = playerItem else { return }
        
        let statusObserver = playerItem.observe(\.status, options: [.new, .initial]) { [weak self] playerItem, _ in
            if playerItem.status == .readyToPlay {
                DispatchQueue.main.async {
                    self?.duration = playerItem.duration
                }
            }
        }
        observers.append(statusObserver)
    }
    
    func seek(by seconds: Double) {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + seconds
        let seekTime = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: seekTime)
        self.currentTime = seekTime
    }
}
