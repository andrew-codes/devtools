# Mac App Store apps, as { "App Name" = <numeric app id>; }.
#
# Deliberately NOT wired into `homebrew.masApps`. nix-darwin runs brew bundle
# via plain `sudo --user=<you>` without `launchctl asuser`, so it lands outside
# your per-user launchd session. `mas` reaches the App Store through StoreAgent,
# which lives in that session, so `mas list` comes back empty there and brew
# bundle concludes the app is missing -- then `mas install` fails for want of a
# TTY to sudo against. That happens on every rebuild no matter what's actually
# installed. (For contrast, nix-darwin does use `launchctl asuser` for the
# home-manager activation on the very next lines of the same script.)
#
# So setup/macOS.sh reads this file directly and runs `mas get` as the real
# user, in the real session, where mas works. Find an app's id with:
#   mas search "App Name"
{
  # Dynamic Wallpaper Library intentionally omitted on the `work` branch: not
  # installed in the work-environment variant of this config.
}
