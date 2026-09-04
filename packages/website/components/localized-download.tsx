"use client";

import type { AnchorHTMLAttributes, ReactNode } from "react";
import { useEffect, useState } from "react";

type LocalizedDownloadLinkProps = Omit<AnchorHTMLAttributes<HTMLAnchorElement>, "href"> & {
  englishHref: string;
  chineseHref: string;
  children: ReactNode;
};

function browserPrefersChinese() {
  const language = navigator.languages?.[0] ?? navigator.language;
  return /^zh(?:-|$)/i.test(language);
}

export function LocalizedDownloadLink({
  englishHref,
  chineseHref,
  children,
  ...props
}: LocalizedDownloadLinkProps) {
  const [href, setHref] = useState(englishHref);

  useEffect(() => {
    if (browserPrefersChinese()) setHref(chineseHref);
  }, [chineseHref]);

  return <a {...props} href={href}>{children}</a>;
}

export function LocalizedChecksum({ english, chinese }: { english: string; chinese: string }) {
  const [checksum, setChecksum] = useState(english);

  useEffect(() => {
    if (browserPrefersChinese()) setChecksum(chinese);
  }, [chinese]);

  return <code>{checksum}</code>;
}
