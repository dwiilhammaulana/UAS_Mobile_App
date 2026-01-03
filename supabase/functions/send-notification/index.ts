import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const encodeBase64Url = (str: string) =>
  btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")

serve(async () => {
  const serviceAccount = JSON.parse(
    Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ?? '{}'
  )

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

  const encodedSignature = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")

  const jwt = `${signingInput}.${encodedSignature}`

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  })

  const { access_token } = await tokenRes.json()

  return new Response(access_token ? "Token OK" : "Token failed", { status: 200 })
})
