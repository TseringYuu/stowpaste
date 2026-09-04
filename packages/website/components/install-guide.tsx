import { site } from "@/lib/site";

const steps = [
  {
    title: "Try the installer once",
    text: "Download the PKG and open it. macOS may say it cannot verify that the package is free of malware."
  },
  {
    title: "Open Privacy & Security",
    text: "In System Settings, choose Privacy & Security, then scroll down to the Security section."
  },
  {
    title: "Choose Open Anyway",
    text: "Confirm Open Anyway, authenticate with your Mac password, and return to the installer."
  }
];

export function InstallGuide() {
  return (
    <section className="install-guide" id="install" aria-labelledby="install-title">
      <div className="install-sheet">
        <div className="install-sheet-meta">
          <span>INSTALL RECEIPT / {site.versionTag}</span>
          <span>OPEN SOURCE / NOT NOTARIZED</span>
        </div>

        <div className="install-guide-layout">
          <div className="install-guide-intro">
            <span className="install-kicker">BEFORE YOU OPEN</span>
            <h2 id="install-title">macOS may stop the installer once.</h2>
            <p>
              StowPaste is independent open-source software and does not use a paid Apple Developer
              account. The app is ad-hoc signed; the PKG is not Developer ID signed or notarized by Apple.
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
            <code>{site.checksumSha256}</code>
          </div>
          <div className="install-guide-actions">
            <a className="install-download" href={site.downloadUrl}>Download PKG <span aria-hidden="true">↓</span></a>
            <a href={site.checksumUrl}>Checksum file</a>
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
