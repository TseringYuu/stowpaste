export const dynamic = "force-static";

export function GET() {
  return Response.json({
    ok: true,
    service: "stowpaste-website",
    timestamp: new Date().toISOString()
  });
}
