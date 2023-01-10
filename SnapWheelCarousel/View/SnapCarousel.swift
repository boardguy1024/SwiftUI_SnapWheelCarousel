//
//  SnapCarousel.swift
//  SnapWheelCarousel
//
//  Created by パク・ギョンソク on 2023/01/06.
//

import SwiftUI

struct SnapCarousel<Content: View, T: Identifiable>: View {
    
    var content: (T) -> Content
    var list: [T]
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    
    @Binding var index: Int
    
    init(spacing: CGFloat = 15,
         trailingSpace: CGFloat = 100,
         index: Binding<Int>,
         items: [T],
         @ViewBuilder content: @escaping (T) -> Content) {
        
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.list = items
        self.content = content
    }
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    var body: some View {
        
        GeometryReader { proxy in
            
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustmentWidth: CGFloat = (trailingSpace / 2) - spacing
            HStack(spacing: self.spacing) {
                ForEach(self.list) { object in
                    content(object)
                        .frame(width: proxy.size.width - trailingSpace)
                        .offset(y: getOffset(item: object, width: width))
                }
            }
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? adjustmentWidth : 0)   + offset)
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, offsetState, _ in
                        offsetState = value.translation.width
                    })
                    .onChanged({ value in
                        let movedWidth = value.translation.width
                        let index = (movedWidth / -width).rounded()
                        self.index = max(min(currentIndex + Int(index), list.count - 1), 0)
                    })
                    .onEnded({ value in
                                                
                        let movedWidth = value.translation.width
                        
                        let index = (movedWidth / -width).rounded()
                        
                        self.currentIndex = max(min(currentIndex + Int(index), list.count - 1), 0)
                        
                        //宣言元にも indexを更新
                        self.index = self.currentIndex
                    })
            )
            .animation(.easeInOut, value: offset == 0)
        }
       
    }
    
    // Moving View based on scroll Offset.
    func getOffset(item: T, width: CGFloat) -> CGFloat {
        
        // 0 ~~~ 1
        // 0 ~~~ 60
        let progress = ( (offset < 0 ? offset : -offset) / width) * 60
        
        // 指を離したタイミングで progressは「0」になる　離していないとdrawOffsetYを持っているので 60を超えないようにする
        let topOffset = -progress < 60 ? progress : -(progress + 120)

        let previousOffset = getIndex(item: item) - 1 == currentIndex ? topOffset : 0
        let nextOffset = getIndex(item: item) + 1 == currentIndex ? topOffset : 0
        
        // 左と右の offsetY
        let betweenOffset: CGFloat = currentIndex == getIndex(item: item) - 1 ? previousOffset : nextOffset
        
        let betweendOffsetOfSafe = currentIndex >= 0 && currentIndex < list.count ? betweenOffset : 0
        
        // currentIndex -> -60  :  以外は betweenOffset
        return getIndex(item: item) == currentIndex ? -60 - topOffset : betweendOffsetOfSafe
    }
    
    func getIndex(item: T) -> Int {
        return self.list.firstIndex(where: { $0.id == item.id }) ?? 0
    }
}

struct SnapCarousel_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
