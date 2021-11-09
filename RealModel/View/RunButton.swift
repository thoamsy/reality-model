//
//  RunButton.swift
//  RealModel
//
//  Created by yk on 2021/11/8.
//

import SwiftUI
import RealityKit

struct RunButton: View {
  @EnvironmentObject var store: Store

  var outputName = "model"

  @AppStorage("featureSensitivity") var featureSensitivity = PhotogrammetrySession.Configuration.FeatureSensitivity.normal
  @AppStorage("sampleOrdering") var sampleOrdering = PhotogrammetrySession.Configuration.SampleOrdering.unordered
  @AppStorage("detailLevel") var detailLevel = PhotogrammetrySession.Request.Detail.reduced

  @State private var canExport = false
  @State private var maybeSession: PhotogrammetrySession?
  @Binding private var progress: Double

  func sessionConfiguration() -> PhotogrammetrySession.Configuration {
    var configuration = PhotogrammetrySession.Configuration()
    configuration.sampleOrdering = sampleOrdering
    configuration.featureSensitivity = featureSensitivity
    configuration.isObjectMaskingEnabled = false

    return configuration
  }

  init(progress: Binding<Double>) {
    _progress = progress
  }

  func resetProgress() {
    maybeSession = nil
    store.isProgressing = false
    DispatchQueue.main.async {
      progress = 0
    }
  }

  func run() {
    guard let url = store.folderURL else { return }

    do {
      let session = try PhotogrammetrySession(input: url, configuration: sessionConfiguration())
      maybeSession = session
    } catch {
      print(error)
      return
    }

    guard let session = maybeSession else { return }

    store.isProgressing = true
    let waiter = Task {
      do {
        for try await output in session.outputs {
          switch output {
            case .processingComplete:
              canExport = true
              // RealityKit has processed all requests.
            case .requestError(let request, let error):
              print("Error: ")
              print(request, error)
              resetProgress()
              // Request encountered an error.
            case .requestComplete(let request, let result):
              print("complete, \(request), \(result)")
              resetProgress()
              // RealityKit has finished processing a request.
            case .requestProgress(let request, let fractionComplete):
              print("requestProgress, \(request), \(fractionComplete)")
              progress = fractionComplete
              // Periodic progress update. Update UI here.
            case .inputComplete:
              print("input complete")
//               Ingestion of images is complete and processing begins.
            case .invalidSample(let id, let reason):
              print(id, reason)
              // RealityKit deemed a sample invalid and didn't use it.
            case .skippedSample(let id):
              print(id)
              // RealityKit was unable to use a provided sample.
              //              case .automaticDownsampling:
              //                // RealityKit downsampled the input images because of
              //                // resource constraints.
            case .processingCancelled:
              print("Cancel")
              resetProgress()
            @unknown default:
              print("Do nothing")
          }
        }
      } catch {
        print("Output: ERROR = \(String(describing: error))")
        // Handle error.
      }
    }

    withExtendedLifetime((session, waiter)) {
      do {
      let outputURL = URL(fileURLWithPath: fileName + ".usdz")

      let request = PhotogrammetrySession.Request.modelFile(url: outputURL, detail: detailLevel)
      try session.process(requests: [request])
      } catch {
        print("Process got error: \(String(describing: error))")
        maybeSession = nil
      }
    }
  }

  var fileName: String {
    "\(outputName)-\(detailLevel)"
  }

  var body: some View {
    Button(action: {
      if isProgress {
        maybeSession?.cancel()
        return
      }

      run()
    }) {
      Label(isProgress ? "Stop" : "Run", systemImage: (maybeSession?.isProcessing ?? false) ? "stop.circle" : "play")
    }
    .fileExporter(
      isPresented: $canExport,
      document: USDZURLDocument(name: fileName),
      contentType: .usdz,
      defaultFilename: fileName,
      onCompletion: { $0 }
    )
    .keyboardShortcut(isProgress ? "S" : "R", modifiers: [.command])
    .disabled(store.folderURL == nil)
  }

  var isProgress: Bool {
    maybeSession?.isProcessing ?? false
  }
}

//struct RunButton_Previews: PreviewProvider {
//    static var previews: some View {
//        RunButton()
//    }
//}
