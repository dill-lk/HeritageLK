import "./global.css";

import { Toaster } from "@/components/ui/toaster";
import { createRoot } from "react-dom/client";
import { useEffect, useState } from "react";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { Session } from "@supabase/supabase-js";
import { BrowserRouter, Routes, Route, Navigate, useNavigate } from "react-router-dom";
import { supabase } from "@/lib/supabase";
import Index from "./pages/Index";
import Login from "./pages/Login";
import Home from "./pages/Home";
import Explore from "./pages/Explore";
import Quests from "./pages/Quests";
import Scanner from "./pages/Scanner";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

const AuthCallback = ({
  isReady,
  session,
}: {
  isReady: boolean;
  session: Session | null;
}) => {
  const navigate = useNavigate();

  useEffect(() => {
    if (!isReady) {
      return;
    }

    navigate(session ? "/home" : "/login", { replace: true });
  }, [isReady, navigate, session]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#100E0A] px-6 text-center text-[#FEFAE0]">
      Completing verification...
    </div>
  );
};

const App = () => {
  const [session, setSession] = useState<Session | null>(null);
  const [isAuthReady, setIsAuthReady] = useState(false);

  useEffect(() => {
    if (!supabase) {
      setIsAuthReady(true);
      return;
    }

    void supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      setIsAuthReady(true);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      setSession(nextSession);
      setIsAuthReady(true);
    });

    return () => subscription.unsubscribe();
  }, []);

  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter basename={import.meta.env.BASE_URL}>
          <Routes>
            <Route path="/" element={<Navigate to={session ? "/home" : "/login"} replace />} />
            <Route
              path="/auth/callback"
              element={<AuthCallback isReady={isAuthReady} session={session} />}
            />
            <Route path="/login" element={session ? <Navigate to="/home" replace /> : <Login />} />
            <Route path="/signup" element={session ? <Navigate to="/home" replace /> : <Index />} />
            <Route path="/home" element={<Home />} />
            <Route path="/explore" element={<Explore />} />
            <Route path="/quests" element={<Quests />} />
            <Route path="/scanner" element={<Scanner />} />
            {/* ADD ALL CUSTOM ROUTES ABOVE THE CATCH-ALL "*" ROUTE */}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </BrowserRouter>
      </TooltipProvider>
    </QueryClientProvider>
  );
};

const rootElement = document.getElementById("root")!;
// Reuse existing root during HMR to avoid duplicate root warning
const existingRoot = (rootElement as any).__reactRoot;
if (existingRoot) {
  existingRoot.render(<App />);
} else {
  const root = createRoot(rootElement);
  (rootElement as any).__reactRoot = root;
  root.render(<App />);
}
