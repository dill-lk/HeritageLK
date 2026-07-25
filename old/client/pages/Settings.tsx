import {
  ArrowLeft,
  User,
  Lock,
  Bell,
  Shield,
  LifeBuoy,
  MessageSquare,
  Info,
  LogOut,
} from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";

export default function Settings() {
  const navigate = useNavigate();
  const [userName, setUserName] = useState("");
  const [userLevel, setUserLevel] = useState("Curator Level 4");

  useEffect(() => {
    async function fetchUser() {
      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (!session?.user) return;

      const defaultName =
        session.user.user_metadata?.full_name ||
        session.user.email?.split("@")[0] ||
        "Explorer";
      setUserName(defaultName.split(" ")[0]);

      try {
        const { data } = await supabase
          .from("profiles")
          .select("full_name, points")
          .eq("id", session.user.id)
          .maybeSingle();

        if (data?.full_name) {
          setUserName(data.full_name);
        }

        // Simple level logic for display
        if (data?.points) {
          const lvl = Math.max(1, Math.floor(data.points / 100));
          setUserLevel(`Curator Level ${lvl}`);
        }
      } catch (e) {}
    }
    fetchUser();
  }, []);

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    navigate("/login");
  };

  return (
    <div className="min-h-screen w-full bg-[#100E0A] flex justify-center font-['Plus_Jakarta_Sans',sans-serif]">
      <div className="relative w-full sm:max-w-[430px] min-h-screen bg-[#100E0A] text-white overflow-y-auto overflow-x-hidden shadow-[0_0_40px_rgba(0,0,0,0.5)]">
        {/* Header background image */}
        <div
          className="absolute top-0 left-0 right-0 h-[220px] bg-cover bg-center z-0"
          style={{
            backgroundImage:
              "url('https://images.unsplash.com/photo-1586224372551-7f91854580bf?q=80&w=800&auto=format&fit=crop')", // Sigiriya or similar
            maskImage:
              "linear-gradient(to bottom, rgba(0,0,0,1) 0%, rgba(0,0,0,0) 100%)",
            WebkitMaskImage:
              "linear-gradient(to bottom, rgba(0,0,0,1) 0%, rgba(0,0,0,0) 100%)",
            opacity: 0.6,
          }}
        />

        <div className="relative z-10 px-6 pt-10 pb-8 min-h-screen flex flex-col">
          {/* Top Bar */}
          <div className="flex items-center justify-between mb-8">
            <Link
              to="/profile"
              className="w-10 h-10 rounded-full bg-white/10 backdrop-blur-md border border-white/10 flex items-center justify-center transition-colors hover:bg-white/20"
            >
              <ArrowLeft className="w-5 h-5 text-white" />
            </Link>
            <h1 className="text-2xl font-bold font-['Playfair_Display',serif]">
              Settings
            </h1>
            <div className="w-10 h-10 rounded-full bg-white/10 backdrop-blur-md border border-white/10 flex items-center justify-center">
              <Info className="w-5 h-5 text-[#E9C46A]" />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-[#F4A261] text-lg font-bold">HeritageLK</h2>
            <p className="text-[#F4A261]/80 text-xs font-bold uppercase tracking-wider">
              EDIT PROFILE
            </p>
          </div>

          {/* User Preview */}
          <div className="flex items-center gap-4 mb-10">
            <div className="w-14 h-14 rounded-full overflow-hidden border border-[#F4A261]/30">
              <img
                src="https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=200&auto=format&fit=crop"
                alt="Profile"
                className="w-full h-full object-cover"
              />
            </div>
            <div>
              <p className="font-bold text-white text-lg">
                {userName || "Disara Bimsilu"}
              </p>
              <p className="text-[#F4A261]/80 text-sm">{userLevel}</p>
            </div>
          </div>

          <div className="flex flex-col gap-8">
            {/* Account Section */}
            <div>
              <h3 className="text-[#F4A261]/50 text-xs font-bold uppercase tracking-widest mb-4">
                ACCOUNT
              </h3>
              <div className="flex flex-col gap-1">
                <Link
                  to="/settings/personal"
                  className="flex items-center justify-between p-4 bg-white/5 border border-white/5 rounded-2xl mb-2 hover:bg-white/10 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <User className="w-5 h-5 text-[#F4A261]" />
                    <span className="text-sm font-medium">
                      Personal Information
                    </span>
                  </div>
                  <ArrowLeft className="w-4 h-4 text-white/40 rotate-180" />
                </Link>
                <Link
                  to="/settings/security"
                  className="flex items-center justify-between p-4 bg-white/5 border border-white/5 rounded-2xl hover:bg-white/10 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <Lock className="w-5 h-5 text-[#F4A261]" />
                    <span className="text-sm font-medium">Security</span>
                  </div>
                  <ArrowLeft className="w-4 h-4 text-white/40 rotate-180" />
                </Link>
              </div>
            </div>

            {/* Preferences & Privacy Section */}
            <div>
              <h3 className="text-[#F4A261]/50 text-xs font-bold uppercase tracking-widest mb-4">
                PREFERENCES & PRIVACY
              </h3>
              <div className="flex flex-col gap-1">
                <Link
                  to="/settings/notifications"
                  className="flex items-center justify-between p-4 bg-white/5 border border-white/5 rounded-2xl mb-2 hover:bg-white/10 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <Bell className="w-5 h-5 text-[#F4A261]" />
                    <span className="text-sm font-medium">Notifications</span>
                  </div>
                  <ArrowLeft className="w-4 h-4 text-white/40 rotate-180" />
                </Link>
                <Link
                  to="/settings/privacy"
                  className="flex items-center justify-between p-4 bg-white/5 border border-white/5 rounded-2xl hover:bg-white/10 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <Shield className="w-5 h-5 text-[#F4A261]" />
                    <span className="text-sm font-medium">Privacy & Data</span>
                  </div>
                  <ArrowLeft className="w-4 h-4 text-white/40 rotate-180" />
                </Link>
              </div>
            </div>

            {/* Support Section */}
            <div>
              <h3 className="text-[#F4A261]/50 text-xs font-bold uppercase tracking-widest mb-4">
                SUPPORT
              </h3>
              <div className="flex flex-col gap-1">
                <Link
                  to="/settings/help"
                  className="flex items-center justify-between p-4 bg-white/5 border border-white/5 rounded-2xl mb-2 hover:bg-white/10 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <LifeBuoy className="w-5 h-5 text-[#F4A261]" />
                    <span className="text-sm font-medium">Help Center</span>
                  </div>
                  <ArrowLeft className="w-4 h-4 text-white/40 rotate-180" />
                </Link>
                <Link
                  to="/settings/feedback"
                  className="flex items-center justify-between p-4 bg-white/5 border border-white/5 rounded-2xl mb-2 hover:bg-white/10 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <MessageSquare className="w-5 h-5 text-[#F4A261]" />
                    <span className="text-sm font-medium">Give a Feedback</span>
                  </div>
                  <ArrowLeft className="w-4 h-4 text-white/40 rotate-180" />
                </Link>
                <Link
                  to="/settings/about"
                  className="flex items-center justify-between p-4 bg-white/5 border border-white/5 rounded-2xl hover:bg-white/10 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <Lock className="w-5 h-5 text-[#F4A261]" />
                    <span className="text-sm font-medium">
                      About HeritageLK
                    </span>
                  </div>
                  <ArrowLeft className="w-4 h-4 text-white/40 rotate-180" />
                </Link>
              </div>
            </div>
          </div>

          <button
            onClick={handleSignOut}
            className="w-full mt-10 p-4 border border-red-500/20 rounded-2xl text-red-400 font-bold hover:bg-red-500/10 transition-colors"
          >
            Log Out
          </button>

          <div className="mt-12 flex flex-col items-center justify-center opacity-50 pb-8">
            <p className="text-[#F4A261] text-xs font-bold uppercase tracking-widest flex items-center gap-2 mb-2">
              <span className="w-4 h-3 bg-[#F4A261] rounded-[2px] opacity-80 inline-block" />
              PRESERVE THE LEGACY
            </p>
            <p className="text-[10px]">Version 2.4.1 (Stable Build)</p>
          </div>
        </div>
      </div>
    </div>
  );
}
