---
version: alpha
name: "StowPaste"
description: "A macOS clipboard utility whose homepage turns scattered clipboard fragments into an ordered field through WebGL."
colors:
  field: "#655DFF"
  paper: "#F7F7F1"
  ink: "#17181C"
  signal: "#FF6846"
  mint: "#9FF5E0"
  utility-canvas: "#D5D9DF"
typography:
  sans:
    fontFamily: "-apple-system, BlinkMacSystemFont, 'Helvetica Neue', Arial, sans-serif"
  mono:
    fontFamily: "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace"
rounded:
  DEFAULT: "0.75rem"
  sm: "0.375rem"
  md: "0.75rem"
  lg: "1.25rem"
spacing:
  section-gap: "2rem"
  page-max: "none"
components:
  button: { }
  paper-fragment: { }
  download-label: { }
  keycap: { }
---

# StowPaste Design System

## Overview

### Creative North Star

The homepage is a living clipboard field. GPU-rendered paper fragments containing text, images, links, files, colors, code, and masked passwords drift through a saturated violet space. Hovering or focusing the download action makes every fragment snap into a strict archive grid: StowPaste turns clipboard disorder into retrieval. Guide and privacy routes retain the quieter macOS utility workspace.

### Product context and register

- **Audience and primary job:** Mac users who repeatedly reuse copied text, images, and files and need to understand and download StowPaste quickly.
- **Target market(s) and evidence:** General macOS users; the product targets macOS 14 or later and currently publishes English website content.
- **Locale(s) and language policy:** English website UI; product UI supports Chinese and English independently.
- **Usage scene:** Desktop-first download decision, with a complete narrow mobile layout for discovery and installation handoff.
- **Register:** Expressive WebGL brand homepage paired with restrained product-like guide and privacy routes.
- **Memorable signature:** Scattered clipboard papers physically organize themselves around the fixed download label when the pointer or keyboard reaches it.
- **Restraint:** The WebGL field is the one visual spectacle. The central paper label, navigation, and download action remain flat, direct, and readable; no additional decorative effects compete with the paper movement.
- **Anti-references:** No dark gradient SaaS hero, floating glass product mockup, repeated eyebrow labels, four-card feature grid, giant centered slogan, warm editorial serif, or acid-accent startup landing page.
- **Token ownership/runtime mapping:** `packages/website/app/globals.css` is the canonical runtime token source. Route-scoped `.paper-site` variables own the expressive homepage palette; root variables and `packages/website/tailwind.config.ts` continue to own/adapt the quieter guide and privacy palette. This file records both roles without making Tailwind a second source for homepage values.

## Colors

The homepage uses one saturated field (`#655DFF`), warm printer paper (`#F7F7F1`), black graphite, a coral registration mark, and mint for the download arrow. There are no gradients, glows, or translucent glass surfaces. Guide and privacy routes keep their existing cool-gray utility palette. Focus uses a high-contrast outline; forced-colors mode defers to the system.

## Typography

The central label uses a condensed system display stack (`Avenir Next Condensed`, `Arial Narrow`) in deliberately compressed uppercase lines, recalling industrial label printers rather than editorial or SaaS typography. System sans handles prose and controls. The mono stack carries paper metadata, shortcuts, versions, and operational captions. No remote fonts are loaded.

## Layout

The homepage owns the full viewport. A fixed top title bar and bottom status rail frame a GPU canvas; a single paper label stays centered over the field. The lower-left shortcut remains as the one corner control, while Guide, Privacy, the live GitHub star count, and Download stay in the title bar. Below 760px the label fills most of the width, text-only navigation collapses, and the WebGL particle count drops. Guide and privacy routes retain the established sidebar/content layout.

## Elevation & Depth

Homepage depth comes from WebGL particle scale, z-order, roll, pitch, yaw, shader lighting, and restrained vertex bending. Every fragment is fully opaque. Paper material combines a warm uncoated stock base, directional fibers, stochastic grain, two low-contrast fold lines, and edge compression; it must never read as translucent glass or a flat UI card. UI labels use hard offset shadows like stacked paper or print registration, never blurred ambient glows. Utility routes retain the single soft workspace shadow.

## Shapes

Homepage paper and actions are rectangular with 0–2px radius and hard black outlines. This printer-label geometry is intentionally separate from the softer utility-route workspace. Pills are not used on the homepage.

## Components

### Foundational visual states

Interactive elements have visible hover, pressed, and focus-visible states. Focus is never indicated by color alone. Disabled/busy states retain control geometry. Reduced-motion disables translation and scale effects.

### Buttons and actions

`Download DMG` is the unmistakable primary action in both the title bar and central label. The central action includes version and minimum macOS information, a mint download tile, a black field, and a coral offset shadow. Hover, keyboard focus, and touch also trigger the paper-organization state. The neighboring GitHub control is secondary and shows the repository's current public star count.

The release disclosure sits directly beneath the primary download action and states that the open-source build is not Apple-notarized before the user downloads it. A second-screen installation card explains dragging the app from the DMG to Applications and the one-app `Open Anyway` flow, publishes the checksum, and links the source and Apple guidance. It uses the same opaque paper, hard rules, mono metadata, and offset print shadow as the hero instead of introducing a generic warning banner or modal.

The release provides separate English and Chinese DMG Finder windows. The website selects the Chinese artifact when the browser's primary language starts with `zh`; every other language and the no-JavaScript fallback receive English. Each window positions the StowPaste app opposite the Applications shortcut with a direct drag arrow. The Chinese window embeds a real macOS Privacy & Security screenshot and preserves the highlighted `仍要打开` control. The English window presents the corresponding `Privacy & Security → Open Anyway` path in English.

### Navigation and data display

The WebGL paper fragments visibly encode the supported clipboard world: text, images, files, links, code, colors, and masked credentials. Feature content remains present as semantic screen-reader content on the homepage. Guide and privacy navigation remains text-based and direct.

### Forms and overlays

The marketing site has no product forms or overlays. Support remains a mail link. The page avoids browser-native dialogs.

### Iconography

Use the actual StowPaste application icon for identity. Utility symbols are text glyphs or simple CSS shapes with visible labels; icon-only navigation is avoided.

### Motion

Paper drift is continuous but slow, GPU-rendered, and non-interactive. Motion uses gravity, terminal velocity, per-sheet air resistance, lateral gusts, flutter torque, and independent pitch/yaw oscillation rather than uniform vertical translation. The orchestrated moment is the transition from scattered particles to an aligned archive grid when download receives hover or focus. Once aligned, the archive continues as a slow top-to-bottom conveyor: rows cross the lower boundary and wrap seamlessly to the top while retaining strict columns and spacing. Reduced-motion starts in a static ordered state and disables CSS transitions. The canvas is `aria-hidden` and never owns focus or pointer events.

## Content voice

Use direct product language: open, paste, favorite, pin, group, download. Do not describe removed capabilities, future promises, internal implementation, or edition names. Copy explains what the user can do now.

Distribution trust copy is factual and visible: distinguish ad-hoc app signing, a disk image without Developer ID signing, and missing Apple notarization without implying that open source alone guarantees safety. Lead users through drag-to-Applications installation, the per-app macOS exception, source review, and checksum verification; never recommend disabling Gatekeeper globally.

## Accessibility and stability

Target WCAG 2.2 AA. Use semantic headings, links, and navigation landmarks; visible focus; 44px minimum touch targets where practical; global visible scrollbars; stable icon/media dimensions; and responsive reflow without horizontal page scrolling at 320px.
