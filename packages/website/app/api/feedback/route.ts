const maxMessageLength = 4000;

export async function POST(request: Request) {
  const payload = (await request.json().catch(() => null)) as {
    email?: unknown;
    message?: unknown;
    topic?: unknown;
  } | null;

  if (!payload || typeof payload.message !== "string") {
    return Response.json({ ok: false, error: "message_required" }, { status: 400 });
  }

  const message = payload.message.trim();
  if (message.length < 4 || message.length > maxMessageLength) {
    return Response.json({ ok: false, error: "message_length_invalid" }, { status: 400 });
  }

  return Response.json({
    ok: true,
    accepted: true,
    topic: typeof payload.topic === "string" ? payload.topic.slice(0, 80) : "general"
  });
}
