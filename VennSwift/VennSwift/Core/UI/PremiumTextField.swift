import SwiftUI

/// Premium Text Field - Advanced input component
/// Features: Floating labels, validation, icons, character count
struct PremiumTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let isSecure: Bool
    let validation: ValidationRule?
    let maxLength: Int?
    
    @FocusState private var isFocused: Bool
    @State private var showPassword = false
    @State private var validationState: ValidationState = .none
    
    enum ValidationRule {
        case email
        case phone
        case username
        case password
        case custom((String) -> Bool)
        
        func validate(_ text: String) -> Bool {
            switch self {
            case .email:
                return text.contains("@") && text.contains(".")
            case .phone:
                return text.count >= 10
            case .username:
                return text.count >= 3
            case .password:
                return text.count >= 8
            case .custom(let validator):
                return validator(text)
            }
        }
        
        var errorMessage: String {
            switch self {
            case .email: return "Enter a valid email"
            case .phone: return "Enter a valid phone number"
            case .username: return "Username must be at least 3 characters"
            case .password: return "Password must be at least 8 characters"
            case .custom: return "Invalid input"
            }
        }
    }
    
    enum ValidationState {
        case none, valid, invalid
        
        var color: Color {
            switch self {
            case .none: return .clear
            case .valid: return .green
            case .invalid: return .red
            }
        }
    }
    
    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false,
        validation: ValidationRule? = nil,
        maxLength: Int? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
        self.validation = validation
        self.maxLength = maxLength
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Input field
            HStack(spacing: 12) {
                // Leading icon
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconColor)
                        .frame(width: 24)
                }
                
                // Text field
                ZStack(alignment: .leading) {
                    // Placeholder
                    if text.isEmpty && !isFocused {
                        Text(placeholder)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(VennColors.textTertiary)
                    }
                    
                    // Input
                    if isSecure && !showPassword {
                        SecureField("", text: $text)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(VennColors.textPrimary)
                            .focused($isFocused)
                            .onChange(of: text) { _ in handleTextChange() }
                    } else {
                        TextField("", text: $text)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(VennColors.textPrimary)
                            .focused($isFocused)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: text) { _ in handleTextChange() }
                    }
                }
                
                // Trailing icons
                HStack(spacing: 8) {
                    // Character count
                    if let maxLength = maxLength, isFocused || !text.isEmpty {
                        Text("\(text.count)/\(maxLength)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(
                                text.count > maxLength ? .red : VennColors.textTertiary
                            )
                    }
                    
                    // Show/hide password
                    if isSecure && !text.isEmpty {
                        Button {
                            HapticManager.shared.impact(.light)
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(VennColors.textTertiary)
                        }
                    }
                    
                    // Validation icon
                    if validationState != .none && !text.isEmpty {
                        Image(systemName: validationState == .valid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(validationState.color)
                    }
                    
                    // Clear button
                    if !text.isEmpty && isFocused {
                        Button {
                            HapticManager.shared.impact(.light)
                            text = ""
                            validationState = .none
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(VennColors.textTertiary)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
                    )
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: validationState)
            
            // Error message
            if validationState == .invalid, let validation = validation {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text(validation.errorMessage)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.red)
                .padding(.leading, icon != nil ? 40 : 16)
            }
        }
    }
    
    private var iconColor: Color {
        if isFocused {
            return VennColors.coral
        } else if validationState == .invalid {
            return .red
        } else if validationState == .valid {
            return .green
        } else {
            return VennColors.textTertiary
        }
    }
    
    private var borderColor: Color {
        if isFocused {
            return VennColors.coral.opacity(0.5)
        } else if validationState == .invalid {
            return .red.opacity(0.5)
        } else if validationState == .valid {
            return .green.opacity(0.5)
        } else {
            return Color.white.opacity(0.1)
        }
    }
    
    private func handleTextChange() {
        // Enforce max length
        if let maxLength = maxLength, text.count > maxLength {
            text = String(text.prefix(maxLength))
            HapticManager.shared.impact(.rigid)
        }
        
        // Validate
        if let validation = validation {
            if text.isEmpty {
                validationState = .none
            } else {
                validationState = validation.validate(text) ? .valid : .invalid
            }
        }
    }
}

/// Search Field - Specialized search input
struct SearchField: View {
    @Binding var text: String
    let placeholder: String
    
    @FocusState private var isFocused: Bool
    
    init(_ placeholder: String = "Search...", text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isFocused ? VennColors.coral : VennColors.textTertiary)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(VennColors.textPrimary)
                .focused($isFocused)
                .tint(VennColors.coral)
            
            if !text.isEmpty {
                Button {
                    HapticManager.shared.impact(.light)
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(VennColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            isFocused ? VennColors.coral.opacity(0.3) : Color.white.opacity(0.1),
                            lineWidth: 1.5
                        )
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

// MARK: - Preview

struct PremiumTextFieldPreview: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var bio = ""
    @State private var search = ""
    
    var body: some View {
        ZStack {
            VennColors.darkBg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Premium Text Fields")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        PremiumTextField(
                            "Email",
                            text: $email,
                            icon: "envelope.fill",
                            validation: .email
                        )
                        
                        PremiumTextField(
                            "Password",
                            text: $password,
                            icon: "lock.fill",
                            isSecure: true,
                            validation: .password
                        )
                        
                        PremiumTextField(
                            "Username",
                            text: $username,
                            icon: "person.fill",
                            validation: .username,
                            maxLength: 20
                        )
                        
                        PremiumTextField(
                            "Bio",
                            text: $bio,
                            icon: "text.alignleft",
                            maxLength: 150
                        )
                        
                        SearchField(text: $search)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    PremiumTextFieldPreview()
}
