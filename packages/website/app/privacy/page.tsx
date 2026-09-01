import type { Metadata } from "next";
import Link from "next/link";
import { ClipboardSidebar } from "@/components/clipboard-sidebar";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { site } from "@/lib/site";

export const metadata: Metadata = {
  title: "StowPaste privacy",
  description: "A practical overview of how StowPaste handles clipboard history and settings.",
  alternates: { canonical: "/privacy" }
};

const sections = [
  {
    title: "What stays on your Mac",
    body:
      "StowPaste stores clipboard text, image data, file URLs, groups, favorites, settings, and shortcut preferences locally so the panel can work when you need it."
  },
  {
    title: "Retention and deletion",
    body:
      "Choose a retention window in Settings, from one week to unlimited. You can delete individual entries or clear the full history. Favorites, pinned items, and items in custom groups are protected from automatic cleanup."
  },
  {
    title: "Custom themes",
    body:
      "When you ask for a custom theme, the prompt is processed locally to create color options. Theme prompts and previews are not sent to an external service."
  },
  {
    title: "Support messages",
    body:
      "If you email support, we receive the address and message you choose to send. We use that information to respond to you and diagnose the issue you reported."
  },
  {
    title: "Website and GitHub",
    body:
      "The website requests the public StowPaste repository record from GitHub to display its current star count. GitHub receives the normal network information associated with that browser request. The desktop app does not make this request."
  },
  {
    title: "Tracking",
    body:
      "StowPaste does not use third-party advertising identifiers, cross-app tracking, or behavioral advertising."
  }
];

export default function PrivacyPage() {
  return (
    <main className="site-page">
      <div className="clipboard-shell doc-shell">
        <SiteHeader />
        <div className="workspace">
          <ClipboardSidebar />
          <div className="doc-content">
            <div className="content-toolbar">
              <h1>Privacy</h1>
              <div className="toolbar-meta"><span>{site.versionTag}</span><span>local-first</span></div>
            </div>
            <section className="doc-intro">
              <span className="type-label">PRIVACY</span>
              <h1>Privacy in StowPaste</h1>
              <p>What remains on your Mac, how it is handled, and what happens when you contact support.</p>
            </section>
            {sections.map((section, index) => (
              <article className="doc-row" key={section.title}>
                <div>
                  <span className="type-label">NOTE {String(index + 1).padStart(2, "0")}</span>
                  <h2>{section.title}</h2>
                </div>
                <p>{section.body}</p>
              </article>
            ))}
            <div className="doc-actions">
              <Link className="secondary-button" href="/">Back to StowPaste</Link>
              <a className="download-button" href={`mailto:${site.supportEmail}`}>Contact support</a>
            </div>
            <SiteFooter />
          </div>
        </div>
      </div>
    </main>
  );
}
