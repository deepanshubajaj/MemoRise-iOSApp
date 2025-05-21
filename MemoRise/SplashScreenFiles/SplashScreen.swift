//
//  SplashScreen.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import SwiftUI
import UIKit
import AVFoundation

struct GIFView: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                if let source = CGImageSourceCreateWithData(data as CFData, nil) {
                    let frameCount = CGImageSourceGetCount(source)
                    var images = [UIImage]()
                    
                    for i in 0..<frameCount {
                        if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                            images.append(UIImage(cgImage: image))
                        }
                    }
                    
                    imageView.animationImages = images
                    imageView.animationDuration = Double(images.count) * 0.1
                    imageView.animationRepeatCount = 0
                    imageView.startAnimating()
                }
            }
        }
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        if isActive {
            HomeView()
                .environment(\.managedObjectContext, CoreDataProvider.shared.persistentContainer.viewContext)
        } else {
            ZStack {
                Color("CardBackground", bundle: Bundle(path: "Assets"))
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Top GIF
                    GIFView(gifName: "giphyA")
                        .frame(width: 200, height: 200)
                        .padding(.top, 0)
                    
                    // Middle GIF
                    GIFView(gifName: "giphyB")
                        .frame(width: 150, height: 150)
                    
                    Spacer()
                    
                    // Bottom section with GIF and text
                    HStack(alignment: .bottom) {
                        GIFView(gifName: "giphyC")
                            .frame(width: 15, height: 15)
                        
                        Text("Designed & Developed By:\nDeepanshu Bajaj")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 70)
                            .padding(.bottom, 150)
                    }
                    .padding(.bottom, 30)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    // Play audio when splash screen appears
                    playAudio()
                    
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                    
                    // Navigate to HomeView after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        // Stop audio before transitioning
                        stopAudio()
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
    
    private func playAudio() {
        guard let url = Bundle.main.url(forResource: "upSplash", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
