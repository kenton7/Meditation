//
//  PlayerViewModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 29.06.2024.
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer

final class PlayerViewModel: ObservableObject {
    
    static let shared = PlayerViewModel()
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var timeObserver: Any?
    var endObserver: Any?
    var timer: Timer?
    
    @Published var isPlaying: Bool = false
    @Published var currentPlayingURL: String? = nil
    @Published var currentTime: CMTime = .zero
    @Published var duration: CMTime = .zero
    @Published var currentTrackIndex: Int = 0
    @Published var lessonName: String = ""
    @Published private var playlist: [Lesson] = []
    @Published private var course: CourseAndPlaylistOfDayModel?
    @Published private var isFemale = true
    private let contentItem = MPContentItem()
    
    private var audioSession = AVAudioSession.sharedInstance()
    private var observers: [NSKeyValueObservation] = []
    
    
    private init() {
        setupNotifications()
        configureAudioSession()
        createRemoteControlActions()
    }
    
    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, 
                                         options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    deinit {
        removeTimeObserver()
        removeEndObserver()
    }
    
    func createRemoteControlActions() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        //Play on Lock Screen
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player?.rate == 0.0 {
                self.player?.play()
                return .success
            }
            return .commandFailed
        }
        
        //Pause on Lock Screen
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player?.rate != 0.0 {
                self.player?.pause()
                return .success
            }
            return .commandFailed
        }
        
        //Next Track
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            currentTrackIndex += 1
            if currentTrackIndex < self.playlist.count {
                let nextAudioURL = isFemale ? playlist[currentTrackIndex].audioFemaleURL : playlist[currentTrackIndex].audioMaleURL
                self.playAudio(from: nextAudioURL, playlist: playlist, trackIndex: currentTrackIndex, type: .playlist, isFemale: isFemale, course: course!)
                currentPlayingURL = nextAudioURL
                return .success
            } else {
                currentTrackIndex = 0
                let nextAudioURL = isFemale ? playlist[currentTrackIndex].audioFemaleURL : playlist[currentTrackIndex].audioMaleURL
                self.playAudio(from: nextAudioURL, playlist: playlist, trackIndex: currentTrackIndex, type: .playlist, isFemale: isFemale, course: course!)
                currentPlayingURL = nextAudioURL
                return .success
            }
        }
        
        //Previous Track
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            currentTrackIndex -= 1
            if currentTrackIndex < 0 {
                currentTrackIndex = self.playlist.last!.trackIndex!
            }
            
            if currentTrackIndex < self.playlist.count {
                let nextAudioURL = isFemale ? playlist[currentTrackIndex].audioFemaleURL : playlist[currentTrackIndex].audioMaleURL
                self.playAudio(from: nextAudioURL, playlist: playlist, trackIndex: currentTrackIndex, type: .playlist, isFemale: isFemale, course: course!)
                currentPlayingURL = nextAudioURL
                return .success
            } else {
                currentTrackIndex = 0
                let nextAudioURL = isFemale ? playlist[currentTrackIndex].audioFemaleURL : playlist[currentTrackIndex].audioMaleURL
                self.playAudio(from: nextAudioURL, playlist: playlist, trackIndex: currentTrackIndex, type: .playlist, isFemale: isFemale, course: course!)
                currentPlayingURL = nextAudioURL
                return .success
            }
        }
    }
    
    func setupNowPlaying() async {
        guard let player = player, let playerItem = player.currentItem else { return }

        var nowPlayingInfo = [String: Any]()
        if !playlist.isEmpty {
            nowPlayingInfo[MPMediaItemPropertyTitle] = playlist[currentTrackIndex].name
        }
        
        do {
            let duration = try await playerItem.asset.load(.duration)
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(duration) as NSNumber
        } catch {
            print(error.localizedDescription)
        }
        
        if let artworkURL = URL(string: course!.imageURL) {
            if let data = try? Data(contentsOf: artworkURL), let image = UIImage(data: data) {
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
                }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
        }
        
        let currentTime = CMTimeGetSeconds(player.currentTime())
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime as NSNumber
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate as NSNumber

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateNowPlaying()
        }
    }
    
    func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
    
    @objc func updateNowPlaying() {
           guard let player = player else { return }

           var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
           nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime()) as NSNumber
           nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate as NSNumber

           MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
       }
    
    func autoPlayingNextTrack(playlist: [Lesson], trackIndex: Int) {
            currentTrackIndex += 1
            if currentTrackIndex < playlist.count {
                let nextAudioURL = isFemale ? playlist[currentTrackIndex].audioFemaleURL : playlist[currentTrackIndex].audioMaleURL
                playAudio(from: nextAudioURL, playlist: playlist, trackIndex: currentTrackIndex, type: .playlist, isFemale: isFemale, course: course!)
            } else {
                currentTrackIndex = 0
                currentPlayingURL = nil
            }
    }
    
    func playLocalAudioFrom(url: URL, lessonName: String) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Файла не существует по данному пути: \(url.path)")
            return
        }
        
        let urlString = url.absoluteString
        let decodedURLString = urlString.decodeURL() ?? ""

        if currentPlayingURL != decodedURLString {
            removeTimeObserver()
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            currentPlayingURL = decodedURLString
            currentTime = .zero
            setupTimeObserver()
            observePlayerItemStatus()
        }
        player?.play()
        isPlaying = true
        self.lessonName = lessonName
        contentItem.title = self.lessonName
    }
    
    func playAudio(from urlString: String, playlist: [Lesson], trackIndex: Int?, type: Types, isFemale: Bool, course: CourseAndPlaylistOfDayModel) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        self.isFemale = isFemale
        self.playlist = playlist
        self.course = course
        
        if let trackIndex {
            self.currentTrackIndex = trackIndex
            if !playlist.isEmpty {
                lessonName = playlist[currentTrackIndex].name
            }
        }
        
        if currentPlayingURL != urlString {
            removeTimeObserver()
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            currentPlayingURL = urlString
            currentTime = .zero
            setupTimeObserver()
            observePlayerItemStatus()
        }
        
        player?.play()
        isPlaying = true
        contentItem.title = self.playlist[currentTrackIndex].name
        Task.detached {
            await self.setupNowPlaying()
        }
        startTimer()
    }
    
    func isAudioPlaying() -> Bool {
        return player?.rate != 0
    }
    
    func isPlayingLocal(url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Файла не существует по данному пути: \(url.path)")
            return false
        }
        
        let urlString = url.absoluteString
        let decodedURLString = urlString.decodeURL() ?? ""
        return player?.rate != 0 && player?.error == nil && currentPlayingURL == decodedURLString
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
        autoPlayingNextTrack(playlist: self.playlist, trackIndex: currentTrackIndex)
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
