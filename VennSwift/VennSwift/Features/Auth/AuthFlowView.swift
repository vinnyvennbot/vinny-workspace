import SwiftUI

// MARK: - AuthFlowView
// Premium dark auth screen. Phone -> OTP with animated digit boxes.

struct AuthFlowView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var phoneNumber  = ""
    @State private var otp          = ""
    @State private var showOTPField = false
    @State private var isLoading    = false
    @State private var errorMessage: String?

    // Entry animations
    @State private var heroAppeared  = false
    @State private var formAppeared  = false

    var body: some View {
        ZStack {
            // Background
            VennColors.darkBg.ignoresSafeArea()

            // Ambient glow
            VStack {
                Circle()
                    .fill(VennColors.coral.opacity(0.08))
                    .frame(width: 420, height: 420)
                    .blur(radius: 80)
                    .offset(y: -80)
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Hero section
                heroSection

                Spacer().frame(height: VennSpacing.massive)

                // Form section
                ZStack {
                    if !showOTPField {
                        phoneSection
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .leading)),
                                    removal:   .opacity.combined(with: .move(edge: .leading))
                                )
                            )
                    } else {
                        otpSection
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                                    removal:   .opacity.combined(with: .move(edge: .trailing))
                                )
                            )
                    }
                }
                .animation(VennAnimation.standard, value: showOTPField)

                // Error message
                if let error = errorMessage {
                    HStack(spacing: VennSpacing.sm) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 13))
                        Text(error)
                            .font(VennTypography.caption)
                    }
                    .foregroundColor(VennColors.error)
                    .padding(.horizontal, VennSpacing.xxl)
                    .padding(.top, VennSpacing.md)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                Spacer()
            }
            .padding(.horizontal, VennSpacing.xl)
            .disabled(isLoading)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(VennAnimation.gentle.delay(0.1)) {
                heroAppeared = true
            }
            withAnimation(VennAnimation.gentle.delay(0.3)) {
                formAppeared = true
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: VennSpacing.lg) {
            // Logo mark
            ZStack {
                Circle()
                    .fill(VennColors.coral.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .offset(x: -18)

                Circle()
                    .fill(VennColors.gold.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .offset(x: 18)

                Circle()
                    .fill(VennGradients.primary)
                    .frame(width: 30, height: 30)
            }
            .opacity(heroAppeared ? 1 : 0)
            .scaleEffect(heroAppeared ? 1.0 : 0.6)
            .animation(VennAnimation.bouncy.delay(0.1), value: heroAppeared)

            // Wordmark
            Text("Venn")
                .font(VennTypography.displayMedium)
                .foregroundStyle(
                    LinearGradient(
                        colors: [VennColors.coral, VennColors.gold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(heroAppeared ? 1 : 0)
                .offset(y: heroAppeared ? 0 : 12)

            // Tagline
            Text("connect through experiences")
                .font(VennTypography.body)
                .foregroundColor(VennColors.textTertiary)
                .opacity(heroAppeared ? 1 : 0)
                .offset(y: heroAppeared ? 0 : 8)
        }
    }

    // MARK: - Phone Section

    private var phoneSection: some View {
        VStack(spacing: VennSpacing.lg) {
            // Section label
            VStack(spacing: VennSpacing.xs) {
                Text("Enter your number")
                    .font(VennTypography.subheading)
                    .foregroundColor(VennColors.textPrimary)

                Text("We'll send a one-time code to verify it's you.")
                    .font(VennTypography.caption)
                    .foregroundColor(VennColors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .opacity(formAppeared ? 1 : 0)
            .offset(y: formAppeared ? 0 : 10)

            // Phone input
            VennTextField(
                placeholder: "+1 (555) 000-0000",
                text: $phoneNumber,
                contentType: .telephoneNumber,
                keyboardType: .phonePad
            )
            .opacity(formAppeared ? 1 : 0)
            .offset(y: formAppeared ? 0 : 8)

            // Continue button
            Button(action: requestOTP) {
                ZStack {
                    if isLoading {
                        HStack(spacing: VennSpacing.sm) {
                            VennSpinner()
                            Text("Sending...")
                        }
                    } else {
                        Text("Continue")
                    }
                }
            }
            .vennButton(isEnabled: !phoneNumber.isEmpty && !isLoading)
            .disabled(phoneNumber.isEmpty || isLoading)
            .opacity(formAppeared ? 1 : 0)
            .offset(y: formAppeared ? 0 : 6)
        }
    }

    // MARK: - OTP Section

    private var otpSection: some View {
        VStack(spacing: VennSpacing.xxl) {
            // Header
            VStack(spacing: VennSpacing.sm) {
                Text("Verify your number")
                    .font(VennTypography.subheading)
                    .foregroundColor(VennColors.textPrimary)

                Group {
                    Text("Code sent to ")
                        .foregroundColor(VennColors.textTertiary)
                    + Text(phoneNumber)
                        .foregroundColor(VennColors.textSecondary)
                        .fontWeight(.semibold)
                }
                .font(VennTypography.caption)
                .multilineTextAlignment(.center)
            }

            // OTP digit boxes
            OTPInputView(otp: $otp, length: 6)

            // Verify button
            Button(action: verifyOTP) {
                ZStack {
                    if isLoading {
                        HStack(spacing: VennSpacing.sm) {
                            VennSpinner()
                            Text("Verifying...")
                        }
                    } else {
                        Text("Verify Code")
                    }
                }
            }
            .vennButton(isEnabled: otp.count == 6 && !isLoading)
            .disabled(otp.count < 6 || isLoading)

            // Change number
            Button {
                withAnimation(VennAnimation.standard) {
                    showOTPField = false
                    otp = ""
                    errorMessage = nil
                }
            } label: {
                Text("Change number")
                    .font(VennTypography.bodyMedium)
                    .foregroundColor(VennColors.coral)
            }
            .buttonStyle(.plain)
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
                    withAnimation(VennAnimation.standard) {
                        showOTPField = true
                    }
                    isLoading = false
                    Task { @MainActor in
                        HapticManager.shared.success()
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(VennAnimation.snappy) {
                        errorMessage = error.localizedDescription
                    }
                    isLoading = false
                    Task { @MainActor in
                        HapticManager.shared.error()
                    }
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
                // AuthManager handles state transition
                await MainActor.run {
                    Task { @MainActor in
                        HapticManager.shared.success()
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(VennAnimation.snappy) {
                        errorMessage = error.localizedDescription
                    }
                    isLoading = false
                    Task { @MainActor in
                        HapticManager.shared.error()
                    }
                }
            }
        }
    }
}

// MARK: - Venn Text Field
// Warm glass-bordered input consistent with design system.

struct VennTextField: View {
    let placeholder: String
    @Binding var text: String
    var contentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .font(VennTypography.bodyLarge)
            .foregroundColor(VennColors.textPrimary)
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .autocorrectionDisabled()
            .focused($isFocused)
            .padding(.horizontal, VennSpacing.lg)
            .padding(.vertical, VennSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                    .fill(VennColors.surfacePrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: VennRadius.large, style: .continuous)
                            .stroke(
                                isFocused ? VennColors.coral.opacity(0.55) : VennColors.borderMedium,
                                lineWidth: isFocused ? 1.5 : 1
                            )
                    )
            )
            .animation(VennAnimation.micro, value: isFocused)
    }
}

// MARK: - OTP Input View
// Six individual digit boxes that animate on fill.

struct OTPInputView: View {
    @Binding var otp: String
    let length: Int

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Hidden text field captures input
            TextField("", text: $otp)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: otp) { _, newValue in
                    // Clamp to max length and digits only
                    let filtered = String(newValue.filter(\.isNumber).prefix(length))
                    if filtered != newValue { otp = filtered }
                }

            // Visual digit boxes
            HStack(spacing: VennSpacing.sm) {
                ForEach(0..<length, id: \.self) { index in
                    OTPDigitBox(
                        digit: digit(at: index),
                        isFilled: index < otp.count,
                        isActive: index == otp.count && isFocused
                    )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }

    private func digit(at index: Int) -> String {
        guard index < otp.count else { return "" }
        return String(otp[otp.index(otp.startIndex, offsetBy: index)])
    }
}

// MARK: OTP Digit Box

struct OTPDigitBox: View {
    let digit: String
    let isFilled: Bool
    let isActive: Bool

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                .fill(isFilled ? VennColors.surfaceSecondary : VennColors.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: VennRadius.medium, style: .continuous)
                        .stroke(
                            borderColor,
                            lineWidth: isActive ? 1.5 : 1
                        )
                )
                .frame(width: 46, height: 56)
                .shadow(
                    color: isActive ? VennColors.coral.opacity(0.20) : .clear,
                    radius: 8,
                    x: 0,
                    y: 2
                )

            if isFilled {
                Text(digit)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(VennColors.textPrimary)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.4).combined(with: .opacity),
                            removal:   .scale(scale: 0.4).combined(with: .opacity)
                        )
                    )
            } else if isActive {
                // Blinking cursor
                Capsule()
                    .fill(VennColors.coral)
                    .frame(width: 2, height: 22)
                    .vennPulse(duration: 0.9)
            }
        }
        .animation(VennAnimation.snappy, value: isFilled)
        .animation(VennAnimation.micro, value: isActive)
    }

    private var borderColor: Color {
        if isActive { return VennColors.coral.opacity(0.70) }
        if isFilled { return VennColors.borderStrong }
        return VennColors.borderSubtle
    }
}

// MARK: - Preview

#Preview {
    AuthFlowView()
        .environmentObject(AuthenticationManager.shared)
}
