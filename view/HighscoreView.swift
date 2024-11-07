import SwiftUI

struct HighscoreView: View {
    @AppStorage("highScore") private var highScore: Int = 0

    var body: some View {
        VStack {
            Text("Highscore: \(highScore)")
                .font(.largeTitle)
                .padding()

            Button(action: {
                resetHighScore()
            }) {
                Text("Reset Highscore")
                    .font(.title)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationBarTitle("Highscore", displayMode: .inline)
    }

    private func resetHighScore() {
        highScore = 0
    }
}

struct HighscoreView_Previews: PreviewProvider {
    static var previews: some View {
        HighscoreView()
    }
}
