import SwiftUI

struct AuthFlowView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var phoneNumber = ""
    @State private var otp = ""
    @State private var showOTPField = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Logo
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.orange)
                
                Text("Venn")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.orange)
                
                Text("Connect through experiences")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Phone Number Input
                if !showOTPField {
                    phoneNumberSection
                } else {
                    otpSection
                }
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .disabled(isLoading)
        }
    }
    
    // MARK: - Phone Number Section
    
    private var phoneNumberSection: some View {
        VStack(spacing: 16) {
            TextField("Phone Number", text: $phoneNumber)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
                .font(.title3)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            Button(action: requestOTP) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Continue")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(phoneNumber.isEmpty || isLoading)
        }
    }
    
    // MARK: - OTP Section
    
    private var otpSection: some View {
        VStack(spacing: 16) {
            Text("Enter the code sent to")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(phoneNumber)
                .font(.headline)
            
            TextField("Code", text: $otp)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            Button(action: verifyOTP) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Verify")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(otp.isEmpty || isLoading)
            
            Button("Change Number") {
                showOTPField = false
                otp = ""
                errorMessage = nil
            }
            .foregroundColor(.orange)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Actions
    
    private func requestOTP() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                try await authManager.requestOTP(phoneNumber: phoneNumber)
                await MainActor.run {
                    showOTPField = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func verifyOTP() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                try await authManager.verifyOTP(phoneNumber: phoneNumber, otp: otp)
                // AuthManager will handle state transition
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AuthFlowView()
        .environmentObject(AuthenticationManager.shared)
}
