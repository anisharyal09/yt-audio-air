//
//  ContentView.swift
//  yt-audio-air
//
//  Created by Anish Aryal on 15/06/2026.
//

import SwiftUI
import WebKit

// MARK: - ContentView (Root Popover View)

struct ContentView: View {
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var isLoading = false
    @State private var pageTitle = "YT Audio Air"
    
    var body: some View {
        VStack(spacing: 0) {
            // ── Premium Header ──
            HeaderView(
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                isLoading: $isLoading,
                pageTitle: $pageTitle
            )
            
            // ── WebView ──
            WebViewContainer()
                .frame(width: 375, height: 480)
            
            // ── Footer ──
            FooterView()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
        .preferredColorScheme(.dark)
        .onAppear {
            startNavigationPolling()
        }
    }
    
    private func startNavigationPolling() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let wv = AppDelegate.shared?.webView else { return }
            canGoBack = wv.canGoBack
            canGoForward = wv.canGoForward
            isLoading = wv.isLoading
            pageTitle = wv.title ?? "YT Audio Air"
        }
    }
}

// MARK: - HeaderView

struct HeaderView: View {
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isLoading: Bool
    @Binding var pageTitle: String
    @State private var hoverBtn: Int? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Brand
                HStack(spacing: 7) {
                    // Animated waveform icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.22, blue: 0.22),
                                        Color(red: 1.0, green: 0.45, blue: 0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 26, height: 26)
                        
                        Image(systemName: "waveform")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("YT Audio Air")
                            .font(.system(size: 12.5, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                        
                        if isLoading {
                            Text("Loading…")
                                .font(.system(size: 8.5, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                        } else if !pageTitle.isEmpty && pageTitle != "YouTube" && pageTitle != "YT Audio Air" {
                            Text(pageTitle)
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                                .lineLimit(1)
                                .frame(maxWidth: 150, alignment: .leading)
                        }
                    }
                }
                
                Spacer()
                
                // Navigation Controls
                HStack(spacing: 6) {
                    navButton(icon: "chevron.left", index: 0, enabled: canGoBack) {
                        AppDelegate.shared?.webView.goBack()
                    }
                    navButton(icon: "chevron.right", index: 1, enabled: canGoForward) {
                        AppDelegate.shared?.webView.goForward()
                    }
                    navButton(icon: "arrow.clockwise", index: 2, enabled: true) {
                        AppDelegate.shared?.webView.reload()
                    }
                    navButton(icon: "house.fill", index: 3, enabled: true) {
                        if let url = URL(string: "https://m.youtube.com") {
                            AppDelegate.shared?.webView.load(URLRequest(url: url))
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            
            // Loading progress bar
            if isLoading {
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.22, blue: 0.22),
                                    Color(red: 1.0, green: 0.45, blue: 0.15)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * 0.4, height: 2)
                        .cornerRadius(1)
                        .offset(x: loadingOffset(width: geo.size.width))
                        .animation(
                            Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: isLoading
                        )
                }
                .frame(height: 2)
            }
        }
        .background(Color.black.opacity(0.12))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.04)),
            alignment: .bottom
        )
    }
    
    private func loadingOffset(width: CGFloat) -> CGFloat {
        return isLoading ? width * 0.6 : 0
    }
    
    @ViewBuilder
    private func navButton(icon: String, index: Int, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(enabled ? .white : .white.opacity(0.25))
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(hoverBtn == index ? Color.white.opacity(0.15) : Color.white.opacity(0.07))
                )
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
        .scaleEffect(hoverBtn == index ? 1.1 : 1.0)
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.65)) {
                hoverBtn = hovering ? index : nil
            }
        }
    }
}

// MARK: - FooterView

struct FooterView: View {
    @State private var hoverGH = false
    @State private var hoverKofi = false
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.04))
            
            HStack {
                // GitHub icon (left)
                Button(action: {
                    if let url = URL(string: "https://github.com/anisharyal09/yt-audio-air") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(hoverGH ? .white : .white.opacity(0.35))
                        .frame(width: 22, height: 22)
                        .background(
                            Circle()
                                .fill(hoverGH ? Color.white.opacity(0.12) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .onHover { h in
                    withAnimation(.easeOut(duration: 0.15)) { hoverGH = h }
                }
                .help("Open Source & Secure")
                
                Spacer()
                
                // Version (middle)
                Text("v1.1.0")
                    .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.18))
                
                Spacer()
                
                // Ko-fi icon (right)
                Button(action: {
                    if let url = URL(string: "https://ko-fi.com/anisharyal09") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("☕")
                        .font(.system(size: 11))
                        .frame(width: 22, height: 22)
                        .background(
                            Circle()
                                .fill(hoverKofi ? Color.white.opacity(0.12) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .onHover { h in
                    withAnimation(.easeOut(duration: 0.15)) { hoverKofi = h }
                }
                .help("Support on Ko-fi")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.08))
        }
    }
}

// MARK: - WebViewContainer (NSViewRepresentable)

struct WebViewContainer: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.black.cgColor
        
        if let appDelegate = AppDelegate.shared, let webView = appDelegate.webView {
            webView.removeFromSuperview()
            webView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(webView)
            
            NSLayoutConstraint.activate([
                webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                webView.topAnchor.constraint(equalTo: container.topAnchor),
                webView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }
        return container
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // No-op - the WebView remains embedded in the container
    }
}

// MARK: - Visual Effect View (Vibrancy Background)

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .active
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

#Preview {
    ContentView()
}
