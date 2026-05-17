import { Link } from "react-router-dom";

export default function Home() {
  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full max-w-[440px] bg-[#100E0A] pb-32">

        {/* Header */}
        <div className="flex items-center justify-between px-6 pt-12 pb-6">
          <div className="flex items-center gap-[10px]">
            <img
              src="https://api.builder.io/api/v1/image/assets/TEMP/8ac6e4f2918cb1ade2b53e903533707e4b93794a?width=88"
              alt="Avatar"
              className="w-11 h-11 rounded-full border-2 border-[#52B788]/30"
            />
            <div className="flex flex-col">
              <span className="text-[#FEFAE0]/60 text-xs font-medium tracking-[0.6px] uppercase leading-4">Explorer</span>
              <span className="text-[#FEFBE0] text-lg font-bold leading-7">Hello Disara!</span>
            </div>
          </div>
          <div className="relative">
            <button className="w-11 h-11 flex items-center justify-center rounded-full border border-[#52B788]/15 bg-white/5">
              <svg width="18" height="20" viewBox="0 0 18 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M8.86021 0C8.16881 0 7.61021 0.558593 7.61021 1.25V1.94922C4.77818 2.39843 2.61021 4.85157 2.61021 7.8125V9.11719C2.61021 10.8906 2.00474 12.6133 0.899273 13.9961L0.317242 14.7266C0.0906792 15.0078 0.0477105 15.3946 0.203961 15.7188C0.360211 16.043 0.688335 16.25 1.04771 16.25H16.6728C17.0321 16.25 17.3602 16.043 17.5164 15.7188C17.6728 15.3946 17.6298 15.0078 17.4032 14.7266L16.8212 14C15.7156 12.6133 15.1102 10.8906 15.1102 9.11719V7.8125C15.1102 4.85157 12.9422 2.39843 10.1102 1.94922V1.25C10.1102 0.558593 9.55162 0 8.86021 0ZM8.86021 3.75H9.17271C11.4149 3.75 13.2352 5.57031 13.2352 7.8125V9.11719C13.2352 10.9883 13.7782 12.8124 14.786 14.375H2.93443C3.94224 12.8124 4.48521 10.9883 4.48521 9.11719V7.8125C4.48521 5.57031 6.30553 3.75 8.54771 3.75H8.86021ZM11.3602 17.5H8.86021H6.36021C6.36021 18.1641 6.62193 18.8008 7.09068 19.2696C7.55943 19.7383 8.19615 20 8.86021 20C9.52427 20 10.161 19.7383 10.6297 19.2696C11.0985 18.8008 11.3602 18.1641 11.3602 17.5Z" fill="#FEFBE0"/>
              </svg>
            </button>
            <div className="absolute top-0.5 right-0.5 w-2 h-2 rounded-full bg-[#F4A261] border-2 border-[#100E0A]" />
          </div>
        </div>

        {/* Hero Section */}
        <div className="px-6">
          <p className="text-[#52B788] text-sm font-semibold tracking-[2px] uppercase leading-5 mb-[7px]">
            Welcome Disara!
          </p>
          <div className="mb-6">
            <p className="text-[#FEFBE0] text-[42px] font-extrabold leading-[46.2px] tracking-[-1.05px]">
              Protect.<br />Discover.
            </p>
            <p className="text-[#F4A261] text-[42px] italic font-normal leading-[46.2px] tracking-[-1.05px] font-['Playfair_Display',serif]">
              Celebrate.
            </p>
          </div>

          {/* Stat Badges */}
          <div className="flex flex-wrap gap-3 mb-8">
            <div className="flex items-center gap-2 h-[38px] px-4 rounded-full border border-[#52B788]/20 bg-white/5">
              <svg width="10" height="13" viewBox="0 0 10 13" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clipPath="url(#clip_place)">
                  <path d="M5.60176 12.675C6.90429 11.0449 9.875 7.09414 9.875 4.875C9.875 2.18359 7.69141 0 5 0C2.30859 0 0.125 2.18359 0.125 4.875C0.125 7.09414 3.09571 11.0449 4.39824 12.675C4.71054 13.0635 5.28946 13.0635 5.60176 12.675ZM5 3.25C5.43097 3.25 5.84431 3.42121 6.14905 3.72595C6.45379 4.03069 6.625 4.44403 6.625 4.875C6.625 5.30597 6.45379 5.71931 6.14905 6.02405C5.84431 6.32879 5.43097 6.5 5 6.5C4.56903 6.5 4.15569 6.32879 3.85095 6.02405C3.54621 5.71931 3.375 5.30597 3.375 4.875C3.375 4.44403 3.54621 4.03069 3.85095 3.72595C4.15569 3.42121 4.56903 3.25 5 3.25Z" fill="#52B788"/>
                </g>
                <defs><clipPath id="clip_place"><rect width="10" height="13" fill="white"/></clipPath></defs>
              </svg>
              <span className="text-[#FEFBE0] text-sm font-medium">12 Places Visited</span>
            </div>
            <div className="flex items-center gap-2 h-[38px] px-4 rounded-full border border-[#52B788]/20 bg-white/5">
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clipPath="url(#clip_star)">
                  <path d="M7.38929 0.992779C7.25551 0.715134 6.97282 0.538452 6.66236 0.538452C6.35191 0.538452 6.07174 0.715134 5.93544 0.992779L4.31248 4.33209L0.687963 4.86718C0.385079 4.91261 0.132675 5.12463 0.0392853 5.41489C-0.0541042 5.70516 0.021617 6.02571 0.238684 6.24025L2.86873 8.84254L2.24782 12.5201C2.19734 12.8229 2.32354 13.1309 2.57342 13.3101C2.8233 13.4893 3.15395 13.512 3.42654 13.3682L6.66488 11.6392L9.90322 13.3682C10.1758 13.512 10.5065 13.4918 10.7564 13.3101C11.0063 13.1283 11.1325 12.8229 11.082 12.5201L10.4585 8.84254L13.0886 6.24025C13.3056 6.02571 13.3839 5.70516 13.2879 5.41489C13.1921 5.12463 12.9421 4.91261 12.6393 4.86718L9.01224 4.33209L7.38929 0.992779Z" fill="#E9C46A"/>
                </g>
                <defs><clipPath id="clip_star"><rect width="14" height="14" fill="white"/></clipPath></defs>
              </svg>
              <span className="text-[#FEFBE0] text-sm font-medium">450 Points</span>
            </div>
            <div className="flex items-center gap-2 h-[38px] px-4 rounded-full border border-[#52B788]/20 bg-white/5">
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M9.375 1H4.125C3.50391 1 2.99766 1.51094 3.02109 2.12969C3.02578 2.25391 3.03047 2.37812 3.0375 2.5H0.5625C0.250781 2.5 0 2.75078 0 3.0625C0 5.23281 0.785156 6.74219 1.83984 7.76641C2.87812 8.77656 4.14375 9.28516 5.07656 9.54297C5.625 9.69531 6 10.1523 6 10.6117C6 11.1016 5.60156 11.5 5.11172 11.5H4.5C4.08516 11.5 3.75 11.8352 3.75 12.25C3.75 12.6648 4.08516 13 4.5 13H9C9.41484 13 9.75 12.6648 9.75 12.25C9.75 11.8352 9.41484 11.5 9 11.5H8.38828C7.89844 11.5 7.5 11.1016 7.5 10.6117C7.5 10.1523 7.87266 9.69297 8.42344 9.54297C9.35859 9.28516 10.6242 8.77656 11.6625 7.76641C12.7148 6.74219 13.5 5.23281 13.5 3.0625C13.5 2.75078 13.2492 2.5 12.9375 2.5H10.4625C10.4695 2.37812 10.4742 2.25625 10.4789 2.12969C10.5023 1.51094 9.99609 1 9.375 1ZM1.14609 3.625H3.12422C3.3375 5.73672 3.80859 7.14766 4.34062 8.09219C3.75703 7.83438 3.15 7.47109 2.625 6.96016C1.875 6.23125 1.26562 5.17891 1.14844 3.625H1.14609ZM10.8773 6.96016C10.3523 7.47109 9.74531 7.83438 9.16172 8.09219C9.69375 7.14766 10.1648 5.73672 10.3781 3.625H12.3563C12.2367 5.17891 11.6273 6.23125 10.8797 6.96016H10.8773Z" fill="#52B788"/>
              </svg>
              <span className="text-[#FEFBE0] text-sm font-medium">Rank #4</span>
            </div>
          </div>

          {/* Community Alert */}
          <div className="flex items-start gap-3 p-4 rounded-2xl border border-[#F4A261]/20 bg-[#F4A261]/10 mb-6">
            <span className="text-xl flex-shrink-0 leading-7">⚠️</span>
            <p className="flex-1 text-[#F4A261] text-sm font-medium leading-[22.75px]">
              Community Report: Damage detected at Galle Fort. Tap to verify.
            </p>
            <svg width="8" height="14" viewBox="0 0 8 14" fill="none" xmlns="http://www.w3.org/2000/svg" className="flex-shrink-0 mt-1">
              <g clipPath="url(#clip_arrow_alert)">
                <path d="M7.49458 5.93286C7.86267 6.30095 7.86267 6.89873 7.49458 7.26681L1.84073 12.9207C1.47264 13.2888 0.874869 13.2888 0.50678 12.9207C0.138691 12.5526 0.138691 11.9548 0.50678 11.5867L5.49512 6.59836L0.509724 1.61002C0.141635 1.24193 0.141635 0.644156 0.509724 0.276067C0.877813 -0.0920223 1.47559 -0.0920223 1.84367 0.276067L7.49752 5.92992L7.49458 5.93286Z" fill="#F4A261" fillOpacity="0.6"/>
              </g>
              <defs><clipPath id="clip_arrow_alert"><rect width="8" height="14" fill="white"/></clipPath></defs>
            </svg>
          </div>
        </div>

        {/* Report Damages Card */}
        <div className="mx-6 mb-0 rounded-[28px] border border-[#F4A261]/20 bg-white/5 p-4">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <span className="text-[30px] leading-[36px] block mb-2">⚠️</span>
              <h3 className="text-[#FEFBE0] text-lg font-bold leading-7">Report Damages</h3>
              <p className="text-[#FEFAE0]/60 text-xs leading-4 mt-0.5">from here</p>
            </div>
            <button className="w-7 h-7 flex items-center justify-center rounded-full bg-[#F4A261]/20 flex-shrink-0 mt-2.5">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g clipPath="url(#clip_arrow_rd)">
                  <path d="M18.7009 10.6594C19.2136 10.1468 19.2136 9.31413 18.7009 8.80144L12.1384 2.23894C11.6257 1.72624 10.7931 1.72624 10.2804 2.23894C9.76773 2.75163 9.76773 3.58425 10.2804 4.09694L14.6076 8.42L2.02398 8.42C1.29801 8.41999 0.711478 9.00652 0.711476 9.7325C0.711487 10.4585 1.29801 11.045 2.02398 11.045L14.6035 11.045L10.2845 15.3681C9.77183 15.8807 9.77184 16.7134 10.2845 17.2261C10.7972 17.7387 11.6298 17.7388 12.1425 17.2261L18.705 10.6636L18.7009 10.6594Z" fill="#F4A261"/>
                </g>
                <defs><clipPath id="clip_arrow_rd"><rect width="14" height="14" fill="white" transform="translate(9.8995) rotate(45)"/></clipPath></defs>
              </svg>
            </button>
          </div>
        </div>

        {/* Feature Grid */}
        <div className="px-6 pt-10">
          <div className="flex gap-4">
            {/* Scanner — tall left card */}
            <div className="w-[156px] rounded-[32px] border border-[#52B788]/20 bg-white/5 overflow-hidden flex flex-col justify-end p-5 relative min-h-[280px]">
              <div className="absolute bottom-20 left-6 w-24 h-24 rounded-full bg-[#52B788]/10 blur-[20px] pointer-events-none" />
              <div className="relative z-10 flex flex-col gap-2">
                <span className="text-4xl leading-10">📸</span>
                <div>
                  <h3 className="text-[#FEFBE0] text-xl font-bold leading-7">Scanner</h3>
                  <p className="text-[#FEFAE0]/60 text-xs leading-[15px]">Identify Heritage and Wildlife</p>
                </div>
                <div className="w-8 h-8 flex items-center justify-center rounded-full bg-[#52B788]/20 mt-2">
                  <svg width="23" height="23" viewBox="0 0 23 23" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <g clipPath="url(#clip_scanner_arrow)">
                      <path d="M20.7019 11.3701C21.2488 10.8232 21.2488 9.93508 20.7019 9.38821L13.7019 2.3882C13.155 1.84133 12.2669 1.84133 11.72 2.38821C11.1732 2.93508 11.1732 3.82321 11.72 4.37008L16.3357 8.98133L2.91316 8.98133C2.13878 8.98133 1.51316 9.60696 1.51315 10.3813C1.51316 11.1557 2.13879 11.7813 2.91316 11.7813L16.3313 11.7813L11.7244 16.3926C11.1775 16.9395 11.1775 17.8276 11.7244 18.3744C12.2713 18.9213 13.1594 18.9213 13.7063 18.3745L20.7063 11.3745L20.7019 11.3701Z" fill="#52B788"/>
                    </g>
                    <defs><clipPath id="clip_scanner_arrow"><rect width="16" height="16" fill="white" transform="translate(11.3137) rotate(45)"/></clipPath></defs>
                  </svg>
                </div>
              </div>
            </div>

            {/* Right column */}
            <div className="flex-1 flex flex-col gap-4">
              {/* Map */}
              <div className="rounded-[28px] border border-[#2D6A4F]/30 bg-white/5 p-4 flex flex-col justify-between h-[134px]">
                <div className="flex justify-between items-start">
                  <span className="text-3xl leading-9">🗺️</span>
                  <div className="w-7 h-7 flex items-center justify-center rounded-full bg-[#2D6A4F]/20">
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <g clipPath="url(#clip_map_arrow)">
                        <path d="M18.7009 10.6594C19.2136 10.1468 19.2136 9.31413 18.7009 8.80144L12.1384 2.23894C11.6257 1.72624 10.7931 1.72624 10.2804 2.23894C9.76773 2.75163 9.76773 3.58425 10.2804 4.09694L14.6076 8.42L2.02398 8.42C1.29801 8.41999 0.711478 9.00652 0.711476 9.7325C0.711487 10.4585 1.29801 11.045 2.02398 11.045L14.6035 11.045L10.2845 15.3681C9.77183 15.8807 9.77184 16.7134 10.2845 17.2261C10.7972 17.7387 11.6298 17.7388 12.1425 17.2261L18.705 10.6636L18.7009 10.6594Z" fill="#2D6A4F"/>
                      </g>
                      <defs><clipPath id="clip_map_arrow"><rect width="14" height="14" fill="white" transform="translate(9.8995) rotate(45)"/></clipPath></defs>
                    </svg>
                  </div>
                </div>
                <div>
                  <h3 className="text-[#FEFBE0] text-lg font-bold leading-7">Map</h3>
                  <p className="text-[#FEFAE0]/60 text-xs leading-4">Explore Places</p>
                </div>
              </div>

              {/* Archive */}
              <div className="rounded-[28px] border border-[#F4A261]/20 bg-white/5 p-4 flex flex-col justify-between h-[134px]">
                <div className="flex justify-between items-start">
                  <span className="text-3xl leading-9">📖</span>
                  <div className="w-7 h-7 flex items-center justify-center rounded-full bg-[#F4A261]/20">
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <g clipPath="url(#clip_archive_arrow)">
                        <path d="M18.7009 10.6594C19.2136 10.1468 19.2136 9.31413 18.7009 8.80144L12.1384 2.23894C11.6257 1.72624 10.7931 1.72624 10.2804 2.23894C9.76773 2.75163 9.76773 3.58425 10.2804 4.09694L14.6076 8.42L2.02398 8.42C1.29801 8.41999 0.711478 9.00652 0.711476 9.7325C0.711487 10.4585 1.29801 11.045 2.02398 11.045L14.6035 11.045L10.2845 15.3681C9.77183 15.8807 9.77184 16.7134 10.2845 17.2261C10.7972 17.7387 11.6298 17.7388 12.1425 17.2261L18.705 10.6636L18.7009 10.6594Z" fill="#F4A261"/>
                      </g>
                      <defs><clipPath id="clip_archive_arrow"><rect width="14" height="14" fill="white" transform="translate(9.8995) rotate(45)"/></clipPath></defs>
                    </svg>
                  </div>
                </div>
                <div>
                  <h3 className="text-[#FEFBE0] text-lg font-bold leading-7">Archive</h3>
                  <p className="text-[#FEFAE0]/60 text-xs leading-4">Ancient Wisdom</p>
                </div>
              </div>
            </div>
          </div>

          {/* Quests Banner */}
          <Link to="/quests" className="mt-4 rounded-[28px] border border-[#B752B7]/30 bg-white/5 overflow-hidden relative block">
            <div className="absolute -left-4 top-0 w-24 h-24 rounded-full bg-[#B752B7]/10 blur-[20px] pointer-events-none" />
            <div className="flex items-center p-5 gap-3 relative z-10">
              <span className="text-4xl leading-10 flex-shrink-0">🎮</span>
              <div className="flex-1 min-w-0 ml-1">
                <h3 className="text-[#FEFBE0] text-lg font-bold leading-7">Quests</h3>
                <p className="text-[#FEFAE0]/60 text-xs leading-[16.5px]">Complete challenges to earn points and compete with others.</p>
              </div>
              <div className="w-9 h-9 flex items-center justify-center rounded-full bg-[#B752B7]/20 flex-shrink-0">
                <svg width="12" height="20" viewBox="0 0 12 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <g clipPath="url(#clip_quests_arrow)">
                    <path d="M10.9924 8.47551C11.5183 9.00135 11.5183 9.85532 10.9924 10.3812L2.91551 18.4582C2.38966 18.984 1.5357 18.984 1.00986 18.4582C0.484018 17.9323 0.484018 17.0783 1.00986 16.5525L8.13606 9.42623L1.01407 2.30003C0.488225 1.77418 0.488225 0.920223 1.01407 0.394381C1.53991 -0.13146 2.39388 -0.13146 2.91971 0.394381L10.9966 8.47131L10.9924 8.47551Z" fill="#B752B7"/>
                  </g>
                  <defs><clipPath id="clip_quests_arrow"><rect width="12" height="20" fill="white"/></clipPath></defs>
                </svg>
              </div>
            </div>
          </Link>
        </div>

        {/* Nearby Heritage */}
        <div className="px-6 pt-10">
          <div className="flex justify-between items-end mb-5">
            <h2 className="text-[#FEFBE0] text-2xl font-bold leading-8 tracking-[-0.445px]">Nearby Heritage</h2>
            <button className="text-[#52B788] text-xs font-bold leading-4 tracking-[0.6px] uppercase">See All</button>
          </div>

          <div className="flex gap-4">
            {/* Galle Fort */}
            <div className="flex-1 rounded-2xl border border-[#52B788]/15 bg-white/5 p-4">
              <div className="w-12 h-12 flex items-center justify-center rounded-full bg-[#FEFBE0]/5 mb-3">
                <span className="text-2xl leading-8">🏰</span>
              </div>
              <h4 className="text-[#FEFBE0] text-sm font-semibold leading-5 mb-1">Galle Fort</h4>
              <div className="flex items-center gap-1.5">
                <svg width="10" height="10" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <g clipPath="url(#clip_nav_galle)">
                    <path d="M8.97548 0.956723C9.08182 0.698477 9.02106 0.401168 8.82358 0.203686C8.62609 0.00620249 8.32878 -0.0545614 8.07053 0.0517754L0.431646 3.17678C0.123486 3.30264 -0.050125 3.62817 0.012809 3.95369C0.075743 4.27921 0.362201 4.51358 0.694232 4.51358H4.51368V8.33302C4.51368 8.66506 4.74806 8.94934 5.07358 9.01444C5.39909 9.07956 5.72461 8.90377 5.85048 8.59561L8.97548 0.956723Z" fill="#52B788"/>
                  </g>
                  <defs><clipPath id="clip_nav_galle"><rect width="10" height="10" fill="white"/></clipPath></defs>
                </svg>
                <span className="text-[#FEFAE0]/50 text-[11px] leading-[16.5px]">1.2 km away</span>
              </div>
            </div>

            {/* Yatagala Temple */}
            <div className="flex-1 rounded-2xl border border-[#52B788]/15 bg-white/5 p-4">
              <div className="w-12 h-12 flex items-center justify-center rounded-full bg-[#FEFBE0]/5 mb-3">
                <span className="text-2xl leading-8">🛕</span>
              </div>
              <h4 className="text-[#FEFBE0] text-sm font-semibold leading-5 mb-1">Yatagala Temple</h4>
              <div className="flex items-center gap-1.5">
                <svg width="10" height="10" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <g clipPath="url(#clip_nav_yata)">
                    <path d="M8.97548 0.956723C9.08182 0.698477 9.02106 0.401168 8.82358 0.203686C8.62609 0.00620249 8.32878 -0.0545614 8.07053 0.0517754L0.431646 3.17678C0.123486 3.30264 -0.050125 3.62817 0.012809 3.95369C0.075743 4.27921 0.362201 4.51358 0.694232 4.51358H4.51368V8.33302C4.51368 8.66506 4.74806 8.94934 5.07358 9.01444C5.39909 9.07956 5.72461 8.90377 5.85048 8.59561L8.97548 0.956723Z" fill="#52B788"/>
                  </g>
                  <defs><clipPath id="clip_nav_yata"><rect width="10" height="10" fill="white"/></clipPath></defs>
                </svg>
                <span className="text-[#FEFAE0]/50 text-[11px] leading-[16.5px]">3.5 km away</span>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Navigation */}
        <div className="fixed bottom-0 left-0 right-0 z-[100] flex justify-center pb-4 pointer-events-none">
          <div className="pointer-events-auto w-[343px] h-[84px] rounded-[42px] border border-[#F4A261]/20 bg-[#231B12]/60 backdrop-blur-xl shadow-[0_24px_48px_rgba(0,0,0,0.55)] flex items-center px-2">

            {/* Home */}
            <div className="flex-1 flex flex-col items-center justify-center gap-1">
              <svg width="23" height="20" viewBox="0 0 23 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M22.4922 9.98047C22.4922 10.6836 21.9062 11.2344 21.2422 11.2344H19.9922L20.0195 17.4922C20.0195 17.5977 20.0117 17.7031 20 17.8086V18.4375C20 19.3008 19.3008 20 18.4375 20H17.8125C17.7695 20 17.7266 20 17.6836 19.9961C17.6289 20 17.5742 20 17.5195 20H16.25H15.3125C14.4492 20 13.75 19.3008 13.75 18.4375V17.5V15C13.75 14.3086 13.1914 13.75 12.5 13.75H10C9.30859 13.75 8.75 14.3086 8.75 15V17.5V18.4375C8.75 19.3008 8.05078 20 7.1875 20H6.25H5.00391C4.94531 20 4.88672 19.9961 4.82812 19.9922C4.78125 19.9961 4.73438 20 4.6875 20H4.0625C3.19922 20 2.5 19.3008 2.5 18.4375V14.0625C2.5 14.0273 2.5 13.9883 2.50391 13.9531V11.2344H1.25C0.546875 11.2344 0 10.6875 0 9.98047C0 9.62891 0.117188 9.31641 0.390625 9.04297L10.4062 0.3125C10.6797 0.0390625 10.9922 0 11.2656 0C11.5391 0 11.8516 0.078125 12.0859 0.273438L22.0625 9.04297C22.375 9.31641 22.5312 9.62891 22.4922 9.98047Z" fill="#FEFBE0"/>
              </svg>
              <span className="text-[#FEFBE0] text-[10px] font-bold uppercase leading-[15px]">Home</span>
            </div>

            {/* Explore */}
            <Link to="/quests" className="flex-1 flex flex-col items-center justify-center gap-1 opacity-40">
              <svg width="23" height="20" viewBox="0 0 23 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M15.9375 4.6875C15.9375 6.82031 13.082 10.6211 11.8281 12.1875C11.5273 12.5625 10.9688 12.5625 10.6719 12.1875C9.41797 10.6211 6.5625 6.82031 6.5625 4.6875C6.5625 2.09766 8.66016 0 11.25 0C13.8398 0 15.9375 2.09766 15.9375 4.6875ZM16.25 7.82812C16.3867 7.55859 16.5117 7.28906 16.625 7.02344C16.6445 6.97656 16.6641 6.92578 16.6836 6.87891L21.2148 5.06641C21.832 4.82031 22.5 5.27344 22.5 5.9375V16.5156C22.5 16.8984 22.2656 17.2422 21.9102 17.3867L16.25 19.6484V7.82812ZM5.375 5.40234C5.46875 5.95312 5.65625 6.50781 5.875 7.02344C5.98828 7.28906 6.11328 7.55859 6.25 7.82812V17.6484L1.28516 19.6367C0.667969 19.8828 0 19.4297 0 18.7656V8.1875C0 7.80469 0.234375 7.46094 0.589844 7.31641L5.37891 5.40234H5.375ZM12.8047 12.9688C13.3477 12.2891 14.1992 11.1836 15 9.96094V19.6992L7.5 17.5547V9.96094C8.30078 11.1836 9.15234 12.2891 9.69531 12.9688C10.4961 13.9688 12.0039 13.9688 12.8047 12.9688ZM11.25 5.9375C11.6644 5.9375 12.0618 5.77288 12.3549 5.47985C12.6479 5.18683 12.8125 4.7894 12.8125 4.375C12.8125 3.9606 12.6479 3.56317 12.3549 3.27015C12.0618 2.97712 11.6644 2.8125 11.25 2.8125C10.8356 2.8125 10.4382 2.97712 10.1451 3.27015C9.85212 3.56317 9.6875 3.9606 9.6875 4.375C9.6875 4.7894 9.85212 5.18683 10.1451 5.47985C10.4382 5.77288 10.8356 5.9375 11.25 5.9375Z" fill="white"/>
              </svg>
              <span className="text-white text-[10px] font-medium uppercase leading-[15px]">Explore</span>
            </Link>

            {/* Camera (center) */}
            <div className="flex-none h-full flex items-center justify-center px-3">
              <button className="w-14 h-14 flex items-center justify-center rounded-full border-4 border-[#241B13] bg-[#F4A261] shadow-[0_0_20px_0_rgba(244,162,97,0.40)]">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M6.98906 3.0375L6.50156 4.5H3C1.34531 4.5 0 5.84531 0 7.5V19.5C0 21.1547 1.34531 22.5 3 22.5H21C22.6547 22.5 24 21.1547 24 19.5V7.5C24 5.84531 22.6547 4.5 21 4.5H17.4984L17.0109 3.0375C16.7062 2.11875 15.8484 1.5 14.8781 1.5H9.12188C8.15156 1.5 7.29375 2.11875 6.98906 3.0375ZM12 9C13.1935 9 14.3381 9.47411 15.182 10.318C16.0259 11.1619 16.5 12.3065 16.5 13.5C16.5 14.6935 16.0259 15.8381 15.182 16.682C14.3381 17.5259 13.1935 18 12 18C10.8065 18 9.66193 17.5259 8.81802 16.682C7.97411 15.8381 7.5 14.6935 7.5 13.5C7.5 12.3065 7.97411 11.1619 8.81802 10.318C9.66193 9.47411 10.8065 9 12 9Z" fill="#241B13"/>
                </svg>
              </button>
            </div>

            {/* Archive */}
            <div className="flex-1 flex flex-col items-center justify-center gap-1 opacity-40">
              <svg width="23" height="20" viewBox="0 0 23 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M9.75 18.418C10.1719 18.5664 10.625 18.2578 10.625 17.8125V3.07031C10.625 2.90625 10.5625 2.74219 10.4297 2.64062C9.66406 2.03125 7.90625 1.25 5.625 1.25C3.65234 1.25 1.80859 1.76953 0.707031 2.19141C0.265625 2.36328 0 2.80078 0 3.27344V17.7383C0 18.2031 0.5 18.5273 0.941406 18.3828C2.17188 17.9727 4.12109 17.5 5.625 17.5C6.94922 17.5 8.71094 18.0469 9.75 18.418ZM12.75 18.418C13.7891 18.0469 15.5508 17.5 16.875 17.5C18.3789 17.5 20.3281 17.9727 21.5586 18.3828C22 18.5312 22.5 18.2031 22.5 17.7383V3.27344C22.5 2.80078 22.2344 2.36328 21.793 2.19531C20.6914 1.76953 18.8477 1.25 16.875 1.25C14.5938 1.25 12.8359 2.03125 12.0703 2.64062C11.9414 2.74219 11.875 2.90625 11.875 3.07031V17.8125C11.875 18.2578 12.332 18.5664 12.75 18.418Z" fill="white"/>
              </svg>
              <span className="text-white text-[10px] font-medium uppercase leading-[15px]">Archive</span>
            </div>

            {/* Profile */}
            <div className="flex-1 flex flex-col items-center justify-center gap-1 opacity-40">
              <svg width="25" height="20" viewBox="0 0 25 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M8.75 10C10.0761 10 11.3479 9.47322 12.2855 8.53553C13.2232 7.59785 13.75 6.32608 13.75 5C13.75 3.67392 13.2232 2.40215 12.2855 1.46447C11.3479 0.526784 10.0761 0 8.75 0C7.42392 0 6.15215 0.526784 5.21447 1.46447C4.27678 2.40215 3.75 3.67392 3.75 5C3.75 6.32608 4.27678 7.59785 5.21447 8.53553C6.15215 9.47322 7.42392 10 8.75 10ZM6.96484 11.875C3.11719 11.875 0 14.9922 0 18.8398C0 19.4805 0.519531 20 1.16016 20H16.3398C16.4102 20 16.4766 19.9922 16.5469 19.9805C13.5664 17.8281 12.6484 14.4727 12.5195 12.1602C11.8906 11.9727 11.2266 11.875 10.5391 11.875H6.96484ZM19.0273 8.81641L14.3398 10.6914C13.9844 10.8359 13.75 11.1797 13.75 11.5625C13.75 14.0352 14.7617 18.1562 19.0156 19.9297C19.2461 20.0273 19.5078 20.0273 19.7383 19.9297C23.9883 18.1562 25 14.0352 25 11.5625C25 11.1797 24.7656 10.8359 24.4102 10.6914L19.7227 8.81641C19.5 8.72656 19.25 8.72656 19.0273 8.81641ZM23.1016 12.1875C22.9492 14.168 22.0391 16.7461 19.375 18.0352V10.6953L23.1016 12.1875Z" fill="white"/>
              </svg>
              <span className="text-white text-[10px] font-medium uppercase leading-[15px]">Profile</span>
            </div>

          </div>
        </div>
      </div>
    </div>
  );
}
