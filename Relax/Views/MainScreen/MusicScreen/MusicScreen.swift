//
//  MusicScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 27.06.2024.
//

import SwiftUI
import AVKit

struct MusicScreen: View {
    @StateObject private var viewModel = MusicFilesViewModel()
    @State private var player: AVPlayer?

    var body: some View {
        
        List(viewModel.files) { file in
            
            Button {
                playMusic(from: file.url)
            } label: {
                Text(file.name)
                    .font(.headline)
            }
        }
    }
    
    private func playMusic(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        player = AVPlayer(url: url)
        player?.play()
    }
}

#Preview {
    MusicScreen()
}
