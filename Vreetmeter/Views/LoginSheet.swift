
import SwiftUI

struct LoginSheet: View {
    @Environment(EetmeterAPI.self) var eetmeter
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loggingIn = false
    
    var body: some View {
        VStack(content: {
            ScrollView(content: {
                Text("Login").font(.system(.largeTitle, weight: .bold))
                TextField(text: $email, prompt: Text("Email")) { }
                SecureField(text: $password, prompt: Text("Password")) { }
            }).padding([.leading, .trailing], 16)
                
            HStack(content: {
                Button(action: {
                    loggingIn = true
                    Task {
                        try await eetmeter.login(email: email, password: password)
                        if eetmeter.loggedIn { presentationMode.wrappedValue.dismiss() }
                        loggingIn = false
                    }
                }, label: { Text("Login") })
                    .buttonStyle(ActionButtonStyle(disabled: loggingIn))
                    .disabled(loggingIn)
            }).padding(16)
        }).interactiveDismissDisabled(true)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(TextInputStyle())
            .padding([.top], 32)
    }
}

#Preview {
    LoginSheet().environment(EetmeterAPI())
}
