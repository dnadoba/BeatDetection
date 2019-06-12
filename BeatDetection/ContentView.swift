//
//  ContentView.swift
//  BeatDetection
//
//  Created by David Nadoba on 12.06.19.
//  Copyright © 2019 David Nadoba. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    var body: some View {
        Text("Hello World")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
