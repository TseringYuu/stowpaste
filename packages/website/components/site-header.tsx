import Link from "next/link";
import Image from "next/image";
import { GitHubLink } from "@/components/github-link";
import { site } from "@/lib/site";

export function SiteHeader() {
  return (
    <header className="titlebar">
      <div className="window-dots" aria-hidden="true">
        <span />
        <span />
        <span />
      </div>

      <Link className="brand" href="/" aria-label="StowPaste home">
        <Image src="/brand/stowpaste-icon.png" width="36" height="36" alt="" priority />
        <span>StowPaste</span>
      </Link>

      <span className="titlebar-status mono">clipboard ready</span>

      <nav className="titlebar-nav" aria-label="Main navigation">
        <Link href={site.docsUrl}>Guide</Link>
        <Link href={site.privacyUrl}>Privacy</Link>
        <GitHubLink />
        <a className="header-download js-organize-trigger" href={site.downloadUrl}>
          <span>Download PKG</span>
          <small>{site.versionTag}</small>
          <b aria-hidden="true">↓</b>
        </a>
      </nav>
    </header>
  );
}
