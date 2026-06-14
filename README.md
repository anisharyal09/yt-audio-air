# 🎵 YT Audio Air

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2014.0+-blue?style=for-the-badge&logo=apple" alt="Platform: macOS" />
  <img src="https://img.shields.io/badge/Language-Swift%20-orange?style=for-the-badge&logo=swift" alt="Language: Swift" />
</p>

A native macOS menu bar wrapper designed for seamless, resource-efficient YouTube audio streaming. 

Unlike Chromium-bloated Electron apps that consume massive memory and battery cycles just to play audio, **YT Audio Air** is built natively using Swift and Apple's system-integrated **WebKit engine (`WKWebView`)**. It is designed to sit cleanly in your system menu bar, keeping your desktop workspace clutter-free and your system resources optimized.

---

## Features

- **🔄 Persistent Background Playback:** The player's lifecycle is completely decoupled from the popover window. Closing the interface parks the WebView headlessly in an offscreen window at `(-20000, -20000)` so your audio never cuts out.
- **⚡ High-Speed Ad Skipping:**
  - Instantly detects active YouTube ads (pre-rolls & mid-rolls).
  - Automatically **mutes** the ad audio and boosts the playback rate to **16x** (max WebKit limit).
  - Simulates an immediate click on the "Skip Ad" button as soon as it renders. Ads fly by in under 200ms completely silently.
- **📉 GPU Frame Detachment:** Minimizes GPU resource footprint by setting video opacity to `0.001`. WebKit continues decoding the audio track while skipping heavy visual composition and hardware layer painting.
- **🎛️ Dynamic Header Controls:** Custom navigation bar equipped with spring-animated buttons (Back, Forward, Refresh, Home), a progress loader, and a dynamic subtitle displaying the currently playing video title.
- **🛠️ Right-Click Quick Actions:** Right-click the menu bar icon to toggle the player, jump to the home feed, clear cookies & cache (sign out), or close the app.
- **🔒 Privacy First:** 100% client-side, zero trackers, zero telemetry, and zero third-party servers. All session keys and YouTube logins are managed directly inside macOS's sandboxed local WebKit container.

---

## The Technical "Secret Sauce"

### 1. Visibility Spoofing
Many websites pause player elements when their tab is hidden. YT Audio Air injects a script at document start that overwrites the browser's Visibility API so YouTube believes the player is always visible:
```javascript
Object.defineProperty(document, 'visibilityState', { get: function() { return 'visible'; } });
Object.defineProperty(document, 'hidden', { get: function() { return false; } });
```

### 2. Layout Deflation
To save RAM, a dynamic `MutationObserver` actively purges unnecessary YouTube web assets like comments, recommendations grids, live chats, and animated avatars:
```css
ytm-live-chat-renderer, #chat, ytm-comment-section-renderer, 
ytm-item-section-renderer[section-identifier="related-items"], 
.ytm-animated-thumbnail { display: none !important; }
```

---

## Building & Installing

### Compilation (Xcode)
1. Open `yt-audio-air.xcodeproj` in Xcode.
2. Select the `yt-audio-air` scheme and click **Product > Build** (or `⌘B`).
3. To package the release build, choose **Product > Archive** and select **Copy App** to save the optimized binary directly to your Applications directory.

### First Launch & Permissions
Since this app is built locally and run outside the App Store:
1. **Right-click (Control-click)** the compiled `yt-audio-air.app` in Finder and select **Open**.
2. Click **Open** on the confirmation dialog to register the app on your system (only needed on the very first launch).
3. **Permissions:** If macOS prompts you for outgoing network access, select **Allow** to ensure the WebKit engine can load YouTube audio.

---
## Contact & Feedback

For bug reports, feature requests, or general inquiries:
* Send an [Email Inquiry](mailto:anish.creations.hq@gmail.com?subject=YT%20Audio%20Air%20-%20Support%20%26%20Feedback) with a descriptive subject line.
* Contact directly online at [anisharyal09.com.np](https://anisharyal09.com.np/#contact).
