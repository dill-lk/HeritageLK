import { useState, useEffect, useMemo } from "react";
import {
  ArrowLeft,
  Search,
  MapPin,
  ChevronRight,
  BookOpen,
  Plus,
  Loader2,
} from "lucide-react";
import { Link } from "react-router-dom";
import BottomNav from "@/components/BottomNav";
import ShingoLogo from "@/components/ShingoLogo";
import { supabase } from "@/lib/supabase";

interface ArchiveItem {
  id: string;
  title: string;
  loc: string;
  category: string;
  content: string;
  image?: string;
  images: string[];
  created_at: string;
}

export default function Archive() {
  const [activeTab, setActiveTab] = useState("All Records");
  const [searchQuery, setSearchQuery] = useState("");
  const [archives, setArchives] = useState<ArchiveItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function loadArchives() {
      if (!supabase) return;
      setIsLoading(true);
      const { data, error } = await supabase
        .from("archives")
        .select("*")
        .order("created_at", { ascending: false });

      if (!error && data) {
        const dbArchives = data.map((item) => ({
          id: item.id,
          title: item.title,
          loc: item.location || "SRI LANKA",
          category: item.category || "Artifacts",
          content: item.content || item.intro || "",
          images: item.image ? [item.image] : item.images || [],
          created_at: item.created_at,
        }));
        setArchives(dbArchives);
      }
      setIsLoading(false);
    }
    loadArchives();
  }, []);

  const displayedArchives = useMemo(() => {
    return archives.filter((archive) => {
      const matchesTab =
        activeTab === "All Records" || archive.category === activeTab;
      const q = searchQuery.trim().toLowerCase();
      const matchesSearch =
        !q ||
        archive.title.toLowerCase().includes(q) ||
        archive.loc.toLowerCase().includes(q) ||
        archive.content.toLowerCase().includes(q);
      return matchesTab && matchesSearch;
    });
  }, [archives, activeTab, searchQuery]);

  const featuredArchive = archives.length > 0 ? archives[0] : null;
  const listArchives = displayedArchives;

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full sm:max-w-[430px] min-h-screen bg-[#100E0A] pb-[100px] text-[#FEFBE0] shadow-[0_0_40px_rgba(0,0,0,0.5)] overflow-x-hidden">
        {/* Header */}
        <div className="px-6 pt-12 pb-6 flex flex-col gap-6 safe-top">
          <div className="flex items-center justify-between">
            <Link
              to="/home"
              className="w-10 h-10 rounded-full bg-white/5 border border-white/10 flex items-center justify-center transition-colors hover:bg-white/10"
            >
              <ArrowLeft className="w-5 h-5 text-[#F4A261]" />
            </Link>
            <h1 className="text-xl text-[#FEFBE0] font-medium font-['Playfair_Display',serif] tracking-wide">
              Archive
            </h1>
            <Link
              to="/archive/shingo"
              className="w-10 h-10 rounded-full bg-[#E9C46A]/20 border border-[#E9C46A]/40 flex items-center justify-center transition-colors hover:bg-[#E9C46A]/30 group"
            >
              <ShingoLogo className="w-5 h-5 text-[#E9C46A] transition-transform group-hover:scale-110" />
            </Link>
          </div>

          {/* Search */}
          <div className="relative w-full h-12 rounded-2xl bg-white/5 border border-white/10 flex items-center px-4 overflow-hidden">
            <Search className="w-5 h-5 text-white/40 mr-3" />
            <input
              type="text"
              placeholder="Search history & archives..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="bg-transparent border-none outline-none flex-1 text-sm text-white placeholder-white/40 font-medium"
            />
          </div>
        </div>

        {isLoading ? (
          <div className="flex flex-col items-center justify-center p-12 text-[#F4A261]/60">
            <Loader2 className="w-8 h-8 animate-spin mb-4" />
            <p className="text-sm font-medium tracking-wide">
              Unearthing archives...
            </p>
          </div>
        ) : (
          <>
            {/* Tabs */}
            <div className="px-6 flex items-center gap-3 mb-8 overflow-x-auto [&::-webkit-scrollbar]:hidden pb-2">
              {[
                "All Records",
                "Artifacts",
                "Oral History",
                "Ancient Sites",
              ].map((tab) => (
                <button
                  key={tab}
                  onClick={() => setActiveTab(tab)}
                  className={`px-5 py-2 rounded-full text-xs font-bold tracking-wider uppercase whitespace-nowrap transition-all duration-300 ${
                    activeTab === tab
                      ? "bg-[#F4A261] text-[#100E0A] shadow-[0_0_15px_rgba(244,162,97,0.4)]"
                      : "bg-white/5 border border-white/10 text-white/60 hover:bg-white/10 hover:text-white"
                  }`}
                >
                  {tab}
                </button>
              ))}
            </div>

            {/* Featured Archive (latest) */}
            {featuredArchive && activeTab === "All Records" && !searchQuery && (
              <div className="px-6 mb-10">
                <div className="flex items-center gap-2 mb-4">
                  <div className="w-1.5 h-1.5 rounded-full bg-[#F4A261] animate-pulse" />
                  <span className="text-xs font-bold tracking-[0.2em] text-[#F4A261] uppercase">
                    Newly Discovered
                  </span>
                </div>

                <Link
                  to={`/archive/${featuredArchive.id}`}
                  className="block relative h-[320px] rounded-[24px] overflow-hidden border border-white/10 group"
                >
                  <img
                    src={
                      featuredArchive.image ||
                      featuredArchive.images?.[0] ||
                      `https://image.pollinations.ai/prompt/${encodeURIComponent(featuredArchive.title + " Sri Lanka historical artifact heritage realistic 4k")}?width=1000&height=1000&nologo=true`
                    }
                    alt={featuredArchive.title}
                    onError={(e) => {
                      e.currentTarget.src =
                        "https://images.unsplash.com/photo-1596706798032-9cb773b40bb0?q=80&w=2670&auto=format&fit=crop";
                    }}
                    className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-[#100E0A] via-[#100E0A]/60 to-transparent opacity-90" />
                  <div className="absolute inset-0 bg-black/20 group-hover:bg-transparent transition-colors duration-500" />

                  <div className="absolute inset-x-0 bottom-0 p-6 flex flex-col justify-end">
                    <p className="text-[10px] text-[#F4A261] font-bold uppercase tracking-widest mb-2 flex items-center gap-1.5">
                      <MapPin size={12} /> {featuredArchive.loc}
                    </p>
                    <h2 className="text-[28px] font-medium leading-[1.1] mb-3 text-white font-['Playfair_Display',serif] drop-shadow-md">
                      {featuredArchive.title}
                    </h2>
                    <p className="text-sm font-medium text-white/70 line-clamp-2">
                      {featuredArchive.content.replace(/#|\*/g, "")}
                    </p>
                  </div>
                </Link>
              </div>
            )}

            {/* List */}
            <div className="px-6 pb-20 space-y-4">
              {listArchives.map((item) => (
                <Link
                  key={item.id}
                  to={`/archive/${item.id}`}
                  className="group relative block w-full rounded-[20px] bg-white/5 border border-white/5 overflow-hidden transition-all hover:bg-white/10"
                >
                  <div className="flex p-4 gap-4 items-center">
                    <div className="w-[88px] h-[88px] shrink-0 rounded-2xl overflow-hidden relative">
                      <img
                        src={
                          item.image ||
                          item.images?.[0] ||
                          `https://image.pollinations.ai/prompt/${encodeURIComponent(item.title + " Sri Lanka historical artifact heritage realistic 4k")}?width=1000&height=1000&nologo=true`
                        }
                        alt={item.title}
                        onError={(e) => {
                          e.currentTarget.src =
                            "https://images.unsplash.com/photo-1596706798032-9cb773b40bb0?q=80&w=2670&auto=format&fit=crop";
                        }}
                        className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                      />
                    </div>
                    <div className="flex-1 min-w-0 py-1">
                      <div className="flex items-center gap-1.5 mb-1.5">
                        <MapPin size={10} className="text-[#F4A261]" />
                        <span className="text-[9px] font-bold uppercase tracking-wider text-[#F4A261] truncate">
                          {item.loc}
                        </span>
                      </div>
                      <h3 className="text-base font-medium text-white leading-tight font-['Playfair_Display',serif] mb-2 truncate">
                        {item.title}
                      </h3>
                      <p className="text-xs text-white/50 line-clamp-2 leading-relaxed">
                        {item.content.replace(/#|\*/g, "").substring(0, 100)}...
                      </p>
                    </div>
                    <div className="w-8 h-8 rounded-full bg-white/5 border border-white/10 flex items-center justify-center shrink-0 transition-all group-hover:bg-[#F4A261] group-hover:border-[#F4A261] group-hover:text-black">
                      <ChevronRight className="w-4 h-4" />
                    </div>
                  </div>
                </Link>
              ))}

              {listArchives.length === 0 && (
                <div className="text-center py-16 px-4 bg-white/5 rounded-3xl border border-white/5">
                  <BookOpen className="w-10 h-10 mx-auto text-white/20 mb-4" />
                  <h3 className="text-lg font-medium text-white mb-2 font-['Playfair_Display',serif]">
                    Record Not Found
                  </h3>
                  <p className="text-sm text-white/50">
                    There are no records matching your search in the chronicles.
                  </p>
                </div>
              )}
            </div>
          </>
        )}

        {/* Floating Add Action Button */}
        <Link
          to="/archive/upload"
          className="fixed bottom-[100px] right-6 sm:absolute sm:right-6 w-14 h-14 rounded-full bg-[#F4A261] flex items-center justify-center text-[#100E0A] transition-all duration-400 shadow-[0_4px_20px_rgba(244,162,97,0.4)] hover:shadow-[0_8px_30px_rgba(244,162,97,0.6)] z-50 hover:scale-110 active:scale-95"
        >
          <Plus className="w-7 h-7" strokeWidth={2.5} />
        </Link>

        {/* Bottom Navigation */}
        <BottomNav />
      </div>
    </div>
  );
}
