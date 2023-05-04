//
//  ContentView.swift
//  Jokes
//
//  Created by Hidayat Abisena on 04/05/23.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    // MARK: - PROPERTIES
    @StateObject var jokeVM = JokeViewModel()
    @State private var showPunchline = false
    @State private var selectedJoke = JokeType.general
    @State private var audioPlayer: AVAudioPlayer!
    @State private var soundNumber = 0
    let totalSounds = 25
    
    enum JokeType: String, CaseIterable {
        case general, knock_knock, programming, anime, food, dad
    }
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .leading) {
            Text("Jokes! 🤡")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .background(.purple)
            
            // MARK: - Setup Jokes
            Group {
                Text("Setup:".uppercased())
                    .foregroundColor(.indigo)
                    .fontWeight(.bold)
                
                Text(jokeVM.joke.setup)
                    .animation(.default, value: jokeVM.joke.setup)
                    .lineLimit(5)
                
                Spacer()
                
                if showPunchline {
                    Text("Punchline:".uppercased())
                        .foregroundColor(.indigo)
                        .fontWeight(.bold)
                    
                    Text(jokeVM.joke.punchline)
                        .lineLimit(5)
                }
                
                
                Spacer()
            }
            .font(.system(.largeTitle, design: .rounded))
            .padding(.horizontal)
            
            // MARK: - Button Get a Joke
            if showPunchline {
                Button("Get Joke") {
                    showPunchline.toggle()
                    jokeVM.urlString = "https://joke.deno.dev/type/\(formatJokeType(jokeType: selectedJoke))/1"
                    Task {
                        await jokeVM.getData()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
            } else {
                Button("Show Punchline") {
                    playSound(soundName: "\(soundNumber)")
                    soundNumber += 1
                    if soundNumber > totalSounds {
                        soundNumber = 0
                    }
                    showPunchline.toggle()
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
            }
            
            // MARK: - Joke Type Picker
            HStack {
                Text("Joke Type:")
                    .foregroundColor(.purple)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("", selection: $selectedJoke) {
                    ForEach(JokeType.allCases, id: \.self) { jokeType in
                        Text(formatJokeType(jokeType: jokeType))
                    }
                }

                
            } //: HSTACK
            .padding()
            
        } //: VSTACK
        .task {
            jokeVM.urlString = "https://joke.deno.dev/type/\(formatJokeType(jokeType: selectedJoke))/1"
            await jokeVM.getData()
        }
    }
    
    func formatJokeType(jokeType: JokeType) -> String {
        if jokeType == .knock_knock {
            return "knock-knock"
        } else {
            return jokeType.rawValue
        }
    }
    
    func playSound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 Could not read file named \(soundName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("😡 ERROR: \(error.localizedDescription) creating audioPlayer")
        }
    }
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
