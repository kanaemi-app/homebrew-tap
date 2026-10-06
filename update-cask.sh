#!/usr/bin/env bash
# Write Casks/kanaemi.rb for the latest release of Kanaemi from the app it
# ships. The latest, not a given one: a prerelease or a rerun of an older
# release would otherwise hand that version to every brew upgrade.
set -euo pipefail

tag="$(gh release view --repo kanaemi-app/kanaemi --json tagName --jq .tagName)"
version="${tag#v}"
root="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

zip="Kanaemi-$version-macos-arm64.zip"
gh release download "$tag" --repo kanaemi-app/kanaemi --pattern "$zip" --dir "$work"
sha256="$(sha256sum "$work/$zip" | cut -d' ' -f1)"

mkdir -p "$root/Casks"
cat >"$root/Casks/kanaemi.rb" <<RUBY
cask "kanaemi" do
  version "$version"
  sha256 "$sha256"

  url "https://github.com/kanaemi-app/kanaemi/releases/download/v#{version}/Kanaemi-#{version}-macos-arm64.zip"
  name "Kanaemi"
  desc "Japanese input method based on SKK"
  homepage "https://kanaemi-app.github.io/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :ventura

  input_method "Kanaemi.app"

  # Kanaemi is signed by its own identity rather than notarized, so Gatekeeper
  # would refuse it while it carries the quarantine Homebrew gives downloads.
  preflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "Kanaemi.app"], chdir: "{{staged_path}}"
  end

  # A running instance keeps the old binary; macOS starts the new one when
  # needed.
  postflight_steps do
    terminate_process "kanaemi"
    terminate_process "kanaemi-settings"
  end

  uninstall quit: [
    "io.github.kanaemi-app.inputmethod.Kanaemi",
    "io.github.kanaemi-app.kanaemi.settings",
  ]

  zap trash: [
    "~/Library/Application Support/kanaemi",
    "~/Library/Caches/io.github.kanaemi-app.kanaemi.settings",
    "~/Library/Caches/kanaemi",
    "~/Library/Logs/kanaemi.log*",
    "~/Library/WebKit/io.github.kanaemi-app.kanaemi.settings",
  ]

  # System Settings lists input sources from a cache that does not notice a
  # newly installed one. The installer package removes it, but install steps
  # run in a sandbox that may not write where the cache lives.
  caveats <<~EOS
    Add Kanaemi in System Settings > Keyboard > Input Sources.
    If it is not listed there, quit System Settings, remove the cache of the list,
    and open System Settings again:
      rm "\$(getconf DARWIN_USER_CACHE_DIR)"/com.apple.IntlDataCache.le*
  EOS
end
RUBY
