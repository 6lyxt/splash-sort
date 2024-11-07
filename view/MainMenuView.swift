//
//  MainMenuView.swift
//  ColorSort
//
//  Created by Johannes Dietze on 11.06.24.
//

import SwiftUI

struct MainMenuView: View {
    @State private var showGameView = false
    @State private var showHighscoreView = false

    var body: some View {
        NavigationView {
            VStack {
                VStack {
        
                Text("splashsort")
                    .font(.largeTitle)
                    .foregroundColor(Color.primary)
                    Text("a concentration & brain-training game").font(.headline).foregroundColor(Color.secondary)
                }.padding()
            
                HStack {
                    NavigationLink(destination: ContentView(), isActive: $showGameView) {
                        Button(action: {
                            self.showGameView = true
                        }) {
                            Text("play now")
                                .font(.title3)
                                .padding()
                                .background(Color.indigo)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    NavigationLink(destination: HighscoreView(), isActive: $showHighscoreView) {
                        Button(action: {
                            self.showHighscoreView = true
                        }) {
                            Text("highscores")
                                .font(.title3)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }.padding()
            }
        }
    }
}


struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
