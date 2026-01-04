import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const encodeBase64Url = (str: string) =>
  btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

serve(async (_req) => {
  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const serviceAccount = JSON.parse(
      Deno.env.get("FIREBASE_SERVICE_ACCOUNT") ?? "{}"
    );

    const now = new Date(Date.now() + 7 * 60 * 60 * 1000);
    const currentDate = now.toISOString().split("T")[0];
    const currentTime = now.toTimeString().split(" ")[0].substring(0, 5);

    console.log(`[WIB] Checking: ${currentDate} ${currentTime}`);

    const { data: todos, error: todoError } = await supabase
      .from("todos")
      .select("*")
      .eq("reminder_sent", false)
      .lte("reminder_date", currentDate)
      .lte("reminder_time", currentTime);

    if (todoError) throw todoError;
    if (!todos || todos.length === 0) return new Response("No reminders", { status: 200 });

    const rawKey = (serviceAccount.private_key ?? "").replace(/\\n/g, "\n");
    if (!rawKey || !serviceAccount.client_email || !serviceAccount.project_id) {
      throw new Error("Service account env tidak lengkap (private_key/client_email/project_id).");
    }

    const pemContents = rawKey.replace(
      /-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----|\s+/g,
      ""
    );
    const binaryKey = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

    const cryptoKey = await crypto.subtle.importKey(
      "pkcs8",
      binaryKey,
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["sign"]
    );

    const header = encodeBase64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
    const iat = Math.floor(Date.now() / 1000);
    const exp = iat + 3600;

    const payload = encodeBase64Url(
      JSON.stringify({
        iss: serviceAccount.client_email,
        sub: serviceAccount.client_email,
        aud: "https://oauth2.googleapis.com/token",
        iat,
        exp,
        scope: "https://www.googleapis.com/auth/firebase.messaging",
      })
    );

    const signingInput = `${header}.${payload}`;
    const signature = await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      cryptoKey,
      new TextEncoder().encode(signingInput)
    );

    const encodedSignature = btoa(String.fromCharCode(...new Uint8Array(signature)))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "");

    const jwt = `${signingInput}.${encodedSignature}`;

    const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: jwt,
      }),
    });

    if (!tokenRes.ok) {
      const t = await tokenRes.text();
      throw new Error(`Gagal ambil access token: ${t}`);
    }

    const { access_token } = await tokenRes.json();
    if (!access_token) throw new Error("access_token kosong.");

    for (const todo of todos) {
      const { data: tokenRows, error: tokenErr } = await supabase
        .from("firebase_tokens")
        .select("fcm_token, updated_at")
        .eq("user_id", todo.user_id)
        .order("updated_at", { ascending: false })
        .limit(1);

      if (tokenErr) {
        console.log(`⚠️ Token query error untuk user ${todo.user_id}: ${tokenErr.message}`);
        continue;
      }

      const tokenRow = tokenRows?.[0];
      const fcmToken = tokenRow?.fcm_token;

      if (!fcmToken) {
        console.log(`⚠️ Skip: User ${todo.user_id} tidak punya token valid.`);
        continue;
      }

      const fcmRes = await fetch(
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${access_token}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
  message: {
    token: fcmToken,
    notification: {
      title: `🔔 Tugas: ${todo.title}`,
      body: todo.description || "Jangan lupa kerjakan tugasmu!",
    },
    data: {
      todo_id: String(todo.id),   
    },
  },
}),

        }
      );

      if (fcmRes.ok) {
        await supabase.from("todos").update({ reminder_sent: true }).eq("id", todo.id);
        console.log(`✅ Sukses: Notifikasi "${todo.title}" terkirim.`);
      } else {
        const errorText = await fcmRes.text();
        console.error(`❌ Gagal FCM: ${errorText}`);

        try {
          const errorObj = JSON.parse(errorText);
          if (
            fcmRes.status === 404 &&
            errorObj.error?.details?.[0]?.errorCode === "UNREGISTERED"
          ) {
            console.log(`🧹 Membersihkan token kadaluwarsa (UNREGISTERED) untuk user ${todo.user_id}`);
            await supabase.from("firebase_tokens").delete().eq("fcm_token", fcmToken);
          }
        } catch {
          console.error("Gagal memproses detail error FCM.");
        }
      }
    }

    return new Response("Success", { status: 200 });
  } catch (error) {
    console.error("CRITICAL ERROR:", error?.message ?? error);
    return new Response(String(error?.message ?? error), { status: 500 });
  }
});
