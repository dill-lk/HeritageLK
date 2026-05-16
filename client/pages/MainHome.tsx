import { Link } from "react-router-dom";

export default function MainHome() {
  return (
    <div className="min-h-screen bg-[#100E0A] text-[#FEFAE0] flex items-center justify-center px-6">
      <div className="w-full max-w-md rounded-3xl border border-[#8B5E3C]/30 bg-[#8B5E3C]/10 p-8 text-center">
        <h1 className="text-3xl font-bold mb-2">HeritageLK</h1>
        <p className="text-[#8B5E3C] mb-8">Explore and preserve Sri Lanka&apos;s heritage.</p>
        <div className="space-y-3">
          <Link
            to="/login"
            className="block w-full h-12 rounded-xl bg-[#F4A261] text-[#100E0A] font-semibold leading-[48px] hover:bg-[#f0985a] transition-colors"
          >
            Sign In
          </Link>
          <Link
            to="/signup"
            className="block w-full h-12 rounded-xl border border-[#F4A261]/40 text-[#F4A261] font-semibold leading-[48px] hover:border-[#F4A261] hover:bg-[#8B5E3C]/10 transition-colors"
          >
            Sign Up
          </Link>
        </div>
      </div>
    </div>
  );
}
