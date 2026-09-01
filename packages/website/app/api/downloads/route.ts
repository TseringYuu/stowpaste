import { site } from "@/lib/site";

export const dynamic = "force-static";

export function GET() {
  return Response.json({
    version: site.version,
    tag: site.versionTag,
    platform: "macOS",
    minimumSystemVersion: site.minimumSystemVersion,
    architecture: site.architecture,
    artifacts: [
      {
        type: "pkg",
        url: `${site.url}${site.downloadUrl}`,
        checksumUrl: `${site.url}${site.checksumUrl}`
      }
    ]
  });
}
