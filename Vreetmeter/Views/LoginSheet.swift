
import SwiftUI

struct LoginSheet: View {
    @EnvironmentObject var eetmeterAPI: EetmeterAPI
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loggingIn = false
    
    func login() async {
        do {
            try await eetmeterAPI.login(email: email, password: password)
        } catch let e {
            print(e)
        }
    }
    
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
                        await login()
                        loggingIn = false
                    }
                }, label: { Text("Login") })
                    .buttonStyle(ActionButtonStyle(disabled: loggingIn))
                    .disabled(loggingIn)
            }).padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 8)
        }).interactiveDismissDisabled(true)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(TextInputStyle())
            .padding([.top], 32)
    }
}

#Preview {
    LoginSheet()
}
