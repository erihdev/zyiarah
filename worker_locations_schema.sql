-- ==========================================
-- Live Worker Tracking Schema
-- ==========================================

-- 1. Create worker_locations Table
CREATE TABLE public.worker_locations (
    worker_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.worker_locations ENABLE ROW LEVEL SECURITY;

-- Policy: Workers can upsert their own location
CREATE POLICY "Workers can update their own location" 
ON public.worker_locations FOR ALL 
USING (worker_id = auth.uid())
WITH CHECK (worker_id = auth.uid());

-- Policy: Everyone (or clients/admins) can read locations
CREATE POLICY "Locations are viewable by everyone" 
ON public.worker_locations FOR SELECT 
USING (true);

-- 2. Enable Realtime for worker_locations
-- Note: Make sure Realtime is enabled in your Supabase Dashboard settings as well.
ALTER PUBLICATION supabase_realtime ADD TABLE public.worker_locations;
