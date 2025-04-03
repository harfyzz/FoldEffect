//
//  ContentView.swift
//  FoldEffect
//
//  Created by Afeez Yunus on 02/04/2025.
//

import SwiftUI
import RiveRuntime
import SwiftData

struct ContentView: View {
    @Query private var foldImages: [FoldImage]
    @Environment(\.modelContext) private var modelContext
    @StateObject var paper = SharedRiveViewModel.shared.paper
    @State var isHidden: Bool = false
    @State var isFullView: Bool = false
    @State var selectedFoldImage: FoldImage?
    var devicewidth: CGFloat = UIScreen.main.bounds.width - 32
    var body: some View {
        VStack {
            if !isFullView {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(spacing: 0),
                        GridItem(spacing: 0)
                    ], spacing: 16) {
                        ForEach(foldImages) { foldImage in
                            
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
                                                .font(.headline)
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
                                withAnimation{
                                    isFullView = true
                                }
                                
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else {
                VStack(spacing:24){
                    Spacer()
                    HStack{
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                    .background(Color("bg"))
                    .onTapGesture {
                        isFullView = false
                    }
                    paper.view()
                        .frame(height:devicewidth)
                    Text("Hide")
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .onTapGesture {
                            isHidden.toggle()
                            paper.setInput("isHidden?", value: isHidden)
                        }
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color("bg"))
        .ignoresSafeArea(.all)
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
    ContentView()
}

class SharedRiveViewModel: ObservableObject {
    static let shared = SharedRiveViewModel()
    let paper: RiveViewModel
    init() {
        paper = RiveViewModel(
            fileName: "paperfold",
            stateMachineName: "State Machine 1",
            loadCdn: false,
            customLoader: { (asset: RiveFileAsset, data: Data, factory: RiveFactory) -> Bool in
                // Load the image from Assets.xcassets
                guard let uiImage = UIImage(named: "Img 2") else {
                    fatalError("Failed to load 'IMG_5172-3764573' from Assets.")
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

