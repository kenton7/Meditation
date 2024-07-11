//
//  SelectGenreViewModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 10.07.2024.
//

import Foundation
import SwiftUI

class SelectGenreViewModel: ObservableObject {
    
    private var nightStoriesVM = NightStoriesViewModel()
    @Published var filteredResults = [CourseAndPlaylistOfDayModel]()
    
    @Published var genres = [
        StoryGenresModel(genre: "Всё", isSelected: true, image: "headphones"),
        StoryGenresModel(genre: "Любимое", isSelected: false, image: "heart"),
        StoryGenresModel(genre: "Волнуюсь", isSelected: false, image: "brain.head.profile"),
        StoryGenresModel(genre: "Уснуть", isSelected: false, image: "powersleep"),
        StoryGenresModel(genre: "Музыка", isSelected: false, image: "music.quarternote.3"),
        StoryGenresModel(genre: "Детям", isSelected: false, image: "teddybear")
    ]
    
    var selectedGenre: String {
            return genres.first { $0.isSelected }?.genre ?? "Всё"
        }
    
    func selectGenre(at index: Int) {
        for i in genres.indices {
            genres[i].isSelected = (i == index)
        }
    }    
}
