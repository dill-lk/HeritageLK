import "./global.css";

import { Toaster } from "@/components/ui/toaster";
import { createRoot } from "react-dom/client";
import { useEffect } from "react";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { supabase } from "@/lib/supabase";
import Index from "./pages/Index";
import Login from "./pages/Login";
import Home from "./pages/Home";
import Quests from "./pages/Quests";
import Scanner from "./pages/Scanner";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

const App = () => {
  useEffect(() => {
    if (!supabase) {
      return;
    }
    void supabase.auth.getSession();
  }, []);

  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter basename={import.meta.env.BASE_URL}>
          <Routes>
            <Route path="/" element={<Navigate to="/login" replace />} />
            <Route path="/login" element={<Login />} />
            <Route path="/signup" element={<Index />} />
            <Route path="/home" element={<Home />} />
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
