import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var canvasURL: String = ""
    @State private var apiToken: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case url, token
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Input Fields
                    inputFieldsSection
                    
                    // Login Button
                    loginButtonSection
                    
                    // Help Section
                    helpSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }

            .navigationTitle("Canvas Login")
        }
        .alert("Authentication Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onReceive(authManager.$errorMessage) { errorMessage in
            if let error = errorMessage {
                alertMessage = error
                showingAlert = true
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Welcome to Better Canvas")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Enter your Canvas credentials to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var inputFieldsSection: some View {
        VStack(spacing: 16) {
            // Canvas URL Field
            VStack(alignment: .leading, spacing: 8) {
                Label("Canvas URL", systemImage: "link")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("https://yourschool.instructure.com", text: $canvasURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .url)
                    .onSubmit {
                        focusedField = .token
                    }
                
                if !canvasURL.isEmpty && !isValidURL(canvasURL) {
                    Label("Please enter a valid Canvas URL", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            // API Token Field
            VStack(alignment: .leading, spacing: 8) {
                Label("API Token", systemImage: "key.fill")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                SecureField("Paste your Canvas API token here", text: $apiToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .token)
                    .onSubmit {
                        if isFormValid {
                            Task {
                                await performLogin()
                            }
                        }
                    }
                
                if !apiToken.isEmpty && apiToken.count < 10 {
                    Label("API token seems too short", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var loginButtonSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await performLogin()
                }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    
                    Text(authManager.isLoading ? "Signing In..." : "Sign In")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isFormValid ? Color.accentColor : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!isFormValid || authManager.isLoading)
            
            // Form validation feedback
            if !canvasURL.isEmpty || !apiToken.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    if canvasURL.isEmpty {
                        Label("Canvas URL is required", systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    if apiToken.isEmpty {
                        Label("API token is required", systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private var helpSection: some View {
        VStack(spacing: 16) {
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Label("How to get your API token:", systemImage: "questionmark.circle")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HelpStepView(
                        number: 1,
                        text: "Log in to your Canvas account in a web browser"
                    )
                    HelpStepView(
                        number: 2,
                        text: "Go to Account → Settings"
                    )
                    HelpStepView(
                        number: 3,
                        text: "Scroll down to 'Approved Integrations'"
                    )
                    HelpStepView(
                        number: 4,
                        text: "Click '+ New Access Token'"
                    )
                    HelpStepView(
                        number: 5,
                        text: "Enter a purpose (e.g., 'Better Canvas App') and generate"
                    )
                    HelpStepView(
                        number: 6,
                        text: "Copy the token and paste it above"
                    )
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !canvasURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !apiToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidURL(canvasURL)
    }
    
    // MARK: - Methods
    
    private func isValidURL(_ urlString: String) -> Bool {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Allow URLs with or without protocol
        let urlWithProtocol = trimmed.hasPrefix("http") ? trimmed : "https://\(trimmed)"
        
        guard let url = URL(string: urlWithProtocol) else { return false }
        
        // Basic validation for Canvas URLs
        return url.host != nil && 
               (url.host?.contains("instructure") == true || 
                url.host?.contains("canvas") == true ||
                trimmed.contains("."))
    }
    
    private func performLogin() async {
        let trimmedURL = canvasURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedToken = apiToken.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try await authManager.authenticate(baseURL: trimmedURL, apiToken: trimmedToken)
        } catch {
            // Error handling is done through the authManager's errorMessage publisher
        }
    }
}

// MARK: - Helper Views

struct HelpStepView: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.accentColor)
                .clipShape(Circle())
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationManager())
    }
}
