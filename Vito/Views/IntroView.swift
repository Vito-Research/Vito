import SwiftUI
struct IntroView: View {
   
    //@StateObject var ml = ML()
    @State var animate1 = false
    @State var animate2 = false
    @State var pulse = false
    @State var timer = Timer.publish(every: 10.0, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
                .onReceive(timer) { input in
                    withAnimation(.easeIn(duration: 0.7)) {
                    pulse.toggle()
                    }
                }
                .onAppear() {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        timer = Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()
                        withAnimation(.easeInOut(duration: 1.0)) {
                        animate1 = true
                        }
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//                            animate2 = true
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 1.0)) {
                            animate2 = true
                            }
                            
                        }
                        
                //}
                    }
                }
            VStack {
                Spacer()
        if animate1 {
            
            Image("bird")
                .resizable()
                .scaledToFit()
                .padding()
                .padding()
                .padding()
                .scaleEffect(pulse ? 1.1 : 1.0)
            if animate2 {
               
            Text("Vito")
                    .gradientForeground(colors: [Color("blue"), Color("teal")])
                .font(.custom("Poppins", size: 72, relativeTo: .headline))
        
        }
           
        }
                Spacer()
               
           
            }
        }
    }
}
