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

class AuthService: ObservableObject {
    @Published var isSignedIn = false
    
    
    func checkSessionStatus() {
        _ = Amplify.Auth.fetchAuthSession { [weak self] result in
            switch result {
            case .success(let session):
                DispatchQueue.main.async {
                    self?.isSignedIn = session.isSignedIn
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }

    
    private var window: UIWindow {
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
            let window = windowSceneDelegate.window as? UIWindow
        else {
            return UIWindow()

        }

        return window
    }


    func webSignIn() {
        _ = Amplify.Auth.signInWithWebUI(presentationAnchor: window) { result in
            switch result {
            case .success:
                print("Signed in")

            case .failure(let error):
                print(error)
            }
//        _ = Amplify.Auth.signIn()
//            .resultPublisher
//            .sink {
//                if case let .failure(authError) = $0 {
//                    print("Sign in failed \(authError)")
//                }
//            }
//            receiveValue: { result in
//                if case .confirmSignInWithCustomChallenge(_) = result.nextStep {
//                    // Ask the user to enter the custom challenge.
//                } else {
//                    print("Sign in succeeded")
//                }
//            }
        }
    }
        
        func observeAuthEvents() {
            _ = Amplify.Hub.listen(to: .auth) { [weak self] result in
                switch result.eventName {
                case HubPayload.EventName.Auth.signedIn:
                    DispatchQueue.main.async {
                        self?.isSignedIn = true
                    }
                    
                case HubPayload.EventName.Auth.signedOut,
                     HubPayload.EventName.Auth.sessionExpired:
                    DispatchQueue.main.async {
                        self?.isSignedIn = false
                    }
                    
                default:
                    break
                }
            }
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

    func confirmSignUp(for username: String, with confirmationCode: String) -> AnyCancellable {
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



@main
struct PasswordlessAmplifyApp: App {
    @ObservedObject var auth = AuthService()
    
    init() {
        configureAmplify()
        auth.checkSessionStatus()
    }
    
     var body: some Scene {
         WindowGroup {
             
             if auth.isSignedIn {
                 SessionView()
                     .environmentObject(auth)
             } else {
                 SignInView()
                     .environmentObject(auth)
             }
         }
     }
    
    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify configured")
            
        } catch {
            print("Could not initialize Amplify -", error)
        }
    }

}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify configured with auth plugin")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
        return true
    }
}




