import Foundation

class Authenticator: ObservableObject {
  @Published var needsAuthentication: Bool
  @Published var isAuthenticating: Bool

  init() {
    self.needsAuthentication = true
    self.isAuthenticating = false
  }

  func login(username: String, password: String) {
    self.isAuthenticating = true
    // emulate a short delay when authenticating
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      self.isAuthenticating = false
      self.needsAuthentication = false
    }
  }

  func logout() {
    self.needsAuthentication = true
  }
}
