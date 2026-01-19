// ============================================================================
// OBJECTIVE 1: THE BOUNCER (TCP HANDSHAKE & IDENTITY)
// Purpose: Establish a secure identity before switching to high-speed UDP.
// ============================================================================
// TODO: 
// 1. Establish TCP connection (standard std.net.Address/Stream).
// 2. Perform Key Exchange: Use HKDF to "stretch" a password string 
//    plus a server-provided Salt into a high-entropy 32-byte Secret Key.
// 3. Receive unique 20-byte Connection ID (CID) from server.
// 4. Synchronize initial Sequence Counters (starting at 0 or random).
// 5. Close TCP; transition to UDP using the CID and Derived Key.



// ============================================================================
// OBJECTIVE 2: THE ARMORED ENVELOPE (UDP AEAD + HEADER PROTECTION)
// Purpose: Encrypt data and hide the sequence counter from traffic analysis.
// ============================================================================
// TODO:
// 1. Packet Construction:
//    - Bytes [0..19]: Visible Connection ID (for server routing).
//    - Bytes [20..27]: MASKED Sequence Counter (The "Hidden" Nonce).
//    - Bytes [28..43]: 16-byte AEAD Tag (The "Bit-Lock").
//    - Bytes [44..N]: Encrypted Payload (Game Data).
// 2. Encryption: Use XChaCha20-Poly1305 with the Secret Key.
// 3. Header Protection: Use a separate "Header Key" to XOR the 
//    Sequence Counter bits so the packet looks like random noise.
// 4. Verification: On receive, check CID -> Unmask Counter -> Verify Tag.



// ============================================================================
// OBJECTIVE 3: THE TRAFFIC COP (RELIABILITY & CONGESTION)
// Purpose: Prevent "Death Spirals" and manage network traffic jams.
// ============================================================================
// TODO:
// 1. Heartbeat System: Send encrypted timestamps to calculate RTT (Ping).
// 2. Acknowledgment (ACK): Maintain a bit-mask of received sequence numbers.
// 3. Token Bucket Rate Limiter: Cap outgoing packets based on current "tokens."
// 4. AIMD Logic (The Speed Limit):
//    - Success: Increase token refill rate by 5% (Additive Increase).
//    - Loss: Cut token refill rate by 50% (Multiplicative Decrease).
// 5. Retransmission: Only re-send packets flagged as "Critical" if ACK times out.