import { useState, useRef, useEffect, type FormEvent } from "react";
import { Link, useNavigate } from "react-router-dom";
import { supabase } from "@/lib/supabase";

const GlobeIcon = () => (
  <svg width="17" height="10" viewBox="0 0 17 10" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M0.616699 1.51859C0.616699 0.680995 1.2978 0 2.13552 0H6.69199H7.83111H8.21081H14.2861C15.1238 0 15.8049 0.680995 15.8049 1.51859V7.59297C15.8049 8.43057 15.1238 9.11155 14.2861 9.11155H8.21081H7.83111H6.69199H2.13552C1.2978 9.11155 0.616699 8.43057 0.616699 7.59297V1.51859ZM8.21081 1.51859V7.59297H14.2861V1.51859H8.21081ZM4.84804 2.65517C4.7721 2.48433 4.60124 2.37281 4.41376 2.37281C4.22628 2.37281 4.05541 2.48433 3.97947 2.65517L2.46065 6.07201C2.35385 6.31166 2.46301 6.59164 2.70271 6.69843C2.9424 6.80521 3.22243 6.69605 3.32922 6.4564L3.54044 5.97946H5.28708L5.49829 6.4564C5.60508 6.69605 5.88512 6.80283 6.1248 6.69843C6.3645 6.59403 6.47129 6.31166 6.36687 6.07201L4.84804 2.65517ZM4.41376 4.01478L4.86465 5.03035H3.96286L4.41376 4.01478ZM11.2485 2.37281C11.5095 2.37281 11.7231 2.58635 11.7231 2.84736V2.94227H12.7672H13.147C13.4081 2.94227 13.6216 3.15583 13.6216 3.41684C13.6216 3.67785 13.4081 3.8914 13.147 3.8914H13.0995L13.0616 3.99817C12.8504 4.57714 12.53 5.1039 12.1217 5.54999C12.1432 5.56423 12.1645 5.57609 12.1859 5.58795L12.6344 5.85608C12.8598 5.99134 12.9311 6.28319 12.7981 6.50624C12.6652 6.72927 12.371 6.80283 12.1479 6.66995L11.6994 6.40183C11.5926 6.33776 11.4905 6.27132 11.3885 6.20014C11.1369 6.3781 10.8688 6.53233 10.5816 6.66046L10.4962 6.69843C10.2564 6.80521 9.97647 6.69605 9.86963 6.4564C9.76289 6.21674 9.87209 5.93676 10.1117 5.82998L10.1971 5.79202C10.3491 5.7232 10.4962 5.64727 10.6362 5.55948L10.3466 5.27C10.1616 5.08493 10.1616 4.78357 10.3466 4.5985C10.5317 4.41342 10.8331 4.41342 11.0183 4.5985L11.3648 4.94493L11.3767 4.95679C11.6709 4.64595 11.9106 4.28528 12.0838 3.88903H11.2485H9.53974C9.27873 3.88903 9.06516 3.67548 9.06516 3.41447C9.06516 3.15345 9.27873 2.93991 9.53974 2.93991H10.7738V2.845C10.7738 2.58398 10.9874 2.37043 11.2485 2.37043V2.37281Z" fill="#F4A261"/>
  </svg>
);

const UserIcon = () => (
  <svg width="11" height="12" viewBox="0 0 11 12" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M5.25 6C6.04565 6 6.80871 5.68393 7.37132 5.12132C7.93393 4.55871 8.25 3.79565 8.25 3C8.25 2.20435 7.93393 1.44129 7.37132 0.87868C6.80871 0.316071 6.04565 0 5.25 0C4.45435 0 3.69129 0.316071 3.12868 0.87868C2.56607 1.44129 2.25 2.20435 2.25 3C2.25 3.79565 2.56607 4.55871 3.12868 5.12132C3.69129 5.68393 4.45435 6 5.25 6ZM4.17891 7.125C1.87031 7.125 0 8.99531 0 11.3039C0 11.6883 0.311719 12 0.696094 12H9.80391C10.1883 12 10.5 11.6883 10.5 11.3039C10.5 8.99531 8.62969 7.125 6.32109 7.125H4.17891Z" fill="#8B5E3C"/>
  </svg>
);

const LockIcon = () => (
  <svg width="11" height="12" viewBox="0 0 11 12" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M3.375 3.375V4.5H7.125V3.375C7.125 2.33906 6.28594 1.5 5.25 1.5C4.21406 1.5 3.375 2.33906 3.375 3.375ZM1.875 4.5V3.375C1.875 1.51172 3.38672 0 5.25 0C7.11328 0 8.625 1.51172 8.625 3.375V4.5H9C9.82734 4.5 10.5 5.17266 10.5 6V10.5C10.5 11.3273 9.82734 12 9 12H1.5C0.672656 12 0 11.3273 0 10.5V6C0 5.17266 0.672656 4.5 1.5 4.5H1.875Z" fill="#8B5E3C"/>
  </svg>
);

const languages = [
  { code: "en", label: "English", font: "Inter, sans-serif", weight: "600", size: "12px" },
  { code: "si", label: "සිංහල", font: "'Abhaya Libre', serif", weight: "700", size: "14px" },
  { code: "ta", label: "தமிழ்", font: "Inter, sans-serif", weight: "600", size: "12px" },
];

export default function Login() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [langOpen, setLangOpen] = useState(false);
  const [selectedLang, setSelectedLang] = useState(languages[0]);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [authMessage, setAuthMessage] = useState("");
  const langRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (langRef.current && !langRef.current.contains(e.target as Node)) {
        setLangOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleSignIn = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setAuthMessage("");

    if (!supabase) {
      setAuthMessage("Supabase is not configured. Add VITE_SUPABASE_URL and VITE_SUPABASE_PUBLISHABLE_KEY.");
      return;
    }

    setIsSubmitting(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setIsSubmitting(false);

    if (error) {
      setAuthMessage(error.message);
      return;
    }

    navigate("/home");
  };

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex items-center justify-center font-['Inter',sans-serif]">
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
            src="https://api.builder.io/api/v1/image/assets/TEMP/b02856ceecd423ab75d2e1d643e2e881960878b0?width=880"
            alt="Heritage"
            className="w-full h-full object-cover opacity-60"
          />
          {/* Bottom fade */}
          <div className="absolute inset-0 bg-gradient-to-t from-[#100E0A] via-[#100E0A]/0 to-transparent" />
          {/* Top fade */}
          <div className="absolute inset-0 bg-gradient-to-b from-[#100E0A]/40 via-transparent to-transparent" />

          {/* Top bar */}
          <div className="absolute top-0 left-0 right-0 flex items-start justify-between px-6 pt-12 sm:pt-14">
            {/* Language selector */}
            <div className="relative" ref={langRef}>
              <div
                className={`absolute left-0 top-0 transition-all duration-200 origin-top-left ${
                  langOpen
                    ? "opacity-80 scale-100 pointer-events-auto"
                    : "opacity-0 scale-95 pointer-events-none"
                }`}
              >
                <div className="flex flex-col gap-[5px] px-4 py-[9px] rounded-[25px] border border-[#F4A261]/25 bg-black/[0.58]" style={{ minWidth: "132px" }}>
                  {languages.map((lang) => (
                    <button
                      key={lang.code}
                      onClick={() => {
                        setSelectedLang(lang);
                        setLangOpen(false);
                      }}
                      className="flex items-center gap-[8px] text-left hover:opacity-100 transition-opacity"
                    >
                      <GlobeIcon />
                      <span
                        className="text-[#CA895B] leading-4"
                        style={{
                          fontFamily: lang.font,
                          fontWeight: lang.weight,
                          fontSize: lang.size,
                        }}
                      >
                        {lang.label}
                      </span>
                    </button>
                  ))}
                </div>
              </div>

              <button
                onClick={() => setLangOpen(!langOpen)}
                className={`flex items-center gap-2 h-8 px-4 rounded-full border border-[#F4A261]/20 bg-[#8B5E3C]/15 text-[#F4A261] text-xs font-semibold tracking-wide transition-opacity duration-150 ${langOpen ? "opacity-0 pointer-events-none" : "opacity-100"}`}
              >
                <GlobeIcon />
                <span
                  style={{
                    fontFamily: selectedLang.font,
                    fontWeight: selectedLang.weight,
                    fontSize: selectedLang.size,
                    color: "#F4A261",
                  }}
                >
                  {selectedLang.label}
                </span>
                <svg width="9" height="5" viewBox="0 0 9 5" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M3.61321 4.46405C3.83738 4.68837 4.20144 4.68837 4.42561 4.46405L7.86889 1.01852C8.09307 0.794204 8.09307 0.42991 7.86889 0.205592C7.64472 -0.0187259 7.28067 -0.0187259 7.0565 0.205592L4.01851 3.24555L0.980532 0.207387C0.756357 -0.0169315 0.392301 -0.0169315 0.168129 0.207387C-0.056043 0.431705 -0.056043 0.795998 0.168129 1.02031L3.61141 4.46584L3.61321 4.46405Z" fill="#F4A261"/>
                </svg>
              </button>
            </div>

            {/* Info button */}
            <button className="w-10 h-10 flex items-center justify-center rounded-full border border-[#F4A261]/10 bg-[#8B5E3C]/15 flex-shrink-0">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M8 16C10.1217 16 12.1566 15.1571 13.6569 13.6569C15.1571 12.1566 16 10.1217 16 8C16 5.87827 15.1571 3.84344 13.6569 2.34315C12.1566 0.842855 10.1217 0 8 0C5.87827 0 3.84344 0.842855 2.34315 2.34315C0.842855 3.84344 0 5.87827 0 8C0 10.1217 0.842855 12.1566 2.34315 13.6569C3.84344 15.1571 5.87827 16 8 16ZM6.75 10.5H7.5V8.5H6.75C6.33437 8.5 6 8.16562 6 7.75C6 7.33437 6.33437 7 6.75 7H8.25C8.66562 7 9 7.33437 9 7.75V10.5H9.25C9.66562 10.5 10 10.8344 10 11.25C10 11.6656 9.66562 12 9.25 12H6.75C6.33437 12 6 11.6656 6 11.25C6 10.8344 6.33437 10.5 6.75 10.5ZM8 4C8.26522 4 8.51957 4.10536 8.70711 4.29289C8.89464 4.48043 9 4.73478 9 5C9 5.26522 8.89464 5.51957 8.70711 5.70711C8.51957 5.89464 8.26522 6 8 6C7.73478 6 7.48043 5.89464 7.29289 5.70711C7.10536 5.51957 7 5.26522 7 5C7 4.73478 7.10536 4.48043 7.29289 4.29289C7.48043 4.10536 7.73478 4 8 4Z" fill="#F4A261"/>
              </svg>
            </button>
          </div>

          {/* Brand name & tagline */}
          <div className="absolute bottom-6 left-6">
            <p className="text-[#F4A261] font-['Inter',sans-serif] text-[32px] font-normal leading-[1.25]">
              HeritageLK
            </p>
            <p className="text-[#8B5E3C] text-sm font-semibold tracking-[0.7px] uppercase mt-0.5">
              Join the legacy
            </p>
          </div>
        </div>

        {/* Form Section */}
        <div className="flex-1 flex flex-col px-6 pb-12 pt-0 relative">
          {/* Heading */}
          <div className="mb-6">
            <h1 className="text-[#FEFAE0] text-2xl font-bold leading-9 mb-1">
              Welcome Back
            </h1>
            <p className="text-[#8B5E3C] text-sm font-normal leading-[21px]">
              Continue your journey through history.
            </p>
          </div>

          <form onSubmit={handleSignIn}>
            {/* Form fields */}
            <div className="flex flex-col gap-4 mb-3">
            {/* Username */}
            <div className="relative">
              <div className="absolute left-4 top-1/2 -translate-y-1/2 pointer-events-none">
                <UserIcon />
              </div>
              <input
                type="email"
                placeholder="Enter Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full h-14 pl-12 pr-4 rounded-2xl border border-[#8B5E3C]/30 bg-[#8B5E3C]/10 text-[#FEFAE0] placeholder-[#8B5E3C]/50 text-base font-normal outline-none focus:border-[#F4A261]/50 focus:bg-[#8B5E3C]/15 transition-colors font-['Plus_Jakarta_Sans',sans-serif]"
              />
            </div>

            {/* Password */}
            <div className="relative">
              <div className="absolute left-4 top-1/2 -translate-y-1/2 pointer-events-none">
                <LockIcon />
              </div>
              <input
                type={showPassword ? "text" : "password"}
                placeholder="Enter Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full h-14 pl-12 pr-12 rounded-2xl border border-[#8B5E3C]/30 bg-[#8B5E3C]/10 text-[#FEFAE0] placeholder-[#8B5E3C]/50 text-base font-normal outline-none focus:border-[#F4A261]/50 focus:bg-[#8B5E3C]/15 transition-colors font-['Plus_Jakarta_Sans',sans-serif]"
              />
              <button
                type="button"
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

            {authMessage ? (
              <p className="mb-4 text-sm text-[#F4A261]">{authMessage}</p>
            ) : null}

            {/* Forgot Password */}
            <div className="flex justify-end mb-6">
              <button type="button" className="text-[#F4A261] text-sm font-semibold leading-[21px] tracking-[0.027px] hover:opacity-80 transition-opacity">
                Forgot Password?
              </button>
            </div>

            {/* Sign In Button */}
            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full h-14 flex items-center justify-center gap-2 rounded-2xl bg-[#F4A261] text-[#100E0A] text-base font-bold tracking-wide hover:bg-[#f0985a] active:scale-[0.98] transition-all mb-6 disabled:opacity-60 disabled:cursor-not-allowed"
            >
              {isSubmitting ? "Signing In..." : "Sign In"}
              <svg width="11" height="9" viewBox="0 0 11 9" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M9.36642 4.78903C9.63337 4.52208 9.63337 4.08858 9.36642 3.82164L5.94958 0.404795C5.68263 0.137855 5.24912 0.137855 4.98218 0.404795C4.71523 0.671736 4.71523 1.10525 4.98218 1.37219L7.23515 3.62304H0.683368C0.30538 3.62304 0 3.92841 0 4.3064C0 4.68439 0.30538 4.98976 0.683368 4.98976H7.23302L4.98431 7.24061C4.71737 7.50755 4.71737 7.94106 4.98431 8.208C5.25125 8.47494 5.68477 8.47494 5.9517 8.208L9.36852 4.79116L9.36642 4.78903Z" fill="#100E0A"/>
              </svg>
            </button>
          </form>

          {/* Divider */}
          <div className="flex items-center gap-4 mb-6">
            <div className="flex-1 h-px bg-[#8B5E3C]/20" />
            <span className="text-[#8B5E3C] text-xs font-semibold tracking-[0.6px] shrink-0">
              or sign in with
            </span>
            <div className="flex-1 h-px bg-[#8B5E3C]/20" />
          </div>

          {/* Social Buttons */}
          <div className="flex gap-4 mb-8">
            <button className="flex-1 h-14 flex items-center justify-center gap-2 rounded-2xl border border-[#8B5E3C]/30 bg-[#8B5E3C]/10 text-[#FEFAE0] text-sm font-semibold hover:bg-[#8B5E3C]/20 transition-colors">
              <svg width="17" height="17" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M16.2067 8.42693C16.2067 13.1251 12.9886 16.4687 8.23618 16.4687C3.67971 16.4687 0 12.7898 0 8.23435C0 3.67889 3.67971 0 8.23618 0C10.4546 0 12.321 0.813475 13.759 2.15487L11.5174 4.30976C8.58489 1.48085 3.13174 3.60585 3.13174 8.23435C3.13174 11.1064 5.42658 13.434 8.23618 13.434C11.4975 13.434 12.7196 11.0965 12.9122 9.88456H8.23618V7.05232H16.0772C16.1535 7.474 16.2067 7.87908 16.2067 8.42693Z" fill="#FEFAE0"/>
              </svg>
              Google
            </button>
            <button className="flex-1 h-14 flex items-center justify-center gap-2 rounded-2xl border border-[#8B5E3C]/30 bg-[#8B5E3C]/10 text-[#FEFAE0] text-sm font-semibold hover:bg-[#8B5E3C]/20 transition-colors">
              <svg width="13" height="16" viewBox="0 0 13 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M10.2734 8.22709C10.2668 7.02902 10.8088 6.12475 11.9057 5.45878C11.2919 4.58063 10.3648 4.09749 9.14062 4.00282C7.98172 3.91141 6.71509 4.67857 6.25153 4.67857C5.76186 4.67857 4.63886 4.03546 3.75745 4.03546C1.93586 4.06484 0 5.48817 0 8.38378C0 9.23909 0.156696 10.1227 0.470089 11.0345C0.887946 12.2327 2.39615 15.1707 3.96964 15.1217C4.7923 15.1022 5.37338 14.5374 6.44414 14.5374C7.48225 14.5374 8.0209 15.1217 8.93822 15.1217C10.5248 15.0989 11.8893 12.4285 12.2876 11.2271C10.1591 10.2249 10.2734 8.28912 10.2734 8.22709ZM8.4257 2.86677C9.31691 1.80907 9.23529 0.846038 9.20918 0.5C8.42243 0.545703 7.51163 1.03538 6.99258 1.63931C6.42128 2.28569 6.08505 3.0855 6.15686 3.9865C7.0089 4.05179 7.78586 3.61434 8.4257 2.86677Z" fill="#FEFAE0"/>
              </svg>
              Apple
            </button>
          </div>

          {/* Sign up link */}
          <div className="flex items-center justify-center gap-1 pt-2">
            <span className="text-[#8B5E3C] text-sm font-normal leading-[21px]">
              Don't have an account?
            </span>
            <Link to="/signup" className="text-[#F4A261] text-sm font-bold leading-[21px] hover:opacity-80 transition-opacity">
              Sign up
            </Link>
          </div>

          <div className="absolute -bottom-12 -right-12 w-48 h-48 rounded-full bg-[#8B5E3C] opacity-5 blur-[50px] pointer-events-none" />
        </div>
      </div>
    </div>
  );
}
