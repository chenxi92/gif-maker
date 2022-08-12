//
//  GIFMaker.swift
//  GIFMaker
//
//  Created by peak on 2022/8/11.
//

import Foundation
import CoreGraphics
import UniformTypeIdentifiers
import Cocoa

/// This class inspired by:
/// https://img.ly/blog/how-to-make-an-animated-gif-using-swift
class GIFMaker: ObservableObject {

    @Published private(set) var imageURLs: [URL] = []
    @Published var delayTime: Double = 2.0
    @Published var output: String = ""
    @Published var errorMessage: String = ""
    @Published var isSuccess: Bool = false
    
    public func updateSelectedURLs(urls: [URL]) {
        self.imageURLs.append(contentsOf: urls)
    }
    
    public func remove(at index: Int) {
        guard index >= 0 && index < imageURLs.count else {
            return
        }
        imageURLs.remove(at: index)
    }
    
    public func move(from: IndexSet, to: Int) {
        imageURLs.move(fromOffsets: from, toOffset: to)
    }
    
    public func reset() {
        imageURLs = []
        delayTime = 2.0
        output = ""
        errorMessage = ""
        isSuccess = false
    }
    
    public func run() {
        guard !output.isEmpty else {
            errorMessage = "Didn't select output path"
            return
        }
        let images = imageURLs.compactMap { NSImage(contentsOf: $0) }
        guard images.count > 0 else {
            errorMessage = "Not find valid image"
            return
        }
        
        let directory = URL(fileURLWithPath: output, isDirectory: true)
        let fileName = String(UUID().uuidString + ".gif")
        let destinationURL = directory.appendingPathComponent(fileName)
        
        isSuccess = generate(images: images, delayTime: delayTime, at: destinationURL)
        
        if isSuccess {
            NSWorkspace.shared.selectFile(directory.path, inFileViewerRootedAtPath: "")
            print("create gif success in: \(destinationURL.path)")
        }
    }
    
    /// Generate gif from a sequence images.
    /// - Parameters:
    ///   - images: The source images.
    ///   - delayTime: The amount of time, in seconds, to wait before displaying the next image in an animated sequence.
    ///   - destinationURL: The destination file.
    /// - Returns: The execution result is whether success or fail.
    private func generate(images: [NSImage], delayTime: Double, at destinationURL: URL) -> Bool {
        
        guard let animatedGifFile = CGImageDestinationCreateWithURL(destinationURL as CFURL, UTType.gif.identifier as CFString, images.count, nil) else {
            errorMessage = "error creating gif file"
            return false
        }
        
        let fileDictionary = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0
            ]
        ]
        CGImageDestinationSetProperties(animatedGifFile, fileDictionary as CFDictionary)
        
        let frameDictionary = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: delayTime
            ]
        ]
        for image in images {
            let cgImage: CGImage = image.cgImage!
            CGImageDestinationAddImage(animatedGifFile, cgImage, frameDictionary as CFDictionary)
        }
        
        if CGImageDestinationFinalize(animatedGifFile) {
            return true
        }
        errorMessage = "create gif fail."
        return false
    }
}

extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)
        return cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
    }
}
