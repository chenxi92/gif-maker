//
//  ContentView.swift
//  GIFMaker
//
//  Created by peak on 2022/8/11.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var gifMaker = GIFMaker()
    
    var body: some View {
        VStack {
            if gifMaker.imageURLs.isEmpty {
                Text("Please select images to create gif")
                    .font(.headline)
            } else {
                if !gifMaker.errorMessage.isEmpty {
                    errorView()
                }
                
                List {
                    ForEach(0..<gifMaker.imageURLs.count, id: \.self) { index in
                        listRow(index: index)
                    }
                    .onMove { indices, destination in
                        gifMaker.move(from: indices, to: destination)
                    }
                }
                .frame(minHeight: 240)
                
                settingView()
                                
                Button {
                    gifMaker.run()
                } label: {
                    Text("Run")
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .blue, disable: gifMaker.output.isEmpty))
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if gifMaker.isSuccess {
                    resetButton
                } else {
                    selectButton
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
    
    func errorView() -> some View {
        HStack {
            Text(gifMaker.errorMessage)
                .foregroundColor(.red)
            
            Spacer()
            
            Button {
                gifMaker.reset()
            } label: {
                Image(systemName: "xmark")
            }
            .clipShape(Circle())
            .shadow(radius: 5)
        }
        .padding()
    }
    
    func settingView() -> some View {
        Section {
            HStack {
                Text("Delay Time: \(gifMaker.delayTime.toString())")
                Slider(value: $gifMaker.delayTime, in: 1...5, step: 0.5)
                Spacer()
            }
            
            HStack {
                Text("Output: ")
                TextField("Please output path", text: $gifMaker.output)
                Button {
                    showSelectOutputPathPannel()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .padding(.horizontal)
    }
    
    func listRow(index: Int) -> some View {
        HStack {
            Image(nsImage: NSImage(contentsOf: gifMaker.imageURLs[index])!)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Text(gifMaker.imageURLs[index].lastPathComponent)
                .padding()
        }
        .contextMenu {
            deleteButton(index: index)
        }
    }
    
    func deleteButton(index: Int) -> some View {
        Button {
            gifMaker.remove(at: index)
        } label: {
            Text("Delete")
                .padding()
        }
    }
    
    var selectButton: some View {
        Button {
            showSelectImagePannel()
        } label: {
            Text("Select")
                .padding()
                .padding(.vertical)
                .foregroundColor(.blue)
                .font(.headline)
        }
        .background(RoundedRectangle(cornerRadius: 5).stroke(Material.ultraThickMaterial))
    }
    
    var resetButton: some View {
        Button {
            gifMaker.reset()
        } label: {
            Text("Reset")
                .padding()
                .padding(.vertical)
                .foregroundColor(.red)
                .font(.headline)
        }
        .background(RoundedRectangle(cornerRadius: 5).stroke(Material.ultraThickMaterial))
    }
}

// MARK: Pannels
extension ContentView {
    
    func showSelectOutputPathPannel() {
        let pannel = NSOpenPanel()
        pannel.allowsMultipleSelection = true
        pannel.canChooseFiles = false
        pannel.canChooseDirectories = true
        if pannel.runModal() == .OK, let url = pannel.url {
            gifMaker.output = url.path
        }
    }
    
    func showSelectImagePannel() {
        let pannel = NSOpenPanel()
        pannel.allowsMultipleSelection = true
        pannel.canChooseDirectories = false
        pannel.canChooseFiles = true
        pannel.allowedContentTypes = [.png, .jpeg]
        if pannel.runModal() == .OK {
            gifMaker.updateSelectedURLs(urls: pannel.urls)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
