import type { Metadata, Viewport } from "next";
import "./globals.css";
import { site } from "@/lib/site";

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#655DFF"
};

export const metadata: Metadata = {
  metadataBase: new URL(site.url),
  title: {
    default: "StowPaste — clipboard history for macOS",
    template: "%s | StowPaste"
  },
  description: site.description,
  applicationName: site.name,
  keywords: [
    "StowPaste",
    "macOS clipboard manager",
    "clipboard history",
    "paste history",
    "clipboard groups",
    "Mac productivity app"
  ],
  authors: [{ name: "StowPaste" }],
  creator: "StowPaste",
  publisher: "StowPaste",
  icons: {
    icon: "/brand/stowpaste-icon.png",
    apple: "/brand/stowpaste-icon.png"
  },
  alternates: {
    canonical: "/"
  },
  openGraph: {
    type: "website",
    url: site.url,
    title: "StowPaste — clipboard history for macOS",
    description: site.description,
    siteName: site.name,
    images: [
      {
        url: "/opengraph-image",
        width: 1200,
        height: 630,
        alt: "StowPaste macOS clipboard companion"
      }
    ]
  },
  twitter: {
    card: "summary_large_image",
    title: "StowPaste — clipboard history for macOS",
    description: site.description,
    images: ["/opengraph-image"]
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-image-preview": "large",
      "max-snippet": -1,
      "max-video-preview": -1
    }
  }
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
