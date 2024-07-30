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
        NavigationStack {
            ScrollView(showsIndicators: false) {
                MusicHeaderView()
                AllMusicPlaylists()
           }
        }
        .padding(.bottom)
    }
}

struct MusicHeaderView: View {
    var body: some View {
        VStack {
            Text("Музыка")
                .padding()
                .foregroundStyle(.black)
                .font(.system(.title, design: .rounded, weight: .bold))
            
            Text("Насладитесь успокаивающей музыкой, которая поможет вам снять стресс и найти внутреннее спокойствие.")
                .padding()
                .foregroundStyle(Color(uiColor: .init(red: 160/255,
                                                      green: 163/255,
                                                      blue: 177/255,
                                                      alpha: 1)))
                .font(.system(.headline, design: .rounded, weight: .light))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.vertical)
    }
}

struct AllMusicPlaylists: View {
    
    @StateObject private var musicViewModel = MusicFilesViewModel()
    @State private var isSelected = false
    @State var selectedPlaylist: CourseAndPlaylistOfDayModel?
    
    var body: some View {
        NavigationStack {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20, content: {
                        ForEach(musicViewModel.files, id: \.name) { file in
                            Button(action: {
                                isSelected = true
                                selectedPlaylist = file
                            }, label: {
                                LazyVStack {
                                    AsyncImage(url: URL(string: file.imageURL), scale: 2.0) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .clipShape(.rect(cornerRadius: 16))
                                            .padding(.horizontal)
                                            .frame(width: 200, height: 150)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    
                                    Text(file.name)
                                        .foregroundStyle(.black)
                                        .font(.system(size: 17, design: .rounded)).bold()
                                    
                                    Text("\(file.duration) мин.")
                                        .padding(.horizontal, 10)
                                        .foregroundStyle(Color(uiColor: .init(red: 152/255,
                                                                              green: 161/255,
                                                                              blue: 189/255,
                                                                              alpha: 1)))
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            })
                        }
                })
                }
        }
        .navigationDestination(isPresented: $isSelected) {
            if let selectedPlaylist {
                ReadyCourseDetailView(course: selectedPlaylist)
            }
        }
    }
}


#Preview("AllMusic") {
    AllMusicPlaylists()
}
