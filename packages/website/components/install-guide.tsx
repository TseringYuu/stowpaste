import { site } from "@/lib/site";
import { LocalizedChecksum, LocalizedDownloadLink } from "@/components/localized-download";

const steps = [
  {
    title: "Drag into Applications",
    text: "Open the DMG, then drag StowPaste onto the Applications shortcut."
  },
  {
    title: "Try opening StowPaste",
    text: "Launch it from Applications once. macOS may say it cannot verify the developer."
  },
  {
    title: "Choose Open Anyway",
    text: "In System Settings → Privacy & Security, choose Open Anyway for StowPaste and authenticate if prompted."
  }
];

export function InstallGuide() {
  return (
    <section className="install-guide" id="install" aria-labelledby="install-title">
      <div className="install-sheet">
        <div className="install-sheet-meta">
          <span>INSTALL CARD / {site.versionTag}</span>
          <span>OPEN SOURCE / NOT NOTARIZED</span>
        </div>

        <div className="install-guide-layout">
          <div className="install-guide-intro">
            <span className="install-kicker">BEFORE YOU OPEN</span>
            <h2 id="install-title">macOS may stop the app once.</h2>
            <p>
              StowPaste is independent open-source software and does not use a paid Apple Developer
              account. The app is ad-hoc signed; the app and DMG are not Developer ID signed or notarized by Apple.
            </p>
            <p className="install-trust-copy">
              Review the source and checksum before creating a one-app exception for StowPaste.
              Never disable Gatekeeper globally.
            </p>
          </div>

          <ol className="install-steps">
            {steps.map((step, index) => (
              <li className="install-step" key={step.title}>
                <span className="install-step-number" aria-hidden="true">0{index + 1}</span>
                <span><strong>{step.title}</strong><small>{step.text}</small></span>
              </li>
            ))}
          </ol>
        </div>

        <div className="integrity-ticket">
          <div className="checksum-block">
            <span>SHA-256 / {site.versionTag}</span>
            <LocalizedChecksum english={site.checksumSha256} chinese={site.checksumSha256ZhCN} />
          </div>
          <div className="install-guide-actions">
            <LocalizedDownloadLink
              className="install-download"
              englishHref={site.downloadUrl}
              chineseHref={site.downloadUrlZhCN}
            >Download DMG <span aria-hidden="true">↓</span></LocalizedDownloadLink>
            <LocalizedDownloadLink
              englishHref={site.checksumUrl}
              chineseHref={site.checksumUrlZhCN}
            >Checksum file</LocalizedDownloadLink>
            <a href={site.githubUrl} target="_blank" rel="noreferrer">Review source</a>
            <a href={site.appleOpenAnywayUrl} target="_blank" rel="noreferrer">Apple&apos;s guide</a>
          </div>
        </div>

        <p className="privacy-stamp" id="privacy">
          <strong>LOCAL DATA</strong>
          Clipboard history stays on this Mac. No account is required and clipboard content is not uploaded to an external service.
        </p>
      </div>
    </section>
  );
}
