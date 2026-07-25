import { useState, useEffect, useRef } from "react";
import { ArrowLeft, Zap, Landmark, ScanLine, X, Search } from "lucide-react";
import BottomNav from "@/components/BottomNav";
import { useQuery } from "@tanstack/react-query";

const NAV_TABS = ["Sites", "Plants", "Wildlife"] as const;

export default function Scanner() {
  const [activeTab, setActiveTab] = useState<string>("Sites");
  const [siteName, setSiteName] = useState("");
  const [isScanning, setIsScanning] = useState(false);
  const [scanResult, setScanResult] = useState<any>(null);
  const [reconstructMode, setReconstructMode] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    let stream: MediaStream | null = null;
    const startCamera = async () => {
      try {
        stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: "environment" },
        });
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
        }
      } catch (err) {
        console.error("Error accessing camera:", err);
      }
    };
    startCamera();
    return () => {
      if (stream) {
        stream.getTracks().forEach((track) => track.stop());
      }
    };
  }, []);

  const handleScan = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!siteName.trim()) return;

    setIsScanning(true);
    setReconstructMode(false);

    // Simulate API delay for scanning
    setTimeout(() => {
      setScanResult({
        name: siteName,
        era: "Ancient Kingdom",
        status: "Needs Restoration",
        confidence: "98%",
        distance: "1.2 KM",
      });
      setIsScanning(false);
    }, 2500);
  };

  return (
    <div className="min-h-[100dvh] w-full flex justify-center bg-[#100E0A] font-['Plus_Jakarta_Sans',sans-serif] stretch">
      <div className="relative flex flex-col h-[100dvh] w-full sm:max-w-[430px] bg-[#100E0A] overflow-hidden shadow-[0_0_40px_rgba(0,0,0,0.5)]">
        {/* ── Camera / Scanner Section ── */}
        <div className="relative flex-shrink-0 overflow-hidden h-[65vh] bg-black">
          <video
            ref={videoRef}
            autoPlay
            playsInline
            muted
            className="absolute inset-0 w-full h-full object-cover opacity-80"
          />

          {/* AR / Recon overlay effects */}
          {reconstructMode && (
            <div className="absolute inset-0 z-10 pointer-events-none">
              <div className="absolute inset-0 bg-[#F4A261]/20 mix-blend-color-dodge transition-all duration-1000" />
              <div
                className="absolute inset-0"
                style={{
                  backgroundImage:
                    "linear-gradient(rgba(244, 162, 97, 0.4) 1px, transparent 1px), linear-gradient(90deg, rgba(244, 162, 97, 0.4) 1px, transparent 1px)",
                  backgroundSize: "20px 20px",
                  perspective: "1000px",
                  transform: "rotateX(60deg) scale(2.5) translateY(10%)",
                  transformOrigin: "bottom",
                }}
              />
            </div>
          )}

          {isScanning && (
            <div className="absolute inset-0 z-10 flex flex-col justify-center items-center pointer-events-none">
              <div className="w-48 h-48 border-2 border-[#10b981] rounded-2xl relative overflow-hidden">
                <div className="absolute top-0 left-0 right-0 h-1 bg-[#10b981] shadow-[0_0_15px_#10b981] animate-[scan_2s_ease-in-out_infinite]" />
              </div>
              <p className="mt-4 text-[#10b981] font-bold tracking-widest text-sm animate-pulse">
                ANALYZING...
              </p>
            </div>
          )}

          {/* ── Header ── */}
          <div className="absolute top-0 left-0 right-0 z-20 flex items-center justify-between px-5 pt-12 pb-4 safe-top bg-gradient-to-b from-black/80 to-transparent pointer-events-none">
            <div className="flex items-center rounded-full bg-[#1A1311]/80 border border-white/10 backdrop-blur-md p-1 mx-auto pointer-events-auto">
              {NAV_TABS.map((tab) => (
                <button
                  key={tab}
                  onClick={() => setActiveTab(tab)}
                  className={`px-4 py-1.5 rounded-full text-xs transition-all ${
                    activeTab === tab
                      ? "bg-[#F4A261] text-white font-bold"
                      : "text-[#FEFBE0]/60 font-medium"
                  }`}
                >
                  {tab}
                </button>
              ))}
            </div>
          </div>

          {/* ── Scan Input ── */}
          <div className="absolute bottom-8 left-0 right-0 z-20 px-5">
            <form onSubmit={handleScan} className="flex gap-2">
              <div className="relative flex-1">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-[#FEFBE0]/60" />
                <input
                  type="text"
                  value={siteName}
                  onChange={(e) => setSiteName(e.target.value)}
                  placeholder="Enter place to scan..."
                  className="w-full bg-[#1A1311]/90 backdrop-blur-md border border-white/10 rounded-2xl py-3.5 pl-11 pr-4 text-[14px] text-white placeholder:text-white/40 focus:outline-[#F4A261]/50 font-medium"
                />
                {siteName && (
                  <button
                    type="button"
                    onClick={() => setSiteName("")}
                    className="absolute right-4 top-1/2 -translate-y-1/2 hidden active:block"
                  >
                    <X className="w-4 h-4 text-white/40" />
                  </button>
                )}
              </div>
              <button
                type="submit"
                disabled={!siteName.trim() || isScanning}
                className="bg-[#10b981] disabled:bg-[#10b981]/50 text-white rounded-2xl px-5 flex items-center justify-center transition-transform active:scale-95"
              >
                <ScanLine className="w-5 h-5" />
              </button>
            </form>
          </div>
        </div>

        {/* ── Info Panel ── */}
        <div className="flex-1 bg-[#100E0A] flex flex-col px-5 pt-6 pb-3 gap-4 overflow-hidden min-h-0 z-30 -mt-4 rounded-t-3xl relative">
          <div className="absolute top-2 left-1/2 -translate-x-1/2 w-12 h-1.5 bg-white/10 rounded-full" />

          {scanResult ? (
            <div className="animate-in slide-in-from-bottom-8 duration-500">
              <div className="flex items-start justify-between gap-3 mb-4">
                <h1 className="flex-1 text-[#FEFBE0] font-bold text-[24px] leading-tight tracking-tight">
                  {scanResult.name}
                </h1>
                <div className="flex flex-col items-end shrink-0 bg-[#1A1311] px-3 py-1.5 rounded-xl border border-white/5">
                  <span className="text-[#F4A261] font-bold text-sm leading-tight text-right">
                    {scanResult.confidence}
                  </span>
                  <span className="text-white/40 text-[9px] uppercase tracking-[0.1em] mt-0.5">
                    Match
                  </span>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3 mb-4">
                <div className="bg-[#1A1311] border border-white/5 rounded-2xl p-4">
                  <p className="text-white/40 text-[10px] font-bold uppercase tracking-wider mb-1.5">
                    Era
                  </p>
                  <p className="text-[#FEFBE0] text-sm font-bold">
                    {scanResult.era}
                  </p>
                </div>
                <div className="bg-[#1A1311] border border-white/5 rounded-2xl p-4">
                  <p className="text-white/40 text-[10px] font-bold uppercase tracking-wider mb-1.5">
                    Status
                  </p>
                  <p className="text-[#10b981] text-sm font-bold leading-tight">
                    {scanResult.status}
                  </p>
                </div>
              </div>

              <div className="flex gap-3">
                <button
                  onClick={() => setReconstructMode(!reconstructMode)}
                  className={`flex-1 py-4 rounded-2xl text-sm font-bold transition-opacity active:opacity-80 flex items-center justify-center gap-2 border-2 ${reconstructMode ? "bg-[#F4A261] text-white border-[#F4A261] shadow-[0_0_20px_rgba(244,162,97,0.3)]" : "border-[#F4A261] text-[#F4A261]"}`}
                >
                  {reconstructMode ? "Exit AR View" : "3D Reconstruct"}
                </button>
              </div>
            </div>
          ) : (
            <div className="flex-1 flex flex-col items-center justify-center text-center px-4 opacity-60">
              <ScanLine className="w-12 h-12 text-white/20 mb-4" />
              <h3 className="text-[#FEFBE0] font-bold mb-2">
                Ready to Discover
              </h3>
              <p className="text-sm text-white/50 leading-relaxed">
                Point your camera at a heritage site and enter its name to begin
                scanning and 3D reconstruction.
              </p>
            </div>
          )}
        </div>

        <BottomNav />
      </div>
    </div>
  );
}
