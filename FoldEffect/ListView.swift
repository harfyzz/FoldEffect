//
//  ContentView.swift
//  FoldEffect
//
//  Created by Afeez Yunus on 02/04/2025.
//

import SwiftUI
import RiveRuntime
import SwiftData

struct ListView: View {
    @Query private var foldImages: [FoldImage]
    @Environment(\.modelContext) private var modelContext
    @State private var paper: RiveViewModel = SharedRiveViewModel.shared.createPaperViewModel(imageNumber: 1) // Default to Img 1
    @State var isFullView: Bool = false
    @State var selectedFoldImage: FoldImage?
    var devicewidth: CGFloat = UIScreen.main.bounds.width - 32
    @Namespace private var animation
    var body: some View {
        VStack {
            if !isFullView {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(spacing: 0),
                            GridItem(spacing: 0)
                        ], spacing: 16) {
                            ForEach(foldImages.sorted(by: { $0.image > $1.image } )) { foldImage in
                                VStack(alignment: .leading) {
                                    if foldImage.isFolded {
                                        ZStack {
                                            
                                            Image("Hashed bg")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 150)
                                                .background(Color("bg"))
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                            VStack{
                                                Image("folded.white")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 80)
                                                Text("Folded")
                                                    .font(.footnote)
                                                    .fontWeight(.medium)
                                                    .foregroundStyle(.tertiary)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(.white)
                                                    .clipShape(RoundedRectangle(cornerRadius: 64))
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 64)
                                                            .stroke(style: StrokeStyle(lineWidth: 1))
                                                            .opacity(0.1)
                                                    }
                                            }
                                        }
                                    } else {
                                        Image("Img \(foldImage.image)")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(foldImage.name)
                                        Text(String(format: "%.1f ft", foldImage.height))
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 4)
                                    .padding(.top, 2)
                                }
                                .padding(6)
                                .padding(.bottom, 2)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                }
                                .scrollTransition { content, phase in
                                    content
                                        .blur(radius: phase.isIdentity ? 0 : 10)
                                }
                                .onTapGesture {
                                    selectedFoldImage = foldImage
                                    paper = SharedRiveViewModel.shared.createPaperViewModel(imageNumber: foldImage.image) // Recreate with new image
                                    withAnimation(.spring(duration:0.3)){
                                        isFullView = true
                                    }
                                    
                                }
                            }
                        }
                    }
                    .onAppear {
                            if let imageId = selectedFoldImage?.id {
                                proxy.scrollTo(imageId, anchor: .center)
                            }
                        
                    }
                    .scrollIndicators(.hidden)
                }
                .transition(.move(edge: .leading))
            } else {
                VStack(spacing:16){
                    Spacer()
                    ZStack {
                        Image("Hashed bg")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: devicewidth)
                        
                        paper.view()
                            .onAppear{
                                paper.setInput("isHidden?", value: selectedFoldImage?.isFolded ?? false)
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
                                Text(String(format: "%.1f ft", selectedFoldImage?.height ?? 0))
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
                            Text(selectedFoldImage?.name.capitalized ?? "")
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
                            Image(systemName: "chevron.backward")
                                .font(.headline)
                                .padding()
                        }
                        .background(Color("bg"))
                        .clipShape(Circle())
                        .onTapGesture {
                            withAnimation(.spring(duration:0.3)){
                                isFullView = false
                            }
                        }
                    HStack{
                        Spacer()
                        Text(selectedFoldImage?.isFolded ?? false ? "Show" : "Hide")
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
                            selectedFoldImage?.isFolded.toggle()
                        }
                        paper.setInput("isHidden?", value: selectedFoldImage?.isFolded ?? false)
                    }
                }
                    .padding(.horizontal, 8)
                }
                .padding(.horizontal, 16)
                .background(.white)
                .transition(.move(edge: .trailing))
            }
        }
        .background(Color("bg"))
        .preferredColorScheme(.light)
        .onAppear {
            initializeFoldImages()
        }
    }
    private func initializeFoldImages() {
        // Check if the data already exists to avoid duplicating
        if foldImages.isEmpty {
            // Array of 22 unique first names
            let firstNames = [
                "Alex", "Jamie", "Taylor", "Morgan", "Chris",
                "Sam", "Jordan", "Casey", "Riley", "Avery",
                "Peyton", "Quinn", "Hayden", "Skylar", "Dakota",
                "Emerson", "Finley", "Rowan", "Sage", "Cameron",
                "Blake", "Parker"
            ]
            // Array of 22 unique last names
            let lastNames = [
                "Smith", "Johnson", "Williams", "Brown", "Jones",
                "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
                "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
                "Thomas", "Taylor", "Moore", "Jackson", "Martin",
                "Lee", "Perez"
            ]
            
            // Generate 22 FoldImage items with unique names
            for index in 0..<22 {
                let fullName = "\(firstNames[index]) \(lastNames[index])"
                let height = CGFloat.random(in: 4.5...6.5)
                
                let foldImage = FoldImage(
                    image: index + 1,
                    name: fullName,
                    height: height
                )
                
                // Insert into SwiftData
                modelContext.insert(foldImage)
            }
            
            // Save the changes
            do {
                try modelContext.save()
            } catch {
                print("Failed to save FoldImage items: \(error)")
            }
        }
    }
}

#Preview {
    ListView()
}


struct SharedRiveViewModel {
    static let shared = SharedRiveViewModel()
    
    // Private initializer to enforce singleton-like behavior
    private init() {}
    
    // Function to create a RiveViewModel with a specific image number
    func createPaperViewModel(imageNumber: Int) -> RiveViewModel {
        RiveViewModel(
            fileName: "paperfold",
            stateMachineName: "State Machine 1",
            loadCdn: false,
            customLoader: { (asset: RiveFileAsset, data: Data, factory: RiveFactory) -> Bool in
                // Load the image dynamically based on imageNumber
                let imageName = "Img \(imageNumber)"
                guard let uiImage = UIImage(named: imageName) else {
                    fatalError("Failed to load '\(imageName)' from Assets.")
                }
                
                // Convert the UIImage to Data (PNG format)
                guard let imageData = uiImage.pngData() else {
                    fatalError("Failed to convert UIImage to PNG data.")
                }
                
                // Pass the image data to Rive
                (asset as! RiveImageAsset).renderImage(
                    factory.decodeImage(imageData)
                )
                return true
            }
        )
    }
}
