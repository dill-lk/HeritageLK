import { useState } from "react";
import { ArrowLeft, Zap, Landmark } from "lucide-react";
import BottomNav from "@/components/BottomNav";

const NAV_TABS = ["Sites", "Plants", "Wildlife"] as const;

export default function Index() {
  const [activeTab, setActiveTab] = useState<string>("Sites");

  return (
    <div className="flex flex-col h-screen w-full bg-heritage-bg overflow-hidden font-dm">
      {/* ── Camera / Scanner Section ── */}
      <div className="relative flex-shrink-0 overflow-hidden h-[58vh]">
        {/* Background image */}
        <img
          src="https://api.builder.io/api/v1/image/assets/TEMP/9a4ecce04790a80550b5da7dd2dcde34cb36c4c6?width=898"
          alt="Ancient temple ruins"
          className="absolute inset-0 w-full h-full object-cover"
        />
        {/* Radial gradient vignette */}
        <div className="absolute inset-0 scanner-radial-gradient" />
        {/* Dark overlay */}
        <div className="absolute inset-0 bg-black/[0.56]" />
        {/* Bottom fade into info panel */}
        <div className="absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-b from-transparent to-heritage-bg" />

        {/* ── Header ── */}
        <div className="absolute top-0 left-0 right-0 z-20 flex items-center justify-between px-5 pt-10 pb-4">
          <button className="w-10 h-10 rounded-full bg-heritage-dark-brown border border-white/10 backdrop-blur-md flex items-center justify-center shrink-0">
            <ArrowLeft className="w-4 h-4 text-heritage-cream" />
          </button>

          <div className="flex items-center rounded-full bg-heritage-dark-brown border border-white/10 backdrop-blur-md p-1">
            {NAV_TABS.map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`px-4 py-1.5 rounded-full text-xs transition-all ${
                  activeTab === tab
                    ? "bg-heritage-amber text-white font-bold"
                    : "text-heritage-cream/60 font-medium"
                }`}
              >
                {tab}
              </button>
            ))}
          </div>

          <button className="w-10 h-10 rounded-full bg-heritage-dark-brown border border-white/10 backdrop-blur-md flex items-center justify-center shrink-0">
            <Zap className="w-4 h-4 text-heritage-cream" />
          </button>
        </div>

        {/* ── Detection Badge ── */}
        <div className="absolute top-24 right-4 z-20">
          <div className="flex items-center gap-2 px-3 py-2 rounded-xl bg-heritage-dark-brown/80 detection-border backdrop-blur-md animate-scan-pulse">
            <Landmark className="w-4 h-4 text-heritage-cream shrink-0" />
            <div className="flex flex-col">
              <span className="text-heritage-green-border text-[8px] font-bold tracking-[0.15em] uppercase font-space">
                Detection
              </span>
              <span className="text-heritage-cream text-[11px] font-semibold font-dm">
                Ancient Pillar
              </span>
            </div>
          </div>
        </div>

        {/* ── 3D / Reconstruct Toggle ── */}
        <div className="absolute bottom-7 left-4 z-20 flex items-center rounded-full bg-black/50 backdrop-blur-md border border-white/10 p-1">
          <button className="px-4 py-1.5 rounded-full bg-heritage-amber text-white text-xs font-bold font-dm">
            3D
          </button>
          <button className="px-4 py-1.5 text-heritage-cream/70 text-xs font-medium font-dm">
            Reconstruct
          </button>
        </div>
      </div>

      {/* ── Info Panel ── */}
      <div className="flex-1 bg-heritage-bg flex flex-col px-5 pt-4 pb-3 gap-3 overflow-hidden min-h-0">

        {/* Title + Distance */}
        <div className="flex items-start justify-between gap-3">
          <h1 className="flex-1 text-heritage-cream font-bold text-[22px] leading-tight tracking-tight font-jakarta">
            Yatagala Raja Maha Viharaya
          </h1>
          <div className="flex flex-col items-end shrink-0 pt-0.5">
            <span className="text-heritage-amber font-bold text-sm leading-tight text-right font-space">
              1.2
              <br />
              KM
            </span>
            <span className="text-white/40 text-[9px] uppercase tracking-[0.1em] mt-1 font-space">
              Distance
            </span>
          </div>
        </div>

        {/* Tags */}
        <div className="flex items-center gap-2">
          <span className="px-2 py-[3px] rounded border border-heritage-green-border/30 bg-heritage-green-border/20 text-heritage-amber text-[9px] font-bold uppercase tracking-[0.05em] font-dm">
            Verified
          </span>
          <span className="px-2 py-[3px] rounded border border-white/5 bg-white/10 text-heritage-cream/70 text-[9px] font-bold uppercase tracking-[0.05em] font-dm">
            Archaeological Site
          </span>
        </div>

        {/* Info Cards */}
        <div className="grid grid-cols-2 gap-3">
          <div className="bg-heritage-brown border border-white/5 rounded-2xl p-3">
            <p className="text-heritage-green/50 text-[9px] font-normal uppercase tracking-wide mb-1 font-space">
              Era
            </p>
            <p className="text-heritage-cream text-sm font-bold font-dm">Anuradhapura</p>
          </div>
          <div className="bg-heritage-brown border border-white/5 rounded-2xl p-3">
            <p className="text-heritage-green/50 text-[9px] font-normal uppercase tracking-wide mb-1 font-space">
              Status
            </p>
            <p className="text-heritage-amber text-sm font-bold leading-tight font-dm">
              Under Restoration
            </p>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex gap-3">
          <button className="flex-1 py-4 rounded-2xl border-2 border-heritage-amber text-heritage-amber text-sm font-bold font-dm transition-opacity hover:opacity-80 active:opacity-70">
            View History
          </button>
          <button className="flex-1 py-4 rounded-2xl bg-heritage-amber text-heritage-dark-brown text-sm font-bold font-dm transition-opacity hover:opacity-90 active:opacity-80">
            Start Quest
          </button>
        </div>

      </div>

      <BottomNav />
    </div>
  );
}
