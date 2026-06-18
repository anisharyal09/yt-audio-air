# 🎵 YT Audio Air

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2014.0+-blue?logo=apple" alt="Platform: macOS 14.0+" />
  <a href="updates.md"><img src="https://img.shields.io/badge/App-v1.2.0-green" alt="App Version: v1.2.0" /></a>
  <img src="https://img.shields.io/badge/Built%20with-Swift%205%20%2B%20WKWebView-orange?logo=swift" alt="Built with Swift 5 + WKWebView" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-blue" alt="License: Apache 2.0" /></a>
  <a href="SECURITY.md"><img src="https://img.shields.io/badge/Security-Policy-brightgreen" alt="Security Policy" /></a>
</p>

A native macOS menu bar app for resource-efficient YouTube audio streaming.

No Electron, no Chromium — built with Swift and Apple's system **WKWebView**. Sits in your menu bar, plays YouTube audio in the background, and uses a fraction of the RAM a browser tab would. (See [updates.md](updates.md) for the latest release notes).

---

## Why Build This?

### The Problem
Web browsers (especially Firefox and Chrome) are notoriously resource-heavy, consuming a massive amount of memory and GPU rendering power just to stream background audio. And also other open-source, third-party clients often feel bloated or heavy, or simply don't meet my need.

At the same time, most minimal or custom players strip away account features entirely. Syncing playback history directly to a main YouTube account is a must-have criteria (simply for seamless history tracking), for no reason, i just want to keep it as it is.

### The Solution
Finding nothing that was minimal, lightweight, bug-free, and supported direct history syncing, **YT Audio Air** was built. It runs natively in the macOS menu bar, keeps history synced, and operates on a fraction of a browser's resources.

And **NO data is collected**, not even interested in doing so :)

This project was built using Xcode and Swift, with developer assistance from:
- **Open Code**
- **Antigravity**


---

## Features

- **Background Playback** — Uses a persistent `NSPanel` with the WebView permanently embedded. Closing the UI parks the window offscreen; audio never stops.
- **Instant Ad Skipping** — Detects ads via `.ad-showing` class → mutes → 16x speed → seeks to end → clicks skip. Ads vanish silently in milliseconds.
- **Minimal Resource Usage** — Video element deflated to 1×1px. Quality forced to 144p. GPU raster bypassed. No MutationObservers — single 250ms polling loop handles everything.
- **Locked-Down Watch Page** — Descriptions, comments, like/share buttons, engagement panels, related videos, and Shorts are all hidden. Only the player and playlist queue are visible.
- **Auto-Unmute** — Defeats YouTube mobile's autoplay muting by continuously forcing `video.muted = false` on watch pages.
- **Hide Images & Avatars** — Toggle to visually hide all video thumbnails and channel profile pictures. Uses non-collapsing styling to preserve card grid alignment and keep video duration overlays fully visible.
- **Grayscale Mode** — Native-performance grayscale filter option for the entire interface, hardware layer composited (`will-change: transform`) to prevent WebKit animation or sticky-scroll glitches.
- **Settings Control Popover** — A glassmorphic options card to toggle preferences (Hide Images, Grayscale, Go to Home) with clean right-aligned switches.
- **Navigation Bar** — Back, Forward, Refresh, settings controls, and a high-resolution brand logo.
- **Right-Click Menu & Settings Shortcut** — Toggle player window, go home, open settings directly (`Options...` item or `⌘,` hotkey), clear cache (stay signed in), sign out & clear all data, support link, and quit.
- **Privacy** — 100% client-side. No trackers, no telemetry, no third-party servers. Cookies stored in macOS's sandboxed WebKit container.

---

## How It Works

### Visibility Spoofing
Overrides the Visibility API at document start so YouTube thinks the player tab is always active — even when the window is parked at `(-20000, -20000)`:
```javascript
Object.defineProperty(document, 'visibilityState', { get: () => 'visible' });
Object.defineProperty(document, 'hidden', { get: () => false });
```

### Layout Deflation
Aggressive CSS injection strips everything except the player and playlist queue:
```css
ytm-comment-section-renderer, ytm-slim-video-action-bar-renderer,
ytm-engagement-panel-section-list-renderer, ytm-video-description-header-renderer,
ytm-item-section-renderer[section-identifier="related-items"],
ytm-reel-shelf-renderer { display: none !important; }
```

### Ad Detection
Uses YouTube's own `.ad-showing` class on the player element — no overlay heuristics that can false-positive. When detected: mute → 16x speed → seek to end → click skip button.

### Image Hiding & Grayscale
- **Image Hiding**: Injects dynamic CSS to set `opacity: 0` on `img` and `lazy-image` elements rather than `display: none`. This preserves the dimensions of card containers, allowing video duration text overlays to display perfectly on top of dark placeholder backgrounds.
- **Grayscale Mode**: Injects a root-level `filter: grayscale(100%)` rule on the `html` tag. To keep the slide-in header functional during scroll under a root-level filter, it applies layer acceleration (`will-change: transform`) to YouTube's mobile header elements, forcing WebKit to create a separate compositing layer.

### Unified 250ms Loop
A single `setInterval(globalUpdate, 250)` replaces heavy DOM observers. Each tick handles ad skipping, 144p quality enforcement, autoplay initiation, force-unmuting, and dynamic preference evaluation.

---

## Download & Installation

### Pre-built Release (Recommended)
1. Go to the [Releases](https://github.com/anisharyal09/yt-audio-air/releases) page on GitHub.
2. Download the latest `yt-audio-air.zip` from the release assets.
3. Double-click to extract the ZIP archive, yielding the `yt-audio-air.app` bundle.
4. Drag and drop the app into your `/Applications` directory.

### First Launch (Bypassing macOS Gatekeeper)
Because the app is compiled and released without an Apple Developer signature, macOS will initially block it with an "unidentified developer" warning.
To allow the app to run:
1. **Right-click (or Control-click)** on `yt-audio-air.app` in Finder and select **Open**.
2. Click the **Open** button in the pop-up warning dialog.
3. Once bypassed, the app will run and show its custom neon waveform brand icon in the system menu bar.

---

## Building from Source

If you prefer to compile the application locally yourself:

1. Open `yt-audio-air.xcodeproj` in Xcode.
2. Select the `yt-audio-air` target and select scheme **My Mac**.
3. Build the project using `⌘B`.
4. To package a standalone release binary, navigate to **Product > Archive**, then click **Distribute App** → **Copy App** to save the compiled `.app` bundle.

---

## Contact & Feedback

For bug reports, feature requests, or general inquiries:
* Send an [Email Inquiry](mailto:anish.creations.hq@gmail.com?subject=YT%20Audio%20Air%20-%20Support%20%26%20Feedback) with a descriptive subject line.
* Contact directly online at [anisharyal09.com.np](https://anisharyal09.com.np/#contact).

---

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.