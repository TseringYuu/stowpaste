import Link from "next/link";
import { site } from "@/lib/site";

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <span>© {new Date().getFullYear()} StowPaste · {site.versionTag}</span>
      <nav className="footer-links" aria-label="Footer navigation">
        <Link href={site.docsUrl}>Guide</Link>
        <Link href={site.privacyUrl}>Privacy</Link>
        <a href={`mailto:${site.supportEmail}`}>Support</a>
      </nav>
    </footer>
  );
}
