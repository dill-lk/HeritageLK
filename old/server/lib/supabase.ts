import { createClient } from "@supabase/supabase-js";

export const getServerSupabaseConfig = () => {
  const supabaseUrl = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL;
  const supabaseAnonKey =
    process.env.SUPABASE_ANON_KEY ||
    process.env.VITE_SUPABASE_ANON_KEY ||
    process.env.VITE_SUPABASE_PUBLISHABLE_KEY;
  return { supabaseUrl, supabaseAnonKey };
};

const { supabaseUrl, supabaseAnonKey } = getServerSupabaseConfig();

export const getRequiredServerSupabaseConfig = () => {
  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error("Supabase URL/anon key not configured on the server");
  }

  return { supabaseUrl, supabaseAnonKey };
};

export const supabaseServer =
  supabaseUrl && supabaseAnonKey
    ? createClient(supabaseUrl, supabaseAnonKey)
    : null;
