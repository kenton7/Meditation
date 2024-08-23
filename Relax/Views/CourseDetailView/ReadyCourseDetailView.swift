//
//  ReadyCourseDetailView.swift
//  Relax
//
//  Created by Илья Кузнецов on 05.07.2024.
//

import SwiftUI

struct ReadyCourseDetailView: View {
    
    let course: CourseAndPlaylistOfDayModel
    @StateObject private var databaseViewModel = ChangeDataInDatabase.shared
    @EnvironmentObject private var courseViewModel: CoursesViewModel
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            CourseDetailView(course: course, size: size, safeArea: safeArea)
                .environmentObject(databaseViewModel)
                .environmentObject(courseViewModel)
                .environmentObject(playerViewModel)
                .ignoresSafeArea(.all, edges: .top)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

