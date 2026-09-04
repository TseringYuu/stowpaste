export const site = {
  name: "StowPaste",
  url: process.env.NEXT_PUBLIC_SITE_URL ?? "https://stowpaste.aiware.store",
  description:
    "StowPaste is a quiet macOS menu bar utility for keeping text, images, and files ready to paste.",
  version: "0.1.0",
  versionTag: "v0.1.0",
  minimumSystemVersion: "macOS 14 or later",
  architecture: "Apple silicon + Intel",
  downloadUrl: "/downloads/StowPaste-v0.1.0.dmg?build=2df30d38",
  downloadUrlZhCN: "/downloads/StowPaste-v0.1.0-zh-CN.dmg?build=802ab228",
  checksumUrl: "/downloads/StowPaste-v0.1.0.dmg.sha256",
  checksumUrlZhCN: "/downloads/StowPaste-v0.1.0-zh-CN.dmg.sha256",
  checksumSha256: "2df30d3840f6782ad1d0de1fd0798f1064cd3a87a097ccd4a6b36967711e3147",
  checksumSha256ZhCN: "802ab228f5dc24ad388af90a9ebf48b5d936a088ade3e9d636652dfbf3bb68bf",
  privacyUrl: "/privacy",
  docsUrl: "/docs",
  githubUrl: "https://github.com/TseringYuu/stowpaste",
  githubApiUrl: "https://api.github.com/repos/TseringYuu/stowpaste",
  appleOpenAnywayUrl: "https://support.apple.com/102445",
  githubStarsFallback: 0,
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
    text: "Recent images have previews and their own tab, while files retain names and locations instead of becoming anonymous text."
  },
  {
    id: "file",
    kind: "file",
    label: "GROUP",
    source: "Finder",
    age: "8 min",
    title: "Favorites, pins, and groups",
    text: "Favorite, rename, pin, delete, and drag items into custom groups. Reorder favorites and groups around the way you already work."
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
