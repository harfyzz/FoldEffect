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
            Text("Basic Fold effect exploration.")
                .padding(.top, 32)
                .padding(.horizontal, 32)
                .font(.title)
                .multilineTextAlignment(.center)
                .foregroundStyle(.tertiary)
            Spacer()
            ScrollView(.horizontal){
                HStack{
                    ForEach(images, id: \.self){ image in
                        Image("Img \(image)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 330)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .scrollIndicators(.hidden)
            Spacer()
            /*
            paper.view()
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
                guard let url = (.main as Bundle).url(forResource: "IMG_5172-3764573", withExtension: "png") else {
                    fatalError("Failed to locate 'picture-47982' in bundle.")
                }
                guard let data = try? Data(contentsOf: url) else {
                    fatalError("Failed to load \(url) from bundle.")
                }
                (asset as! RiveImageAsset).renderImage(
                    factory.decodeImage(data)
                )
                return true;
            })
            }
    
    
}
