import { useState } from "react";

export default function Index() {
  const [showPassword, setShowPassword] = useState(false);
  const [langOpen, setLangOpen] = useState(false);

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex items-center justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      {/* Desktop glow blobs */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none hidden md:block">
        <div className="absolute top-1/4 -left-32 w-96 h-96 rounded-full bg-[#8B5E3C] opacity-5 blur-[80px]" />
        <div className="absolute bottom-1/4 -right-32 w-96 h-96 rounded-full bg-[#F4A261] opacity-5 blur-[80px]" />
      </div>

      {/* Card */}
      <div className="relative w-full max-w-[440px] min-h-screen md:min-h-0 md:rounded-3xl md:overflow-hidden md:shadow-2xl md:my-8 bg-[#100E0A] flex flex-col">

        {/* Hero Image Section */}
        <div className="relative w-full h-[300px] sm:h-[340px] overflow-hidden flex-shrink-0">
          <img
            src="https://api.builder.io/api/v1/image/assets/TEMP/4ec87cd73d917c7f7f04e8ea52fdce696daca5d7?width=880"
            alt="Heritage"
            className="w-full h-full object-cover opacity-60"
          />
          {/* Bottom gradient fade */}
          <div className="absolute inset-0 bg-gradient-to-t from-[#100E0A] via-[#100E0A]/0 to-transparent" />

          {/* Top bar */}
          <div className="absolute top-0 left-0 right-0 flex items-center justify-between px-6 pt-12 sm:pt-14">
            {/* Language selector */}
            <div className="relative">
              <button
                onClick={() => setLangOpen(!langOpen)}
                className="flex items-center gap-2 h-8 px-4 rounded-full border border-[#F4A261]/20 bg-[#8B5E3C]/15 text-[#F4A261] text-xs font-semibold tracking-wide"
              >
                <svg width="18" height="14" viewBox="0 0 18 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M0 3.5C0 2.53477 0.784766 1.75 1.75 1.75H7H8.3125H8.75H15.75C16.7152 1.75 17.5 2.53477 17.5 3.5V10.5C17.5 11.4652 16.7152 12.25 15.75 12.25H8.75H8.3125H7H1.75C0.784766 12.25 0 11.4652 0 10.5V3.5ZM8.75 3.5V10.5H15.75V3.5H8.75ZM4.87539 4.80977C4.78789 4.61289 4.59102 4.48438 4.375 4.48438C4.15898 4.48438 3.96211 4.61289 3.87461 4.80977L2.12461 8.74727C2.00156 9.02344 2.12734 9.34609 2.40352 9.46914C2.67969 9.59219 3.00234 9.46641 3.12539 9.19023L3.36875 8.64062H5.38125L5.62461 9.19023C5.74766 9.46641 6.07031 9.58945 6.34648 9.46914C6.62266 9.34883 6.7457 9.02344 6.62539 8.74727L4.87539 4.80977ZM4.375 6.37656L4.89453 7.54688H3.85547L4.375 6.37656ZM12.25 4.48438C12.5508 4.48438 12.7969 4.73047 12.7969 5.03125V5.14062H14H14.4375C14.7383 5.14062 14.9844 5.38672 14.9844 5.6875C14.9844 5.98828 14.7383 6.23438 14.4375 6.23438H14.3828L14.3391 6.35742C14.0957 7.02461 13.7266 7.63164 13.2562 8.1457C13.2809 8.16211 13.3055 8.17578 13.3301 8.18945L13.8469 8.49844C14.1066 8.6543 14.1887 8.99063 14.0355 9.24766C13.8824 9.50469 13.5434 9.58945 13.2863 9.43633L12.7695 9.12734C12.6465 9.05352 12.5289 8.97695 12.4113 8.89492C12.1215 9.1 11.8125 9.27773 11.4816 9.42539L11.3832 9.46914C11.107 9.59219 10.7844 9.46641 10.6613 9.19023C10.5383 8.91406 10.6641 8.59141 10.9402 8.46836L11.0387 8.42461C11.2137 8.34531 11.3832 8.25781 11.5445 8.15664L11.2109 7.82305C10.9977 7.60977 10.9977 7.2625 11.2109 7.04922C11.4242 6.83594 11.7715 6.83594 11.9848 7.04922L12.384 7.44844L12.3977 7.46211C12.7367 7.10391 13.0129 6.68828 13.2125 6.23164H12.25H10.2812C9.98047 6.23164 9.73438 5.98555 9.73438 5.68477C9.73438 5.38398 9.98047 5.13789 10.2812 5.13789H11.7031V5.02852C11.7031 4.72773 11.9492 4.48164 12.25 4.48164V4.48438Z" fill="#F4A261"/>
                </svg>
                English
                <svg width="10" height="10" viewBox="0 0 10 10" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M4.55859 7.94141C4.80273 8.18555 5.19922 8.18555 5.44336 7.94141L9.19336 4.19141C9.4375 3.94727 9.4375 3.55078 9.19336 3.30664C8.94922 3.0625 8.55273 3.0625 8.30859 3.30664L5 6.61523L1.69141 3.30859C1.44727 3.06445 1.05078 3.06445 0.806641 3.30859C0.5625 3.55273 0.5625 3.94922 0.806641 4.19336L4.55664 7.94336L4.55859 7.94141Z" fill="#F4A261"/>
                </svg>
              </button>
            </div>

            {/* Info button */}
            <button className="w-10 h-10 flex items-center justify-center rounded-full border border-[#F4A261]/10 bg-[#8B5E3C]/15">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M8 16C10.1217 16 12.1566 15.1571 13.6569 13.6569C15.1571 12.1566 16 10.1217 16 8C16 5.87827 15.1571 3.84344 13.6569 2.34315C12.1566 0.842855 10.1217 0 8 0C5.87827 0 3.84344 0.842855 2.34315 2.34315C0.842855 3.84344 0 5.87827 0 8C0 10.1217 0.842855 12.1566 2.34315 13.6569C3.84344 15.1571 5.87827 16 8 16ZM6.75 10.5H7.5V8.5H6.75C6.33437 8.5 6 8.16562 6 7.75C6 7.33437 6.33437 7 6.75 7H8.25C8.66562 7 9 7.33437 9 7.75V10.5H9.25C9.66562 10.5 10 10.8344 10 11.25C10 11.6656 9.66562 12 9.25 12H6.75C6.33437 12 6 11.6656 6 11.25C6 10.8344 6.33437 10.5 6.75 10.5ZM8 4C8.26522 4 8.51957 4.10536 8.70711 4.29289C8.89464 4.48043 9 4.73478 9 5C9 5.26522 8.89464 5.51957 8.70711 5.70711C8.51957 5.89464 8.26522 6 8 6C7.73478 6 7.48043 5.89464 7.29289 5.70711C7.10536 5.51957 7 5.26522 7 5C7 4.73478 7.10536 4.48043 7.29289 4.29289C7.48043 4.10536 7.73478 4 8 4Z" fill="#F4A261"/>
              </svg>
            </button>
          </div>

          {/* Brand name & tagline — overlaid at bottom-left of hero */}
          <div className="absolute bottom-6 left-6">
            <p className="text-[#F4A261] italic font-['Inter',sans-serif] text-[32px] font-normal leading-[1.4]">
              HeritageLK
            </p>
            <p className="text-[#8B5E3C] text-sm font-semibold tracking-[0.35px] uppercase mt-0.5">
              Join the legacy
            </p>
          </div>
        </div>

        {/* Form Section */}
        <div className="flex-1 flex flex-col px-6 pb-12 pt-0 relative">
          {/* Heading */}
          <div className="mb-6">
            <h1 className="text-[#FEFAE0] text-2xl font-bold leading-8 mb-1">
              Create Account
            </h1>
            <p className="text-[#8B5E3C] text-sm font-normal leading-5">
              Preserve your heritage today.
            </p>
          </div>

          {/* Form fields */}
          <div className="flex flex-col gap-4 mb-6">
            {/* Full Name */}
            <div className="relative">
              <div className="absolute left-4 top-1/2 -translate-y-1/2">
                <svg width="11" height="12" viewBox="0 0 11 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M5.25 6C6.04565 6 6.80871 5.68393 7.37132 5.12132C7.93393 4.55871 8.25 3.79565 8.25 3C8.25 2.20435 7.93393 1.44129 7.37132 0.87868C6.80871 0.316071 6.04565 0 5.25 0C4.45435 0 3.69129 0.316071 3.12868 0.87868C2.56607 1.44129 2.25 2.20435 2.25 3C2.25 3.79565 2.56607 4.55871 3.12868 5.12132C3.69129 5.68393 4.45435 6 5.25 6ZM4.17891 7.125C1.87031 7.125 0 8.99531 0 11.3039C0 11.6883 0.311719 12 0.696094 12H9.80391C10.1883 12 10.5 11.6883 10.5 11.3039C10.5 8.99531 8.62969 7.125 6.32109 7.125H4.17891Z" fill="#8B5E3C"/>
                </svg>
              </div>
              <input
                type="text"
                placeholder="Full Name"
                className="w-full h-14 pl-12 pr-4 rounded-2xl border border-[#8B5E3C]/30 bg-[#8B5E3C]/10 text-[#FEFAE0] placeholder-[#8B5E3C]/50 text-base font-bold outline-none focus:border-[#F4A261]/50 focus:bg-[#8B5E3C]/15 transition-colors"
              />
            </div>

            {/* Email Address */}
            <div className="relative">
              <div className="absolute left-4 top-1/2 -translate-y-1/2">
                <svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M1.125 1.5C0.503906 1.5 0 2.00391 0 2.625C0 2.97891 0.166406 3.31172 0.45 3.525L5.55 7.35C5.81719 7.54922 6.18281 7.54922 6.45 7.35L11.55 3.525C11.8336 3.31172 12 2.97891 12 2.625C12 2.00391 11.4961 1.5 10.875 1.5H1.125ZM0 4.125V9C0 9.82734 0.672656 10.5 1.5 10.5H10.5C11.3273 10.5 12 9.82734 12 9V4.125L6.9 7.95C6.36562 8.35078 5.63438 8.35078 5.1 7.95L0 4.125Z" fill="#8B5E3C"/>
                </svg>
              </div>
              <input
                type="email"
                placeholder="Email Address"
                className="w-full h-14 pl-12 pr-4 rounded-2xl border border-[#8B5E3C]/30 bg-[#8B5E3C]/10 text-[#FEFAE0] placeholder-[#8B5E3C]/50 text-base font-normal outline-none focus:border-[#F4A261]/50 focus:bg-[#8B5E3C]/15 transition-colors"
              />
            </div>

            {/* Create Password */}
            <div className="relative">
              <div className="absolute left-4 top-1/2 -translate-y-1/2">
                <svg width="11" height="12" viewBox="0 0 11 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M3.375 3.375V4.5H7.125V3.375C7.125 2.33906 6.28594 1.5 5.25 1.5C4.21406 1.5 3.375 2.33906 3.375 3.375ZM1.875 4.5V3.375C1.875 1.51172 3.38672 0 5.25 0C7.11328 0 8.625 1.51172 8.625 3.375V4.5H9C9.82734 4.5 10.5 5.17266 10.5 6V10.5C10.5 11.3273 9.82734 12 9 12H1.5C0.672656 12 0 11.3273 0 10.5V6C0 5.17266 0.672656 4.5 1.5 4.5H1.875Z" fill="#8B5E3C"/>
                </svg>
              </div>
              <input
                type={showPassword ? "text" : "password"}
                placeholder="Create Password"
                className="w-full h-14 pl-12 pr-12 rounded-2xl border border-[#8B5E3C]/30 bg-[#8B5E3C]/10 text-[#FEFAE0] placeholder-[#8B5E3C]/50 text-base font-normal outline-none focus:border-[#F4A261]/50 focus:bg-[#8B5E3C]/15 transition-colors"
              />
              <button
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-[#8B5E3C]/50 hover:text-[#8B5E3C] transition-colors"
              >
                {showPassword ? (
                  <svg width="16" height="12" viewBox="0 0 16 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M8 0C4.36364 0 1.25818 2.18909 0 5.33333C1.25818 8.47758 4.36364 10.6667 8 10.6667C11.6364 10.6667 14.7418 8.47758 16 5.33333C14.7418 2.18909 11.6364 0 8 0ZM8 8.88889C5.94182 8.88889 4.27273 7.30182 4.27273 5.33333C4.27273 3.36485 5.94182 1.77778 8 1.77778C10.0582 1.77778 11.7273 3.36485 11.7273 5.33333C11.7273 7.30182 10.0582 8.88889 8 8.88889ZM8 3.2C6.77818 3.2 5.81818 4.14545 5.81818 5.33333C5.81818 6.52121 6.77818 7.46667 8 7.46667C9.22182 7.46667 10.1818 6.52121 10.1818 5.33333C10.1818 4.14545 9.22182 3.2 8 3.2Z" fill="currentColor"/>
                  </svg>
                ) : (
                  <svg width="16" height="14" viewBox="0 0 16 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M1.5 0.5L14.5 13.5M6.5 5.5C6.18 5.81 6 6.24 6 6.72C6 7.72 6.84 8.5 7.88 8.5C8.36 8.5 8.8 8.32 9.12 8M3.5 2.5C1.9 3.5 0.7 5 0 6.72C1.26 9.86 4.36 12 8 12C9.6 12 11.08 11.5 12.32 10.68M11.5 8.5C12.18 7.56 12.64 6.46 12.78 5.26C12.06 3.74 10.54 2.5 8.72 2.16" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                )}
              </button>
            </div>
          </div>

          {/* CTA Button */}
          <button className="w-full h-14 flex items-center justify-center gap-2 rounded-2xl bg-[#F4A261] text-[#100E0A] text-base font-bold tracking-wide hover:bg-[#f0985a] active:scale-[0.98] transition-all mb-6">
            Begin Journey
            <svg width="11" height="12" viewBox="0 0 11 12" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M10.2797 6.52974C10.5727 6.23677 10.5727 5.76099 10.2797 5.46802L6.52969 1.71802C6.23672 1.42505 5.76094 1.42505 5.46797 1.71802C5.175 2.01099 5.175 2.48677 5.46797 2.77974L7.94062 5.25005H0.75C0.335156 5.25005 0 5.58521 0 6.00005C0 6.41489 0.335156 6.75005 0.75 6.75005H7.93828L5.47031 9.22036C5.17734 9.51333 5.17734 9.98911 5.47031 10.2821C5.76328 10.575 6.23906 10.575 6.53203 10.2821L10.282 6.53208L10.2797 6.52974Z" fill="#100E0A"/>
            </svg>
          </button>

          {/* Divider */}
          <div className="flex items-center gap-4 mb-6">
            <div className="flex-1 h-px bg-[#8B5E3C]/20" />
            <span className="text-[#8B5E3C] text-xs font-semibold tracking-[0.6px] uppercase shrink-0">
              or join with
            </span>
            <div className="flex-1 h-px bg-[#8B5E3C]/20" />
          </div>

          {/* Social Buttons */}
          <div className="flex gap-4 mb-6">
            <button className="flex-1 h-14 flex items-center justify-center gap-2 rounded-2xl border border-[#8B5E3C]/30 bg-[#8B5E3C]/10 text-[#FEFAE0] text-sm font-semibold hover:bg-[#8B5E3C]/20 transition-colors">
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M17.16 9.20388C17.16 14.1785 13.7526 17.7187 8.72066 17.7187C3.89616 17.7187 0 13.8234 0 8.99997C0 4.17655 3.89616 0.28125 8.72066 0.28125C11.0696 0.28125 13.0458 1.14258 14.5684 2.56288L12.1949 4.84452C9.08988 1.84921 3.31596 4.09921 3.31596 8.99997C3.31596 12.041 5.74579 14.5054 8.72066 14.5054C12.1738 14.5054 13.4678 12.0304 13.6717 10.7472H8.72066V7.74841H17.0229C17.1037 8.1949 17.16 8.6238 17.16 9.20388Z" fill="#FEFAE0"/>
              </svg>
              Google
            </button>
            <button className="flex-1 h-14 flex items-center justify-center gap-2 rounded-2xl border border-[#8B5E3C]/30 bg-[#8B5E3C]/10 text-[#FEFAE0] text-sm font-semibold hover:bg-[#8B5E3C]/20 transition-colors">
              <svg width="14" height="18" viewBox="0 0 14 18" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11.2043 9.44648C11.1973 8.15625 11.7809 7.18242 12.9621 6.46523C12.3012 5.51953 11.3027 4.99922 9.98438 4.89727C8.73633 4.79883 7.37227 5.625 6.87305 5.625C6.3457 5.625 5.13633 4.93242 4.18711 4.93242C2.22539 4.96406 0.140625 6.49688 0.140625 9.61523C0.140625 10.5363 0.309375 11.4879 0.646875 12.4699C1.09688 13.7602 2.72109 16.9242 4.41563 16.8715C5.30156 16.8504 5.92734 16.2422 7.08047 16.2422C8.19844 16.2422 8.77851 16.8715 9.76641 16.8715C11.475 16.8469 12.9445 13.9711 13.3734 12.6773C11.0813 11.598 11.2043 9.51328 11.2043 9.44648ZM9.21445 3.67383C10.1742 2.53477 10.0863 1.49766 10.0582 1.125C9.21094 1.17422 8.23008 1.70156 7.67109 2.35195C7.05586 3.04805 6.69375 3.90938 6.77109 4.87969C7.68867 4.95 8.52539 4.47891 9.21445 3.67383Z" fill="#FEFAE0"/>
              </svg>
              Apple
            </button>
          </div>

          {/* Login link */}
          <div className="flex items-center justify-center gap-1">
            <span className="text-[#8B5E3C] text-sm font-normal leading-5">
              Already have an account?
            </span>
            <button className="text-[#F4A261] text-sm font-bold leading-5 border-b border-[#F4A261]/20 hover:border-[#F4A261]/60 transition-colors pb-px">
              Log in
            </button>
          </div>

          {/* Decorative glow */}
          <div className="absolute -bottom-12 -right-12 w-48 h-48 rounded-full bg-[#8B5E3C] opacity-5 blur-[50px] pointer-events-none" />
        </div>
      </div>
    </div>
  );
}
