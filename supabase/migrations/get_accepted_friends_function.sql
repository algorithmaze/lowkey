CREATE OR REPLACE FUNCTION get_accepted_friends(p_user_id uuid)
RETURNS SETOF public.profiles
LANGUAGE plpgsql
AS $$
DECLARE
    friend_id uuid;
BEGIN
    -- Get friends where p_user_id is the sender
    FOR friend_id IN
        SELECT receiver_id
        FROM public.friend_requests
        WHERE sender_id = p_user_id AND status = 'accepted'
    LOOP
        RETURN QUERY SELECT * FROM public.profiles WHERE id = friend_id;
    END LOOP;

    -- Get friends where p_user_id is the receiver
    FOR friend_id IN
        SELECT sender_id
        FROM public.friend_requests
        WHERE receiver_id = p_user_id AND status = 'accepted'
    LOOP
        RETURN QUERY SELECT * FROM public.profiles WHERE id = friend_id;
    END LOOP;

    RETURN;
END;
$$;