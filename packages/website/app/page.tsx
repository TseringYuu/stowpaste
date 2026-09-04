import Image from "next/image";
import Script from "next/script";
import { InstallGuide } from "@/components/install-guide";
import { SeoJsonLd } from "@/components/seo-json-ld";
import { SiteHeader } from "@/components/site-header";
import { features, site } from "@/lib/site";

export default function HomePage() {
  return (
    <main className="paper-site">
      <SeoJsonLd />
      <Script src="/paper-field.js" strategy="afterInteractive" />
      <div className="paper-stage">
        <canvas className="paper-field" data-paper-field aria-hidden="true" />

        <div className="paper-interface">
          <SiteHeader />

          <section className="paper-hero" aria-labelledby="hero-title">
            <div className="edge-note edge-note-left" aria-hidden="true">TEXT · IMAGE · FILE · PASSWORD · LINK</div>
            <div className="edge-note edge-note-right" aria-hidden="true">STORED LOCALLY / READY TO PASTE</div>

            <div className="hero-label-card">
              <div className="label-card-topline">
                <span className="label-card-brand">
                  <Image src="/brand/stowpaste-icon.png" width="62" height="62" alt="" priority />
                  <span><strong>STOWPASTE</strong><small>CLIPBOARD MEMORY</small></span>
                </span>
                <span>macOS / READY</span>
              </div>
              <h1 id="hero-title">Copied.<br />Copied over.<br /><em>Not gone.</em></h1>
              <p>
                StowPaste keeps recent text, images, and files within reach.
                Press Command twice, choose an earlier copy, and paste it back.
              </p>

              <a className="download-cta js-organize-trigger" href={site.downloadUrl}>
                <span className="download-cta-copy">
                  <strong>Download PKG</strong>
                  <small>{site.versionTag} · {site.minimumSystemVersion}</small>
                </span>
                <span className="download-cta-arrow" aria-hidden="true">↓</span>
              </a>
              <div className="release-disclosure" role="note">
                <span><b aria-hidden="true">!</b> OPEN SOURCE BUILD</span>
                <small>Not Apple-notarized.</small>
                <a href="#install">First-open guide ↓</a>
              </div>
              <span className="organize-hint"><i aria-hidden="true" /> Hover to organize the clipboard</span>
            </div>

            <div className="command-sequence" aria-label="Press Command twice to open StowPaste">
              <span>OPEN ANYWHERE</span>
              <kbd>⌘</kbd>
              <kbd>⌘</kbd>
            </div>

            <section className="sr-only" aria-label="StowPaste features">
              <h2>What StowPaste does</h2>
              <ul>
                {features.map((feature) => <li key={feature.id}><strong>{feature.title}.</strong> {feature.text}</li>)}
              </ul>
              <p>Clipboard history, images, files, groups, favorites, settings, and custom themes are stored locally. No account is required.</p>
            </section>
          </section>

          <footer className="paper-footer">
            <span>© 2026 StowPaste</span>
            <span>{site.architecture}</span>
            <span>Move over the download button to tidy the field</span>
          </footer>
        </div>
      </div>

      <InstallGuide />
    </main>
  );
}
