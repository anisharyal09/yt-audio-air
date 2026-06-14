//
//  yt_audio_airApp.swift
//  yt-audio-air
//
//  Created by Anish Aryal on 15/06/2026.
//

import SwiftUI
import AppKit
import WebKit

@main
struct yt_audio_airApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate, WKNavigationDelegate {
    static private(set) var shared: AppDelegate?
    
    var statusItem: NSStatusItem?
    let popover = NSPopover()
    
    // Persistent WebView — created once, lives forever
    var webView: WKWebView!
    var offscreenWindow: NSWindow!
    
    // App Nap prevention token
    private var appNapActivity: NSObjectProtocol?
    
    // Click-outside monitor
    private var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        
        // Ensure the app runs as an accessory (hides from Dock)
        NSApp.setActivationPolicy(.accessory)
        
        setupWebView()
        setupOffscreenWindow()
        setupPopover()
        setupStatusItem()
        disableAppNap()
    }
    
    // MARK: - WKWebView Setup
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Developer extras & Tab Discarding bypass
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        // Default data store for cookie persistence (Google auth, history, playlists)
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        // ── Visibility API Override (document start) ──
        // Forces YouTube to believe the tab is always visible even when
        // the popover is closed and the WebView is parked offscreen.
        let visibilityJS = """
        (function() {
            Object.defineProperty(document, 'visibilityState', {
                get: function() { return 'visible'; },
                configurable: true
            });
            Object.defineProperty(document, 'hidden', {
                get: function() { return false; },
                configurable: true
            });
            window.addEventListener('visibilitychange', function(e) {
                e.stopImmediatePropagation();
            }, true);
            document.dispatchEvent(new Event('visibilitychange'));
        })();
        """
        configuration.userContentController.addUserScript(
            WKUserScript(source: visibilityJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        )
        
        // ── Aggressive CSS & JS RAM / Graphics Deflation (document end) ──
        let optimizationJS = """
        (function() {
            if (!window.location.hostname.includes('youtube.com')) return;
            if (window.__ytAudioAirOpt) return;
            window.__ytAudioAirOpt = true;

            var css = `
                /* ═══ VIDEO VISUAL DEFLATION ═══
                   Keeps layout dimensions so YouTube player init passes,
                   but hides visual output to prevent GPU frame rendering. */
                video {
                    opacity: 0.001 !important;
                    pointer-events: none !important;
                }
                .player-container, #player-container-id, .html5-video-player,
                .video-stream {
                    background: #000000 !important;
                }

                /* ═══ HEAVY VISUAL/RAM DEFLATION ═══ */
                /* Live chat & comments */
                ytm-live-chat-renderer, #chat, iframe[src*="live_chat"],
                ytm-comment-section-renderer, ytm-comments-entry-point-header-renderer,
                #comment-section, .comment-section-renderer,
                /* Ads & Promotions (excl .ad-showing to avoid freezing player) */
                .companion-ad, #masthead-ad, ytm-companion-ad-renderer,
                .ad-container, .promoted-item, ytm-promoted-item,
                .ytm-promoted-sparkles-web-renderer, ytm-upsell-dialog-renderer,
                #upsell-dialog, .video-ads, .ytp-ad-overlay-container,
                .ytp-ad-skip-button-slot, .ytp-ad-module,
                ytm-companion-slot, ytm-promoted-sparkles-text-search-renderer,
                .ytm-autonav-bar,
                /* Related recommendations grid on watch page */
                ytm-item-section-renderer[section-identifier="related-items"],
                /* Animated thumbnails/avatars */
                .ytm-animated-thumbnail,
                /* Banners & promotions */
                .yt-banner, ytm-banner-promo-renderer,
                ytm-engagement-panel-section-list-renderer {
                    display: none !important;
                    height: 0 !important;
                    max-height: 0 !important;
                    overflow: hidden !important;
                    visibility: hidden !important;
                }
            `;

            var style = document.createElement('style');
            style.id = 'yt-audio-air-opt';
            style.textContent = css;
            document.documentElement.appendChild(style);

            var wasAdActive = false;

            function optimizeVideo() {
                document.querySelectorAll('video').forEach(function(v) {
                    v.style.setProperty('opacity', '0.001', 'important');
                    v.disableRemotePlayback = true;
                    v.playsInline = true;

                    var wrapper = v.closest('.player-container, .html5-video-player');
                    if (wrapper) {
                        wrapper.style.setProperty('background', '#000000', 'important');
                    }
                });
            }

            function handleAds() {
                var player = document.querySelector('.html5-video-player, .player-container, #player');
                var isAd = false;
                
                if (player && (player.classList.contains('ad-showing') || player.classList.contains('ad-interrupting'))) {
                    isAd = true;
                }
                
                if (!isAd) {
                    var skipBtn = document.querySelector('.ytp-ad-skip-button, .ytp-ad-skip-button-modern, .ytp-ad-skip-button-slot, .ytp-ad-skip-button-container');
                    if (skipBtn) {
                        isAd = true;
                    }
                }
                
                if (!isAd) {
                    var adOverlay = document.querySelector('.ytp-ad-player-overlay, .ytp-ad-overlay-container, .ytp-ad-message-container');
                    if (adOverlay && adOverlay.style.display !== 'none' && adOverlay.offsetHeight > 0) {
                        isAd = true;
                    }
                }

                var video = document.querySelector('video');
                if (video) {
                    if (isAd) {
                        // 1. Mute ad audio instantly
                        if (!video.muted) {
                            video.muted = true;
                            wasAdActive = true;
                        }
                        // 2. Speed up playback to 16x
                        video.playbackRate = 16;
                        
                        // 3. Skip instantly if button is present
                        var skipBtn = document.querySelector('.ytp-ad-skip-button, .ytp-ad-skip-button-modern, .ytp-ad-skip-button-slot button, .ytp-ad-skip-button-slot, .ytp-ad-skip-button-container');
                        if (skipBtn) {
                            skipBtn.click();
                        }
                        
                        // 4. Force-seek to end of the ad to bypass it instantly
                        if (isFinite(video.duration) && video.currentTime < video.duration - 0.2) {
                            video.currentTime = video.duration - 0.1;
                        }
                    } else {
                        // Reset speed if it is stuck at 16x
                        if (video.playbackRate === 16) {
                            video.playbackRate = 1;
                        }
                        // Reset mute if it was muted by an ad
                        if (wasAdActive) {
                            video.muted = false;
                            wasAdActive = false;
                        }
                    }
                }
            }

            optimizeVideo();
            handleAds();

            var observer = new MutationObserver(function() {
                optimizeVideo();
                handleAds();
            });
            observer.observe(document.documentElement, { childList: true, subtree: true });

            // Periodic safety sweep
            setInterval(optimizeVideo, 1200);
            setInterval(handleAds, 250);
        })();
        """
        configuration.userContentController.addUserScript(
            WKUserScript(source: optimizationJS, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        )
        
        webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 375, height: 600), configuration: configuration)
        webView.navigationDelegate = self
        
        // Mobile Safari user agent → forces m.youtube.com lightweight layout
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
        
        if let url = URL(string: "https://m.youtube.com") {
            webView.load(URLRequest(url: url))
        }
    }
    
    // MARK: - Offscreen Window (keeps WebView alive when popover is closed)
    
    private func setupOffscreenWindow() {
        offscreenWindow = NSWindow(
            contentRect: NSRect(x: -20000, y: -20000, width: 375, height: 600),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        offscreenWindow.isReleasedWhenClosed = false
        offscreenWindow.title = "YTAudioAirOffscreen"
        
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 375, height: 600))
        offscreenWindow.contentView = container
        
        // Park WebView in offscreen window initially
        webView.removeFromSuperview()
        webView.frame = container.bounds
        webView.autoresizingMask = [.width, .height]
        webView.translatesAutoresizingMaskIntoConstraints = true
        container.addSubview(webView)
        
        offscreenWindow.orderBack(nil)
    }
    
    // MARK: - Popover Setup
    
    private func setupPopover() {
        popover.contentSize = NSSize(width: 375, height: 550)
        popover.behavior = .transient   // ← auto-closes when clicking outside
        popover.delegate = self
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }
    
    // MARK: - Status Item (Menu Bar Icon)
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: "YT Audio Air")
            button.action = #selector(handleStatusItem)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    // MARK: - Status Item Click Handler
    
    @objc private func handleStatusItem() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    // MARK: - Right-Click Context Menu
    
    private func showContextMenu() {
        guard let button = statusItem?.button else { return }
        
        let menu = NSMenu()
        
        // Toggle Player
        let toggleItem = NSMenuItem(
            title: popover.isShown ? "Hide Player" : "Show Player",
            action: #selector(menuTogglePlayer),
            keyEquivalent: "t"
        )
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Go Home
        let homeItem = NSMenuItem(title: "Go to Home", action: #selector(menuGoHome), keyEquivalent: "h")
        homeItem.target = self
        menu.addItem(homeItem)
        
        // Clear Cache
        let clearItem = NSMenuItem(title: "Clear Cache & Sign Out", action: #selector(menuClearCache), keyEquivalent: "c")
        clearItem.target = self
        menu.addItem(clearItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Support ☕
        let supportItem = NSMenuItem(title: "☕ Support Me", action: #selector(menuSupport), keyEquivalent: "")
        supportItem.target = self
        menu.addItem(supportItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit YT Audio Air", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        // Show then clear (one-shot menu)
        statusItem?.menu = menu
        button.performClick(nil)
        statusItem?.menu = nil
    }
    
    // MARK: - Menu Actions
    
    @objc private func menuTogglePlayer() {
        togglePopover()
    }
    
    @objc private func menuGoHome() {
        if let url = URL(string: "https://m.youtube.com") {
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc private func menuClearCache() {
        let alert = NSAlert()
        alert.messageText = "Clear Cache & Sign Out"
        alert.informativeText = "This will remove all saved cookies and sign you out of YouTube. Continue?"
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        
        if alert.runModal() == .alertFirstButtonReturn {
            let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: Date(timeIntervalSince1970: 0)) {
                self.webView.load(URLRequest(url: URL(string: "https://m.youtube.com")!))
            }
        }
    }
    
    @objc private func menuSupport() {
        if let url = URL(string: "https://ko-fi.com/anisharyal09") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // MARK: - App Nap Prevention
    
    private func disableAppNap() {
        appNapActivity = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiated, .idleSystemSleepDisabled, .suddenTerminationDisabled, .automaticTerminationDisabled],
            reason: "YT Audio Air — background audio playback"
        )
    }
    
    // MARK: - Offscreen Parking Helpers
    
    func parkWebViewOffscreen() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let container = self.offscreenWindow.contentView else { return }
            if self.webView.superview != container {
                self.webView.removeFromSuperview()
                self.webView.frame = container.bounds
                self.webView.autoresizingMask = [.width, .height]
                self.webView.translatesAutoresizingMaskIntoConstraints = true
                container.addSubview(self.webView)
            }
        }
    }
    
    func retrieveWebViewFromOffscreen() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.webView.superview == self.offscreenWindow.contentView {
                self.webView.removeFromSuperview()
            }
        }
    }
    
    // MARK: - NSPopoverDelegate
    
    func popoverWillShow(_ notification: Notification) {
        // Managed dynamically via SwiftUI onAppear visibility
    }
    
    func popoverDidClose(_ notification: Notification) {
        // Safety fallback to ensure webView is never left without a parent in memory
        if webView.superview == nil {
            parkWebViewOffscreen()
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        let host = url.host?.lowercased() ?? ""
        
        // Keep YouTube and Google auth flows inside the WebView
        let internalHosts = ["youtube.com", "m.youtube.com", "www.youtube.com",
                             "accounts.google.com", "accounts.youtube.com",
                             "consent.youtube.com", "consent.google.com",
                             "myaccount.google.com", "gstatic.com",
                             "googleusercontent.com", "googlevideo.com",
                             "youtube-nocookie.com", "ytimg.com",
                             "play.google.com", "ggpht.com"]
        
        let isInternal = internalHosts.contains(where: { host.hasSuffix($0) })
        
        if isInternal {
            decisionHandler(.allow)
        } else if navigationAction.navigationType == .linkActivated {
            // Open external links in the default browser
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
