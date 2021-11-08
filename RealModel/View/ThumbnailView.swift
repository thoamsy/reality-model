//
//  ThumbnailView.swift
//  RealModel
//
//  Created by yk on 2021/11/4.
//

import SwiftUI
import AVFoundation

struct ThumbnailView: View {
  var fileURL: URL
  var thumbnailSize: Double = 128

  // optimaze for just run once
  func generateThumbnails(path: URL) -> Image? {
    print(fileURL.lastPathComponent)
    if (path.pathExtension == "mp4") {
      do {
        let asset = AVURLAsset(url: path, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true

        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        let thumbnail = NSImage(cgImage: cgImage, size: NSSize(width: thumbnailSize, height: thumbnailSize))

        return Image(nsImage: thumbnail)
      } catch {
        print("*** Error generating thumbnail: \(error.localizedDescription)")
        return nil
      }
    } else {
      if let img = NSImage(contentsOf: path) {
        return Image(nsImage: img)
      }
      return nil
    }
  }

  var body: some View {
    VStack {
      if let image = generateThumbnails(path: fileURL) {
        image
          .resizable()
          .scaledToFit()
          .cornerRadius(6)
      } else {
        Image(systemName: "questionmark.folder.fill")
          .resizable()
          .scaledToFit()
      }
      Text(fileURL.lastPathComponent)
        .font(.caption2)
    }
    .frame(width: thumbnailSize, height: thumbnailSize)
    .padding()
  }
}

struct ThumbnailView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ThumbnailView(fileURL: URL(string: "file:///Users/yk/Downloads/aaaa/%E8%99%8E%E7%89%99%20%E7%8C%AB%E5%B4%BD%E5%B4%BD%E4%B8%89%E5%88%86%E7%B3%96%20%E7%83%AD%E8%88%9E%E5%9B%9E%E6%94%BE%2020210729.mp4")!, thumbnailSize: 128)

      ThumbnailView(fileURL: URL(string: "file:///Users/yk/Downloads/aaaa/%E8%99%8E%E7%89%99%20%E7%8C%AB%E5%B4%BD%E5%B4%BD%E4%B8%89%E5%88%86%E7%B3%96%20%E7%83%AD%E8%88%9E%E5%9B%9E%E6%94%BE%2020210729.mp4")!, thumbnailSize: 256)
    }
  }
}
