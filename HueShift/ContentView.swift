import SwiftUI

struct ContentView: View {
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var selectedImage: UIImage? = nil
    @State private var showEditor = false
    @State private var dotMatrixRefreshID = UUID()
    @State private var showPhotoLibraryPicker = false
    @State private var showCameraPicker = false

    var body: some View {
        NavigationView {
            ZStack {
                DotMatrix().edgesIgnoringSafeArea(.all).id(dotMatrixRefreshID)
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 290, height: 80)
                            .opacity(0.99)
                            .blur(radius: 4)
                        
                        Text("HueShift")
                            .font(.system(size: 60, weight: .bold, design: .default))
                            .foregroundColor(Color(.label))
                    }
                    .padding()
                    
                    Spacer()
                    Button(action: {
                        showPhotoLibraryPicker = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                                .foregroundColor(Color(.label))

                            Text("Upload")
                        }
                    }
                    .buttonStyle(RoundedButtonStyle(backgroundColor: Color(.secondarySystemBackground), foregroundColor: Color(.label), borderColor: Color(.label)))
                    .padding(.bottom, 10)

                    Button(action: {
                        showCameraPicker = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                                .foregroundColor(Color(.secondarySystemBackground))

                            Text("Capture")
                        }
                    }
                    .buttonStyle(RoundedButtonStyle(backgroundColor: Color(.label), foregroundColor: Color(.secondarySystemBackground), borderColor: Color(.secondarySystemBackground)))
                    .padding(.bottom, 10)
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 180, height: 40)
                            .blur(radius: 5)
                        
                        Text("By Aaron McLean")
                            .font(.system(size: 12))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    .padding(.bottom)
                }
                .sheet(isPresented: $showPhotoLibraryPicker, content: {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage, completionHandler: { result in
                        if case .success(let image) = result {
                            selectedImage = image
                            showEditor = true
                        }
                    })
                })
                .sheet(isPresented: $showCameraPicker, content: {
                    ImagePicker(sourceType: .camera, selectedImage: $selectedImage, completionHandler: { result in
                        if case .success(let image) = result {
                            selectedImage = image
                            showEditor = true
                        }
                    })
                })
                .background(NavigationLink("", destination: ImageEditorView(selectedImage: $selectedImage), isActive: $showEditor).opacity(0))
            }
        }
        .onChange(of: showEditor) { value in
            if !value {
                dotMatrixRefreshID = UUID()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct RoundedButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let borderColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .bold))
            .padding(.horizontal, 70)
            .padding(.vertical)
            .background(RoundedRectangle(cornerRadius: 10).fill(backgroundColor))
            .foregroundColor(foregroundColor)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: 3))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
