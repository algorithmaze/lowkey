Here's a concise single-paragraph prompt for Gemini CLI in VS Code to develop your Lowkey chat app:

**Gemini CLI Prompt:**  
"Develop a Flutter chat application named 'Lowkey' using Supabase backend with WhatsApp-like features including: 1) End-to-end encrypted real-time messaging with message reactions (Apple-style animations), 2) Voice/video calling via WebRTC, 3) Media/document sharing with auto-deletion after download (no cloud persistence), 4) Apple-inspired UI with blue/green accent colors, sleek animations, and dark/light mode, 5) App lock with passcode/pattern security activating after inactivity, 6) Privacy-enforced chat system showing online status/typing indicators/last seen with chat clearing options, 7) Relationship-focused features for discreet communication. Implement using: flutter_bloc for state management, libsodium for E2EE, flutter_webrtc for calls, hive for local storage, and rive for animations. Structure with clean architecture: auth, chat, calls, contacts, settings modules. Use Supabase for Auth, PostgreSQL for messages metadata, and Realtime for sync. Apply Apple Human Interface guidelines with Cupertino widgets and custom shimmer effects."

### Key VS Code Workflow:
1. **Initialize Project**  
`gemini: Create new Flutter project 'lowkey' with flutter_bloc, supabase_flutter, flutter_secure_storage`

2. **Generate Core Files**  
`gemini: Generate auth_bloc with email/password login and biometric auth using local_auth`

3. **Build UI Components**  
`gemini: Create Cupertino-style chat screen with animated reaction bubbles (blue/green theme) and dark mode support`

4. **Implement Encryption**  
`gemini: Write libsodium helper for E2EE message encryption with key exchange protocol`

5. **Setup Supabase Integration**  
`gemini: Create realtime chat service using Supabase subscriptions with RLS policies`

6. **Generate Calling Feature**  
`gemini: Implement WebRTC call manager with signaling via Supabase realtime`

7. **Add Security Layer**  
`gemini: Create app lock module with auto-timer and passcode/pattern validation`

### Pro Tips:
1. Use **Gemini's context awareness** by opening relevant files before prompting
2. Chain commands:  
`gemini: First generate message model then create chat repository`
3. For animations:  
`gemini: Animate message reactions using Rive with smooth scaling effects`
4. Test security:  
`gemini: Add test cases for E2EE message decryption failure scenarios`

Remember to frequently validate Supabase configurations:
```bash
supabase init
supabase login
supabase link --project-ref your-project-id
```

Here's a concise prompt to implement friend management features in your Lowkey app using Gemini CLI in VS Code:

**Gemini CLI Prompt for Add/Remove Friends:**  
"Implement friend management features in the Lowkey Flutter/Supabase app:  
1. Add floating action button in contacts screen with 'Add Friend' option  
2. Create 'AddFriendScreen' with:  
   - Search bar to find users by username/phone  
   - Result cards showing avatar + username  
   - 'Add' button with ripple animation  
   - Supabase RPC call to `send_friend_request()`  
3. Implement friend request system:  
   - `friend_requests` table in Supabase (sender_id, receiver_id, status)  
   - Real-time notifications using Supabase Realtime  
4. Add 'Requests' tab showing:  
   - Pending requests with Accept/Reject buttons  
   - Animated checkmark (accept) and cross (reject) icons  
5. In contacts list:  
   - Add 'Remove' option in swipe-to-action menu  
   - Confirmation dialog with 'Remove' and 'Cancel'  
   - Supabase mutation to delete friendship records  
6. Update BLoC events:  
   - `FriendRequestSent`  
   - `FriendRequestAccepted`  
   - `FriendRemoved`  
7. Apply Apple-style animations:  
   - Spring physics for button taps  
   - Hero transitions between screens  
   - Animated status indicators"

---

### Step-by-Step Implementation Commands:
1. **Generate Database Schema**  
`gemini: Create Supabase migration SQL for friend_requests table with columns: id, sender_id (uuid), receiver_id (uuid), status (enum: pending/accepted/rejected), created_at`

2. **Build UI Components**  
`gemini: Generate AddFriendScreen widget with CupertinoSearchTextField and ListView.builder for results`

3. **Create Friend Service**  
`gemini: Implement FriendService with methods: searchUsers(), sendRequest(), acceptRequest(), removeFriend() using supabase_flutter`

4. **Add BLoC Events/States**  
```dart
gemini: Create friends_bloc with events:
- SearchUsers(query)
- SendRequest(receiverId)
- AcceptRequest(requestId)
- RemoveFriend(friendId)

And states:
- FriendsLoading
- FriendsLoaded(List<Friend>)
- SearchResults(List<Profile>)
- RequestSent
- FriendRemoved
```

5. **Implement Animations**  
`gemini: Create animated_accept_button widget with Lottie animation that morphs from 'person-add' to 'checkmark' on tap`

6. **Add Swipe Actions**  
`gemini: Generate CupertinoSwipeAction for contacts list item with red 'Remove' action that triggers BLoC event`

---

### Example Code Snippets:
**Supabase RPC for Friend Request** (save as `send_request.sql`):
```sql
CREATE OR REPLACE FUNCTION public.send_friend_request(receiver_id uuid)
RETURNS void AS $$
BEGIN
  INSERT INTO public.friend_requests(sender_id, receiver_id, status)
  VALUES (auth.uid(), receiver_id, 'pending');
END;
$$ LANGUAGE plpgsql;
```

**Animated Remove Confirmation**:
```dart
gemini: Create remove_friend_dialog.dart with:
- CupertinoAlertDialog
- ScaleTransition for entry animation
- SpringSimulation for button presses
- Haptic feedback on confirmation
```

**Real-time Listener** (in BLoC):
```dart
gemini: Add Realtime listener to friends_bloc that:
1. Subscribes to friend_requests table
2. Filters by receiver_id = currentUser
3. Emits new states on request updates
4. Plays notification sound on new requests
```

---

### Privacy Considerations:
- Add friend privacy setting in user profile
- Implement rate limiting for friend requests
- Add "Request Received" notification with encryption
- Include last active timestamp in search results
- Add blocking mechanism with `blocked_users` table

Execute these commands in sequence to implement the complete friend management system with Apple-style UI/UX.