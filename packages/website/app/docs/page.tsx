import type { Metadata } from "next";
import Link from "next/link";
import { ClipboardSidebar } from "@/components/clipboard-sidebar";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { docs, site } from "@/lib/site";

export const metadata: Metadata = {
  title: "StowPaste guide",
  description: "How to install, open, use, and personalize StowPaste on macOS.",
  alternates: { canonical: "/docs" },
  openGraph: {
    title: "StowPaste guide",
    description: "How to install, open, use, and personalize StowPaste on macOS.",
    url: `${site.url}/docs`
  }
};

const sections = [
  {
    title: "Install and authorize",
    body:
      "Download the PKG and open it on a Mac running macOS 14 or later. StowPaste lives in the menu bar, so it does not add a Dock icon. The first time you use the global shortcut, macOS asks for Accessibility permission.",
    bullets: [
      "Open System Settings → Privacy & Security → Accessibility.",
      "Turn on StowPaste, then return to the app.",
      "Keep the same installed app when updating to avoid a new authorization prompt."
    ]
  },
  {
    title: "Open and paste",
    body:
      "The default shortcut is two presses of the left Command key (⌘⌘). The panel opens near the focused insertion point when possible, or near the pointer when there is no text field. Select an item with the keyboard or mouse to paste it into the active app.",
    bullets: [
      "The first five visible items have ⌘1–⌘5 shortcuts.",
      "Press the opening shortcut again to paste the current clipboard item quickly.",
      "Drag the panel to move it and use its resize handle to change its size."
    ]
  },
  {
    title: "Organize history",
    body:
      "Text, images, and files are kept in one local history with tabs for each type and for favorites. Use the row actions to paste, favorite, pin, rename, or delete. Drag items into a custom group or reorder favorites to make a personal shelf.",
    bullets: [
      "Images appear in their own Images tab for quick scanning.",
      "Create groups with a name and icon, then reorder or edit them later.",
      "Pinned and favorited items are protected from automatic retention cleanup."
    ]
  },
  {
    title: "Themes and retention",
    body:
      "Choose System, Light, Dark, or a local custom theme in Settings. Custom theme prompts are handled on your Mac and produce a set of color options you can preview and save. You can also choose how long ordinary history is kept, from one week to unlimited.",
    bullets: [
      "Custom themes can be deleted or switched without changing your history.",
      "Retention options include week, month, quarter, half-year, year, three years, and unlimited.",
      "Enable Launch at Login when you want the menu bar utility available after signing in."
    ]
  }
];

export default function DocsPage() {
  return (
    <main className="site-page">
      <div className="clipboard-shell doc-shell">
        <SiteHeader />
        <div className="workspace">
          <ClipboardSidebar />
          <div className="doc-content">
            <div className="content-toolbar">
              <h1>StowPaste guide</h1>
              <div className="toolbar-meta"><span>{site.versionTag}</span><span>4 topics</span></div>
            </div>
            <section className="doc-intro">
              <span className="type-label">GUIDE</span>
              <h1>Using StowPaste</h1>
              <p>Installation, permissions, panel behavior, history organization, themes, and retention.</p>
            </section>
            {sections.map((section, index) => (
              <article className="doc-row" id={docs[index]?.slug} key={section.title}>
                <div>
                  <span className="type-label">TOPIC 0{index + 1}</span>
                  <h2>{section.title}</h2>
                </div>
                <div>
                  <p>{section.body}</p>
                  <ul>
                    {section.bullets.map((bullet) => <li key={bullet}>{bullet}</li>)}
                  </ul>
                </div>
              </article>
            ))}
            <div className="doc-actions">
              <a className="download-button" href={site.downloadUrl}>Download {site.versionTag}</a>
              <Link className="secondary-button" href={site.privacyUrl}>Read privacy details</Link>
            </div>
            <SiteFooter />
          </div>
        </div>
      </div>
    </main>
  );
}
