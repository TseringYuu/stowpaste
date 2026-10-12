export const site = {
  name: "StowPaste",
  url: process.env.NEXT_PUBLIC_SITE_URL ?? "https://stowpaste.aiware.store",
  description:
    "StowPaste is a quiet macOS menu bar utility for keeping text, images, and files ready to paste.",
  version: "0.1.3",
  versionTag: "v0.1.3",
  minimumSystemVersion: "macOS 14 or later",
  architecture: "Apple silicon + Intel",
  downloadUrl: "/downloads/StowPaste-v0.1.3.dmg?build=0a804ad5",
  downloadUrlZhCN: "/downloads/StowPaste-v0.1.3-zh-CN.dmg?build=fa6f05cd",
  checksumUrl: "/downloads/StowPaste-v0.1.3.dmg.sha256",
  checksumUrlZhCN: "/downloads/StowPaste-v0.1.3-zh-CN.dmg.sha256",
  checksumSha256: "0a804ad5fa08cde2215847afaab87fec1836b9c08bfe5f5346650792724f8e9c",
  checksumSha256ZhCN: "fa6f05cd9e1c2185ee1720c3c0a4449ff979114a127268749a09775ad58d6ec5",
  privacyUrl: "/privacy",
  docsUrl: "/docs",
  githubUrl: "https://github.com/TseringYuu/stowpaste",
  githubStarsUrl: "https://img.shields.io/github/stars/TseringYuu/stowpaste.json",
  appleOpenAnywayUrl: "https://support.apple.com/102445",
  githubStarsFallback: 10,
  supportEmail: process.env.NEXT_PUBLIC_SUPPORT_EMAIL ?? "support@aiware.store"
};

export const features = [
  {
    id: "shortcut",
    kind: "text",
    label: "⌘⌘",
    source: "StowPaste Help",
    age: "just now",
    title: "Open with two taps of Command",
    text: "Press the left Command key twice to call StowPaste from the app you are using. Record another shortcut in Settings whenever you want."
  },
  {
    id: "image",
    kind: "image",
    label: "MEDIA",
    source: "Preview",
    age: "2 min",
    title: "Text, images, and files",
    text: "Press Space or use the preview button to view an original image. Press Space or Escape to return. Images have their own tab, and files keep their names and locations."
  },
  {
    id: "file",
    kind: "file",
    label: "GROUP",
    source: "Finder",
    age: "8 min",
    title: "Favorites, pins, and groups",
    text: "Favorite, rename, pin, and drag items into custom groups. Press Backspace to delete the selected record, then continue from its neighbor. Reorder favorites and groups around the way you already work."
  },
  {
    id: "theme",
    kind: "theme",
    label: "THEME",
    source: "StowPaste",
    age: "saved",
    title: "Your own appearance",
    text: "Use the system appearance or create a local color theme, choose a history retention window, and launch StowPaste at login."
  }
];

export const docs = [
  {
    slug: "install-authorize",
    title: "Install and authorize",
    summary: "Install from the disk image, grant Accessibility permission, and keep the menu bar utility ready."
  },
  {
    slug: "paste-panel",
    title: "Open and paste",
    summary: "Use the global shortcut, navigate the panel, and paste back into the app that has focus."
  },
  {
    slug: "organize-history",
    title: "Organize history",
    summary: "Use tabs, favorites, custom groups, titles, drag-and-drop, and pinning to keep useful items close."
  },
  {
    slug: "themes-and-retention",
    title: "Themes and retention",
    summary: "Choose an appearance, generate a local color theme, and decide how long ordinary history stays."
  }
];
