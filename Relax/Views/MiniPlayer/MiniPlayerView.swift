//
//  MiniPlayerView.swift
//  Серотоника
//
//  Created by Илья Кузнецов on 08.09.2024.
//

import SwiftUI

struct MiniPlayerView: View {
    
    var size: CGSize
    //@Binding var config: PlayerConfig2
    //var config: PlayerConfig2
    @EnvironmentObject var config: PlayerConfig2
    
    var body: some View {
        Rectangle()
            .fill(.green)
            .clipped()
            .contentShape(.rect)
            //.offset(y: config.progress * -65)
            .offset(y: config.position)
            .frame(height: size.height - config.position, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .bottom)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        let height = config.lastPosition + value.translation.height
                        //config.position = min(height, (size.height - 50))
                        config.position = max(min(height, size.height - 65), 0)
                        generateProgress()
                    })
                    .onEnded({ value in
                        let velocity = value.velocity.height * 5
                        withAnimation(.smooth(duration: 0.3)) {
                            if (config.position + velocity) > (size.height * 0.50) {
                                config.position = size.height - 65
                                config.lastPosition = config.position
                                config.progress = 1
                            } else {
                                config.resetPosition()
                            }
                        }
                    })
            )
            .transition(.offset(y: size.height))
    }
    
    func generateProgress() {
        let progress = max(min((size.height - config.position - 50) / (size.height - 65), 1.0), .zero)
                config.progress = progress
    }
}


