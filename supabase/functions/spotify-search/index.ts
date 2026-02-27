import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { withAuth } from "../_shared/auth.ts";

const SPOTIFY_TOKEN_URL = "https://accounts.spotify.com/api/token";
const SPOTIFY_API_BASE = "https://api.spotify.com/v1";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ---------------------------------------------------------------------------
// Token cache
// ---------------------------------------------------------------------------

interface SpotifyToken {
  accessToken: string;
  expiresAt: number;
}

let cachedToken: SpotifyToken | null = null;

async function getAccessToken(): Promise<string> {
  if (cachedToken && Date.now() < cachedToken.expiresAt) {
    return cachedToken.accessToken;
  }

  const clientId = Deno.env.get("SPOTIFY_CLIENT_ID");
  const clientSecret = Deno.env.get("SPOTIFY_CLIENT_SECRET");

  if (!clientId || !clientSecret) {
    console.log(Deno.env.toObject());
    throw new Error("Missing SPOTIFY_CLIENT_ID or SPOTIFY_CLIENT_SECRET");
  }

  const response = await fetch(SPOTIFY_TOKEN_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      Authorization: `Basic ${btoa(`${clientId}:${clientSecret}`)}`,
    },
    body: "grant_type=client_credentials",
  });

  if (!response.ok) {
    throw new Error(`Spotify token request failed: ${response.status}`);
  }

  const data = await response.json();

  cachedToken = {
    accessToken: data.access_token,
    // Expire 60s early to avoid edge-of-expiry failures.
    expiresAt: Date.now() + (data.expires_in - 60) * 1000,
  };

  return cachedToken.accessToken;
}

// ---------------------------------------------------------------------------
// Search action
// ---------------------------------------------------------------------------

interface SearchTrack {
  spotify_track_id: string;
  title: string;
  artist: string;
  artist_id: string;
  album_art_url: string | null;
}

async function handleSearch(
  query: string,
  accessToken: string
): Promise<Response> {
  const searchParams = new URLSearchParams({
    q: query.trim(),
    type: "track",
    limit: "20",
  });

  const response = await fetch(
    `${SPOTIFY_API_BASE}/search?${searchParams}`,
    { headers: { Authorization: `Bearer ${accessToken}` } }
  );

  if (response.status === 429) {
    return new Response(
      JSON.stringify({ error: "Rate limited. Try again in a moment." }),
      { status: 429, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  }

  if (!response.ok) {
    throw new Error(`Spotify search failed: ${response.status}`);
  }

  const data = await response.json();

  const tracks: SearchTrack[] = (data.tracks?.items ?? []).map(
    // deno-lint-ignore no-explicit-any
    (track: any) => ({
      spotify_track_id: track.id,
      title: track.name,
      artist:
        track.artists?.map((a: { name: string }) => a.name).join(", ") ??
        "Unknown Artist",
      artist_id: track.artists?.[0]?.id ?? "",
      album_art_url: track.album?.images?.[0]?.url ?? null,
    })
  );

  return new Response(JSON.stringify({ tracks }), {
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

// ---------------------------------------------------------------------------
// Artist genres action
// ---------------------------------------------------------------------------

async function handleArtistGenres(
  artistId: string,
  accessToken: string
): Promise<Response> {
  const response = await fetch(`${SPOTIFY_API_BASE}/artists/${artistId}`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });

  if (response.status === 429) {
    return new Response(
      JSON.stringify({ error: "Rate limited. Try again in a moment." }),
      { status: 429, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  }

  if (!response.ok) {
    // Non-fatal: genres are best-effort. Return empty array.
    return new Response(JSON.stringify({ genres: [] }), {
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }

  const data = await response.json();

  return new Response(
    JSON.stringify({ genres: data.genres ?? [] }),
    { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
  );
}

// ---------------------------------------------------------------------------
// Handler
// ---------------------------------------------------------------------------

serve(withAuth(async (req, _claims) => {
  try {
    const body = await req.json();

    const accessToken = await getAccessToken();

    // Action: search — { "action": "search", "query": "..." }
    if (body.action === "search") {
      if (!body.query || typeof body.query !== "string" || body.query.trim().length === 0) {
        return new Response(
          JSON.stringify({ error: "query is required" }),
          { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
        );
      }
      return handleSearch(body.query, accessToken);
    }

    // Action: artist-genres — { "action": "artist-genres", "artistId": "..." }
    if (body.action === "artist-genres") {
      if (!body.artistId || typeof body.artistId !== "string") {
        return new Response(
          JSON.stringify({ error: "artistId is required" }),
          { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
        );
      }
      return handleArtistGenres(body.artistId, accessToken);
    }

    return new Response(
      JSON.stringify({ error: "Unknown action. Use 'search' or 'artist-genres'." }),
      { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("spotify-search error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  }
}));
