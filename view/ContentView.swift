import SwiftUI
import AVFoundation


struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var colorObjects: [ColorObject] = []
    @State private var containers: [ColorObject] = []
    @State private var points = 0
    @State private var level = 1
    @State private var timeRemaining = 10
    @State private var showAlert = false
    @State private var gameOverAlert = false
    @State private var correctPlacements = 0
    @State private var shouldAnimate = false
    @State private var effectPlayer: AVAudioPlayer?
    @State private var musicPlayer: AVAudioPlayer?

    @State private var timer: Timer?
    
    @AppStorage("highScore") private var highScore: Int = 0
    

    var body: some View {
        ZStack {
            ForEach($colorObjects) { $colorObject in
                ColorObjectView(colorObject: $colorObject, shouldAnimate: $shouldAnimate)
                    .position(colorObject.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                colorObject.position = value.location
                            }
                            .onEnded { value in
                                checkIfObjectIsInContainer(colorObject)
                            }
                    )
            }
            
            ForEach(containers) { container in
                Circle()
                    .strokeBorder(container.color, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .position(container.position)
            }
            
            VStack {
                Spacer()
                Text("Time remaining: \(timeRemaining)")
                    .font(.title)
                Text("Current level: \(level)")
                    .font(.title2)
                    .padding(.bottom)
            }
        }
        .onAppear(perform: startGame)
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $gameOverAlert) {
            Alert(
                title: Text("Time is up"),
                message: Text("You failed to assign the given colors in time. Your highscore was saved."),
                primaryButton: .default(Text("try again"), action: {
                    startGame()
                }),
                secondaryButton: .cancel(Text("exit"), action: {})
            )
        }
    }

    func startGame() {
        resetGame()
        setupGameObjects()
        startTimer()
    }

    func resetGame() {
        points = 0
        level = 1
        timeRemaining = 10
        colorObjects.removeAll()
        containers.removeAll()
        showAlert = false
        gameOverAlert = false
        correctPlacements = 0
    }
    
    func cancelAndGoBack() {
        colorObjects.removeAll()
        containers.removeAll()
        showAlert = false
        gameOverAlert = false
        dismiss()
    }

    func setupGameObjects() {
           let screenWidth = UIScreen.main.bounds.width
           let screenHeight = UIScreen.main.bounds.height

        for _ in 0..<level {
            let existingColors = colorObjects.map { $0.color } + containers.map { $0.color }
            let color = generateDistinctColor(existingColors: existingColors, threshold: 0.5)
            
            let colorObjectPosition = generateValidPosition(existingPositions: colorObjects.map { $0.position } + containers.map { $0.position }, screenWidth: screenWidth, screenHeight: screenHeight)
            colorObjects.append(ColorObject(color: color, position: colorObjectPosition))
            
            let containerPosition = generateValidPosition(existingPositions: colorObjects.map { $0.position } + containers.map { $0.position }, screenWidth: screenWidth, screenHeight: screenHeight)
            containers.append(ColorObject(color: color, position: containerPosition))
        }
       }
    
    func colorDistance(_ color1: Color, _ color2: Color) -> Double {
        let (r1, g1, b1) = color1.rgbComponents()
        let (r2, g2, b2) = color2.rgbComponents()
        
        return sqrt(pow(r2 - r1, 2) + pow(g2 - g1, 2) + pow(b2 - b1, 2))
    }

    func generateDistinctColor(existingColors: [Color], threshold: Double = 0.5, usePredefinedPalette: Bool = true) -> Color {
        let predefinedColors = [
            Color.red, Color.green, Color.blue, Color.yellow, Color.orange, Color.purple, Color.pink,
            Color.gray, Color.cyan, Color.brown, Color.indigo, Color.mint
        ]
        
        var newColor: Color
        if usePredefinedPalette {
            var availableColors = predefinedColors
            existingColors.forEach { existingColor in availableColors = availableColors.filter {
                colorDistance($0, existingColor) >= threshold
                }
            }
            newColor = availableColors.randomElement() ?? Color.random()
        } else {
            newColor = Color.random()
            while existingColors.contains(where: { colorDistance($0, newColor) < threshold }) {
                newColor = Color.random()
            }
        }
        return newColor
    }


       func generateValidPosition(existingPositions: [CGPoint], screenWidth: CGFloat, screenHeight: CGFloat) -> CGPoint {
           var position: CGPoint
           var isValid: Bool
           let maxAttempts = 100
           var attempt = 0

           repeat {
               isValid = true
               position = CGPoint(
                   x: CGFloat.random(in: 50...screenWidth - 50),
                   y: CGFloat.random(in: 100...screenHeight - 150)
               )
               for existingPosition in existingPositions {
                   if distance(from: position, to: existingPosition) < 100 {
                       isValid = false
                       break
                   }
               }
               attempt += 1
               if attempt >= maxAttempts {
                   print("no valid pos found")
                   break
               }
           } while !isValid
           return position
       }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.gameOverAlert = true
                playError()
                updateHighScore()
            }
        }
    }

    func nextLevel() {
        level += 1
        points += level
        timeRemaining = 10 + level * 2
        colorObjects.removeAll()
        containers.removeAll()
        correctPlacements = 0
        setupGameObjects()
        startTimer()
        showAlert = false
    }

    
    func checkIfObjectIsInContainer(_ colorObject: ColorObject) {
        for container in containers {
            if distance(from: colorObject.position, to: container.position) < 25 {
                if container.color == colorObject.color {
                    withAnimation {
                        shouldAnimate = true
                            containers.removeAll {$0.id == container.id }
                            colorObjects.removeAll { $0.id == colorObject.id }
                            shouldAnimate = false
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    playPlop()
                    correctPlacements += 1
                    if correctPlacements == level {
                        timer?.invalidate()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            playSuccess()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            nextLevel()
                            self.showAlert = true
                            updateHighScore()
                        }
                    }
                    break
                }
            }
        }
    }
    
    func updateHighScore() {
            if level > highScore {
                highScore = level
            }
        }
  
        
    func playSound(_ path: String,_ vol: Float) {
        guard let path = Bundle.main.path(forResource: path, ofType:"mp3") else {
            return }
        let url = URL(fileURLWithPath: path)

        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.setVolume(vol, fadeDuration: 0.0)
            effectPlayer?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playSuccess() {
        playSound("success", 0.1)
    }
    
    func playPlop() {
        playSound("plop", 1)

    }
    
    func playError() {
        playSound("fail", 0.5)
    }

    func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

