//
//  DownloadedScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 31.07.2024.
//

import SwiftUI

struct DownloadedScreen: View {
    
    @State private var downloadedFiles: [FileItem] = []
    let fileManagerSerivce: IFileManagerSerivce
    
    var body: some View {
        NavigationStack {
            if downloadedFiles.isEmpty {
                VStack {
                    EmptyAnimation()
//                    Text("Вы пока ничего не скачивали.")
//                        .foregroundStyle(.black)
//                        .font(.system(.title2, design: .rounded, weight: .bold))
                }
            } else {
                List(downloadedFiles) { file in
                    NavigationLink {
                        FolderContentsView(folderURL: file.url, fileManagerSerivce: fileManagerSerivce)
                    } label: {
                        Text(file.url.lastPathComponent)
                    }
                    .swipeActions {
                        Button {
                            if fileManagerSerivce.deleteFile(at: file.url) {
                                downloadedFiles.removeAll { $0.id == file.id }
                            }
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
        }
        .onAppear {
            downloadedFiles = fileManagerSerivce.getDownloadFiles()
        }
    }
}

struct FolderContentsView: View {
    let folderURL: URL
    @State private var lessonURL: String = ""
    let fileManagerSerivce: IFileManagerSerivce
    @State private var contents: [FileItem] = []
    @State private var isSelected = false
    @EnvironmentObject private var playerViewModel: PlayerViewModel

    var body: some View {
        List(contents) { item in
            Button(action: {
                isSelected = true
                self.lessonURL = item.url.absoluteString
                playerViewModel.playLocalAudioFrom(url: item.url, lessonName: item.url.deletingPathExtension().lastPathComponent)
            }, label: {
                HStack {
                    ZStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.indigo)
                        Image(systemName: playerViewModel.isPlayingLocal(url: item.url) ? "pause.fill" : "play.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 15, design: .rounded)).bold()
                    }
                    Text(item.url.deletingPathExtension().lastPathComponent)
                        .foregroundStyle(.black)
                        .font(.system(size: 17, design: .rounded)).bold()
                }
            })
            .padding(.vertical)
            .swipeActions {
                Button {
                    if fileManagerSerivce.deleteFile(at: item.url) {
                        contents.removeAll { $0.id == item.id }
                    }
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
                .tint(.red)
            }
        }
        .navigationTitle(folderURL.lastPathComponent)
        .onAppear {
            contents = fileManagerSerivce.getContentsOfFolder(at: folderURL)
        }
        .fullScreenCover(isPresented: $isSelected, content: {
            PlayerScreen(lesson: nil, isFemale: true, course: .init(id: "", name: "", imageURL: "", color: .init(red: 0, green: 0, blue: 0), duration: "", description: "", listenedCount: 0, type: .meditation, isDaily: false, likes: 0), url: lessonURL)
            
        })
    }
}

#Preview {
    let fileManagerService: IFileManagerSerivce = FileManagerSerivce()
    
    return DownloadedScreen(fileManagerSerivce: fileManagerService)
}
