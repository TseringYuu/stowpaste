import { site } from "@/lib/site";

export function SeoJsonLd() {
  const graph = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "SoftwareApplication",
        name: "StowPaste",
        applicationCategory: "ProductivityApplication",
        operatingSystem: "macOS 14 or later",
        description: site.description,
        url: site.url,
        codeRepository: site.githubUrl,
        downloadUrl: `${site.url}${site.downloadUrl}`,
        offers: {
          "@type": "Offer",
          price: "0",
          priceCurrency: "USD"
        }
      },
      {
        "@type": "Organization",
        name: "StowPaste",
        url: site.url,
        sameAs: [site.githubUrl]
      }
    ]
  };

  return (
    <script
      type="application/ld+json"
      suppressHydrationWarning
      dangerouslySetInnerHTML={{ __html: JSON.stringify(graph) }}
    />
  );
}
