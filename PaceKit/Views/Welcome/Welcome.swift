//
//  Welcome.swift
//  PaceKit
//
//  Created by Calvin Korver on 2/23/25.
//

import SwiftUI


struct Welcome: View {
    @Environment(ModelData.self) var modelData
    @State private var email: String = ""
    @State private var navigateToWorkouts = false
    
    var isEmailValid: Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    VStack {
                        Image(systemName: "figure.run.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        Text("Welcome to PaceKit!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("A custom workout builder")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom)
                    
                    
                    
                    VStack(spacing: 16) {
                        TextField("What's a good email?", text: $email)
                            .font(.subheadline)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            
                        
                        Button {
                            if isEmailValid {
                                navigateToWorkouts = true
                            }
                        } label: {

                                
                                Text("Continue")

                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isEmailValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        .disabled(!isEmailValid)
                    }
                    
                    Spacer()
                }
                
                NavigationLink(destination: WorkoutList(), isActive: $navigateToWorkouts) {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    Welcome()
        .environment(ModelData())
}

#Preview {
    Welcome()
}
