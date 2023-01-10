//
//  Home.swift
//  SnapWheelCarousel
//
//  Created by パク・ギョンソク on 2023/01/06.
//

import SwiftUI

struct Home: View {
    
    @State var currentIndex: Int = 0
    @State var list: [Post] = posts
    
    var body: some View {
        
        ZStack {
            
            //背景
            TabView(selection: $currentIndex) {
                ForEach(posts.indices, id: \.self) { index in
                    
                    GeometryReader { proxy in
                        Image(posts[index].postImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .cornerRadius(1)
                    }
                    .ignoresSafeArea()
                    .offset(y: -100)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentIndex)
            .overlay(
                
                LinearGradient(colors: [Color.clear,
                                        Color.white.opacity(0.3),
                                        Color.white, Color.white], startPoint: .top, endPoint: .bottom)
            )
            .ignoresSafeArea()
            
            SnapCarousel(trailingSpace: 150, index: $currentIndex, items: list) { post in
                CardView(post: post)
            }
            .offset(y: getRect().height / 5)
        }
    }
    
    @ViewBuilder
    func CardView(post: Post) -> some View {
        VStack(spacing: 10) {
            GeometryReader { proxy in
                Image(post.postImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .cornerRadius(25)
            }
            .padding(.vertical, 50)
            .frame(height: getRect().height / 2.3)
            .background(Color.gray.opacity(0.1))
            .padding(.bottom, 15)
            
            Text(post.title)
                .font(.title2.bold())
            
            HStack(spacing: 3) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .foregroundColor(index <= post.starRating ? .yellow : .gray)
                }
                Text("(\(post.starRating).0)")
            }
            .font(.caption)
            
            Text(post.description)
                .font(.callout)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
