-- damage_reports table schema
-- Run this in Supabase SQL Editor to ensure the table has all required columns

CREATE TABLE IF NOT EXISTS public.damage_reports (
  id text PRIMARY KEY DEFAULT ('DR-' || floor(random() * 90000 + 10000)::text),
  location text NOT NULL,
  damage_type text NOT NULL,
  details text NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  user_id uuid REFERENCES auth.users(id),
  photo_url text,
  photos jsonb DEFAULT '[]'::jsonb,
  notes text DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.damage_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read access for damage_reports" ON public.damage_reports;
CREATE POLICY "Public read access for damage_reports"
  ON public.damage_reports FOR SELECT
  TO public
  USING (true);

DROP POLICY IF EXISTS "Anon insert damage_reports" ON public.damage_reports;
CREATE POLICY "Anon insert damage_reports"
  ON public.damage_reports FOR INSERT
  TO anon
  WITH CHECK (true);

DROP POLICY IF EXISTS "Authenticated update damage_reports" ON public.damage_reports;
CREATE POLICY "Authenticated update damage_reports"
  ON public.damage_reports FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Authenticated delete damage_reports" ON public.damage_reports;
CREATE POLICY "Authenticated delete damage_reports"
  ON public.damage_reports FOR DELETE
  TO authenticated
  USING (true);
