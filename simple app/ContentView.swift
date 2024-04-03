import SwiftUI
import UIKit

struct ContentView: View {
    @State private var rotationAngle: Angle = .zero
    @State private var circleScale: CGFloat = 1.0
    @State private var obstacleCount = 0
    @State private var showAlert = false
    @State private var obstaclePosition: CGFloat = 0
    @State private var movement: CGFloat = 5
    @State private var collisionCooldown = false
    @State private var show1 = false
    @State private var show2 = false
    @State private var circleFrame = CGRect(x: 0, y: 0, width: 25, height: 25)
    var body: some View {
        VStack{
            GeometryReader{cords in
                Circle()
                    .fill( Color(collisionCooldown ? .red : .blue))
                    .overlay(
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 25 * circleScale, height: 25 * circleScale) // Adjust size as needed
                    )
                    .rotationEffect(rotationAngle)
                    .frame(width: 100 * circleScale, height: 100 * circleScale)
                    .background(
                        GeometryReader { geo in
                            Spacer().onAppear{
                                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                                    var frame = geo.frame(in: .global)
                                    circleFrame = frame
//                                    print(circleFrame.width,circleFrame.height)
                                }
                            }

                        }
                    )
                    .offset(x: cords.size.width/2-50 * circleScale, y: cords.size.height/2-50 * circleScale)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                            rotationAngle = .radians(.pi * 2)
                        }
                    }
                    .onTapGesture {
                        handleCollision()
                    }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Warning"), message: Text("You need to restart the screen."), dismissButton: .default(Text("OK")))
            }
            .onChange(of: obstacleCount) { newValue in
                if newValue == 5 {
                    showAlert = true
                    obstacleCount = 0
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if(show1){
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 50, height: 5)
                                .background(
                                    GeometryReader{geo in
                                        Spacer().onAppear{
                                            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                                                if intersects(center: CGPoint(x: circleFrame.midX, y: circleFrame.midY), r: circleFrame.height/2, rect: geo.frame(in: .global)){
                                                    print("1:   ",geo.frame(in: .global))
                                                        handleCollision()
                                                }
                                            }
                                        }
                                    }
                                )
                                .offset(x:  -obstaclePosition)
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        if(show2){
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 50, height: 5)
                                .background(
                                    GeometryReader{geo in
                                        Spacer().onAppear{
                                            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                                                if intersects(center: CGPoint(x: circleFrame.midX, y: circleFrame.midY), r: circleFrame.height/2, rect: geo.frame(in: .global)){
                                                    print("2:   ",geo.frame(in: .global))
                                                        handleCollision()
                                                }
                                            }
                                        }
                                    }
                                )
                                .offset(x: obstaclePosition)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    show1 = true
                    moveObstacles()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        show2 = true
                    }
                }
            }
            Spacer()
            HStack {
                Button(action: {
                    withAnimation {
                        circleScale += 0.1
                    }
                }) {
                    Image(systemName: "plus")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    withAnimation {
                        circleScale -= 0.1
                    }
                }) {
                    Image(systemName: "minus")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }        .frame(maxWidth: .infinity)
        }
    }
    
    func handleCollision() {
        if collisionCooldown {
            return;
        }
        obstacleCount += 1
        if obstacleCount == 5 {
            // Show alert after 5 collisions
            showAlert = true
        }else{
            showAlert = false
        }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
        print("Collision")
        collisionCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation{
                collisionCooldown = false
            }
        }
    }
    
    func moveObstacles() {
        withAnimation(Animation.linear(duration: 5.0).repeatForever(autoreverses: false)) {
            self.obstaclePosition = 0
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                self.obstaclePosition += self.movement
                
                if abs(self.obstaclePosition) > 120 {
                    self.movement = -self.movement
                }
            }
        }
    }
    func intersects(center: CGPoint, r: CGFloat, rect: CGRect) -> Bool {
        var circleDistance = (x: abs(center.x - rect.midX), y: abs(center.y - rect.midY))

        if circleDistance.x > (rect.width / 2 + r) { return false }
        if circleDistance.y > (rect.height / 2 + r) { return false }

        if circleDistance.x <= (rect.width / 2) { return true }
        if circleDistance.y <= (rect.height / 2) { return true }

        let cornerDistanceSquared = pow(circleDistance.x - rect.width / 2, 2) +
                                    pow(circleDistance.y - rect.height / 2, 2)

        return cornerDistanceSquared <= pow(r, 2)
    }

}


