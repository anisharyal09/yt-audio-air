# Updates

All notable changes to this project will be documented in this file.

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

## [v1.0.0] - 2026-06-15

### Added
- **Initial release** — Native macOS menu bar utility using Swift + WKWebView.
- **Visibility spoofing** — `visibilityState = 'visible'` override prevents playback throttling when WebView is parked offscreen.
- **Layout deflation** — CSS injection strips comments, chats, promotions, related feeds, and Shorts.
- **Ad skipper** — 16x playback speed, mute, seek-to-end, and skip button click on detected pre-roll/mid-roll ads.
- **Right-click menu** — Show/hide player, reload home, clear data, quit.
