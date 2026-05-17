import { useEffect, useMemo, useState } from "react";
import { ArrowLeft, ChevronRight, Landmark, LogOut, MapPin, Pencil, Shield, Star, Trophy } from "lucide-react";
import { useNavigate } from "react-router-dom";
import type { HeritageDetailsResponse } from "@shared/api";
import BottomNav from "@/components/BottomNav";
import { supabase } from "@/lib/supabase";

type DiscoveryCard = {
  placeName: string;
  imageUrl: string;
  visitedAgo: string;
};

const DISCOVERIES: DiscoveryCard[] = [
  {
    placeName: "Galle Fort",
    imageUrl:
      "https://images.unsplash.com/photo-1584646098378-0874589d76b1?auto=format&fit=crop&w=800&q=80",
    visitedAgo: "Visited 2d ago",
  },
  {
    placeName: "Sigiriya Rock",
    imageUrl:
      "https://images.unsplash.com/photo-1708925591868-fce81f3f8183?auto=format&fit=crop&w=800&q=80",
    visitedAgo: "Visited 1w ago",
  },
  {
    placeName: "Ruwanwelisaya",
    imageUrl:
      "https://images.unsplash.com/photo-1587235277593-88f5f3d0754e?auto=format&fit=crop&w=800&q=80",
    visitedAgo: "Visited 2w ago",
  },
];

const achievementItems = [
  { title: "Guardian", icon: Shield, active: true },
  { title: "Historian", icon: Landmark, active: true },
  { title: "Explorer", icon: MapPin, active: false },
  { title: "Wildlife", icon: Star, active: false },
];

const menuItems = [
  { title: "Edit Profile", icon: Pencil, tone: "bg-[#52B788]/20 text-[#52B788]" },
  { title: "My Quests", icon: MapPin, tone: "bg-[#B752B7]/20 text-[#B752B7]" },
  { title: "Settings", icon: Star, tone: "bg-[#F4A261]/20 text-[#F4A261]" },
  { title: "Help & Support", icon: Shield, tone: "bg-white/10 text-[#FEFAE0]/80" },
];

const getDisplayName = (metadata: Record<string, unknown> | undefined, email?: string) => {
  const fullName = typeof metadata?.full_name === "string" ? metadata.full_name : "";
  if (fullName.trim()) {
    return fullName.trim();
  }
  return email?.split("@")[0] ?? "Explorer";
};

export default function Profile() {
  const navigate = useNavigate();
  const [displayName, setDisplayName] = useState("Explorer");
  const [details, setDetails] = useState<HeritageDetailsResponse | null>(null);
  const [isLoadingDetails, setIsLoadingDetails] = useState(true);

  useEffect(() => {
    if (!supabase) {
      return;
    }

    const loadUser = async () => {
      const { data } = await supabase.auth.getUser();
      if (!data.user) {
        return;
      }

      setDisplayName(getDisplayName(data.user.user_metadata, data.user.email));
    };

    void loadUser();
  }, []);

  useEffect(() => {
    const places = DISCOVERIES.map((item) => item.placeName).join(",");
    const loadDetails = async () => {
      try {
        const response = await fetch(`/api/heritage-details?places=${encodeURIComponent(places)}`);
        if (!response.ok) {
          return;
        }
        const data = (await response.json()) as HeritageDetailsResponse;
        setDetails(data);
      } finally {
        setIsLoadingDetails(false);
      }
    };

    void loadDetails();
  }, []);

  const detailsByPlace = useMemo(() => {
    const map = new Map<string, HeritageDetailsResponse["places"][number]>();
    details?.places.forEach((place) => {
      map.set(place.placeName.toLowerCase(), place);
    });
    return map;
  }, [details]);

  const handleLogout = async () => {
    if (supabase) {
      await supabase.auth.signOut();
    }
    navigate("/login", { replace: true });
  };

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full max-w-[440px] bg-[#100E0A] px-6 pt-10 pb-36">
        <button
          onClick={() => navigate(-1)}
          className="w-12 h-12 rounded-full border border-[#F4A261]/20 bg-white/5 text-[#FEFBE0] flex items-center justify-center"
        >
          <ArrowLeft size={18} />
        </button>

        <div className="mt-4 flex flex-col items-center text-center">
          <div className="relative">
            <img
              src="https://github.com/user-attachments/assets/7a763b7d-9eb9-4ef2-b821-484bc15e7ca8"
              alt="Profile"
              className="w-40 h-40 rounded-full object-cover border-4 border-[#52B788]/40 shadow-[0_0_36px_rgba(82,183,136,0.45)]"
            />
            <button className="absolute right-0 bottom-1 w-11 h-11 rounded-full bg-[#52B788] text-[#100E0A] flex items-center justify-center border-4 border-[#100E0A]">
              <Pencil size={18} />
            </button>
          </div>
          <h1 className="mt-7 text-[#FEFBE0] text-[50px] font-extrabold leading-none tracking-[-0.8px]">{displayName}</h1>
          <p className="mt-2 text-[#52B788] text-[17px] font-semibold tracking-[2.4px] uppercase">Level 12 - Master</p>
        </div>

        <section className="mt-9">
          <div className="flex items-center justify-between text-sm">
            <span className="text-[#52B788] font-bold">Level 12</span>
            <span className="text-[#FEFAE0]/70">85% to Level 13</span>
          </div>
          <div className="mt-3 h-3 rounded-full bg-white/10 overflow-hidden">
            <div className="h-full w-[85%] bg-gradient-to-r from-[#52B788] to-[#E9C46A]" />
          </div>
          <div className="mt-8 grid grid-cols-3 gap-4">
            {[
              { icon: Star, value: "450", label: "POINTS" },
              { icon: MapPin, value: "12", label: "PLACES" },
              { icon: Trophy, value: "#4", label: "RANK" },
            ].map((stat) => (
              <div
                key={stat.label}
                className="rounded-[24px] border border-[#52B788]/20 bg-white/5 h-[120px] flex flex-col items-center justify-center gap-1"
              >
                <stat.icon size={22} className="text-[#52B788]" />
                <p className="text-[#FEFBE0] text-[34px] font-bold leading-none">{stat.value}</p>
                <p className="text-[#FEFAE0]/70 text-xs tracking-[1.2px]">{stat.label}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="mt-10">
          <div className="flex items-end justify-between mb-4">
            <h2 className="text-[#FEFBE0] text-[39px] font-extrabold leading-none">Achievements</h2>
            <button className="text-[#52B788] text-sm font-semibold">View All</button>
          </div>
          <div className="grid grid-cols-4 gap-3">
            {achievementItems.map((item) => (
              <div
                key={item.title}
                className={`rounded-[22px] border p-3 h-24 flex flex-col items-center justify-center gap-1 ${
                  item.active ? "border-[#52B788]/20 bg-white/5" : "border-white/10 bg-black/20"
                }`}
              >
                <item.icon size={20} className={item.active ? "text-[#52B788]" : "text-[#FEFAE0]/45"} />
                <p className={`text-sm ${item.active ? "text-[#FEFBE0]" : "text-[#FEFAE0]/45"}`}>{item.title}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="mt-10">
          <div className="flex items-end justify-between mb-4">
            <h2 className="text-[#FEFBE0] text-[39px] font-extrabold leading-none">Recent Discoveries</h2>
            <button className="text-[#52B788] text-sm font-semibold">History</button>
          </div>
          <div className="grid grid-cols-3 gap-3">
            {DISCOVERIES.map((card) => {
              const place = detailsByPlace.get(card.placeName.toLowerCase());
              return (
                <article key={card.placeName} className="min-w-0">
                  <img src={card.imageUrl} alt={card.placeName} className="w-full h-24 object-cover rounded-2xl mb-2" />
                  <h3 className="text-[#FEFBE0] text-sm font-bold leading-5 truncate">{card.placeName}</h3>
                  <p className="text-[#FEFAE0]/50 text-xs">{card.visitedAgo}</p>
                  <p className="text-[#52B788] text-[10px] mt-1 truncate">
                    {isLoadingDetails ? "Loading ticket prices..." : `LKR: ${place?.ticketPriceLkr ?? "N/A"}`}
                  </p>
                  <p className="text-[#E9C46A] text-[10px] truncate">USD: {place?.ticketPriceForeignUsd ?? "N/A"}</p>
                </article>
              );
            })}
          </div>
        </section>

        <section className="mt-9 space-y-3">
          {menuItems.map((item) => (
            <button
              key={item.title}
              className="w-full rounded-[24px] border border-white/10 bg-white/5 px-4 py-4 flex items-center gap-4"
            >
              <span className={`w-10 h-10 rounded-full flex items-center justify-center ${item.tone}`}>
                <item.icon size={18} />
              </span>
              <span className="text-[#FEFBE0] text-lg font-medium">{item.title}</span>
              <ChevronRight size={20} className="ml-auto text-[#FEFAE0]/35" />
            </button>
          ))}
        </section>

        <button
          onClick={() => void handleLogout()}
          className="mt-7 w-full h-16 rounded-[24px] border border-[#C54F4F]/40 bg-[#3A1414]/30 text-[#FF8F8F] text-[31px] font-bold flex items-center justify-center gap-3"
        >
          <LogOut size={22} />
          Log Out
        </button>

        <BottomNav />
      </div>
    </div>
  );
}
