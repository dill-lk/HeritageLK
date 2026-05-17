import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabasePublishableKey =
  import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY ?? import.meta.env.VITE_SUPABASE_ANON_KEY;

const isPlaceholder = (value?: string) => Boolean(value?.startsWith("__") && value?.endsWith("__"));
const hasValidUrl = (() => {
  if (!supabaseUrl || isPlaceholder(supabaseUrl)) {
    return false;
  }
  try {
    new URL(supabaseUrl);
    return true;
  } catch {
    return false;
  }
})();

export const isSupabaseConfigured = Boolean(
  hasValidUrl && supabasePublishableKey && !isPlaceholder(supabasePublishableKey),
);

export const supabase = isSupabaseConfigured
  ? createClient(supabaseUrl!, supabasePublishableKey!)
  : null;
