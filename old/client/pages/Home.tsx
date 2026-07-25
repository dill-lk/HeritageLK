import { Link } from "react-router-dom";
import { Sparkles } from "lucide-react";
import BottomNav from "@/components/BottomNav";
import ShingoLogo from "@/components/ShingoLogo";
import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";

export default function Home() {
  const [userScore, setUserScore] = useState<number>(0);
  const [userRank, setUserRank] = useState<number | null>(null);
  const [placesVisited, setPlacesVisited] = useState<number>(0);
  const [userName, setUserName] = useState("Explorer");
  const [userEmail, setUserEmail] = useState("");

  const [triggering, setTriggering] = useState(false);

  const triggerArchives = async () => {
    setTriggering(true);
    try {
      const {
        data: { session },
      } = await supabase!.auth.getSession();
      const token = session?.access_token;

      const promises = [];
      for (let i = 0; i < 5; i++) {
        promises.push(
          fetch("/api/cron/generate-daily", {
            method: "POST",
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }).then((res) => res.json()),
        );
      }
      const results = await Promise.allSettled(promises);
      const errors = results
        .filter((r) => r.status === "fulfilled" && r.value?.error)
        .map((r) => (r as any).value?.error);
      if (errors.length > 0) {
        alert("Completed with some errors: " + JSON.stringify(errors[0]));
      } else {
        alert("Triggered 5 archives successfully.");
      }
    } catch (e: any) {
      alert("Error: " + e.message);
    } finally {
      setTriggering(false);
    }
  };

  useEffect(() => {
    async function fetchPoints() {
      if (!supabase) return;
      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (!session?.user) return;
      setUserEmail(session.user.email || "");

      let defaultName =
        session.user.user_metadata?.full_name ||
        session.user.email?.split("@")[0] ||
        "Explorer";
      setUserName(defaultName.split(" ")[0]);

      try {
        const { data, error } = await supabase
          .from("profiles")
          .select("points, full_name")
          .eq("id", session.user.id)
          .maybeSingle();

        if (!error && data) {
          setUserScore(data.points || 0);
          if (data.full_name) {
            setUserName(data.full_name.split(" ")[0]);
          }

          const { count } = await supabase
            .from("profiles")
            .select("*", { count: "exact", head: true })
            .gt("points", data.points || 0);
          setUserRank((count || 0) + 1);
        }

        const { count: placesCount } = await supabase
          .from("user_quests")
          .select("*", { count: "exact", head: true })
          .eq("user_id", session.user.id);
        setPlacesVisited(placesCount || 0);
      } catch (e) {
        console.warn("Could not fetch user points", e);
      }
    }

    fetchPoints();
  }, []);

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex flex-col font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full max-w-7xl mx-auto bg-[#100E0A] pb-32">
        {/* Header */}
        <div className="flex items-center justify-between px-6 pt-12 pb-6">
          <div className="flex items-center gap-[10px]">
            <img
              src="https://api.builder.io/api/v1/image/assets/TEMP/8ac6e4f2918cb1ade2b53e903533707e4b93794a?width=88"
              alt="Avatar"
              className="w-11 h-11 rounded-full border-2 border-[#52B788]/30"
            />
            <div className="flex flex-col">
              <span className="text-[#FEFAE0]/60 text-xs font-medium tracking-[0.6px] uppercase leading-4">
                Explorer
              </span>
              <span className="text-[#FEFBE0] text-lg font-bold leading-7">
                Hello {userName}!
              </span>
            </div>
          </div>
          <Link
            to="/profile"
            className="w-11 h-11 rounded-full border border-[#52B788]/15 bg-white/5 flex items-center justify-center transition-colors hover:bg-white/10"
          >
            <svg
              width="20"
              height="20"
              viewBox="0 0 25 20"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M8.75 10C10.0761 10 11.3479 9.47322 12.2855 8.53553C13.2232 7.59785 13.75 6.32608 13.75 5C13.75 3.67392 13.2232 2.40215 12.2855 1.46447C11.3479 0.526784 10.0761 0 8.75 0C7.42392 0 6.15215 0.526784 5.21447 1.46447C4.27678 2.40215 3.75 3.67392 3.75 5C3.75 6.32608 4.27678 7.59785 5.21447 8.53553C6.15215 9.47322 7.42392 10 8.75 10ZM6.96484 11.875C3.11719 11.875 0 14.9922 0 18.8398C0 19.4805 0.519531 20 1.16016 20H16.3398C16.4102 20 16.4766 19.9922 16.5469 19.9805C13.5664 17.8281 12.6484 14.4727 12.5195 12.1602C11.8906 11.9727 11.2266 11.875 10.5391 11.875H6.96484ZM19.0273 8.81641L14.3398 10.6914C13.9844 10.8359 13.75 11.1797 13.75 11.5625C13.75 14.0352 14.7617 18.1562 19.0156 19.9297C19.2461 20.0273 19.5078 20.0273 19.7383 19.9297C23.9883 18.1562 25 14.0352 25 11.5625C25 11.1797 24.7656 10.8359 24.4102 10.6914L19.7227 8.81641C19.5 8.72656 19.25 8.72656 19.0273 8.81641ZM23.1016 12.1875C22.9492 14.168 22.0391 16.7461 19.375 18.0352V10.6953L23.1016 12.1875Z"
                fill="#FEFBE0"
              />
            </svg>
          </Link>
        </div>

        {/* Hero Section */}
        <div className="px-6 md:flex md:items-center md:justify-between md:gap-12 mb-10">
          <div className="md:flex-1">
            <p className="text-[#52B788] text-sm font-semibold tracking-[2px] uppercase leading-5 mb-[7px]">
              Welcome {userName}!
            </p>
            <div className="mb-6">
              <p className="text-[#FEFBE0] text-[42px] md:text-[64px] font-extrabold md:leading-[70px] leading-[46.2px] tracking-[-1.05px]">
                Protect.
                <br />
                Discover.
              </p>
              <p className="text-[#F4A261] text-[42px] md:text-[64px] italic font-normal md:leading-[70px] leading-[46.2px] tracking-[-1.05px] font-['Playfair_Display',serif]">
                Celebrate.
              </p>
            </div>

            {/* Stat Badges */}
            <div className="flex flex-wrap gap-3 mb-8">
              <div className="flex items-center gap-2 h-[38px] px-4 rounded-full border border-[#52B788]/20 bg-white/5">
                <svg
                  width="10"
                  height="13"
                  viewBox="0 0 10 13"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <g clipPath="url(#clip_place)">
                    <path
                      d="M5.60176 12.675C6.90429 11.0449 9.875 7.09414 9.875 4.875C9.875 2.18359 7.69141 0 5 0C2.30859 0 0.125 2.18359 0.125 4.875C0.125 7.09414 3.09571 11.0449 4.39824 12.675C4.71054 13.0635 5.28946 13.0635 5.60176 12.675ZM5 3.25C5.43097 3.25 5.84431 3.42121 6.14905 3.72595C6.45379 4.03069 6.625 4.44403 6.625 4.875C6.625 5.30597 6.45379 5.71931 6.14905 6.02405C5.84431 6.32879 5.43097 6.5 5 6.5C4.56903 6.5 4.15569 6.32879 3.85095 6.02405C3.54621 5.71931 3.375 5.30597 3.375 4.875C3.375 4.44403 3.54621 4.03069 3.85095 3.72595C4.15569 3.42121 4.56903 3.25 5 3.25Z"
                      fill="#52B788"
                    />
                  </g>
                  <defs>
                    <clipPath id="clip_place">
                      <rect width="10" height="13" fill="white" />
                    </clipPath>
                  </defs>
                </svg>
                <span className="text-[#FEFBE0] text-sm font-medium">
                  {placesVisited} Places Visited
                </span>
              </div>
              <div className="flex items-center gap-2 h-[38px] px-4 rounded-full border border-[#52B788]/20 bg-white/5">
                <svg
                  width="14"
                  height="14"
                  viewBox="0 0 14 14"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <g clipPath="url(#clip_star)">
                    <path
                      d="M7.38929 0.992779C7.25551 0.715134 6.97282 0.538452 6.66236 0.538452C6.35191 0.538452 6.07174 0.715134 5.93544 0.992779L4.31248 4.33209L0.687963 4.86718C0.385079 4.91261 0.132675 5.12463 0.0392853 5.41489C-0.0541042 5.70516 0.021617 6.02571 0.238684 6.24025L2.86873 8.84254L2.24782 12.5201C2.19734 12.8229 2.32354 13.1309 2.57342 13.3101C2.8233 13.4893 3.15395 13.512 3.42654 13.3682L6.66488 11.6392L9.90322 13.3682C10.1758 13.512 10.5065 13.4918 10.7564 13.3101C11.0063 13.1283 11.1325 12.8229 11.082 12.5201L10.4585 8.84254L13.0886 6.24025C13.3056 6.02571 13.3839 5.70516 13.2879 5.41489C13.1921 5.12463 12.9421 4.91261 12.6393 4.86718L9.01224 4.33209L7.38929 0.992779Z"
                      fill="#E9C46A"
                    />
                  </g>
                  <defs>
                    <clipPath id="clip_star">
                      <rect width="14" height="14" fill="white" />
                    </clipPath>
                  </defs>
                </svg>
                <span className="text-[#FEFBE0] text-sm font-medium">
                  {userScore.toLocaleString()} Points
                </span>
              </div>
              <div className="flex items-center gap-2 h-[38px] px-4 rounded-full border border-[#52B788]/20 bg-white/5">
                <svg
                  width="14"
                  height="14"
                  viewBox="0 0 14 14"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    d="M9.375 1H4.125C3.50391 1 2.99766 1.51094 3.02109 2.12969C3.02578 2.25391 3.03047 2.37812 3.0375 2.5H0.5625C0.250781 2.5 0 2.75078 0 3.0625C0 5.23281 0.785156 6.74219 1.83984 7.76641C2.87812 8.77656 4.14375 9.28516 5.07656 9.54297C5.625 9.69531 6 10.1523 6 10.6117C6 11.1016 5.60156 11.5 5.11172 11.5H4.5C4.08516 11.5 3.75 11.8352 3.75 12.25C3.75 12.6648 4.08516 13 4.5 13H9C9.41484 13 9.75 12.6648 9.75 12.25C9.75 11.8352 9.41484 11.5 9 11.5H8.38828C7.89844 11.5 7.5 11.1016 7.5 10.6117C7.5 10.1523 7.87266 9.69297 8.42344 9.54297C9.35859 9.28516 10.6242 8.77656 11.6625 7.76641C12.7148 6.74219 13.5 5.23281 13.5 3.0625C13.5 2.75078 13.2492 2.5 12.9375 2.5H10.4625C10.4695 2.37812 10.4742 2.25625 10.4789 2.12969C10.5023 1.51094 9.99609 1 9.375 1ZM1.14609 3.625H3.12422C3.3375 5.73672 3.80859 7.14766 4.34062 8.09219C3.75703 7.83438 3.15 7.47109 2.625 6.96016C1.875 6.23125 1.26562 5.17891 1.14844 3.625H1.14609ZM10.8773 6.96016C10.3523 7.47109 9.74531 7.83438 9.16172 8.09219C9.69375 7.14766 10.1648 5.73672 10.3781 3.625H12.3563C12.2367 5.17891 11.6273 6.23125 10.8797 6.96016H10.8773Z"
                    fill="#52B788"
                  />
                </svg>
                <span className="text-[#FEFBE0] text-sm font-medium">
                  Rank #{userRank !== null ? userRank : "-"}
                </span>
              </div>
            </div>
          </div>

          {/* Community Alert */}
          <div className="md:w-1/3 flex items-start gap-3 p-4 rounded-2xl border border-[#F4A261]/20 bg-[#F4A261]/10 self-start">
            <span className="text-xl flex-shrink-0 leading-7">⚠️</span>
            <p className="flex-1 text-[#F4A261] text-sm font-medium leading-[22.75px]">
              Community Report: Damage detected at Galle Fort. Tap to verify.
            </p>
            <svg
              width="8"
              height="14"
              viewBox="0 0 8 14"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              className="flex-shrink-0 mt-1"
            >
              <g clipPath="url(#clip_arrow_alert)">
                <path
                  d="M7.49458 5.93286C7.86267 6.30095 7.86267 6.89873 7.49458 7.26681L1.84073 12.9207C1.47264 13.2888 0.874869 13.2888 0.50678 12.9207C0.138691 12.5526 0.138691 11.9548 0.50678 11.5867L5.49512 6.59836L0.509724 1.61002C0.141635 1.24193 0.141635 0.644156 0.509724 0.276067C0.877813 -0.0920223 1.47559 -0.0920223 1.84367 0.276067L7.49752 5.92992L7.49458 5.93286Z"
                  fill="#F4A261"
                  fillOpacity="0.6"
                />
              </g>
              <defs>
                <clipPath id="clip_arrow_alert">
                  <rect width="8" height="14" fill="white" />
                </clipPath>
              </defs>
            </svg>
          </div>
        </div>

        {/* Desktop Layout Split */}
        <div className="md:grid md:grid-cols-2 md:gap-8 px-6">
          <div className="flex flex-col gap-6">
            {/* Report Damages Card */}
            <Link
              to="/report-damage"
              className="rounded-[28px] border border-[#F4A261]/20 bg-white/5 p-4 block hover:bg-white/10 transition-colors"
            >
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <span className="text-[30px] leading-[36px] block mb-2">⚠️</span>
                  <h3 className="text-[#FEFBE0] text-lg font-bold leading-7">
                    Report Damages
                  </h3>
                  <p className="text-[#FEFAE0]/60 text-xs leading-4 mt-0.5">
                    Help us preserve our heritage by reporting any issues you see.
                  </p>
                </div>
                <div className="w-7 h-7 flex items-center justify-center rounded-full bg-[#F4A261]/20 flex-shrink-0 mt-2.5">
                  <svg
                    width="20"
                    height="20"
                    viewBox="0 0 20 20"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <g clipPath="url(#clip_arrow_rd)">
                      <path
                        d="M18.7009 10.6594C19.2136 10.1468 19.2136 9.31413 18.7009 8.80144L12.1384 2.23894C11.6257 1.72624 10.7931 1.72624 10.2804 2.23894C9.76773 2.75163 9.76773 3.58425 10.2804 4.09694L14.6076 8.42L2.02398 8.42C1.29801 8.41999 0.711478 9.00652 0.711476 9.7325C0.711487 10.4585 1.29801 11.045 2.02398 11.045L14.6035 11.045L10.2845 15.3681C9.77183 15.8807 9.77184 16.7134 10.2845 17.2261C10.7972 17.7387 11.6298 17.7388 12.1425 17.2261L18.705 10.6636L18.7009 10.6594Z"
                        fill="#F4A261"
                      />
                    </g>
                    <defs>
                      <clipPath id="clip_arrow_rd">
                        <rect
                          width="14"
                          height="14"
                          fill="white"
                          transform="translate(9.8995) rotate(45)"
                        />
                      </clipPath>
                    </defs>
                  </svg>
                </div>
              </div>
            </Link>

            {/* Feature Grid */}
            <div className="grid grid-cols-2 gap-4">
              {/* Scanner */}
              <Link
                to="/scanner"
                className="rounded-[32px] border border-[#52B788]/20 bg-white/5 overflow-hidden flex flex-col justify-end p-5 relative min-h-[220px] transition-all hover:bg-white/10 hover:border-[#52B788]/40"
              >
                <div className="absolute bottom-20 left-6 w-24 h-24 rounded-full bg-[#52B788]/10 blur-[20px] pointer-events-none" />
                <div className="relative z-10 flex flex-col gap-2">
                  <span className="text-4xl leading-10">📸</span>
                  <div>
                    <h3 className="text-[#FEFBE0] text-xl font-bold leading-7">
                      Scanner
                    </h3>
                    <p className="text-[#FEFAE0]/60 text-xs leading-[15px]">
                      Identify Heritage and Wildlife
                    </p>
                  </div>
                </div>
              </Link>

              <div className="flex flex-col gap-4">
                {/* Map */}
                <Link
                  to="/explore"
                  className="rounded-[28px] border border-[#2D6A4F]/30 bg-white/5 p-4 flex flex-col justify-between h-[100px] transition-all hover:bg-white/10 hover:border-[#2D6A4F]/60"
                >
                  <div className="flex justify-between items-start">
                    <span className="text-2xl leading-9">🗺️</span>
                    <div className="w-7 h-7 flex items-center justify-center rounded-full bg-[#2D6A4F]/20">
                      <svg width="14" height="14" viewBox="0 0 20 20" fill="none">
                        <path
                          d="M18.7009 10.6594C19.2136 10.1468 19.2136 9.31413 18.7009 8.80144L12.1384 2.23894L2.02398 8.42L14.6035 11.045L10.2845 15.3681L18.705 10.6636Z"
                          fill="#2D6A4F"
                        />
                      </svg>
                    </div>
                  </div>
                  <h3 className="text-[#FEFBE0] text-sm font-bold leading-5">Map</h3>
                </Link>

                {/* Archive */}
                <Link
                  to="/archive"
                  className="rounded-[28px] border border-[#F4A261]/20 bg-white/5 p-4 flex flex-col justify-between h-[100px] transition-all hover:bg-white/10 hover:border-[#F4A261]/40"
                >
                  <div className="flex justify-between items-start">
                    <span className="text-2xl leading-9">📖</span>
                    <div className="w-7 h-7 flex items-center justify-center rounded-full bg-[#F4A261]/20">
                      <svg width="14" height="14" viewBox="0 0 20 20" fill="none">
                        <path
                          d="M18.7009 10.6594C19.2136 10.1468 19.2136 9.31413 18.7009 8.80144L12.1384 2.23894L2.02398 8.42L14.6035 11.045L10.2845 15.3681L18.705 10.6636Z"
                          fill="#F4A261"
                        />
                      </svg>
                    </div>
                  </div>
                  <h3 className="text-[#FEFBE0] text-sm font-bold leading-5">Archive</h3>
                </Link>
              </div>
            </div>
          </div>

          <div className="flex flex-col gap-6 mt-6 md:mt-0">
            {/* Shingo AI Banner */}
            <Link
              to="/archive/shingo"
              className="rounded-[28px] border border-[#E9C46A]/30 bg-[#E9C46A]/5 overflow-hidden relative block group transition-all hover:bg-[#E9C46A]/10 min-h-[120px] flex items-center shadow-[0_10px_30px_rgba(0,0,0,0.3)]"
            >
              <div className="absolute -right-4 -bottom-4 w-32 h-32 rounded-full bg-[#E9C46A]/10 blur-[30px] pointer-events-none transition-transform group-hover:scale-150" />
              <div className="flex items-center p-6 gap-5 relative z-10 w-full">
                <div className="w-[60px] h-[60px] flex items-center justify-center rounded-full bg-[#E9C46A]/20 flex-shrink-0 group-hover:scale-110 transition-transform shadow-[0_0_20px_rgba(233,196,106,0.3)]">
                  <ShingoLogo className="w-[32px] h-[32px] text-[#E9C46A]" />
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="text-[#FEFBE0] text-xl font-bold leading-7 flex items-center gap-2">
                    Shingo AI <Sparkles className="w-5 h-5 text-[#E9C46A]" />
                  </h3>
                  <p className="text-[#FEFAE0]/70 text-sm leading-relaxed mt-1">
                    Your personal AI guide to Sri Lankan heritage. Ask anything about history, culture, or sites.
                  </p>
                </div>
              </div>
            </Link>

            {/* Quests Banner */}
            <Link
              to="/quests"
              className="rounded-[28px] border border-[#B752B7]/30 bg-white/5 overflow-hidden relative block group transition-all hover:bg-white/10 min-h-[100px] flex items-center"
            >
              <div className="absolute -left-4 top-0 w-24 h-24 rounded-full bg-[#B752B7]/10 blur-[20px] pointer-events-none transition-transform group-hover:scale-150" />
              <div className="flex items-center p-6 gap-4 relative z-10 w-full">
                <span className="text-4xl leading-10 flex-shrink-0 group-hover:scale-110 transition-transform">
                  🎮
                </span>
                <div className="flex-1 min-w-0">
                  <h3 className="text-[#FEFBE0] text-lg font-bold leading-7">
                    Quests
                  </h3>
                  <p className="text-[#FEFAE0]/60 text-xs leading-[16.5px]">
                    Complete challenges to earn points and compete with others on the leaderboard.
                  </p>
                </div>
              </div>
            </Link>

            {/* Admin Banner */}
            {userEmail === "dill.ruzz.official@gmail.com" && (
              <div
                onClick={triggerArchives}
                className="cursor-pointer rounded-[28px] border border-red-500/30 bg-red-500/10 overflow-hidden relative block group transition-colors hover:bg-red-500/20"
              >
                <div className="flex items-center p-5 gap-3 relative z-10">
                  <div className="w-[42px] h-[42px] flex items-center justify-center rounded-full bg-red-500/20 flex-shrink-0">
                    <span className="text-xl">🛠️</span>
                  </div>
                  <div className="flex-1">
                    <h3 className="text-red-400 text-lg font-bold leading-7">Admin: Trigger AI</h3>
                    <p className="text-red-400/60 text-xs">Generate 5 AI archives now.</p>
                  </div>
                  {triggering && <span className="animate-spin text-red-500">⏳</span>}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Nearby Heritage */}
        <div className="px-6 pt-12">
          <div className="flex justify-between items-end mb-6">
            <h2 className="text-[#FEFBE0] text-3xl font-bold leading-8 tracking-[-0.445px]">
              Nearby Heritage
            </h2>
            <button className="text-[#52B788] text-sm font-bold leading-4 tracking-[0.6px] uppercase hover:underline">
              See All
            </button>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {/* Galle Fort */}
            <div className="rounded-2xl border border-[#52B788]/15 bg-white/5 p-5 transition-transform hover:scale-[1.02]">
              <div className="w-14 h-14 flex items-center justify-center rounded-full bg-[#FEFBE0]/5 mb-4">
                <span className="text-3xl">🏰</span>
              </div>
              <h4 className="text-[#FEFBE0] text-lg font-semibold leading-6 mb-1">
                Galle Fort
              </h4>
              <p className="text-[#FEFAE0]/50 text-sm">1.2 km away</p>
            </div>

            {/* Yatagala Temple */}
            <div className="rounded-2xl border border-[#52B788]/15 bg-white/5 p-5 transition-transform hover:scale-[1.02]">
              <div className="w-14 h-14 flex items-center justify-center rounded-full bg-[#FEFBE0]/5 mb-4">
                <span className="text-3xl">🛕</span>
              </div>
              <h4 className="text-[#FEFBE0] text-lg font-semibold leading-6 mb-1">
                Yatagala Temple
              </h4>
              <p className="text-[#FEFAE0]/50 text-sm">3.5 km away</p>
            </div>
          </div>
        </div>

        <BottomNav />
      </div>
    </div>

  );
}
