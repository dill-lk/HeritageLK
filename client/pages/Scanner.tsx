import { useState } from "react";
import { ArrowLeft, Zap, Landmark } from "lucide-react";
import { Link } from "react-router-dom";
import BottomNav from "@/components/BottomNav";

const NAV_TABS = ["Sites", "Plants", "Wildlife"] as const;

export default function Scanner() {
  const [activeTab, setActiveTab] = useState<(typeof NAV_TABS)[number]>("Sites");

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full max-w-[440px] pb-32">
        <div className="px-6 pt-12 pb-6 flex items-center justify-between">
          <Link
            to="/home"
            className="w-11 h-11 rounded-full border border-[#F4A261]/20 bg-white/5 flex items-center justify-center"
          >
            <ArrowLeft className="w-5 h-5 text-[#FEFBE0]" />
          </Link>
          <h1 className="text-[#FEFBE0] text-2xl font-bold">Scanner</h1>
          <div className="w-11 h-11 rounded-full border border-[#F4A261]/20 bg-[#F4A261]/10 flex items-center justify-center">
            <Zap className="w-5 h-5 text-[#F4A261]" />
          </div>
        </div>

        <div className="px-6">
          <div className="w-full rounded-2xl border border-[#F4A261]/20 bg-white/5 p-1 flex gap-1 mb-6">
            {NAV_TABS.map((tab) => (
              <button
                key={tab}
                type="button"
                onClick={() => setActiveTab(tab)}
                className={`flex-1 rounded-xl py-2 text-sm font-semibold transition-colors ${
                  activeTab === tab ? "bg-[#F4A261] text-[#100E0A]" : "text-[#FEFBE0]/70"
                }`}
              >
                {tab}
              </button>
            ))}
          </div>

          <div className="rounded-[28px] border border-[#52B788]/20 bg-white/5 p-6">
            <div className="w-12 h-12 rounded-2xl bg-[#52B788]/20 flex items-center justify-center mb-4">
              <Landmark className="w-6 h-6 text-[#52B788]" />
            </div>
            <h2 className="text-[#FEFBE0] text-xl font-bold mb-2">Scan {activeTab}</h2>
            <p className="text-[#FEFAE0]/60 text-sm">
              Point your camera at {activeTab.toLowerCase()} to identify and learn details instantly.
            </p>
          </div>
        </div>

        <BottomNav />
      </div>
    </div>
  );
}
