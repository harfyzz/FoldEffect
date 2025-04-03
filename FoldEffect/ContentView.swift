//
//  ContentView.swift
//  FoldEffect
//
//  Created by Afeez Yunus on 02/04/2025.
//

import SwiftUI
import RiveRuntime

struct ContentView: View {
    @State var images: [Int] = Array(1...22)
    @StateObject var paper = SharedRiveViewModel.shared.paper
    @State var isHidden: Bool = false
    var body: some View {
        VStack {
           
            ScrollView {
                LazyVGrid(columns:[GridItem(.fixed(162), spacing: 24), // 150 (image width) + 6 (left padding) + 6 (right padding)
                                   GridItem(.fixed(162), spacing: 0)], spacing: 24){
                    ForEach(images, id: \.self){ image in
                        VStack (alignment:.leading){
                            Image("Img \(image)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            VStack(alignment:.leading,spacing:4){
                                Text("Jamie Suarez")
                                Text("5.4ft")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.leading,4)
                            .padding(.top,2)
                        }
                        .padding(6)
                        .padding(.bottom, 2)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay {
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                        }
                        .scrollTransition(transition: { content, phase in
                            content
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        })
                        
                    }
                   
                }
            }.scrollIndicators(.hidden)
            
            
            /*    paper.view()
             Text("Hide")
             .foregroundStyle(.secondary)
             .padding()
             .background(Color.gray.opacity(0.1))
             .clipShape(RoundedRectangle(cornerRadius: 32))
             .onTapGesture {
             isHidden.toggle()
             paper.setInput( "isHidden?", value: isHidden)
             }
             */
        }.background(Color("bg"))
            .ignoresSafeArea(.all)
        
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

