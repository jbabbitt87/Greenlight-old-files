//
//  ShieldingView.swift
//  GreenLightV4
//
//  Created by Jeffrey  Babbitt on 1/21/25.
//

import SwiftUI

struct ShieldView: View {
    var body: some View {
        
        
            
            VStack{
                Text("This applicaiton is currently blocked. Earn time by visiting your Greenlight application and completing a daily task.")
                    .font(.system(size: 25))
                    .padding(.top, 100)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fontWeight(.semibold)
                    .frame(width: 350, height: 250)
                Image(systemName: "lock.shield")
                    .font(.system(size: 350))
                    .foregroundStyle(.black)
                    .opacity(0.5)
                Button(action: {
                    openUrl((URL(string:"greenlight://open")!))
                }) {
                    Text("Greenlight App")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 350, height: 80)
                        .foregroundColor(.white)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(25)
                }.padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.5))
            .cornerRadius(25)
            .ignoresSafeArea()
        
        /*
         Something that overlays the designated BlockApp. Quote stating
         something like, this Application is currently blocked. Earn time by visiting Greenlight App and completing a daily mission. (really gameify the whole thing with words like mission?)
         
         What I want:
         Glassy overlay with quote
         Symbol showing it is blocked, maybe lock.shield or lock.rectangle
         Button which links back to the Greenlight Application on device
         */
    }
    private func openUrl(_ url: URL) {
          if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
      }
}

#Preview {
    ShieldView()
}
