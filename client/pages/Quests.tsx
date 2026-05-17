import BottomNav from "@/components/BottomNav";

const leaderboard = [
  { rank: 1, name: "Sanul Randisa", city: "Matara", score: "15.2k" },
  { rank: 2, name: "Jinuk Chanthusa", city: "Matara", score: "11.8k" },
  { rank: 3, name: "Disara Bimsilu", city: "Matara", score: "10.9k" },
];

const activeQuests = [
  {
    icon: "🏰",
    title: "The Fort Guardian",
    description: "Scan 3 watchtowers in Galle Fort",
    pts: "+500\nPTS",
    progress: 75,
    accent: "rgba(183,82,183,0.10)",
  },
  {
    icon: "🌿",
    title: "Forest Secret Finder",
    description: "Identify 5 endemic plants from Kanneliya",
    pts: "+800\nPTS",
    progress: 30,
    accent: "rgba(82,183,136,0.10)",
    border: "rgba(82,183,136,0.20)",
  },
];

export default function Quests() {
  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full max-w-[440px] pb-32 overflow-hidden">

        {/* Decorative blurs */}
        <div className="absolute top-[-84px] right-[178px] w-[300px] h-[300px] rounded-full bg-[#F4A261]/5 blur-[60px] pointer-events-none" />
        <div className="absolute top-[151px] left-[-37px] w-[250px] h-[250px] rounded-full bg-[#B752B7]/5 blur-[50px] pointer-events-none" />

        {/* Header */}
        <div className="flex items-center justify-between px-6 pt-12 pb-0 relative">
          <div>
            <h1 className="text-[#FEFBE0] text-[32px] font-extrabold leading-[48px] tracking-[-0.8px]">Quests</h1>
            <p className="text-[#FEFAE0]/60 text-sm font-medium leading-5">Protect and Discover Heritage</p>
          </div>
          <button className="w-11 h-11 flex items-center justify-center rounded-full border border-[#F4A261]/15 bg-white/5 flex-shrink-0">
            <svg width="18" height="20" viewBox="0 0 18 20" fill="none" xmlns="http://www.w3.org/2000/svg">
              <g clipPath="url(#clip_bell)">
                <path d="M8.86021 0C8.16881 0 7.61021 0.558593 7.61021 1.25V1.94922C4.77818 2.39843 2.61021 4.85157 2.61021 7.8125V9.11719C2.61021 10.8906 2.00474 12.6133 0.899273 13.9961L0.317242 14.7266C0.0906792 15.0078 0.0477105 15.3946 0.203961 15.7188C0.360211 16.043 0.688335 16.25 1.04771 16.25H16.6728C17.0321 16.25 17.3602 16.043 17.5164 15.7188C17.6728 15.3946 17.6298 15.0078 17.4032 14.7266L16.8212 14C15.7156 12.6133 15.1102 10.8906 15.1102 9.11719V7.8125C15.1102 4.85157 12.9422 2.39843 10.1102 1.94922V1.25C10.1102 0.558593 9.55162 0 8.86021 0ZM8.86021 3.75H9.17271C11.4149 3.75 13.2352 5.57031 13.2352 7.8125V9.11719C13.2352 10.9883 13.7782 12.8124 14.786 14.375H2.93443C3.94224 12.8124 4.48521 10.9883 4.48521 9.11719V7.8125C4.48521 5.57031 6.30553 3.75 8.54771 3.75H8.86021ZM11.3602 17.5H8.86021H6.36021C6.36021 18.1641 6.62193 18.8008 7.09068 19.2696C7.55943 19.7383 8.19615 20 8.86021 20C9.52427 20 10.161 19.7383 10.6297 19.2696C11.0985 18.8008 11.3602 18.1641 11.3602 17.5Z" fill="#FEFBE0"/>
              </g>
              <defs>
                <clipPath id="clip_bell"><rect width="18" height="20" fill="white"/></clipPath>
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
                  <span className="text-[#F4A262] text-[10px] font-bold tracking-[2px] uppercase leading-[15px]">Heritage Protector</span>
                  <div className="flex items-baseline gap-2">
                    <span className="text-[#FEFBE0] text-[36px] font-extrabold leading-10">1,240</span>
                    <span className="text-[#E9C46A] text-sm font-medium leading-5">Points Earned</span>
                  </div>
                </div>
                <div className="w-12 h-12 rounded-full bg-[#F4A261]/10 flex items-center justify-center flex-shrink-0">
                  <span className="text-[#F4A262] text-lg font-bold leading-7">Lvl 4</span>
                </div>
              </div>

              {/* Progress */}
              <div className="flex flex-col gap-2">
                <div className="flex justify-between items-center">
                  <span className="text-[#FEFAE0]/60 text-xs font-medium leading-4">Progress to Level 5</span>
                  <span className="text-[#F4A261] text-xs font-bold leading-4">75%</span>
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
              <h2 className="text-[#FEFBE0] text-xl font-bold leading-7">Top Users</h2>
              <span className="text-[#F4A261] text-[10px] font-bold tracking-[2px] uppercase leading-[15px]">Season 4</span>
            </div>

            <div className="rounded-[32px] border border-[#F4A261]/10 bg-white/5 overflow-hidden">
              {leaderboard.map((user, i) => (
                <div
                  key={user.rank}
                  className={`flex items-center gap-4 px-5 py-4 ${i < leaderboard.length - 1 ? "border-b border-[#FEFBE0]/5" : ""}`}
                >
                  <span className="text-[#FEFAE0]/40 text-sm font-medium w-4 text-center">{user.rank}</span>
                  <div className="flex-1 min-w-0">
                    <p className="text-[#FEFBE0] text-sm font-semibold leading-5 truncate">{user.name}</p>
                    <p className="text-[#FEFAE0]/40 text-xs leading-4">{user.city}</p>
                  </div>
                  <span className="text-[#FEFBE0] text-sm font-bold">{user.score}</span>
                </div>
              ))}
            </div>
            <div className="flex-none h-full flex items-center justify-center px-3">
              <button className="w-14 h-14 flex items-center justify-center rounded-full border-4 border-[#241B13] bg-[#F4A261] shadow-[0_0_20px_0_rgba(244,162,97,0.40)]">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M6.98906 3.0375L6.50156 4.5H3C1.34531 4.5 0 5.84531 0 7.5V19.5C0 21.1547 1.34531 22.5 3 22.5H21C22.6547 22.5 24 21.1547 24 19.5V7.5C24 5.84531 22.6547 4.5 21 4.5H17.4984L17.0109 3.0375C16.7062 2.11875 15.8484 1.5 14.8781 1.5H9.12188C8.15156 1.5 7.29375 2.11875 6.98906 3.0375ZM12 9C13.1935 9 14.3381 9.47411 15.182 10.318C16.0259 11.1619 16.5 12.3065 16.5 13.5C16.5 14.6935 16.0259 15.8381 15.182 16.682C14.3381 17.5259 13.1935 18 12 18C10.8065 18 9.66193 17.5259 8.81802 16.682C7.97411 15.8381 7.5 14.6935 7.5 13.5C7.5 12.3065 7.97411 11.1619 8.81802 10.318C9.66193 9.47411 10.8065 9 12 9Z" fill="#241B13"/>
                </svg>
              </button>
            </div>

            <div className="flex flex-col gap-3">
              {activeQuests.map((quest) => (
                <div
                  key={quest.title}
                  className="rounded-[32px] border bg-white/5 p-5 overflow-hidden relative flex flex-col gap-3"
                  style={{ borderColor: quest.border ?? "rgba(244,162,97,0.10)" }}
                >
                  {/* Decorative blur */}
                  <div
                    className="absolute -right-10 -top-10 w-32 h-32 rounded-full blur-[32px] pointer-events-none"
                    style={{ background: quest.accent }}
                  />

                  <div className="flex items-start justify-between relative">
                    <div className="flex items-center gap-4">
                      <div className="w-10 h-12 rounded-2xl border border-[#F4A261]/10 bg-[#1F160E] flex items-center justify-center text-2xl leading-8 flex-shrink-0">
                        {quest.icon}
                      </div>
                      <div>
                        <h3 className="text-[#FEFBE0] text-base font-bold leading-6">{quest.title}</h3>
                        <p className="text-[#FEFAE0]/60 text-xs leading-4 mt-0.5">{quest.description}</p>
                      </div>
                    </div>
                    <span className="text-[#E9C46A] text-[10px] font-bold leading-[15px] text-right whitespace-pre-line flex-shrink-0 ml-2">
                      {quest.pts}
                    </span>
                  </div>

                  <div className="h-2 rounded-full bg-[#2E1E12] overflow-hidden">
                    <div
                      className="h-full rounded-full bg-gradient-to-r from-[#F4A262] to-[#FFC496] shadow-[0_0_10px_0_rgba(244,162,98,0.50)]"
                      style={{ width: `${quest.progress}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Completed Today */}
          <div className="flex flex-col gap-4">
            <h2 className="text-[#FEFBE0] text-xl font-bold leading-7 px-2">Completed Today</h2>

            <div className="rounded-[32px] border border-[#F4A261]/10 bg-[#241B13] p-5 flex items-center gap-4">
              <div className="w-14 h-14 rounded-2xl border border-[#F4A261]/10 bg-[#1F160E] flex items-center justify-center text-2xl leading-8 flex-shrink-0">
                ⛩️
              </div>
              <div className="flex-1 min-w-0 flex flex-col gap-1">
                <h3 className="text-[#F4A261] text-base font-bold leading-6">Temple Visit</h3>
                <p className="text-[#F4A261]/70 text-xs leading-4">Visited Yatagala Temple site</p>
                <div className="flex items-center gap-2">
                  <span className="bg-[#1F160E] rounded-full px-2 py-0.5 text-[#F4A261] text-[9px] font-bold tracking-[0.45px] uppercase leading-[13.5px]">
                    Claimed
                  </span>
                  <span className="text-[#E9C46A] text-[10px] font-bold leading-[15px]">+200 PTS</span>
                </div>
              </div>
              <div className="w-8 h-8 rounded-full bg-[#F4A261] shadow-[0_0_15px_0_rgba(244,162,97,0.30)] flex items-center justify-center flex-shrink-0">
                <svg width="11" height="10" viewBox="0 0 11 10" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M10.2797 2.47031C10.5727 2.76328 10.5727 3.23906 10.2797 3.53203L4.27974 9.53203C3.98677 9.82499 3.51099 9.82499 3.21802 9.53203L0.218018 6.53203C-0.0749512 6.23906 -0.0749512 5.76328 0.218018 5.47031C0.510986 5.17734 0.986768 5.17734 1.27974 5.47031L3.75005 7.93828L9.22036 2.47031C9.51333 2.17734 9.98911 2.17734 10.2821 2.47031H10.2797Z" fill="#100E0A"/>
                </svg>
              </div>
            </div>
          </div>

        </div>

        <BottomNav />
      </div>
    </div>
  );
}
