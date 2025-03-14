//
//  ContentView.swift
//  dragAndDrop
//
//  Created by 이재훈 on 3/14/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var items: [DragContent] = [.init(id: 0), .init(id: 1)]
    @State private var imagesPosition: [Int: DragContent] = [:]
    @State private var currentlyDragging: DragContent?
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.green.opacity(0.2)
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    ForEach(0..<3) { index in
                        makeDropContentView(index: index)
                    }
                }
                Spacer()
            }
            HStack(spacing: 10) {
                ForEach(items, id: \.id) { item in
                    makeDragContentView(content: item)
                }
            }
        }
        .animation(.easeInOut(duration: 0.1), value: items)
        .animation(.easeInOut(duration: 0.1), value: imagesPosition)
        .dropDestination(for: String.self) { ids, location in
            print(ids, location)
            if let currentlyDragging,
                let id = ids.first,
               currentlyDragging.id == Int(id) {
                self.currentlyDragging = nil
            }
            return true
        }
    }
    
    @ViewBuilder
    func makeDropContentView(index: Int) -> some View {
        ZStack {
            Rectangle()
                .stroke(style: .init(
                    lineWidth: 1,
                    dash: [3]
                ))
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                }
                .foregroundColor(Color(
                    red: 143/255,
                    green: 143/255,
                    blue: 143/255))
            if let content = imagesPosition[index] {
                Image(content.image)
                    .onTapGesture {
                        imagesPosition[index] = nil
                        items.append(content)
                    }
            }
            else {
                Image("plus")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .padding(7)
                    .background {
                        Color.white
                            .background(
                                .ultraThinMaterial
                            )
                            .clipShape(.circle)
                            .frame(width: 24)
                            .shadow(
                                color: .black.opacity(0.15),
                                radius: 4,
                                x: 0,
                                y: 0)
                    }
            }
        }
            .frame(width: 80, height: 80)
            .dropDestination(for: String.self) { ids, location in
                print(index, ids, location)
                guard let id = ids.first,
                      let item = items.first(where: { $0.id == Int(id) })
                else { return false }
                items.removeAll { $0.id == item.id }
                imagesPosition[index] = item
                self.currentlyDragging = nil
                return true
            }
    }
    
    @ViewBuilder
    func makeDragContentView(content: DragContent) -> some View {
        Image(content.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
            .opacity(currentlyDragging?.id == content.id ? 0.2 : 1)
            .contentShape(.dragPreview, .circle)
            .draggable("\(content.id)") {
                ZStack {
                    Color(
                        red: 167/255,
                        green: 181/255,
                        blue: 225/255)
                    Image(content.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .opacity(0.5)
                }
                .onAppear {
                    currentlyDragging = content
                }
                .contentShape(.dragPreview, .circle)
            }
    }
}



struct DragContent: Identifiable, Hashable, Codable {
    var id: Int
    var image: String {
        "object\(id)"
    }
}


#Preview {
    ContentView()
}
