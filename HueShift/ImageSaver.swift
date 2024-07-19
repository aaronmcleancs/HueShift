import PhotosUI
import SwiftUI

struct ImageSaver: UIViewControllerRepresentable {
    var image: UIImage
    var completion: (Result<Void, Error>) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = UIViewController()
        viewController.view.alpha = 0
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if context.coordinator.isFirstLoad {
            context.coordinator.isFirstLoad = false
            saveImage()
        }
    }

    func saveImage() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges {
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: self.image.jpegData(compressionQuality: 1.0)!, options: nil)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self.completion(.success(()))
                        } else {
                            self.completion(.failure(error!))
                        }
                    }
                }
            } else {
                self.completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"])))
            }
        }
    }

    class Coordinator: NSObject {
        var parent: ImageSaver
        var isFirstLoad = true

        init(_ parent: ImageSaver) {
            self.parent = parent
        }
    }
}
