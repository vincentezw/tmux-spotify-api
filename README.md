# tmux-spotify-api Public

## What the Fuck Is This?
tmux-spotify-api Public displays the currently playing song on Spotify directly in your tmux statusline. This badass tool works even in SSH sessions, so you can jam out and know what's playing no matter where you're logged in from.

## Installation Instructions

### Prerequisites
- You need a `.env` file in your home directory containing your `SPOTIFY_CLIENT_ID` and `SPOTIFY_SECRET`. Get these by creating an app in the Spotify Developer Dashboard.
- This shit needs to be run from the tmux plugin folder, typically found at `~/.tmux/plugins/tmux-spotify-api`.

### Setup
1. Navigate to your tmux plugin folder: `cd ~/.tmux/plugins/tmux-spotify-api/`
2. Run `spotify.rb`: `ruby ./spotify.rb`

This will redirect your ass to a Spotify authorization page. Authorize it, and then you'll be sent to a non-existent address. Don't freak out! Just copy the value of the "code" parameter from the URL.

3. Paste the "code" into the prompt that appears in your terminal. This completes the authorization.

### Configuration
Add the following line to your tmux status bar config: `#{spotify_now_playing}`.

This will display the currently playing song in your tmux statusline.

## Who Should Use This?
Literally anyone who wants to see what song is playing in their tmux sessions, especially useful for SSH sessions where traditional methods like AppleScript or MPRIS are as useless as a marzipan dildo.

