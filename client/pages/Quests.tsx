import { Link } from "react-router-dom";

const quests = [
  {
    title: "Fort Guardian",
    description: "Visit Galle Fort and submit a verified condition report.",
    points: 180,
    progress: 65,
    badge: "🏰",
  },
  {
    title: "Temple Trail",
    description: "Document 3 nearby temples with photos and notes.",
    points: 140,
    progress: 40,
    badge: "🛕",
  },
  {
    title: "Wild Archive",
    description: "Scan 5 native species and add them to your archive.",
    points: 120,
    progress: 20,
    badge: "🌿",
  },
];

export default function Quests() {
  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full max-w-[440px] bg-[#100E0A] pb-32">
        <div className="px-6 pt-12 pb-6">
          <p className="text-[#B752B7] text-xs font-semibold tracking-[2px] uppercase mb-2">Challenge Board</p>
          <h1 className="text-[#FEFBE0] text-[36px] font-extrabold leading-[40px] tracking-[-0.8px]">Quests</h1>
          <p className="text-[#FEFAE0]/60 text-sm leading-6 mt-2">
            Complete active missions to protect heritage sites and earn points.
          </p>
        </div>

        <div className="px-6 space-y-4">
          {quests.map((quest) => (
            <div key={quest.title} className="rounded-[24px] border border-[#B752B7]/25 bg-white/5 p-4">
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-start gap-3">
                  <div className="w-11 h-11 rounded-2xl bg-[#B752B7]/20 flex items-center justify-center text-xl leading-none">
                    {quest.badge}
                  </div>
                  <div>
                    <h2 className="text-[#FEFBE0] text-base font-bold leading-6">{quest.title}</h2>
                    <p className="text-[#FEFAE0]/60 text-xs leading-5 mt-0.5">{quest.description}</p>
                  </div>
                </div>
                <span className="text-[#F4A261] text-xs font-bold">+{quest.points}</span>
              </div>

              <div className="mt-4">
                <div className="flex justify-between text-[11px] leading-4 mb-2">
                  <span className="text-[#FEFAE0]/50 uppercase tracking-[1px]">Progress</span>
                  <span className="text-[#52B788] font-semibold">{quest.progress}%</span>
                </div>
                <div className="h-2 rounded-full bg-[#8B5E3C]/30 overflow-hidden">
                  <div
                    className="h-full rounded-full bg-gradient-to-r from-[#B752B7] to-[#F4A261]"
                    style={{ width: `${quest.progress}%` }}
                  />
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="px-6 pt-8">
          <div className="rounded-[24px] border border-[#52B788]/30 bg-[#52B788]/10 p-4">
            <p className="text-[#52B788] text-xs font-semibold tracking-[1.5px] uppercase">Current Ranking</p>
            <div className="mt-2 flex items-end justify-between">
              <p className="text-[#FEFBE0] text-2xl font-bold leading-8">#4 Explorer</p>
              <p className="text-[#FEFAE0]/70 text-sm">770 XP</p>
            </div>
          </div>
        </div>

        <div className="fixed bottom-0 left-0 right-0 z-[100] flex justify-center pb-4 pointer-events-none">
          <div className="pointer-events-auto w-[343px] h-[84px] rounded-[42px] border border-[#F4A261]/20 bg-[#231B12]/60 backdrop-blur-xl shadow-[0_24px_48px_rgba(0,0,0,0.55)] flex items-center px-2">
            <Link to="/home" className="flex-1 flex flex-col items-center justify-center gap-1 opacity-40">
              <span className="text-white text-[10px] font-medium uppercase leading-[15px]">Home</span>
            </Link>
            <div className="flex-1 flex flex-col items-center justify-center gap-1">
              <span className="text-[#FEFBE0] text-[10px] font-bold uppercase leading-[15px]">Quests</span>
            </div>
            <div className="flex-none h-full flex items-center justify-center px-3">
              <button className="w-14 h-14 flex items-center justify-center rounded-full border-4 border-[#241B13] bg-[#F4A261] shadow-[0_0_20px_0_rgba(244,162,97,0.40)]">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M6.98906 3.0375L6.50156 4.5H3C1.34531 4.5 0 5.84531 0 7.5V19.5C0 21.1547 1.34531 22.5 3 22.5H21C22.6547 22.5 24 21.1547 24 19.5V7.5C24 5.84531 22.6547 4.5 21 4.5H17.4984L17.0109 3.0375C16.7062 2.11875 15.8484 1.5 14.8781 1.5H9.12188C8.15156 1.5 7.29375 2.11875 6.98906 3.0375ZM12 9C13.1935 9 14.3381 9.47411 15.182 10.318C16.0259 11.1619 16.5 12.3065 16.5 13.5C16.5 14.6935 16.0259 15.8381 15.182 16.682C14.3381 17.5259 13.1935 18 12 18C10.8065 18 9.66193 17.5259 8.81802 16.682C7.97411 15.8381 7.5 14.6935 7.5 13.5C7.5 12.3065 7.97411 11.1619 8.81802 10.318C9.66193 9.47411 10.8065 9 12 9Z" fill="#241B13"/>
                </svg>
              </button>
            </div>
            <div className="flex-1 flex flex-col items-center justify-center gap-1 opacity-40">
              <span className="text-white text-[10px] font-medium uppercase leading-[15px]">Archive</span>
            </div>
            <div className="flex-1 flex flex-col items-center justify-center gap-1 opacity-40">
              <span className="text-white text-[10px] font-medium uppercase leading-[15px]">Profile</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
