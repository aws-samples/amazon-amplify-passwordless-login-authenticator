//
//  SignInView.swift
//  PasswordlessAmplify
//
//  Created by Tran, Michael on 8/17/22.
//
import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthService
    
    var body: some View {
            HStack {
                 Button("Sign In", action: {})
                     .padding()
                     .background(Color.purple)
                     .foregroundColor(.white)
                     .cornerRadius(3)
                 
                 Button("Sign Up", action: {})
                     .padding()
                     .background(Color.purple)
                     .foregroundColor(.white)
                     .cornerRadius(3)
             }
    }
//
}
