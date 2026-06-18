# Updates

All notable changes to this project will be documented in this file.

## [v1.2.0] - 2026-06-16
(updated 2026-06-18)

### Added
- **Grayscale Mode Option** — Added a native-performance grayscale preference switch in the options menu to render the whole web interface in grayscale.
- **Global Thumbnail Toggle** — Added a checkbox option in the popover header controls menu (`slider.horizontal.3`) to toggle hiding/showing all thumbnail images across all pages (Home, Search, and Watch), saving bandwidth, memory, and keeping it purely audio-oriented.
- **Menu Bar Options Action** — Added an "Options…" action item to the right-click status menu (shortcut `⌘,`) to open the control options panel directly.
- **Custom Header Brand Logo** — Integrated the newly generated neon waveform app icon image into the popover's top-left brand header for a premium and cohesive design.
- **Add Alert Icons** — Added the high-resolution app icon to cache-clear and sign-out confirmation alerts, replacing blank/generic boxes.
- **Clarifying Toggle Subtitle** — Added a helper description `(also hides channel profile pictures)` to the "Hide Images" toggle switch for better guidance.
- **Open Source License & Security Policy** — Added the Apache License 2.0, file headers to Swift source files, and a project security policy file (`SECURITY.md`).

### Fixed
- **Grayscale Scroll Interaction** — Fixed a WebKit rendering bug that stopped the header from sliding back down on scroll-up by forcing GPU layer compositing (`will-change: transform`) on mobile header elements.
- **Grid Layout Preservation** — Fixed video card grid collapses and missing duration overlays when hiding images by applying transparency (`opacity: 0`) and setting solid placeholder backgrounds instead of hiding elements via `display: none`.
- **Improved Ad Skipping & Detection** — Resolved issues with uncontrollably playing ads on `m.youtube.com` under a black screen by muting, speeding up (16x), and skipping all active `<video>` elements in the DOM. Also switched to a robust page-wide query for `.ad-showing` / `.ad-interrupting` classes and visible skip buttons to prevent false-positives.

### Changed
- **Right-Aligned Settings Toggles** — Redesigned the options popover UI to right-align the switch controls and left-align the labels.
- **High-Res Header Icon** — Replaced the low-resolution header assets with a single high-resolution source image mapped to all scales, ensuring sharp retina-friendly scaling at `30x30` points in the header layout.
- **Changelog footer links** — Changed the version text in the footer to a clickable button that links directly to this `updates.md` file and displays a detailed hover tooltip and update coffee link.

---

## [v1.1.0] - 2026-06-15

### Added
- **NSPanel player window** — Custom `PlayerPanel: NSPanel` with `canBecomeKey` override replaces the old `NSPopover`. WebView is permanently embedded and never detached, preventing gesture token loss and background audio cutouts.
- **Watch-page-only autoplay** — `yt-navigate-finish` listener triggers autoplay exclusively on `/watch` URLs. Home and search pages are never auto-triggered.
- **Text-only playlist queue** — Playlist panel (`ytm-playlist-panel-renderer`) renders as a compact track list with thumbnails hidden via CSS.
- **Separate cache & auth controls** — Right-click menu now has "Clear Cache Only" (keeps login) and "Sign Out & Clear All Data" (nukes everything) as distinct options.
- **Force-unmute on watch pages** — 250ms loop continuously forces `video.muted = false` on watch pages when no ad is active, defeating YouTube mobile's autoplay muting policy.
- **144p quality re-application** — `qualityForced` flag is reset on every `yt-navigate-finish`, ensuring each new video load gets forced to `tiny` (144p).
- **Support Me link** — Added Ko-fi link in right-click menu and footer.

### Changed
- **Viewport**: 375×550 compact dimensions.
- **YouTube header shrunk**: Page zoom at default `1.0`, header elements scaled to `0.75x` via CSS transforms.
- **Video element deflated**: 1×1px, opacity 0.001, scale 0.001 — bypasses GPU raster entirely.
- **Watch page locked down**: Descriptions, like/share/save buttons, engagement panels, related items, comments, Shorts shelf — all hidden. Only player + playlist queue visible.

### Fixed
- **Songs skipping to end** — Removed overlay-based ad detection (`.ytp-ad-player-overlay`) that false-positived on normal content. Now uses only `.ad-showing` / `.ad-interrupting` classes on the player element.
- **Home feed auto-playing first video** — `__needsAutoplay` was initialized `true` and `yt-navigate-finish` fired on all pages. Fixed by initializing `false` and scoping to `/watch` only.
- **Silent playback until manual click** — YouTube mobile muted the video element by default. Force-unmute guard resolves this.
- **144p not re-applying on next songs** — YouTube reuses the same `<video>` element across navigations, so the `qualityForced` dataset flag persisted. Now reset on each navigation.
- **Replaced MutationObserver with 250ms polling loop** — Eliminated CPU-heavy DOM observation. Single `setInterval(globalUpdate, 250)` handles ad skipping, quality forcing, autoplay, and unmuting.
- **Background idle pauses** — Synthetic `mousemove` events dispatched on page transitions prevent YouTube from detecting inactivity.

---

## [v1.0.0] - 2026-06-14/15

### Added
- **Initial release** — Native macOS menu bar utility using Swift + WKWebView.
- **Visibility spoofing** — `visibilityState = 'visible'` override prevents playback throttling when WebView is parked offscreen.
- **Layout deflation** — CSS injection strips comments, chats, promotions, related feeds, and Shorts.
- **Ad skipper** — 16x playback speed, mute, seek-to-end, and skip button click on detected pre-roll/mid-roll ads.
- **Right-click menu** — Show/hide player, reload home, clear data, quit.
