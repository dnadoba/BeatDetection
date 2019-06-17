//
//  ContentView.swift
//  BeatDetection
//
//  Created by David Nadoba on 12.06.19.
//  Copyright © 2019 David Nadoba. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    let audioEngine = AudioEngine()
    @State var bpm: Float = 0
    @State var beat: Bool = false
    var body: some View {
        return Group {
            Text("\(Int(self.bpm.rounded())) BPM")
                .font(.system(.title, design: .monospaced))
                .padding()
                .background(beat ? Color.green : Color.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onReceive(audioEngine.bpmSubject) { (newBpm) in
            self.bpm = newBpm
        }.onReceive(audioEngine.onsetSubject) { _ in
            self.beat.toggle()
        }
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
