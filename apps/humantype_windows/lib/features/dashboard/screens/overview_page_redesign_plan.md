# HumanType Desktop — OverviewPage Complete Redesign Plan
> For AI Agent Implementation · Production-Grade · Premium Modern UI

---

## 🎯 Vision Statement

Strip away every Windows-era pattern. Rebuild the Overview page as a **dark, cinematic dashboard** — think Linear.app meets Vercel's dashboard meets a luxury fintech app. Deep blacks, razor-sharp typography, glowing accent halos, glass-morphism cards, fluid micro-animations, and a floating pill nav at the bottom instead of any sidebar.

The result should feel like a tool a senior engineer at a SF startup would be proud to ship.

---

## 🏗️ Structural Changes (What to Remove / Add)

### ❌ Remove Completely
- `ScaffoldPage.scrollable` (Windows-style scaffold — gone)
- `PageHeader` widget (old header chrome — gone)
- All sidebar navigation references
- `FluentIcons` used purely for decoration (keep only where semantically needed)
- `Button` widget wrapping tiles (replace with custom GestureDetector + AnimatedContainer)
- `GridView.count` with fixed `childAspectRatio` (replace with responsive layout)
- All `.withOpacity(0.1/.2/.05)` grey backgrounds (lazy theming — gone)
- `Colors.grey` backgrounds on disconnected state (replace with intentional dark tone)

### ✅ Add / Replace With
- Custom full-screen `Stack`-based layout with no scaffold chrome
- Floating bottom nav pill (frosted glass, animated active indicator)
- Animated hero section with pulsing connection orb + glow ring
- Bento-grid feature cards (asymmetric, varying sizes)
- Animated status bar with live pulse dots
- Background: deep noise texture + subtle radial gradient mesh
- Staggered entry animations via `AnimationController` + `SlideTransition` + `FadeTransition`
- `BackdropFilter` blur on cards (glassmorphism)
- Custom font: `GoogleFonts.syne` for headings, `GoogleFonts.ibmPlexMono` for stats/labels
- Micro-interaction: hover scale + glow on feature cards
- Live-feel: animated connection status with shimmer when connecting

---

## 🎨 Design System

### Color Palette (Dark Theme Only)
```dart
// Background layers
static const bgBase     = Color(0xFF080A0F);   // near-black with blue tint
static const bgSurface  = Color(0xFF0D1017);   // card base
static const bgElevated = Color(0xFF131820);   // elevated card

// Accent / Brand
static const accentCyan   = Color(0xFF00D9FF);  // primary glow
static const accentViolet = Color(0xFF7C3AED);  // secondary
static const accentGreen  = Color(0xFF00FF88);  // connected / ok status

// Text
static const textPrimary   = Color(0xFFF0F4FF);
static const textSecondary = Color(0xFF6B7A99);
static const textMuted     = Color(0xFF2E3A50);

// Feature tile accent colors (replace flat Colors.x)
static const tileVault    = Color(0xFF3B82F6); // blue
static const tileScratch  = Color(0xFFF59E0B); // amber
static const tileFiles    = Color(0xFF14B8A6); // teal
static const tileClipboard= Color(0xFF8B5CF6); // violet
static const tileNotif    = Color(0xFF10B981); // emerald
static const tileHUD      = Color(0xFFEF4444); // red
```

### Typography
```dart
// Import in pubspec.yaml:
// google_fonts: ^6.x

// Usage:
GoogleFonts.syne(
  fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary,
  letterSpacing: -1.2,
)  // — Hero heading, section titles

GoogleFonts.ibmPlexMono(
  fontSize: 11, fontWeight: FontWeight.w500, color: accentCyan,
  letterSpacing: 2.0,
)  // — Status labels, latency readouts, badge text

GoogleFonts.dmSans(
  fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary,
)  // — Body, subtitles, card descriptions
```

### Spacing / Radius
```dart
const double radiusCard   = 20.0;
const double radiusSmall  = 12.0;
const double radiusPill   = 100.0;  // nav pill
const double gapSection   = 28.0;
const double gapCard      = 14.0;
const double paddingPage  = 24.0;
```

---

## 📐 Layout Architecture

```
┌─────────────────────────────────────┐
│  BACKGROUND LAYER                   │
│  (noise texture + radial gradient)  │
│                                     │
│  ┌─── HERO CARD ─────────────────┐  │
│  │  Orb + Glow Ring  Device Name │  │
│  │  Connection state + uptime    │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌─── BENTO GRID ────────────────┐  │
│  │  [Vault - WIDE]  [Scratch]    │  │
│  │  [Files] [Clip]  [Notif-WIDE] │  │
│  │  [HUD - FULL WIDTH]           │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌─── PROTOCOL STATUS ───────────┐  │
│  │  WebSocket ●  Latency <20ms   │  │
│  └───────────────────────────────┘  │
│                                     │
│  ════ FLOATING BOTTOM NAV PILL ════ │
└─────────────────────────────────────┘
```

### Bento Grid Sizing
Use a `Wrap` or custom `Row/Column` nesting — NOT `GridView.count`:
```
Row 1: Vault (flex:2, tall)  |  Scratchpad (flex:1)
                              |  File Transfer (flex:1)
Row 2: Clipboard (flex:1)    |  Notifications (flex:2, tall)
Row 3: Launch HUD (full width, short strip)
```

---

## 🧩 Component Breakdown

### 1. `_NoiseBackground` Widget
```
- Stack with:
  - Container(color: bgBase)
  - Positioned radial gradient (top-right, cyan 0.06 opacity, 500px radius)
  - Positioned radial gradient (bottom-left, violet 0.04 opacity, 400px radius)
  - Shader-based noise overlay OR a static low-opacity PNG noise asset
  - (Optional) AnimatedBuilder rotating a very subtle conic gradient slowly
```

### 2. `_HeroStatusCard` Widget
```
- Full-width Container, height: 200, radius: 20
- Background: bgElevated with 1px border Color(0xFF1E2A3A)
- Left side:
  - Small monospace label: "CONNECTION STATUS" (accentCyan, letter-spacing)
  - Large Syne heading: device name OR "Scanning..."
  - Row: animated green/amber dot + status text + uptime counter
- Right side:
  - The CONNECTION ORB:
    - AnimatedBuilder with sine-wave pulse
    - Outer glow ring (BoxDecoration, blurRadius 40, accentCyan 0.3 opacity)
    - Middle ring (blurRadius 20)
    - Inner solid circle with icon
    - When disconnected: amber color, slower pulse
    - When connected: cyan color, faster confident pulse
- Bottom strip: thin gradient bar animating left-to-right when connecting
```

### 3. `_BentoCard` Widget (reusable)
```
Parameters: icon, title, subtitle, color, onTap, isWide, isTall

- GestureDetector wrapping AnimatedContainer
- Background: bgElevated
- Border: 1px Color(0xFF1A2333)
- On hover (MouseRegion):
  - Border color transitions to tile color (0.4 opacity)
  - Slight scale: 1.0 → 1.02 (AnimatedScale)
  - Glow shadow: BoxShadow(color: tileColor.withOpacity(0.15), blurRadius: 20)
- Icon container:
  - Background: tileColor.withOpacity(0.1)
  - Icon: tileColor
  - Subtle icon glow via BoxShadow
- Title: DM Sans bold, textPrimary
- Subtitle: IBM Plex Mono, 10px, textSecondary
- Top-right corner badge for HUD tile: "OVERLAY" in a red pill badge
- Arrow icon (top-right): appears on hover only, fade in
```

### 4. `_ProtocolStatusPanel` Widget
```
- Container with bgElevated, radius 20, 1px border
- Header: "SYSTEM DIAGNOSTICS" in monospace label style
- Two stat rows:
  - Each row: Label | AnimatedDot | Value
  - AnimatedDot: if ok → pulse green. if not → slow amber blink
  - Latency value: typed-on animation (character-by-character) when connected
- Bottom: thin progress bar showing "signal strength" (decorative, always 87%)
```

### 5. `_FloatingBottomNav` Widget
```
- Positioned at bottom, centered horizontally
- Padding: bottom 20px from screen edge
- Container:
  - Width: auto (sized to content)
  - Height: 64px
  - Decoration:
    - color: bgElevated.withOpacity(0.85)
    - BackdropFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20)
    - borderRadius: BorderRadius.circular(100) — full pill
    - Border: 1px Color(0xFF1E2A3A)
    - BoxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: Offset(0,10)),
        BoxShadow(color: accentCyan.withOpacity(0.06), blurRadius: 20),
      ]
- Nav items: Overview, Vault, Notes, Files, Clipboard, Notifications
- Each item: Icon + optional label (label only on active)
- Active indicator:
  - AnimatedPositioned sliding pill background under active item
  - Color: accentCyan.withOpacity(0.12), border: 1px accentCyan.withOpacity(0.3)
- Active icon: accentCyan color
- Inactive icon: textSecondary color
- Tap: scale bounce animation (ScaleTransition 1.0 → 0.9 → 1.05 → 1.0)
- On navigation: smooth AnimatedPositioned slide to new tab position
```

---

## 🎬 Animation Plan

### Entry Animations (Page Load)
Use `AnimationController(vsync: this, duration: 800ms)` with stagger:

```
0ms   → Background fades in (FadeTransition)
100ms → Hero card slides up from +30px + fades in
300ms → Bento cards stagger in (each 60ms apart, slide from +20px)
600ms → Protocol panel fades in
700ms → Bottom nav slides up from +40px
```

Use `CurvedAnimation(curve: Curves.easeOutCubic)` for all.

### Continuous Animations
- **Connection orb pulse**: `AnimationController(duration: 2s, repeat: true)` → `sin` wave scale 0.95–1.05 + opacity 0.6–1.0 on glow ring
- **Connecting shimmer**: When `!isConnected` → shimmer sweep across hero card using `LinearGradient` animated position
- **Status dot pulse**: Green dot breathes with 3s loop
- **Background gradient**: Very slow rotation (30s loop), barely perceptible

### Micro-interactions
- Card hover: `MouseRegion` → `AnimatedContainer` (200ms ease) border glow + scale
- Nav tap: quick scale bounce via `TweenAnimationBuilder`
- Feature tile tap: ripple + brief scale-down + navigate
- HUD tile tap: special — brief screen flash (white 5% overlay, 150ms fade) then navigate

---

## 📦 Dependencies to Add

```yaml
# pubspec.yaml additions:
dependencies:
  google_fonts: ^6.2.1        # Syne + IBM Plex Mono + DM Sans
  flutter_animate: ^4.5.0     # Stagger animations made easy
  shimmer: ^3.0.0             # Shimmer effect for connecting state
  # (already have) flutter_riverpod, go_router, fluent_ui
```

> **Note**: `flutter_animate` is highly recommended — it drastically simplifies stagger chains with `.animate().fadeIn().slideY()` chaining syntax and works with Riverpod perfectly.

---

## 🔧 Implementation Steps for AI Agent

Follow this exact order:

### Step 1 — Setup
1. Add `google_fonts`, `flutter_animate` to `pubspec.yaml`
2. Create `/lib/core/theme/ht_colors.dart` — all color constants
3. Create `/lib/core/theme/ht_typography.dart` — all text style getters
4. Run `flutter pub get`

### Step 2 — Bottom Nav
1. Create `/lib/features/shell/widgets/floating_bottom_nav.dart`
2. Implement `_FloatingBottomNav` as `StatefulWidget` with `AnimatedPositioned` pill
3. Replace existing shell/navigation widget reference with this
4. Remove all sidebar/NavigationView references from the shell

### Step 3 — Background
1. Create `/lib/features/overview/widgets/noise_background.dart`
2. Implement `_NoiseBackground` with gradient layers
3. (Optional) Add `assets/noise.png` (512x512 tileable monochrome noise at 3% opacity)
4. Register asset in `pubspec.yaml` if using PNG approach

### Step 4 — Hero Card
1. Create `/lib/features/overview/widgets/hero_status_card.dart`
2. Implement `_HeroStatusCard` with `AnimationController` for orb pulse
3. Implement connecting shimmer with `flutter_animate`'s `.shimmer()` effect

### Step 5 — Bento Cards
1. Create `/lib/features/overview/widgets/bento_card.dart`
2. Implement `_BentoCard` with `MouseRegion` hover state
3. Use `AnimatedContainer` for smooth hover transitions

### Step 6 — Protocol Status
1. Create `/lib/features/overview/widgets/protocol_status_panel.dart`
2. Implement with animated dots and monospace readouts

### Step 7 — Assemble OverviewPage
1. Refactor `overview_page.dart` completely:
   - Replace `ScaffoldPage.scrollable` with plain `Scaffold(body: Stack(...))`
   - Use `SingleChildScrollView` inside with `paddingPage` on all sides
   - Add `_NoiseBackground` as bottom Stack layer
   - Compose sections with stagger via `flutter_animate`
   - Add `_FloatingBottomNav` as `Positioned(bottom: 0)` in Stack

### Step 8 — Polish
1. Test all hover states on Windows desktop
2. Verify `BackdropFilter` performance (wrap in `RepaintBoundary` if needed)
3. Add `Tooltip` to all nav icons
4. Ensure dark theme consistency — no hard-coded white or light colors

---

## 💡 Premium UX Details (Extra Credit)

These small details make it feel production-grade:

| Detail | Implementation |
|--------|---------------|
| Time since connected | Show "Connected 4m 32s ago" with a live ticker (Timer.periodic 1s) |
| Keyboard shortcut hints | Show `⌘1`, `⌘2` etc. on nav items on hover |
| Device battery indicator | If `bridge.androidBatteryLevel` exists, show tiny battery icon in hero |
| Drag-to-reorder tiles | Long-press on bento cards activates drag mode |
| Empty state polish | When disconnected, show a subtle scan-line animation on the orb |
| Sound design hook | On connection established, trigger a very subtle system sound |
| Accessibility | Ensure all interactive elements have `Semantics` labels |
| Window drag region | Make hero card top area a `MoveWindow()` drag region |

---

## 📁 Final File Structure

```
lib/features/overview/
├── overview_page.dart              ← completely rewritten
└── widgets/
    ├── noise_background.dart       ← new
    ├── hero_status_card.dart       ← new
    ├── bento_card.dart             ← new
    └── protocol_status_panel.dart  ← new

lib/features/shell/
└── widgets/
    └── floating_bottom_nav.dart    ← new (replaces sidebar)

lib/core/theme/
├── ht_colors.dart                  ← new
└── ht_typography.dart              ← new
```

---

## ⚠️ Gotchas & Notes for Agent

1. **`BackdropFilter` on Windows Flutter**: Works but requires `flutter run` with `--enable-impeller` on Windows or ensure `FlutterWindow` has compositing enabled. Wrap in `try/catch` UI with fallback to solid color if needed.
2. **`fluent_ui` conflict**: Since we're largely bypassing `ScaffoldPage`/`NavigationView`, make sure the root widget still has `FluentApp` as ancestor for `FluentTheme.of(context)` to work. Keep `FluentTheme` data but use standard Flutter widgets for layout.
3. **`MouseRegion` hover**: Only works on desktop (Windows ✓). No change needed for mobile builds.
4. **`google_fonts` offline**: Fonts are bundled at build time. Run once with internet to cache, then works offline.
5. **Navigation**: Keep `go_router` routes unchanged — only the nav UI changes, not the routing logic.
6. **`RepaintBoundary`**: Wrap the animated orb and the bottom nav in `RepaintBoundary` to isolate repaints from the rest of the page.

---

*Plan generated for HumanType Desktop · OverviewPage Redesign · Premium Dark UI*
