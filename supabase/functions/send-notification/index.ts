import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const now = new Date(new Date().getTime() + (7 * 60 * 60 * 1000))
  const currentDate = now.toISOString().split('T')[0]
  const currentTime = now.toTimeString().split(' ')[0].substring(0, 5)

  const { data: todos, error } = await supabase
    .from('todos')
    .select('*')
    .eq('reminder_sent', false)
    .lte('reminder_date', currentDate)
    .lte('reminder_time', currentTime)

  if (error) throw error
  if (!todos || todos.length === 0) {
    return new Response("No reminders", { status: 200 })
  }

  return new Response("Todos found", { status: 200 })
})
