//
//  ContentView.swift
//  FoldEffect
//
//  Created by Afeez Yunus on 02/04/2025.
//

import SwiftUI
import RiveRuntime
import PhotosUI

struct UploadView: View {
    @State private var paper: RiveViewModel?
    @State var isFullView: Bool = false
    @State private var selectedImage: UIImage? = UIImage(named: "Img 2")
    @State private var showingImagePicker = false
    var devicewidth: CGFloat = UIScreen.main.bounds.width - 32
    @State private var refreshTrigger = false
    @State var isFolded: Bool = false
    init() {
        // Initialize with default image
        _paper = State(initialValue: UploadRiveViewModel.upload.createPaperViewModel(with: UIImage(named: "Img 2")!))
    }
    var body: some View {
        VStack {
            VStack(spacing:16){
                HStack{
                    Text("Fold")
                        .padding()
                    .onTapGesture {
                        paper?.setInput("fold type", value: Double(1))
                    }
                    Text("Squeeze")
                        .padding()
                .onTapGesture {
                    paper?.setInput("fold type", value: Double(2))
                }
                }.background(Color("bg"))
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                ZStack {
                    Image("Hashed bg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: devicewidth)
                    
                    paper?.view()
                        .onAppear {
                            paper?.setInput("isHidden?", value: isFolded)
                            paper?.setInput("fold type", value: Double(1))
                        }
                }
                .frame(height:devicewidth)
                .background(Color("bg"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                HStack(alignment:.top){
                    HStack {
                        VStack {
                            Rectangle()
                                .frame(width:1, height: 16)
                                .foregroundStyle(.tertiary.opacity(0.5))
                            Text("6.1ft")
                                .font(.system(size: 12, weight: .medium, design: .monospaced) )
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                            Rectangle()
                                .frame(width:1)
                                .foregroundStyle(.tertiary.opacity(0.5))
                        }
                        Spacer()
                    }
                    .padding(.leading, 8)
                    .frame(width: devicewidth/2)
                    VStack(alignment:.leading, spacing: 8){
                        Text("Jamie Alexander")
                            .font(.title2)
                            .foregroundStyle(.primary)
                        Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")
                            .multilineTextAlignment(.leading)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack{
                    HStack{
                        Image(systemName: "photo")
                            .font(.headline)
                            .foregroundStyle(.gray)
                            .padding()
                    }
                    .background(Color("bg"))
                    .clipShape(Circle())
                    .onTapGesture {
                        showingImagePicker = true
                    }
                    HStack{
                        Spacer()
                        Text(isFolded ? "Unfold" : "Fold")
                            .foregroundStyle(.gray)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .transition(.blurReplace())
                        Spacer()
                    }
                    .padding()
                    .background(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onTapGesture {
                        withAnimation {
                            isFolded.toggle()
                        }
                        paper?.setInput("isHidden?", value: isFolded)
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 16)
            .background(.white)
            .transition(.move(edge: .trailing))
            
        }
        .id(refreshTrigger)
        .background(Color("bg"))
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { _,newImage in
            if let image = newImage {
                let normalizedImage = image.normalizedImage()
                // Create a new RiveViewModel instance with the new image
                paper = UploadRiveViewModel.upload.createPaperViewModel(with: normalizedImage)
                // Reset the folded state and apply it to the new instance
                refreshTrigger.toggle()
            }
        }
    }
    
}

#Preview {
    UploadView()
}


struct UploadRiveViewModel {
    static let upload = UploadRiveViewModel()
    
    private init() {}
    
    func createPaperViewModel(with image: UIImage) -> RiveViewModel {
        guard let imageData = image.pngData() else {
            fatalError("Failed to convert image to PNG data")
        }
        
        return RiveViewModel(
            fileName: "paperfold",
            stateMachineName: "State Machine 1",
            loadCdn: false,
            customLoader: { (asset: RiveFileAsset, data: Data, factory: RiveFactory) -> Bool in
                guard let riveImageAsset = asset as? RiveImageAsset else {
                    return false
                }
                let decodedImage = factory.decodeImage(imageData)
                riveImageAsset.renderImage(decodedImage)
                return true
            }
        )
    }
}

// Add ImagePicker struct
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

extension UIImage {
    func normalizedImage() -> UIImage {
        if imageOrientation == .up {
            return self // No normalization needed
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}
