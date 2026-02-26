# 04 — Song Management (Performer)

## Overview
Confirmed performers maintain a personal song library — the set of songs they are able to perform. This library is used throughout the app: on the gig screen (what the audience can request), the performer details page (public song list), and the request song flow (filtering by what the performer can play).

## Song library
- A performer's song library is a list of songs they can play
- Each song has at minimum: **title** and **artist**
- Songs in the library are public (visible to audience on the performer details and gig screens)

## Adding songs
- Performer can search for a song by title or artist
- Search uses the **Spotify API** for lookup
- Selecting a search result adds it to the library with title, artist, and Spotify track ID stored
- Performer can also add a song manually (title + artist, no lookup required) as a fallback

## Editing and removing songs
- Performer can remove a song from their library at any time, including during an active gig
- Removing a song does not affect active or historical gig data — a request is a standalone record, not a reference to the song library
- Edit: only manual-entry songs need editing; search-sourced songs are fixed

## Genre tags
- Genre is derived from Spotify track/artist metadata
- Genres are surfaced as chips on the public performer details page
- Performer does not manually set genre per song

## Song management location
- Accessible from the Performer Profile page (private management screen)
- Not directly accessible from the audience-facing Performer Details page

## Open questions
- Does Spotify search require user auth (OAuth) or can we use the client credentials flow (app-level token)?
- How are genres surfaced if Spotify doesn't provide them for a given track? (fallback to artist genres, or omit?)
- Can a performer reorder their song list, or is it always sorted alphabetically?
- Is there a maximum number of songs in a performer's library?
