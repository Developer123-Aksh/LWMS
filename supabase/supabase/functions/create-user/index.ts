import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  // ✅ Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  let body: any;

  try {
    body = await req.json();
  } catch (_) {
    return new Response(
      JSON.stringify({ error: "Invalid or empty JSON body" }),
      { status: 400 },
    );
  }

  const {
    email,
    password,
    name,
    mobile_no,
    role,
    organisation_id,
    venue_id,
  } = body;

  if (!email || !password || !name || !role || !organisation_id) {
    return new Response(
      JSON.stringify({ error: "Missing required fields" }),
      { status: 400 },
    );
  }

  const supabaseAdmin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  try {
    // 1️⃣ Create auth user
    const { data: authUser, error: authError } =
      await supabaseAdmin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      });

    if (authError) throw authError;

    // 2️⃣ Insert into users table
    const { error: insertError } = await supabaseAdmin
      .from("users")
      .insert({
        id: authUser.user.id,
        name,
        email_id: email,
        mobile_no,
        role,
        organisation_id,
        venue_id,
      });

    if (insertError) throw insertError;

    return new Response(
      JSON.stringify({ success: true }),
      {
        status: 200,
        headers: {
          "Access-Control-Allow-Origin": "*",
        },
      },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: e.message }),
      {
        status: 500,
        headers: {
          "Access-Control-Allow-Origin": "*",
        },
      },
    );
  }
});
