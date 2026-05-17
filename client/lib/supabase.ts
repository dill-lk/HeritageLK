import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabasePublishableKey =
  import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY ?? import.meta.env.VITE_SUPABASE_ANON_KEY;
const supabaseAuthRedirectUrl = import.meta.env.VITE_SUPABASE_AUTH_REDIRECT_URL;

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

const getValidUrl = (value?: string) => {
  if (!value || isPlaceholder(value)) {
    return null;
  }

  try {
    return new URL(value).toString();
  } catch {
    return null;
  }
};

export const isSupabaseConfigured = Boolean(
  hasValidUrl && supabasePublishableKey && !isPlaceholder(supabasePublishableKey),
);

export const getSupabaseEmailRedirectUrl = () => {
  const configuredRedirectUrl = getValidUrl(supabaseAuthRedirectUrl);
  if (configuredRedirectUrl) {
    return configuredRedirectUrl;
  }

  if (typeof window === "undefined") {
    return undefined;
  }

  return new URL("/auth/callback", window.location.origin).toString();
};

export const supabase = isSupabaseConfigured
  ? createClient(supabaseUrl!, supabasePublishableKey!)
  : null;
