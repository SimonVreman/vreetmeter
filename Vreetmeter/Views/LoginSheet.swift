
import SwiftUI

struct LoginSheet: View {
    @Environment(EetmeterAPI.self) var eetmeter
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loggingIn = false
    
    var body: some View {
        VStack(content: {
            ScrollView(content: {
                Text("Login").font(.system(.largeTitle, weight: .bold))
                TextField(text: $email, prompt: Text("Email")) { }
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                SecureField(text: $password, prompt: Text("Password")) { }
                    .textContentType(.password)
            }).padding([.leading, .trailing], 16)
                
            HStack(content: {
                Button(action: {
                    loggingIn = true
                    Task {
                        defer { loggingIn = false }
                        try await eetmeter.login(email: email, password: password)
                        if eetmeter.loggedIn { dismiss() }
                    }
                }, label: { Text("Login") })
                    .buttonStyle(ActionButtonStyle(disabled: loggingIn))
                    .disabled(loggingIn)
            }).padding(16)
        }).interactiveDismissDisabled(true)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .textFieldStyle(TextInputStyle())
            .padding([.top], 32)
    }
}

#Preview {
    LoginSheet().environment(EetmeterAPI())
}
