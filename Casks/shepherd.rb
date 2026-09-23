# Homebrew cask for Shepherd, published via the schnaq/homebrew-tap repo
# (tap name: schnaq/tap). Install with:
#   brew install --cask schnaq/tap/shepherd
#
# The template this is copied from lives in the app repo at
# Scripts/homebrew/shepherd.rb, so the cask is reviewed alongside the release
# pipeline that feeds it. Two values change per release — the version and the
# DMG's sha256; docs/RELEASING.md § Homebrew has both commands. Take the
# checksum from the *published* DMG, never from a local build: re-running the
# release workflow for a tag replaces the assets.
cask "shepherd" do
  version "1.5.2"
  sha256 "a81d74644920d0266b7c340b44e040f62863b8018e6ae3565bf2f4919626aa94"

  url "https://github.com/schnaq/shepherd/releases/download/v#{version}/Shepherd-#{version}.dmg",
      verified: "github.com/schnaq/shepherd/"
  name "Shepherd"
  desc "Review inbox for pull requests from coding agents"
  homepage "https://github.com/schnaq/shepherd"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Sparkle keeps the installed copy current, so Homebrew should not fight it: `brew upgrade`
  # leaves an app with `auto_updates true` alone unless the cask's version moved.
  auto_updates true
  # ADR 0038: macOS 27 (Golden Gate) and Apple Silicon only. `brew audit --cask` is the arbiter of the
  # symbol name if a future Homebrew renames it.
  depends_on arch: :arm64
  depends_on macos: :golden_gate

  app "Shepherd.app"

  # The `shepherd` command line (ADR 0013) is a separate build product and is not inside the
  # DMG, so there is no `binary` stanza; the README documents building it. If it is ever copied
  # into the app bundle, add:
  #   binary "#{appdir}/Shepherd.app/Contents/MacOS/shepherd"

  zap trash: [
    "~/Library/Application Support/Shepherd",
    "~/Library/Caches/com.schnaq.shepherd",
    "~/Library/HTTPStorages/com.schnaq.shepherd",
    "~/Library/Preferences/com.schnaq.shepherd.plist",
    "~/Library/Saved Application State/com.schnaq.shepherd.savedState",
  ]

  caveats <<~EOS
    Shepherd keeps everything on this Mac: the local database lives in
    ~/Library/Application Support/Shepherd and your GitHub token lives in the Keychain.
    `brew uninstall --zap --cask shepherd` removes both.
  EOS
end
