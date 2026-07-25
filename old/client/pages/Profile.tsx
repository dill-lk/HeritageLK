import { useEffect, useState } from "react";
import {
  LogOut,
  ArrowLeft,
  Loader2,
  Star,
  MapPin,
  Trophy,
  Shield,
  Building,
  Compass,
  User,
  Map,
  Settings,
  HelpCircle,
  ChevronRight,
  PenSquare,
} from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import BottomNav from "@/components/BottomNav";
import { supabase } from "@/lib/supabase";

export default function Profile() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [userEmail, setUserEmail] = useState("");
  const [userName, setUserName] = useState("");
  const [points, setPoints] = useState(0);
  const [userRank, setUserRank] = useState<number | null>(null);
  const [userLevel, setUserLevel] = useState(1);
  const [completedQuests, setCompletedQuests] = useState<any[]>([]);

  useEffect(() => {
    async function loadProfile() {
      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (!session) {
        navigate("/login");
        return;
      }
      setUserEmail(session.user.email || "");

      let currentName =
        session.user.user_metadata?.full_name ||
        session.user.email?.split("@")[0] ||
        "Explorer";
      setUserName(currentName);

      try {
        const { data, error } = await supabase
          .from("profiles")
          .select("points, full_name")
          .eq("id", session.user.id)
          .maybeSingle();

        if (data && !error) {
          setPoints(data.points || 0);
          if (data.full_name) {
            setUserName(data.full_name);
          }

          const lvl = Math.max(1, Math.floor((data.points || 0) / 100));
          setUserLevel(lvl);

          const { count } = await supabase
            .from("profiles")
            .select("*", { count: "exact", head: true })
            .gt("points", data.points || 0);
          setUserRank((count || 0) + 1);
        }

        // Fetch completed quests
        const { data: userQ } = await supabase
          .from("user_quests")
          .select("created_at, quests(*)")
          .eq("user_id", session.user.id)
          .order("created_at", { ascending: false });
        if (userQ) {
          const completed = userQ
            .map((q) => ({
              ...q.quests,
              completedAt: q.created_at,
            }))
            .filter(Boolean);
          setCompletedQuests(completed);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    loadProfile();
  }, [navigate]);

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    navigate("/login");
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#100E0A] flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-[#52B788] animate-spin" />
      </div>
    );
  }

  // Calculate generic level progression
  // Each level is 100 points
  const pointsNextLevel = 100;
  const pointsCurrentLevelStart = userLevel * 100;
  const progressPercent = Math.min(
    100,
    Math.max(0, ((points % 100) / 100) * 100),
  );
  const displayPercent = progressPercent.toFixed(0);

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full sm:max-w-[430px] min-h-screen bg-[#100E0A] text-white overflow-x-hidden shadow-[0_0_40px_rgba(0,0,0,0.5)]">
        <div className="relative z-10 p-6 flex flex-col min-h-screen pb-24">
          <div className="flex items-center justify-between mb-8">
            <Link
              to="/home"
              className="w-10 h-10 rounded-full bg-[#201D19] flex items-center justify-center transition-colors hover:bg-white/10 group"
            >
              <ArrowLeft className="w-5 h-5 text-white/70 group-hover:text-white" />
            </Link>
          </div>

          <div className="flex flex-col items-center mb-8 relative">
            <div className="w-32 h-32 rounded-full bg-white/5 border-2 border-[#52B788]/20 flex items-center justify-center mb-4 relative overflow-hidden shadow-xl">
              <img
                src="https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=300&auto=format&fit=crop"
                className="w-full h-full object-cover"
                alt="Profile"
              />
              <div className="absolute bottom-1 right-2 bg-[#52B788] text-[#100E0A] w-8 h-8 rounded-full flex items-center justify-center z-20 border-[3px] border-[#100E0A]">
                <PenSquare className="w-4 h-4" />
              </div>
            </div>

            <h1 className="text-3xl font-bold mb-1">
              {userName || userEmail.split("@")[0]}
            </h1>
            <p className="text-[#52B788] text-sm font-bold tracking-widest uppercase mb-8">
              LEVEL {userLevel} - MASTER
            </p>

            {/* Progress Bar */}
            <div className="w-full mb-8">
              <div className="flex justify-between text-xs mb-2">
                <span className="text-[#52B788] font-bold">
                  Level {userLevel}
                </span>
                <span className="text-white/50">
                  {displayPercent}% to Level {userLevel + 1}
                </span>
              </div>
              <div className="h-2 rounded-full pl-0 bg-[#29261E] overflow-hidden">
                <div
                  className="h-full rounded-full bg-gradient-to-r from-[#52B788] to-[#E9C46A]"
                  style={{ width: `${displayPercent}%` }}
                />
              </div>
            </div>

            {/* Stats */}
            <div className="w-full flex gap-3 text-center mb-10">
              <div className="flex-1 bg-[#17140F] border border-white/5 rounded-2xl p-4 flex flex-col items-center justify-center">
                <Star className="text-[#F4A261] mb-2 fill-[#F4A261]" />
                <span className="text-xl font-bold">{points}</span>
                <span className="text-[10px] text-white/40 font-bold tracking-widest uppercase mt-1">
                  Points
                </span>
              </div>
              <div className="flex-1 bg-[#17140F] border border-white/5 rounded-2xl p-4 flex flex-col items-center justify-center">
                <MapPin className="text-[#52B788] mb-2 fill-[#52B788]" />
                <span className="text-xl font-bold">
                  {completedQuests.length}
                </span>
                <span className="text-[10px] text-white/40 font-bold tracking-widest uppercase mt-1">
                  Places
                </span>
              </div>
              <div className="flex-1 bg-[#17140F] border border-white/5 rounded-2xl p-4 flex flex-col items-center justify-center">
                <Trophy className="text-[#52B788] mb-2 fill-transparent" />
                <span className="text-xl font-bold">
                  #{userRank !== null ? userRank : "-"}
                </span>
                <span className="text-[10px] text-white/40 font-bold tracking-widest uppercase mt-1">
                  Rank
                </span>
              </div>
            </div>

            {/* Achievements */}
            <div className="w-full mb-10">
              <div className="flex justify-between items-end mb-4">
                <h2 className="text-2xl font-bold text-white">Achievements</h2>
                <span className="text-[#52B788] text-xs font-bold mb-1 cursor-pointer">
                  View All
                </span>
              </div>
              <div className="flex gap-3 overflow-x-auto pb-4 [&::-webkit-scrollbar]:hidden [-ms-overflow-style:'none'] [scrollbar-width:'none']">
                {completedQuests.length === 0 && (
                  <p className="text-white/50 text-sm">
                    Complete quests to unlock achievements!
                  </p>
                )}
                {completedQuests.map((quest, i) => (
                  <div
                    key={`ach-${i}`}
                    className="min-w-[80px] h-[100px] bg-[#17140F] border border-white/5 rounded-3xl flex flex-col items-center justify-center gap-3"
                  >
                    <div className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center text-white/70 text-xl">
                      {quest.icon || "🌟"}
                    </div>
                    <span className="text-[10px] text-white/50 px-1 text-center truncate w-full">
                      {quest.title?.split(" ")[0]}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Recent Discoveries */}
            <div className="w-full mb-10">
              <div className="flex justify-between items-end mb-4">
                <h2 className="text-2xl font-bold text-white">
                  Recent Discoveries
                </h2>
                <span className="text-[#52B788] text-xs font-bold mb-1 cursor-pointer">
                  History
                </span>
              </div>
              <div className="flex gap-4 overflow-x-auto pb-4 [&::-webkit-scrollbar]:hidden [-ms-overflow-style:'none'] [scrollbar-width:'none']">
                {completedQuests.length === 0 && (
                  <p className="text-white/50 text-sm">
                    No recent discoveries.
                  </p>
                )}
                {completedQuests.map((quest, i) => {
                  // Fallback image picking logic based on id
                  const imgIds = [
                    "1549473889-14f410d83298",
                    "1586224372551-7f91854580bf",
                    "1625805541012-e8ad54933a2a",
                  ];
                  const placeholderImg = `https://images.unsplash.com/photo-${imgIds[i % imgIds.length]}?q=80&w=300&auto=format&fit=crop`;

                  return (
                    <div key={`rec-${i}`} className="min-w-[140px]">
                      <div className="h-[100px] rounded-[24px] overflow-hidden mb-2">
                        <img
                          src={quest.image || placeholderImg}
                          className="w-full h-full object-cover"
                        />
                      </div>
                      <p className="font-bold text-sm truncate">
                        {quest.title}
                      </p>
                      <p className="text-[10px] text-white/40">
                        {quest.completedAt
                          ? new Date(quest.completedAt).toLocaleDateString()
                          : "Recently"}
                      </p>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Actions list */}
            <div className="w-full flex flex-col gap-3 mb-10">
              <Link
                to="/settings"
                className="flex items-center justify-between bg-[#17140F] border border-white/5 p-4 rounded-[24px]"
              >
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-[#52B788]/20 flex items-center justify-center text-[#52B788]">
                    <User size={18} fill="currentColor" />
                  </div>
                  <span className="font-bold">Edit Profile</span>
                </div>
                <ChevronRight className="w-5 h-5 text-white/30" />
              </Link>

              <Link
                to="/quests"
                className="flex items-center justify-between bg-[#17140F] border border-white/5 p-4 rounded-[24px]"
              >
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-purple-500/20 flex items-center justify-center text-purple-400">
                    <Map size={18} fill="currentColor" />
                  </div>
                  <span className="font-bold">My Quests</span>
                </div>
                <ChevronRight className="w-5 h-5 text-white/30" />
              </Link>

              <Link
                to="/settings"
                className="flex items-center justify-between bg-[#17140F] border border-white/5 p-4 rounded-[24px]"
              >
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-[#F4A261]/20 flex items-center justify-center text-[#F4A261]">
                    <Settings size={18} fill="currentColor" />
                  </div>
                  <span className="font-bold">Settings</span>
                </div>
                <ChevronRight className="w-5 h-5 text-white/30" />
              </Link>

              <div className="flex items-center justify-between bg-[#17140F] border border-white/5 p-4 rounded-[24px] cursor-pointer">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-white/70">
                    <HelpCircle size={18} fill="currentColor" />
                  </div>
                  <span className="font-bold">Help & Support</span>
                </div>
                <ChevronRight className="w-5 h-5 text-white/30" />
              </div>
            </div>

            <button
              onClick={handleSignOut}
              className="w-full py-4 rounded-[24px] border border-red-500/20 text-red-400 font-bold text-center transition-colors hover:bg-red-500/10"
            >
              Log Out
            </button>
          </div>
        </div>

        <BottomNav />
      </div>
    </div>
  );
}
