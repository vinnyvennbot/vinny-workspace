import SwiftUI

/// Cached Async Image - Premium image loading with cache
/// Provides smooth loading states, caching, and error handling
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    @State private var loadFailed = false
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = loadedImage {
                content(Image(uiImage: image))
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else if loadFailed {
                placeholder()
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo.badge.exclamationmark")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("Failed to load")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    )
            } else {
                placeholder()
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: VennColors.coral))
                            .scaleEffect(0.8)
                    )
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else {
            await MainActor.run {
                isLoading = false
                loadFailed = true
            }
            return
        }
        
        // Check cache first
        if let cached = ImageCache.shared.get(for: url) {
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.2)) {
                    self.loadedImage = cached
                    self.isLoading = false
                }
            }
            return
        }
        
        // Download image
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let image = UIImage(data: data) {
                ImageCache.shared.set(image, for: url)
                
                await MainActor.run {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        self.loadedImage = image
                        self.isLoading = false
                    }
                }
            } else {
                await MainActor.run {
                    isLoading = false
                    loadFailed = true
                }
            }
        } catch {
            await MainActor.run {
                isLoading = false
                loadFailed = true
            }
        }
    }
}

// MARK: - Image Cache

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }
    
    func get(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    func set(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Placeholder == Color {
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.url = url
        self.content = content
        self.placeholder = { Color.white.opacity(0.05) }
    }
}
