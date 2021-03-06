  //
  //  DropView.swift
  //  RealModel
  //
  //  Created by yk on 2021/11/3.
  //

import SwiftUI
import AppKit
import AVFoundation
import RealityKit


struct DropView: View {
  @EnvironmentObject var store: Store
  @AppStorage("detailLevel") var detailLevel = PhotogrammetrySession.Request.Detail.reduced

  @State var showFileImporter = false
  @State var progress = 0.0

  var body: some View {
    VStack {
      if (store.contentURLs != nil) {
        ZStack {
          ThumbnailGrid(contentURLs: $store.contentURLs)
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel, action: {
                  store.contentURLs = nil
                  store.folderURL = nil
                }) {
                  Image(systemName: "arrow.backward")
                }.disabled(store.isProgressing)
              }
              ToolbarItem(placement: .primaryAction) {
                RunButton(progress: $progress)
              }
            }
          if store.isProgressing {
            VStack {
              Text(verbatim: "Generating \(detailLevel)")
                .font(.headline)
              ProgressView(value: progress) {
                VStack {
                  Text("Task take long time, please be patient")
                  Text("Loading: \(progress * 100, specifier: "%.2f")%")
                }.foregroundColor(.secondary)
              }
              .progressViewStyle(CircularProgressViewStyle())
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
          }
        }
      } else {
        HStack {
          Button(action: {
            showFileImporter = true
          }) {
            VStack {
              Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 120))
              Text("Drop to here")
                .font(.largeTitle)
            }
            .frame(width: 256, height: 256)
          }
          .buttonStyle(.borderless)
          .onDrop(of: [.fileURL], delegate: ModelDirectoryDelegate(contentURLs: $store.contentURLs, folderURL: $store.folderURL))
          .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.fileURL, .directory]) { result in
            switch result {
              case .success(let dirURL):
                let result = ModelDirectoryDelegate.getFilesFromDirectoryURL(dirURL: dirURL)

                if let urls = result, !urls.isEmpty {
                  store.folderURL = dirURL
                  store.contentURLs = urls
                }
              case .failure(let error):
                store.errorMessage = error.localizedDescription
            }
          }
        }
      }
    }.frame(minWidth: 600)
  }
}

struct ModelDirectoryDelegate: DropDelegate {
  @Binding var contentURLs: [URL]?
  @Binding var folderURL: URL?

  static let fileExtension = Set(["mp4", "png", "heic", "jpeg", "heif"])

  static func getFilesFromDirectoryURL(dirURL: URL) -> [URL]? {
    let result = try? FileManager.default.contentsOfDirectory(atPath: dirURL.path)

    guard let contents = result else { return nil }

    print(contents.map {  content in dirURL.appendingPathComponent(content) })
    return contents
      .map { content in dirURL.appendingPathComponent(content) }
      .filter { ModelDirectoryDelegate.fileExtension.contains($0.pathExtension.lowercased()) }
  }

  func performDrop(info: DropInfo) -> Bool {
    return info.itemProviders(for: [.fileURL]).first.flatMap { item in
      _ = item.loadObject(ofClass: URL.self) { pathURL, error in
        if error != nil { return }
        guard let url = pathURL else {
          return
        }
        let result = Self.getFilesFromDirectoryURL(dirURL: url)
        if let urls = result, !urls.isEmpty {
          contentURLs = urls
          folderURL = url
        }
      }
      return true
    } ?? false
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
      //    print(info)
    return nil
  }

  func validateDrop(info: DropInfo) -> Bool {
    print(info)
    return info.hasItemsConforming(to: [.fileURL, .directory])
  }
}

struct DropView_Previews: PreviewProvider {
  static var previews: some View {
    DropView()
  }
}

