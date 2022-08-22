//
//  PasswordlessAmplifyApp.swift
//  PasswordlessAmplify
//
//  Created by Tran, Michael on 8/17/22.
//
import Amplify
import SwiftUI
import Combine
import AWSCognitoAuthPlugin
import Foundation

struct ContentView : View {
    @State var username: String = ""
    @State var password: String = ""

    @State var newUsername: String = ""
    @State var newPassword: String = ""
    @State var newEmail: String = ""
    
    @State var signInCode: String = ""

    @State var confirmationCode: String = ""
    @State var confirmUserName: String = ""

    var body: some View {
        ScrollView {

            VStack {
                Group {
                    Text("Welcome")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.bottom, 20)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    SecureField("Password", text: $password)
                        .padding()
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    Button(action: {signIn(username: username, password: password)}) {
                       LoginButtonContent()
                    }
                }
                Group{
                    TextField("Username", text: $newUsername)
                        .padding()
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    SecureField("Password", text: $newPassword)
                        .padding()
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    SecureField("Password", text: $newEmail)
                        .padding()
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    Button(action: {signUp(username: newUsername, password: newPassword, email: newEmail)}) {
                        SignUpButtonContent()
                    }

                }
                
                Group {
                    TextField("Confirm your sign in code", text: $signInCode)
                        .padding()
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)

                    Button(action: {customChallenge(response: signInCode)}){
                        ConfirmSignInContent()
                    }
                }

                Group{
                    TextField("Confirm Username", text: $confirmUserName)
                        .padding()
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
    
                    TextField("Confirmation Code", text: $confirmationCode)
                        .padding()
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)

                    Button(action: {confirmSignUp(username: confirmUserName, confirmationCode: confirmationCode)}){
                        ConfirmSignUpContent()
                    }
                }
            }
            .padding()
        }
    }
    
    
    func signIn(username: String, password: String) -> AnyCancellable {
        Amplify.Auth.signIn(username: username, password: password)
            .resultPublisher
            .sink {
                if case let .failure(authError) = $0 {
                    print("Sign in failed \(authError)")
                }
            }
            receiveValue: { result in
                if case .confirmSignInWithCustomChallenge(_) = result.nextStep {
                    // Ask the user to enter the custom challenge.
                } else {
                    print("Sign in succeeded")
                }
            }
    }
    
    func customChallenge(response: String) -> AnyCancellable {
        Amplify.Auth.confirmSignIn(challengeResponse: response)
            .resultPublisher
            .sink {
                if case let .failure(authError) = $0 {
                    print("Confirm sign in failed \(authError)")
                }
            }
            receiveValue: { _ in
                print("Confirm sign in succeeded")
            }
    }
    
    func signUp(username: String, password: String, email: String) -> AnyCancellable {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        let sink = Amplify.Auth.signUp(username: username, password: password, options: options)
            .resultPublisher
            .sink {
                if case let .failure(authError) = $0 {
                    print("An error occurred while registering a user \(authError)")
                }
            }
            receiveValue: { signUpResult in
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                } else {
                    print("Signup Complete")
                }

            }
        return sink
    }
    
    func confirmSignUp(username: String, confirmationCode: String) -> AnyCancellable {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode)
            .resultPublisher
            .sink {
                if case let .failure(authError) = $0 {
                    print("An error occurred while confirming sign up \(authError)")
                }
            }
            receiveValue: { _ in
                print("Confirm signUp succeeded")
            }
    }
}

struct LoginButtonContent : View {
    var body: some View {
        return Text("Login")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.green)
            .cornerRadius(15.0)
    }
}

struct SignUpButtonContent : View {
    var body: some View {
        return Text("Sign Up")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.blue)
            .cornerRadius(15.0)
    }
}

struct ConfirmSignInContent : View {
    var body: some View {
        return Text("Confirm Sign In")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.red)
            .cornerRadius(15.0)
    }
}

struct ConfirmSignUpContent : View {
    var body: some View {
        return Text("Confirm Sign Up")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.orange)
            .cornerRadius(15.0)
    }
}

@main
struct PasswordlessAmplifyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    var body: some Scene {
      WindowGroup {
          ContentView()
      }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        do {
            try Amplify.configure()
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }
        return true
    }
}

