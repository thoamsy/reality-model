//
//  RunButton.swift
//  RealModel
//
//  Created by yk on 2021/11/8.
//

import SwiftUI
import RealityKit

struct RunButton: View {
  var outputName = "model"
  var progress: Binding<Double>

  @AppStorage("featureSensitivity") var featureSensitivity = PhotogrammetrySession.Configuration.FeatureSensitivity.normal
  @AppStorage("sampleOrdering") var sampleOrdering = PhotogrammetrySession.Configuration.SampleOrdering.unordered
  @AppStorage("detailLevel") var detailLevel = PhotogrammetrySession.Request.Detail.reduced

  @Binding var folderURL: URL?
  @State private var canExport = false

  func sessionConfiguration() -> PhotogrammetrySession.Configuration {
    var configuration = PhotogrammetrySession.Configuration()
    configuration.sampleOrdering = sampleOrdering
    configuration.featureSensitivity = featureSensitivity
    configuration.isObjectMaskingEnabled = false

    return configuration
  }

  @State private var maybeSession: PhotogrammetrySession?


  init(folderURL: Binding<URL?>, progress: Binding<Double>) {
    _folderURL = folderURL
    self.progress = progress
  }

  func resetProgress() {
    progress.wrappedValue = 0
  }

  func run() {
    guard let url = folderURL else { return }

    do {
      let session = try PhotogrammetrySession(input: url, configuration: sessionConfiguration())
      maybeSession = session
    } catch {
      print(error)
      return
    }

    guard let session = maybeSession else { return }

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
              maybeSession = nil
              // Request encountered an error.
            case .requestComplete(let request, let result):
              print("complete, \(request), \(result)")
              resetProgress()
              maybeSession = nil
              // RealityKit has finished processing a request.
            case .requestProgress(let request, let fractionComplete):
              print("requestProgress, \(request), \(fractionComplete)")
              progress.wrappedValue = fractionComplete
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
              maybeSession = nil
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
      if maybeSession != nil && maybeSession!.isProcessing {
        maybeSession?.cancel()
        return
      }

      run()
    }) {
      Label("Run", systemImage: (maybeSession?.isProcessing ?? false) ? "stop.circle" : "play")
    }
    .fileExporter(
      isPresented: $canExport,
      document: USDZURLDocument(name: fileName),
      contentType: .usdz,
      defaultFilename: fileName,
      onCompletion: { $0 }
    )
    .keyboardShortcut((maybeSession?.isProcessing ?? false) ? "S" : "R", modifiers: [.command])
    .disabled(folderURL == nil)
  }
}

//struct RunButton_Previews: PreviewProvider {
//    static var previews: some View {
//        RunButton()
//    }
//}
