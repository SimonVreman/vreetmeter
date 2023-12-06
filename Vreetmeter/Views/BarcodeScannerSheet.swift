
import SwiftUI
import CodeScanner
import AVFoundation

struct BarcodeScannerSheet: View {
    @EnvironmentObject var eetmeterAPI: EetmeterAPI
    @EnvironmentObject var navigation: NavigationState
    @Environment(\.presentationMode) var presentationMode
    @State var loading: Bool = false
    @State var torch: Bool = false
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationView {
            ZStack {
                CodeScannerView(
                    codeTypes: [.ean8, .ean13],
                    scanMode: .continuous,
                    scanInterval: 2,
                    showViewfinder: true,
                    shouldVibrateOnSuccess: false,
                    isTorchOn: torch,
                    videoCaptureDevice: AVCaptureDevice.default(for: .video)
                ) { response in
                    if (loading) { return }
                    loading = true
                    
                    switch response {
                    case .success(let result):
                        Task {
                            do {
                                let scanned = try await eetmeterAPI.getByBarcode(barcode: result.string)
                                generator.notificationOccurred(.success)
                                navigation.selectionPath.append(Eetmeter.GenericProduct(id: scanned.id, type: .brand))
                                presentationMode.wrappedValue.dismiss()
                                loading = false
                            } catch {
                                generator.notificationOccurred(.error)
                                loading = false
                            }
                        }
                    case .failure:
                        generator.notificationOccurred(.error)
                    }
                }
                if (loading) {
                    Rectangle().fill(.black).opacity(0.5)
                    ProgressView()
                }
            }.toolbar {
                Button(action: { torch = !torch }) {
                    Image(systemName: torch ? "bolt" : "bolt.slash")
                }
            }
        }
    }
}
