"use client";

import { useEffect, useState } from "react";
import { site } from "@/lib/site";

const cacheKey = "stowpaste-github-stars";
const cacheLifetime = 10 * 60 * 1000;

function formatStars(value: number) {
  return new Intl.NumberFormat("en", {
    notation: value >= 1000 ? "compact" : "standard",
    maximumFractionDigits: 1
  }).format(value);
}

export function GitHubLink() {
  const [stars, setStars] = useState(site.githubStarsFallback);

  useEffect(() => {
    try {
      const cached = window.sessionStorage.getItem(cacheKey);
      if (cached) {
        const parsed = JSON.parse(cached) as { stars?: unknown; savedAt?: unknown };
        if (
          typeof parsed.stars === "number" &&
          typeof parsed.savedAt === "number" &&
          Date.now() - parsed.savedAt < cacheLifetime
        ) {
          setStars(parsed.stars);
          return;
        }
      }
    } catch {
      // A disabled storage API should not hide the repository link.
    }

    const controller = new AbortController();

    fetch(site.githubApiUrl, {
      headers: { Accept: "application/vnd.github+json" },
      signal: controller.signal
    })
      .then((response) => {
        if (!response.ok) throw new Error(`GitHub returned ${response.status}`);
        return response.json() as Promise<{ stargazers_count?: unknown }>;
      })
      .then((repository) => {
        if (typeof repository.stargazers_count !== "number") return;
        setStars(repository.stargazers_count);
        try {
          window.sessionStorage.setItem(
            cacheKey,
            JSON.stringify({ stars: repository.stargazers_count, savedAt: Date.now() })
          );
        } catch {
          // The fetched count remains visible even when storage is unavailable.
        }
      })
      .catch(() => undefined);

    return () => controller.abort();
  }, []);

  const count = formatStars(stars);

  return (
    <a
      className="github-link"
      href={site.githubUrl}
      target="_blank"
      rel="noreferrer"
      aria-label={`Open StowPaste on GitHub, ${stars} stars`}
    >
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path
          fill="currentColor"
          d="M12 .7a11.5 11.5 0 0 0-3.64 22.41c.58.1.79-.25.79-.56v-2.24c-3.22.7-3.9-1.36-3.9-1.36-.52-1.34-1.28-1.7-1.28-1.7-1.05-.72.08-.7.08-.7 1.16.08 1.77 1.19 1.77 1.19 1.03 1.77 2.7 1.26 3.36.97.1-.75.4-1.26.73-1.55-2.57-.29-5.27-1.28-5.27-5.68 0-1.26.45-2.28 1.19-3.09-.12-.29-.52-1.46.11-3.05 0 0 .97-.31 3.16 1.18a10.95 10.95 0 0 1 5.76 0c2.2-1.49 3.16-1.18 3.16-1.18.63 1.59.23 2.76.11 3.05.74.81 1.19 1.83 1.19 3.09 0 4.41-2.7 5.38-5.28 5.67.42.36.79 1.07.79 2.16v3.2c0 .31.21.67.8.56A11.5 11.5 0 0 0 12 .7Z"
        />
      </svg>
      <span>GitHub</span>
      <small><b aria-hidden="true">★</b><span data-github-stars>{count}</span></small>
    </a>
  );
}
