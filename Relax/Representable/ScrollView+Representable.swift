//
//  ScrollView+Representable.swift
//  Relax
//
//  Created by Илья Кузнецов on 30.06.2024.
//

import Foundation
import UIKit
import SwiftUI

struct ScrollDetector: UIViewRepresentable {
    
    //Замыкание в которое будет передаваться текущий offset
    var onScroll: (CGFloat) -> Void
    
    //Замыкание которое вызывается когда пользователь отпускает палец
    var onDraggingEnd: (CGFloat, CGFloat) -> Void
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ScrollDetector
        var isDelegateAdded: Bool = false
        
        init(parent: ScrollDetector) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.onScroll(scrollView.contentOffset.y)
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            parent.onDraggingEnd(targetContentOffset.pointee.y, velocity.y)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            parent.onDraggingEnd(scrollView.contentOffset.y, 0)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    //При создании пустой UIView находим UIScrollView и назначаем ему в делегаты наш coordinator
    func makeUIView(context: Context) -> some UIView {
        let uiView = UIView()
        DispatchQueue.main.async {
            if let  scrollView = recursiveFindScrollView(view: uiView), !context.coordinator.isDelegateAdded {
                scrollView.delegate = context.coordinator
                context.coordinator.isDelegateAdded = true
            }
        }
        return uiView
    }
    
    //рекурсивно перебираем родителей нашей пустой UIView в поисках ближайшего UIScrollView
    func recursiveFindScrollView(view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        } else {
            if let superview = view.superview {
                return recursiveFindScrollView(view: superview)
            } else {
                return nil
            }
        }
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
}
