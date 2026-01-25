import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const encodeBase64Url = (str: string) =>
  btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

function toWibNow() {
  // WIB = UTC+7
  return new Date(Date.now() + 7 * 60 * 60 * 1000);
}

async function getGoogleAccessToken(serviceAccount: any) {
  const rawKey = (serviceAccount.private_key ?? "").replace(/\\n/g, "\n");
  if (!rawKey || !serviceAccount.client_email || !serviceAccount.project_id) {
    throw new Error(
      "Service account env tidak lengkap (private_key/client_email/project_id)."
    );
  }

  // Convert PEM -> binary pkcs8
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

  const encodedSignature = btoa(
    String.fromCharCode(...new Uint8Array(signature))
  )
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

  const json = await tokenRes.json();
  if (!json.access_token) throw new Error("access_token kosong.");
  return json.access_token as string;
}

async function sendFcmV1(params: {
  accessToken: string;
  projectId: string;
  fcmToken: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}) {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${params.projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${params.accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: params.fcmToken,
          notification: {
            title: params.title,
            body: params.body,
          },
          data: params.data ?? {},
          android: {
            priority: "HIGH",
          },
        },
      }),
    }
  );

  const text = await res.text();
  return { ok: res.ok, status: res.status, text };
}

function isUnregisteredError(status: number, bodyText: string) {
  if (status !== 404) return false;
  try {
    const obj = JSON.parse(bodyText);
    return obj?.error?.details?.[0]?.errorCode === "UNREGISTERED";
  } catch {
    return false;
  }
}

serve(async (_req) => {
  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const serviceAccount = JSON.parse(
      Deno.env.get("FIREBASE_SERVICE_ACCOUNT") ?? "{}"
    );

    // WIB time
    const now = toWibNow();
    const currentDate = now.toISOString().split("T")[0]; // YYYY-MM-DD
    const currentTime = now.toTimeString().slice(0, 5);  // HH:mm

    console.log(`[WIB] Checking: ${currentDate} ${currentTime}`);

    // Ambil todo yang waktunya sudah lewat dan belum dikirim
    const { data: todos, error: todoError } = await supabase
      .from("todos")
      .select("id,user_id,title,description,reminder_date,reminder_time,reminder_sent")
      .eq("reminder_sent", false)
      .lte("reminder_date", currentDate)
      .lte("reminder_time", currentTime);

    if (todoError) throw todoError;
    if (!todos || todos.length === 0) {
      return new Response("No reminders", { status: 200 });
    }

    const accessToken = await getGoogleAccessToken(serviceAccount);
    const projectId = serviceAccount.project_id as string;

    for (const todo of todos) {
      // Ambil SEMUA token milik user (bukan cuma 1)
      const { data: tokenRows, error: tokenErr } = await supabase
        .from("firebase_tokens")
        .select("fcm_token, updated_at")
        .eq("user_id", todo.user_id)
        .order("updated_at", { ascending: false });

      if (tokenErr) {
        console.log(`⚠️ Token query error untuk user ${todo.user_id}: ${tokenErr.message}`);
        continue;
      }

      const tokens = (tokenRows ?? [])
        .map((r) => r.fcm_token)
        .filter((t) => typeof t === "string" && t.length > 0);

      if (tokens.length === 0) {
        console.log(`⚠️ Skip: User ${todo.user_id} tidak punya token.`);
        continue;
      }

      let successCount = 0;

      // Kirim ke semua token (multi device)
      for (const fcmToken of tokens) {
        const fcm = await sendFcmV1({
          accessToken,
          projectId,
          fcmToken,
          title: `🔔 Tugas: ${todo.title}`,
          body: todo.description || "Jangan lupa kerjakan tugasmu!",
          data: {
            todo_id: String(todo.id),
          },
        });

        if (fcm.ok) {
          successCount++;
          console.log(`✅ Sukses kirim ke token: ${fcmToken.slice(0, 16)}...`);
        } else {
          console.error(`❌ Gagal FCM (${fcm.status}): ${fcm.text}`);

          // Kalau token UNREGISTERED => hapus token
          if (isUnregisteredError(fcm.status, fcm.text)) {
            console.log(`🧹 Hapus token UNREGISTERED: ${fcmToken.slice(0, 16)}...`);
            await supabase.from("firebase_tokens").delete().eq("fcm_token", fcmToken);
          }
        }
      }

      // Update reminder_sent hanya jika minimal 1 sukses
      if (successCount > 0) {
        await supabase.from("todos").update({ reminder_sent: true }).eq("id", todo.id);
        console.log(`✅ Todo "${todo.title}" ditandai reminder_sent=true`);
      } else {
        console.log(`⚠️ Tidak ada token yang sukses untuk todo "${todo.title}" (akan dicoba lagi)`);
      }
    }

    return new Response("Success", { status: 200 });
  } catch (error) {
    console.error("CRITICAL ERROR:", error?.message ?? error);
    return new Response(String(error?.message ?? error), { status: 500 });
  }
});
