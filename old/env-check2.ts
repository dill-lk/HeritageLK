import { createClient } from "@supabase/supabase-js";
const supabase = createClient(
  process.env.VITE_SUPABASE_URL,
  process.env.VITE_SUPABASE_ANON_KEY,
);
async function get() {
  const { data } = await supabase.from("archives").select("user_id").limit(1);
  console.log(data);
}
get();
