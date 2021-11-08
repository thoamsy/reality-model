//
//  ThumbnailGrid.swift
//  RealModel
//
//  Created by yk on 2021/11/4.
//

import SwiftUI

struct ThumbnailGrid: View {
  @Binding var contentURLs: [URL]?
  let thumbnailSize: Double = 128
  
  var body: some View {
    VStack {
      HStack {
        Button(role: .cancel, action: {
          contentURLs = nil
        }) {
          Image(systemName: "arrow.backward")
            .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
            .foregroundColor(.white)
        }
        .frame(width: 72, height: 44)
          .buttonStyle(.borderless)
          .background(Color(NSColor.secondaryLabelColor))
          .clipShape(Circle())
        Spacer()
      }
      if (contentURLs != nil) {
        ScrollView {
          LazyVGrid(columns: Array(repeating: .init(.fixed(thumbnailSize)), count: 4)) {
            ForEach(contentURLs!, id: \.self) { url in
              ThumbnailView(fileURL: url, thumbnailSize: thumbnailSize)
            }
          }
        }
      }
    }.padding()
  }
}

struct ThumbnailGrid_Previews: PreviewProvider {
  static var previews: some View {
    ThumbnailGrid(contentURLs: .constant([URL(string: "file:///Users/yk/Downloads/aaaa/%E8%99%8E%E7%89%99%20%E7%8C%AB%E5%B4%BD%E5%B4%BD%E4%B8%89%E5%88%86%E7%B3%96%20%E7%83%AD%E8%88%9E%E5%9B%9E%E6%94%BE%2020210729.mp4")!]))
  }
}
