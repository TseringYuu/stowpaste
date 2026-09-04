import Link from "next/link";
import Image from "next/image";
import { GitHubLink } from "@/components/github-link";
import { LocalizedDownloadLink } from "@/components/localized-download";
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
        <LocalizedDownloadLink
          className="header-download js-organize-trigger"
          englishHref={site.downloadUrl}
          chineseHref={site.downloadUrlZhCN}
        >
          <span>Download DMG</span>
          <small>{site.versionTag}</small>
          <b aria-hidden="true">↓</b>
        </LocalizedDownloadLink>
      </nav>
    </header>
  );
}
