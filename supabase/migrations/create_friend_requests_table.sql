CREATE TABLE public.friend_requests (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status text NOT NULL DEFAULT 'pending',
    created_at timestamp with time zone DEFAULT now()
);

ALTER TABLE public.friend_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can send friend requests to others." ON public.friend_requests
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can view their own sent and received friend requests." ON public.friend_requests
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can accept or reject their received friend requests." ON public.friend_requests
  FOR UPDATE USING (auth.uid() = receiver_id);

CREATE POLICY "Users can delete their own sent friend requests." ON public.friend_requests
  FOR DELETE USING (auth.uid() = sender_id);