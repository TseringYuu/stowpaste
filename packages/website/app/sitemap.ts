import type { MetadataRoute } from "next";
import { docs, site } from "@/lib/site";

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();
  return [
    {
      url: site.url,
      lastModified: now,
      changeFrequency: "weekly",
      priority: 1
    },
    {
      url: `${site.url}/docs`,
      lastModified: now,
      changeFrequency: "weekly",
      priority: 0.9
    },
    {
      url: `${site.url}/privacy`,
      lastModified: now,
      changeFrequency: "monthly",
      priority: 0.7
    },
    ...docs.map((doc) => ({
      url: `${site.url}/docs#${doc.slug}`,
      lastModified: now,
      changeFrequency: "monthly" as const,
      priority: 0.65
    }))
  ];
}
