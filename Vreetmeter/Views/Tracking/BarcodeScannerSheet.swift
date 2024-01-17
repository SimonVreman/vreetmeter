
import SwiftUI
import CodeScanner
import AVFoundation

struct BarcodeScannerSheet: View {
    @Environment(EetmeterAPI.self) var eetmeterAPI
    @State var loading: Bool = false
    @State var torch: Bool = false
    @State var path: NavigationPath = .init()
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationStack(path: $path) {
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
                                path.append(Eetmeter.GenericProduct(id: scanned.id, type: .brand))
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
            }.navigationDestination(for: Eetmeter.GenericProduct.self) { product in
                ProductView(product: product)
            }
        }
    }
}
