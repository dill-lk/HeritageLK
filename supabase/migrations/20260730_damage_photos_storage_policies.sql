-- Storage policies for damage-photos bucket
-- IMPORTANT: Create the 'damage-photos' bucket in Supabase Dashboard > Storage first
-- Set it as PUBLIC so images can be viewed directly via URL
-- Then run the policies below in Supabase SQL Editor

-- Allow public read access (bucket is already public=true)
DROP POLICY IF EXISTS "Public read access for damage photos" ON storage.objects;
CREATE POLICY "Public read access for damage photos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'damage-photos');

-- Allow anonymous users to upload (for unauthenticated report submissions)
DROP POLICY IF EXISTS "Anon users can upload damage photos" ON storage.objects;
CREATE POLICY "Anon users can upload damage photos"
ON storage.objects FOR INSERT
TO anon
WITH CHECK (bucket_id = 'damage-photos');

-- Allow authenticated users to upload
DROP POLICY IF EXISTS "Authenticated users can upload damage photos" ON storage.objects;
CREATE POLICY "Authenticated users can upload damage photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'damage-photos');
