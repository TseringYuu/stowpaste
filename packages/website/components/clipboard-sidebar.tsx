import Link from "next/link";

const tabs = [
  { href: "/#all", icon: "▦", label: "All", count: "07", active: true },
  { href: "/#features", icon: "Aa", label: "Text", count: "04" },
  { href: "/#detail-image", icon: "▧", label: "Images", count: "01" },
  { href: "/#download", icon: "↗", label: "Files", count: "01" },
  { href: "/#detail-file", icon: "★", label: "Favorites", count: "02" }
];

export function ClipboardSidebar() {
  return (
    <aside className="sidebar" aria-label="Clipboard categories">
      <div className="sidebar-inner">
        <p className="sidebar-heading">Clipboard</p>
        <nav className="tab-list">
          {tabs.map((tab) => (
            <Link className={`sidebar-tab ${tab.active ? "active" : ""}`} href={tab.href} key={tab.label}>
              <span className="sidebar-icon" aria-hidden="true">{tab.icon}</span>
              <span>{tab.label}</span>
              <span className="tab-count">{tab.count}</span>
            </Link>
          ))}
        </nav>
        <div className="sidebar-divider" />
        <p className="sidebar-heading">Custom group</p>
        <Link className="sidebar-tab" href="/#workflow">
          <span className="sidebar-icon" aria-hidden="true">◇</span>
          <span>Daily work</span>
          <span className="tab-count">03</span>
        </Link>
        <div className="sidebar-divider" />
        <p className="sidebar-note">StowPaste stays in the menu bar and opens over the app you are already using.</p>
      </div>
    </aside>
  );
}
