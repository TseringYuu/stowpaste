import { ImageResponse } from "next/og";

export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

const slips = [
  { x: 34, y: 80, rotate: -10, label: "TEXT", value: "Meet at 10:30" },
  { x: 760, y: 58, rotate: 8, label: "PASSWORD", value: "••••••••••" },
  { x: 846, y: 402, rotate: -7, label: "FILE", value: "Launch-notes.pdf" },
  { x: 55, y: 430, rotate: 9, label: "IMAGE", value: "Screenshot.png" }
];

export default function Image() {
  return new ImageResponse(
    <div style={{ position: "relative", display: "flex", width: "100%", height: "100%", alignItems: "center", justifyContent: "center", overflow: "hidden", background: "#655DFF", color: "#17181C" }}>
      {slips.map((slip) => (
        <div key={slip.label} style={{ position: "absolute", left: slip.x, top: slip.y, display: "flex", width: 300, height: 150, flexDirection: "column", border: "3px solid #17181C", background: "#F7F7F1", padding: 20, transform: `rotate(${slip.rotate}deg)`, boxShadow: "9px 9px 0 #17181C" }}>
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: 16, fontWeight: 800 }}><span>{slip.label}</span><span>STOWPASTE</span></div>
          <div style={{ display: "flex", marginTop: 33, fontSize: 27, fontWeight: 800 }}>{slip.value}</div>
        </div>
      ))}

      <div style={{ position: "relative", display: "flex", width: 650, flexDirection: "column", border: "4px solid #17181C", background: "#F7F7F1", padding: 42, boxShadow: "16px 16px 0 #17181C", transform: "rotate(-1deg)" }}>
        <div style={{ display: "flex", justifyContent: "space-between", borderBottom: "3px solid #17181C", paddingBottom: 14, fontSize: 16, fontWeight: 800 }}><span>STOWPASTE</span><span>CLIPBOARD MEMORY / macOS</span></div>
        <div style={{ display: "flex", flexDirection: "column", marginTop: 30, fontSize: 70, fontWeight: 900, lineHeight: 0.84, letterSpacing: -4, textTransform: "uppercase" }}>
          <span>Copied.</span><span>Copied over.</span><span style={{ color: "#655DFF" }}>Not gone.</span>
        </div>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: 34, border: "3px solid #17181C", background: "#17181C", padding: "16px 18px", color: "#FFFFFF", boxShadow: "7px 7px 0 #FF6846", fontSize: 24, fontWeight: 800 }}>
          <span>Download DMG</span><span style={{ display: "flex", alignItems: "center", justifyContent: "center", width: 50, height: 50, background: "#9FF5E0", color: "#17181C", fontSize: 32 }}>↓</span>
        </div>
      </div>
    </div>,
    size
  );
}
