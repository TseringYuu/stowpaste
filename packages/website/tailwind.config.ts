import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./content/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        ink: "#15171C",
        moss: "#5E5CE6",
        cream: "#DDE2E8",
        linen: "#F8FAFC",
        ember: "#FF643D",
        brass: "#00B8C2"
      },
      fontFamily: {
        display: ["-apple-system", "BlinkMacSystemFont", "Helvetica Neue", "Arial", "sans-serif"],
        body: ["-apple-system", "BlinkMacSystemFont", "Helvetica Neue", "Arial", "sans-serif"],
        mono: ["ui-monospace", "SFMono-Regular", "Menlo", "monospace"]
      },
      boxShadow: {
        glow: "0 24px 80px rgb(67 91 66 / 0.18)"
      }
    }
  },
  plugins: []
};

export default config;
