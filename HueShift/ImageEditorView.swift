import SwiftUI
import CoreImage


struct ImageEditorView: View {
    @Binding var selectedImage: UIImage?
    
    @State private var hue: Double = 0
    @State private var saturation: Double = 1
    @State private var brightness: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var angle: Double = 0.0
    @State private var showNotificationBanner = false
    
    func saveToCameraRoll() {
        let finalImage = createFinalImage()
        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
        
        withAnimation {
            showNotificationBanner = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showNotificationBanner = false
            }
        }
    }
    
    private func createFinalImage() -> UIImage {
        let maxDimension: CGFloat = 4000 // Adjust this value according to your desired maximum dimension
        
        let newSize = CGSize(
            width: min(selectedImage!.size.width, maxDimension),
            height: min(selectedImage!.size.height, maxDimension)
        )
        
        let scaleRatio = min(newSize.width / selectedImage!.size.width, newSize.height / selectedImage!.size.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.saveGState()
        
        let centerX = newSize.width / 2
        let centerY = newSize.height / 2
        context.translateBy(x: centerX, y: centerY)
        context.scaleBy(x: scaleRatio, y: scaleRatio)
        context.rotate(by: CGFloat(angle * .pi / 180))
        context.translateBy(x: -selectedImage!.size.width / 2, y: -selectedImage!.size.height / 2)
        
        selectedImage!.draw(at: .zero)
        
        context.restoreGState()
        
        if let editedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            
            let ciImage = CIImage(image: editedImage)
            
            let hueRotationFilter = CIFilter(name: "CIHueAdjust")!
            hueRotationFilter.setValue(ciImage, forKey: kCIInputImageKey)
            hueRotationFilter.setValue(hue / 180 * Double.pi, forKey: kCIInputAngleKey)
            
            let saturationFilter = CIFilter(name: "CIColorControls")!
            saturationFilter.setValue(hueRotationFilter.outputImage, forKey: kCIInputImageKey)
            saturationFilter.setValue(saturation, forKey: kCIInputSaturationKey)
            saturationFilter.setValue(brightness, forKey: kCIInputBrightnessKey)
            
            if let finalCIImage = saturationFilter.outputImage,
               let cgImage = CIContext().createCGImage(finalCIImage, from: finalCIImage.extent) {
                let finalImage = UIImage(cgImage: cgImage)
                return finalImage
            } else {
                return UIImage()
            }
        } else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
    }
    
    
    var body: some View {
        VStack {
            Text("HueShift")
                .font(.system(size: 36, design: .default))
                .padding(.top)
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .hueRotation(Angle(degrees: hue))
                    .saturation(saturation)
                    .brightness(brightness)
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 10)) // Add this line for rounded corners
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Hue")
                    .foregroundColor(.primary)
                Slider(value: $hue, in: -180...180, step: 1)
                    .accentColor(.primary)
                
                Text("Saturation")
                    .foregroundColor(.primary)
                Slider(value: $saturation, in: 0...2, step: 0.01)
                    .accentColor(.primary)
                
                Text("Brightness")
                    .foregroundColor(.primary)
                Slider(value: $brightness, in: 0...2, step: 0.01)
                    .accentColor(.primary)
            }
            .padding()
            
            Button(action: {
                saveToCameraRoll()
            }) {
                Text("Export to Camera Roll")
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                    .padding([.leading, .trailing], 12)
                    .padding([.top, .bottom], 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.primary, lineWidth: 3)
                    )
            }
            .padding(.bottom, 8)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 1)
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding([.leading, .trailing], 16)
                .padding(.bottom, 8)
            
            Text("By Aaron McLean")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(.bottom)
        }
        .overlay(
            Group {
                if showNotificationBanner {
                    NotificationBanner(text: "Saved to Camera Roll", imageSystemName: "checkmark")
                        .padding(.top, 16)
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .top), removal: AnyTransition.opacity.combined(with: .move(edge: .top))))
                }
            }
        )
    }
    
    
    struct NotificationBanner: View {
        let text: String
        let imageSystemName: String
        
        var body: some View {
            HStack {
                Image(systemName: imageSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundColor(.white)
                
                Text(text)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .background(Color.black)
            .cornerRadius(5)
        }
    }
    
    struct ImageEditorView_Previews: PreviewProvider {
        static var previews: some View {
            ImageEditorView(selectedImage: .constant(UIImage(systemName: "photo")))
        }
    }
}
