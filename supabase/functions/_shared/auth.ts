import { createClient } from "npm:@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json",
};

/**
 * Middleware that verifies the caller's JWT using Supabase Auth.
 *
 * `getClaims()` validates the token locally using cached asymmetric public
 * keys from the JWKS endpoint — no round-trip to the Auth server.
 *
 * CORS preflight (OPTIONS) requests are passed through without auth.
 *
 * Usage:
 * ```ts
 * import { withAuth } from "../_shared/auth.ts";
 *
 * serve(withAuth(async (req, claims) => {
 *   const userId = claims.sub;
 *   // ...
 *   return new Response(JSON.stringify({ ok: true }));
 * }));
 * ```
 */
export function withAuth(
  handler: (req: Request, claims: Record<string, unknown>) => Promise<Response>,
): (req: Request) => Promise<Response> {
  return async (req: Request): Promise<Response> => {
    if (req.method === "OPTIONS") {
      return new Response("ok", { headers: CORS_HEADERS });
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing Authorization header" }),
        { status: 401, headers: CORS_HEADERS },
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
    );

    const token = authHeader.replace("Bearer ", "");
    const { data, error } = await supabase.auth.getClaims(token);
    if (error || !data?.claims?.sub) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        { status: 401, headers: CORS_HEADERS },
      );
    }

    return handler(req, data.claims as Record<string, unknown>);
  };
}
