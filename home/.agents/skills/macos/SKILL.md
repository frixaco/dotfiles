---
name: macos
description: "Native macOS app development help: xcodebuild verification, SwiftUI/AppKit patterns, menu bar apps, panels/windows, Settings windows, Dynamic Island-style notch UI, Sparkle auto-updates, DMG/notarization releases, appcast updates, and GitHub releases."
---

# macOS

Use this skill for native macOS app work. Prefer the existing project style and verify builds with `xcodebuild` when code changes affect compilation.

## Pick The Mode

- Build or compile fixes: read `references/build/guide.md`.
- Native app patterns: read `references/patterns/guide.md` for menu bar apps, panels/windows, activation policy, file pickers, pasteboard, drag/drop, launch at login, Quick Look, ScreenCaptureKit, keyboard shortcuts, and UserDefaults.
- Settings/preferences UI: read `references/settings-ui/guide.md` and reuse Swift files in `references/settings-ui/`.
- Notch/Dynamic Island-style UI: read `references/notch-ui/guide.md` and reuse Swift files in `references/notch-ui/`.
- Sparkle auto-update setup: read `references/auto-update/guide.md` and reuse `references/auto-update/UpdaterManager.swift`.
- Release pipeline: read `references/release/guide.md`; use the Go helper under `cli/release/` only after checking project-specific prerequisites.

## Rules

- Treat macOS window levels, activation policy, focus, screen geometry, sandboxing, and entitlement behavior as platform constraints, not web-style layering.
- Preserve signing, bundle identifier, team ID, entitlements, and appcast settings unless the user explicitly asks to change them.
- For release/notarization tasks, state any missing credentials or Apple/GitHub prerequisites instead of guessing.
- For UI work, match native macOS patterns before inventing custom controls.
