import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const encodeBase64Url = (str: string) =>
  btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")

serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const serviceAccount = JSON.parse(
    Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ?? '{}'
  )

  const now = new Date(new Date().getTime() + (7 * 60 * 60 * 1000))
  const currentDate = now.toISOString().split('T')[0]
  const currentTime = now.toTimeString().split(' ')[0].substring(0, 5)

  const { data: todos } = await supabase
    .from('todos')
    .select('*')
    .eq('reminder_sent', false)
    .lte('reminder_date', currentDate)
    .lte('reminder_time', currentTime)

  if (!todos || todos.length === 0) {
    return new Response("No reminders", { status: 200 })
  }

  const rawKey = serviceAccount.private_key.replace(/\\n/g, "\n")
  const pem = rawKey.replace(/-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----|\s+/g, "")
  const binaryKey = Uint8Array.from(atob(pem), c => c.charCodeAt(0))

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  )

  const header = encodeBase64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }))
  const iat = Math.floor(Date.now() / 1000)
  const payload = encodeBase64Url(JSON.stringify({
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: "https://oauth2.googleapis.com/token",
    iat,
    exp: iat + 3600,
    scope: "https://www.googleapis.com/auth/cloud-platform",
  }))

  const signingInput = `${header}.${payload}`
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput)
  )

  const jwt = `${signingInput}.${btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")}`

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  })

  const { access_token } = await tokenRes.json()

  for (const todo of todos) {
    const { data: tokens } = await supabase
      .from('firebase_tokens')
      .select('fcm_token')
      .eq('user_id', todo.user_id)
      .limit(1)

    if (!tokens || tokens.length === 0) continue

    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${access_token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token: tokens[0].fcm_token,
            notification: {
              title: `🔔 Tugas: ${todo.title}`,
              body: todo.description || "Jangan lupa kerjakan tugasmu!",
            },
          },
        }),
      }
    )

    if (res.ok) {
      await supabase.from('todos')
        .update({ reminder_sent: true })
        .eq('id', todo.id)
    }
  }

  return new Response("Success", { status: 200 })
})
