import type { Config } from "tailwindcss";

export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      boxShadow: {
        brutal: "8px 8px 0 #151515",
        "brutal-md": "6px 6px 0 #151515",
        "brutal-sm": "4px 4px 0 #151515",
        "brutal-xs": "2px 2px 0 #151515",
      },
      colors: {
        accentBlue: "#2563eb",
        accentOrange: "#f97316",
        accentRose: "#f43f5e",
        ink: "#151515",
        panel: "#fff8e6",
        rail: "#1f2937",
      },
      fontFamily: {
        body: ["Kosugi Maru", "Hiragino Kaku Gothic ProN", "Noto Sans JP", "sans-serif"],
        mono: ["IBM Plex Mono", "Menlo", "SFMono-Regular", "monospace"],
      },
    },
  },
  plugins: [],
} satisfies Config;
