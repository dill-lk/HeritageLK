import BottomNav from "@/components/BottomNav";
import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";

const initialLeaderboard = [
  { rank: 1, name: "Sanul Randisa", city: "Matara", score: "15.2k" },
  { rank: 2, name: "Jinuk Chanthusa", city: "Matara", score: "11.8k" },
  { rank: 3, name: "Disara Bimsilu", city: "Matara", score: "10.9k" },
];

const fallbackQuests = [
  {
    id: "fake-1",
    icon: "🏰",
    title: "The Fort Guardian",
    description: "Scan 3 watchtowers in Galle Fort",
    points: 500,
    accent: "rgba(183,82,183,0.10)",
  },
  {
    id: "fake-2",
    icon: "🌿",
    title: "Forest Secret Finder",
    description: "Identify 5 endemic plants from Kanneliya",
    points: 800,
    accent: "rgba(82,183,136,0.10)",
    border: "rgba(82,183,136,0.20)",
  },
  {
    id: "fake-3",
    icon: "🐘",
    title: "Wildlife Tracker",
    description: "Spot and document a wild elephant in Minneriya",
    points: 1000,
    accent: "rgba(244,162,97,0.10)",
    border: "rgba(244,162,97,0.20)",
  },
  {
    id: "fake-4",
    icon: "🌊",
    title: "Ocean Defender",
    description: "Participate in a Mirissa beach cleanup",
    points: 300,
    accent: "rgba(82,183,136,0.10)",
  },
  {
    id: "fake-5",
    icon: "🏛️",
    title: "Ruins Explorer",
    description: "Visit and read the history of 3 ruins in Polonnaruwa",
    points: 600,
    accent: "rgba(183,82,183,0.10)",
    border: "rgba(183,82,183,0.20)",
  },
  {
    id: "fake-6",
    icon: "🧗",
    title: "Summit Scaler",
    description: "Climb to the top of Sigiriya Rock Fortress",
    points: 1200,
    accent: "rgba(244,162,97,0.10)",
  },
  {
    id: "fake-7",
    icon: "🫖",
    title: "Tea Trailblazer",
    description: "Learn about the tea-making process in Nuwara Eliya",
    points: 400,
    accent: "rgba(82,183,136,0.10)",
    border: "rgba(82,183,136,0.20)",
  },
  {
    id: "fake-8",
    icon: "🚂",
    title: "Ella Odyssey",
    description: "Take the scenic train ride from Kandy to Ella",
    points: 750,
    accent: "rgba(183,82,183,0.10)",
    border: "rgba(183,82,183,0.20)",
  },
  {
    id: "fake-9",
    icon: "🤿",
    title: "Coral Guardian",
    description: "Explore the coral reefs of Pigeon Island",
    points: 850,
    accent: "rgba(82,183,136,0.10)",
  },
  {
    id: "fake-10",
    icon: "🛕",
    title: "Sacred Relic",
    description: "Visit the Temple of the Sacred Tooth Relic",
    points: 600,
    accent: "rgba(244,162,97,0.10)",
    border: "rgba(244,162,97,0.20)",
  },
  {
    id: "fake-11",
    icon: "🌅",
    title: "Adam's Peak Pilgrim",
    description: "Reach the summit of Adam's Peak at sunrise",
    points: 1500,
    accent: "rgba(183,82,183,0.10)",
  },
  {
    id: "fake-12",
    icon: "🐆",
    title: "Yala Safari",
    description: "Spot a leopard on a safari in Yala National Park",
    points: 1100,
    accent: "rgba(82,183,136,0.10)",
    border: "rgba(82,183,136,0.20)",
  },
  {
    id: "fake-13",
    icon: "🏄",
    title: "Arugam Bay Surfer",
    description: "Catch a wave in the surfing capital",
    points: 900,
    accent: "rgba(244,162,97,0.10)",
  },
];

export default function Quests() {
  const [userScore, setUserScore] = useState<number>(0);
  const [userRank, setUserRank] = useState<number | null>(null);
  const [leaderboard, setLeaderboard] = useState(initialLeaderboard);
  const [activeQuests, setActiveQuests] = useState<any[]>(fallbackQuests);
  const [completedQuests, setCompletedQuests] = useState<any[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Auto-claim interactive flow state
  const [activeFlowQuest, setActiveFlowQuest] = useState<any | null>(null);
  const [flowStep, setFlowStep] = useState<
    "intro" | "checking_location" | "quiz" | "completed" | "error"
  >("intro");
  const [quizSelection, setQuizSelection] = useState<number | null>(null);

  // Fetch logic
  const loadData = async () => {
    if (!supabase) return;
    const {
      data: { session },
    } = await supabase.auth.getSession();
    if (!session?.user) return;

    try {
      // 1. Fetch User Points
      const { data: profile } = await supabase
        .from("profiles")
        .select("points, full_name, city")
        .eq("id", session.user.id)
        .maybeSingle();

      if (profile) {
        setUserScore(profile.points || 0);

        const { count } = await supabase
          .from("profiles")
          .select("*", { count: "exact", head: true })
          .gt("points", profile.points || 0);
        setUserRank((count || 0) + 1);
      }

      // 2. Fetch Leaderboard
      const { data: topUsers } = await supabase
        .from("profiles")
        .select("full_name, city, points")
        .order("points", { ascending: false })
        .limit(3);

      if (topUsers && topUsers.length > 0) {
        setLeaderboard(
          topUsers.map((u: any, idx: number) => ({
            rank: idx + 1,
            name: u.full_name || "Unknown",
            city: u.city || "Sri Lanka",
            score: (u.points / 1000).toFixed(1) + "k",
          })),
        );
      }

      // 3. Fetch Quests from DB
      let { data: dbQuests, error: qError } = await supabase
        .from("quests")
        .select("*");

      if (!qError && dbQuests && dbQuests.length === 0) {
        // Automatically seed the initial database if empty
        const seedData = fallbackQuests.map((q) => ({
          icon: q.icon,
          title: q.title,
          description: q.description,
          points: q.points,
        }));
        await supabase.from("quests").insert(seedData);

        // Re-fetch now that we've seeded
        const { data: generatedQuests } = await supabase
          .from("quests")
          .select("*");
        if (generatedQuests) {
          dbQuests = generatedQuests;
        }
      }

      if (!qError && dbQuests && dbQuests.length > 0) {
        // Fetch User Completed Quests
        const { data: userQ } = await supabase
          .from("user_quests")
          .select("quest_id, quests(*)")
          .eq("user_id", session.user.id);
        const completedIds = userQ ? userQ.map((q) => q.quest_id) : [];

        const available = dbQuests.filter((q) => !completedIds.includes(q.id));
        const completed = userQ
          ? userQ.map((q) => q.quests).filter(Boolean)
          : [];

        // Add styles if missing
        const stylizedAvailable = available.map((q, i) => ({
          ...q,
          accent:
            i % 2 === 0 ? "rgba(183,82,183,0.10)" : "rgba(82,183,136,0.10)",
          border: "rgba(244,162,97,0.10)",
        }));

        setActiveQuests(stylizedAvailable);
        setCompletedQuests(completed);
      } else {
        // Use fallback if table doesn't exist (local session state)
        setActiveQuests(
          fallbackQuests.map((q, i) => ({
            ...q,
            accent:
              i % 2 === 0 ? "rgba(183,82,183,0.10)" : "rgba(82,183,136,0.10)",
            border: "rgba(244,162,97,0.10)",
          })),
        );
      }
    } catch (e) {
      console.warn("Error fetching quest data", e);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleCompleteQuest = async (questId: string, pts: number) => {
    if (!supabase) return;
    setIsSubmitting(true);
    const {
      data: { session },
    } = await supabase.auth.getSession();
    if (!session?.user) {
      setIsSubmitting(false);
      return;
    }

    try {
      // 1. If it's a real backend quest
      if (!questId.startsWith("fake-")) {
        // Insert completion
        const { error: insertErr } = await supabase.from("user_quests").insert({
          user_id: session.user.id,
          quest_id: questId,
        });

        if (insertErr) throw insertErr;
      } else {
        // Fallback UI State
        const completedQuest = activeQuests.find((q) => q.id === questId);
        if (completedQuest) {
          setCompletedQuests((prev) => [...prev, completedQuest]);
          setActiveQuests((prev) => prev.filter((q) => q.id !== questId));
        }
      }

      // 2. Fetch current points to safely increment
      const { data: profile } = await supabase
        .from("profiles")
        .select("points")
        .eq("id", session.user.id)
        .maybeSingle();

      if (!profile) {
        // Create profile if missing
        await supabase.from("profiles").upsert({
          id: session.user.id,
          full_name:
            session.user.user_metadata?.full_name ||
            session.user.email?.split("@")[0] ||
            "Explorer",
          points: pts,
        });
      } else {
        // 3. Update points safely
        const currentPts = profile.points || 0;
        await supabase
          .from("profiles")
          .update({ points: currentPts + pts })
          .eq("id", session.user.id);
      }

      // Refresh
      await loadData();
    } catch (e: any) {
      console.error("Error completing quest:", e);
    } finally {
      setIsSubmitting(false);
      setFlowStep("completed");
    }
  };

  const startQuestFlow = (quest: any) => {
    setActiveFlowQuest(quest);
    setFlowStep("intro");
    setQuizSelection(null);
  };

  const advanceFlow = () => {
    if (flowStep === "intro") {
      setFlowStep("checking_location");

      // Real GPS usage
      if ("geolocation" in navigator) {
        navigator.geolocation.getCurrentPosition(
          (position) => {
            // Once we have a location, we allow proceeding
            setTimeout(() => {
              setFlowStep("quiz");
            }, 1000);
          },
          (error) => {
            console.warn("GPS error", error);
            // Even if it fails (e.g., permissions denied), let them proceed for demo
            setTimeout(() => {
              setFlowStep("quiz");
            }, 1000);
          },
          { enableHighAccuracy: true }, // Request high accuracy for mobile GPS
        );
      } else {
        // Fallback if no geolocation
        setTimeout(() => {
          setFlowStep("quiz");
        }, 2000);
      }
    } else if (flowStep === "quiz") {
      if (quizSelection !== null) {
        handleCompleteQuest(activeFlowQuest.id, activeFlowQuest.points);
      }
    } else if (flowStep === "completed") {
      setActiveFlowQuest(null);
    }
  };

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full sm:max-w-[430px] shadow-[0_0_40px_rgba(0,0,0,0.5)] bg-[#100E0A] pb-32 overflow-hidden">
        {/* Decorative blurs */}
        <div className="absolute top-[-84px] right-[178px] w-[300px] h-[300px] rounded-full bg-[#F4A261]/5 blur-[60px] pointer-events-none" />
        <div className="absolute top-[151px] left-[-37px] w-[250px] h-[250px] rounded-full bg-[#B752B7]/5 blur-[50px] pointer-events-none" />

        {/* Header */}
        <div className="flex items-center justify-between px-6 pt-12 pb-0 relative">
          <div>
            <h1 className="text-[#FEFBE0] text-[32px] font-extrabold leading-[48px] tracking-[-0.8px]">
              Quests
            </h1>
            <p className="text-[#FEFAE0]/60 text-sm font-medium leading-5">
              Protect and Discover Heritage
            </p>
          </div>
          <button className="w-11 h-11 flex items-center justify-center rounded-full border border-[#F4A261]/15 bg-white/5 flex-shrink-0">
            <svg
              width="18"
              height="20"
              viewBox="0 0 18 20"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <g clipPath="url(#clip_bell)">
                <path
                  d="M8.86021 0C8.16881 0 7.61021 0.558593 7.61021 1.25V1.94922C4.77818 2.39843 2.61021 4.85157 2.61021 7.8125V9.11719C2.61021 10.8906 2.00474 12.6133 0.899273 13.9961L0.317242 14.7266C0.0906792 15.0078 0.0477105 15.3946 0.203961 15.7188C0.360211 16.043 0.688335 16.25 1.04771 16.25H16.6728C17.0321 16.25 17.3602 16.043 17.5164 15.7188C17.6728 15.3946 17.6298 15.0078 17.4032 14.7266L16.8212 14C15.7156 12.6133 15.1102 10.8906 15.1102 9.11719V7.8125C15.1102 4.85157 12.9422 2.39843 10.1102 1.94922V1.25C10.1102 0.558593 9.55162 0 8.86021 0ZM8.86021 3.75H9.17271C11.4149 3.75 13.2352 5.57031 13.2352 7.8125V9.11719C13.2352 10.9883 13.7782 12.8124 14.786 14.375H2.93443C3.94224 12.8124 4.48521 10.9883 4.48521 9.11719V7.8125C4.48521 5.57031 6.30553 3.75 8.54771 3.75H8.86021ZM11.3602 17.5H8.86021H6.36021C6.36021 18.1641 6.62193 18.8008 7.09068 19.2696C7.55943 19.7383 8.19615 20 8.86021 20C9.52427 20 10.161 19.7383 10.6297 19.2696C11.0985 18.8008 11.3602 18.1641 11.3602 17.5Z"
                  fill="#FEFBE0"
                />
              </g>
              <defs>
                <clipPath id="clip_bell">
                  <rect width="18" height="20" fill="white" />
                </clipPath>
              </defs>
            </svg>
          </button>
        </div>

        <div className="px-6 pt-8 flex flex-col gap-8">
          {/* Heritage Protector Card */}
          <div className="rounded-[32px] border border-[#F4A261]/10 bg-white/5 p-6 overflow-hidden relative">
            <div className="flex flex-col gap-5">
              {/* Top row: label + level badge */}
              <div className="flex items-start justify-between">
                <div className="flex flex-col gap-1">
                  <span className="text-[#F4A262] text-[10px] font-bold tracking-[2px] uppercase leading-[15px]">
                    Heritage Protector
                  </span>
                  <div className="flex items-baseline gap-2">
                    <span className="text-[#FEFBE0] text-[36px] font-extrabold leading-10">
                      {userScore.toLocaleString()}
                    </span>
                    <span className="text-[#E9C46A] text-sm font-medium leading-5">
                      Points Earned
                    </span>
                  </div>
                  <div className="text-[#E9C46A]/60 text-xs">
                    Global Rank: #{userRank !== null ? userRank : "-"}
                  </div>
                </div>
                <div className="w-12 h-12 rounded-full bg-[#F4A261]/10 flex items-center justify-center flex-shrink-0">
                  <span className="text-[#F4A262] text-lg font-bold leading-7">
                    Lvl 4
                  </span>
                </div>
              </div>

              {/* Progress */}
              <div className="flex flex-col gap-2">
                <div className="flex justify-between items-center">
                  <span className="text-[#FEFAE0]/60 text-xs font-medium leading-4">
                    Progress to Level 5
                  </span>
                  <span className="text-[#F4A261] text-xs font-bold leading-4">
                    75%
                  </span>
                </div>
                <div className="h-2 rounded-full bg-[#2E1E12] overflow-hidden">
                  <div className="h-full w-3/4 rounded-full bg-gradient-to-r from-[#F4A262] to-[#FFC496] shadow-[0_0_10px_0_rgba(244,162,98,0.50)]" />
                </div>
              </div>
            </div>
          </div>

          {/* Top Users */}
          <div className="flex flex-col gap-4">
            <div className="flex justify-between items-end px-2">
              <h2 className="text-[#FEFBE0] text-xl font-bold leading-7">
                Top Users
              </h2>
              <span className="text-[#F4A261] text-[10px] font-bold tracking-[2px] uppercase leading-[15px]">
                Season 4
              </span>
            </div>

            <div className="rounded-[32px] border border-[#F4A261]/10 bg-white/5 overflow-hidden">
              {leaderboard.map((user, i) => (
                <div
                  key={user.rank}
                  className={`flex items-center gap-4 px-5 py-4 ${i < leaderboard.length - 1 ? "border-b border-[#FEFBE0]/5" : ""}`}
                >
                  <span className="text-[#FEFAE0]/40 text-sm font-medium w-4 text-center">
                    {user.rank}
                  </span>
                  <div className="flex-1 min-w-0">
                    <p className="text-[#FEFBE0] text-sm font-semibold leading-5 truncate">
                      {user.name}
                    </p>
                    <p className="text-[#FEFAE0]/40 text-xs leading-4">
                      {user.city}
                    </p>
                  </div>
                  <span className="text-[#FEFBE0] text-sm font-bold">
                    {user.score}
                  </span>
                </div>
              ))}
            </div>

            <div className="flex flex-col gap-3 mt-4">
              <h2 className="text-[#FEFBE0] text-xl font-bold leading-7 px-2 mb-2">
                Available Quests
              </h2>
              {activeQuests.length === 0 && (
                <p className="px-2 text-white/50 text-sm">
                  No new quests available right now! Try again later.
                </p>
              )}
              {activeQuests.map((quest) => (
                <div
                  key={quest.id}
                  className="rounded-[32px] border bg-white/5 p-5 overflow-hidden relative flex flex-col gap-3"
                  style={{
                    borderColor: quest.border ?? "rgba(244,162,97,0.10)",
                  }}
                >
                  {/* Decorative blur */}
                  <div
                    className="absolute -right-10 -top-10 w-32 h-32 rounded-full blur-[32px] pointer-events-none"
                    style={{ background: quest.accent }}
                  />

                  <div className="flex items-start justify-between relative">
                    <div className="flex items-center gap-4">
                      <div className="w-10 h-12 rounded-2xl border border-[#F4A261]/10 bg-[#1F160E] flex items-center justify-center text-2xl leading-8 flex-shrink-0">
                        {quest.icon || "🏆"}
                      </div>
                      <div>
                        <h3 className="text-[#FEFBE0] text-base font-bold leading-6">
                          {quest.title}
                        </h3>
                        <p className="text-[#FEFAE0]/60 text-xs leading-4 mt-0.5">
                          {quest.description}
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center justify-between mt-2 font-sans relative z-10">
                    <span className="text-[#E9C46A] text-xs font-bold leading-[15px] p-2 bg-[#E9C46A]/10 rounded-lg">
                      +{quest.points} PTS
                    </span>
                    <button
                      onClick={() => startQuestFlow(quest)}
                      className="px-4 py-2 bg-[#F4A261] hover:bg-[#F4A261]/80 text-[#100E0A] rounded-full text-xs font-bold uppercase tracking-wider transition-all"
                    >
                      Start
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Completed History */}
          {completedQuests.length > 0 && (
            <div className="flex flex-col gap-4">
              <h2 className="text-[#FEFBE0] text-xl font-bold leading-7 px-2">
                Completed Quests
              </h2>

              {completedQuests.map((quest, i) => (
                <div
                  key={i}
                  className="rounded-[32px] border border-[#F4A261]/10 bg-[#241B13] p-5 flex items-center gap-4 mb-2"
                >
                  <div className="w-14 h-14 rounded-2xl border border-[#F4A261]/10 bg-[#1F160E] flex items-center justify-center text-2xl leading-8 flex-shrink-0">
                    {quest?.icon || "⛩️"}
                  </div>
                  <div className="flex-1 min-w-0 flex flex-col gap-1">
                    <h3 className="text-[#F4A261] text-base font-bold leading-6">
                      {quest?.title || "Unknown Quest"}
                    </h3>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="bg-[#1F160E] rounded-full px-2 py-0.5 text-[#F4A261] text-[9px] font-bold tracking-[0.45px] uppercase leading-[13.5px]">
                        Claimed
                      </span>
                      <span className="text-[#E9C46A] text-[10px] font-bold leading-[15px]">
                        +{quest?.points || 0} PTS
                      </span>
                    </div>
                  </div>
                  <div className="w-8 h-8 rounded-full bg-[#F4A261] shadow-[0_0_15px_0_rgba(244,162,97,0.30)] flex items-center justify-center flex-shrink-0">
                    <svg
                      width="11"
                      height="10"
                      viewBox="0 0 11 10"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        d="M10.2797 2.47031C10.5727 2.76328 10.5727 3.23906 10.2797 3.53203L4.27974 9.53203C3.98677 9.82499 3.51099 9.82499 3.21802 9.53203L0.218018 6.53203C-0.0749512 6.23906 -0.0749512 5.76328 0.218018 5.47031C0.510986 5.17734 0.986768 5.17734 1.27974 5.47031L3.75005 7.93828L9.22036 2.47031C9.51333 2.17734 9.98911 2.17734 10.2821 2.47031H10.2797Z"
                        fill="#100E0A"
                      />
                    </svg>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Quest Action Dialog (Modal overlay) */}
        {activeFlowQuest && (
          <div className="fixed inset-0 z-[200] flex items-center justify-center px-4 bg-black/80 backdrop-blur-md">
            <div className="w-full max-w-[380px] bg-[#241B13] border border-[#F4A261]/20 rounded-[32px] p-6 flex flex-col items-center text-center shadow-2xl relative overflow-hidden">
              <div className="absolute top-[-50px] bg-[#F4A261]/10 rounded-full w-[200px] h-[200px] blur-[50px] -z-10" />

              <button
                onClick={() => setActiveFlowQuest(null)}
                className="absolute top-4 right-4 text-white/50 hover:text-white"
              >
                <svg
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M18 6 6 18" />
                  <path d="m6 6 12 12" />
                </svg>
              </button>

              <div className="w-16 h-16 rounded-full bg-[#1F160E] border border-[#F4A261]/20 flex items-center justify-center text-3xl mb-4 relative z-10">
                {activeFlowQuest.icon || "🗺️"}
                {flowStep === "checking_location" && (
                  <div className="absolute inset-0 rounded-full border-2 border-[#52B788] animate-ping opacity-75"></div>
                )}
              </div>

              <h3 className="text-xl font-bold text-[#FEFBE0] mb-2">
                {activeFlowQuest.title}
              </h3>

              {flowStep === "intro" && (
                <>
                  <p className="text-white/70 text-sm mb-6">
                    {activeFlowQuest.description}
                  </p>
                  <div className="bg-[#F4A261]/10 text-[#F4A261] px-4 py-2 rounded-xl mb-6 font-bold text-sm">
                    Reward: +{activeFlowQuest.points} PTS
                  </div>
                  <button
                    onClick={advanceFlow}
                    className="w-full py-3 bg-[#F4A261] hover:bg-[#F4A261]/80 text-[#100E0A] rounded-2xl font-bold uppercase tracking-wide transition-all"
                  >
                    Confirm Location
                  </button>
                </>
              )}

              {flowStep === "checking_location" && (
                <div className="py-8 flex flex-col items-center">
                  <p className="text-[#52B788] font-bold text-base mb-2">
                    Verifying Location...
                  </p>
                  <p className="text-white/50 text-xs">
                    Accessing GPS coordinates
                  </p>
                </div>
              )}

              {flowStep === "quiz" && (
                <div className="w-full flex flex-col items-center">
                  <div className="text-[#52B788] font-bold text-sm mb-4 bg-[#52B788]/10 px-3 py-1 rounded-full">
                    Location Verified ✓
                  </div>
                  <p className="text-white/90 text-sm mb-4 font-medium">
                    To complete this quest, answer the guardian's question:
                  </p>

                  <div className="w-full text-left bg-black/20 p-4 rounded-2xl mb-4 border border-white/5">
                    <p className="text-white text-sm mb-4 leading-relaxed">
                      What is a key historical or ecological fact associated
                      with this location?
                    </p>

                    <div className="flex flex-col gap-2">
                      {[
                        "Built to protect the coast / Endemic ecosystem",
                        "Created within the last decade",
                        "A shopping complex",
                      ].map((opt, idx) => (
                        <button
                          key={idx}
                          onClick={() => setQuizSelection(idx)}
                          className={`w-full text-left px-4 py-3 rounded-xl border transition-all text-sm ${
                            quizSelection === idx
                              ? "bg-[#F4A261]/20 border-[#F4A261] text-[#F4A261]"
                              : "bg-white/5 border-white/5 text-white/70 hover:bg-white/10"
                          }`}
                        >
                          {opt}
                        </button>
                      ))}
                    </div>
                  </div>

                  <button
                    onClick={advanceFlow}
                    disabled={quizSelection !== 0 && quizSelection !== null}
                    className={`w-full py-3 rounded-2xl font-bold uppercase tracking-wide transition-all ${
                      quizSelection === 0 && !isSubmitting
                        ? "bg-[#52B788] text-white shadow-[0_0_15px_rgba(82,183,136,0.3)]"
                        : "bg-white/10 text-white/30 cursor-not-allowed"
                    }`}
                  >
                    {isSubmitting
                      ? "Claiming..."
                      : quizSelection === 0
                        ? "Claim Reward"
                        : "Select Correct Answer"}
                  </button>
                </div>
              )}

              {flowStep === "completed" && (
                <div className="py-4 flex flex-col items-center">
                  <div className="w-16 h-16 rounded-full bg-[#52B788]/20 text-[#52B788] flex items-center justify-center text-3xl mb-4">
                    ✓
                  </div>
                  <h4 className="text-xl font-bold text-white mb-2">
                    Quest Completed!
                  </h4>
                  <p className="text-[#F4A261] font-bold text-lg mb-6">
                    +{activeFlowQuest.points} PTS
                  </p>
                  <button
                    onClick={advanceFlow}
                    className="w-full py-3 bg-white/10 hover:bg-white/20 text-white rounded-2xl font-bold uppercase tracking-wide transition-all"
                  >
                    Close
                  </button>
                </div>
              )}
            </div>
          </div>
        )}

        <BottomNav />
      </div>
    </div>
  );
}
