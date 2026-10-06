# homebrew-tap

[Kanaemi](https://github.com/kanaemi-app/kanaemi) を [Homebrew](https://brew.sh/) で入れるための tap です。

```sh
brew install --cask kanaemi-app/tap/kanaemi
```

入れたあと、システム設定の「キーボード」の「入力ソース」で Kanaemi を足してください。一覧に出てこないときは、一度ログアウトしてログインし直してください。

## インストーラーで入れた Kanaemi から乗り換える

インストーラー（`.pkg`）で入れた Kanaemi がすでにあると、Homebrew は上書きせずに止まります。`--force` を付けて置き換えてください。置き換わるのはアプリだけで、辞書と設定はそのまま残ります。

```sh
brew install --cask --force kanaemi-app/tap/kanaemi
```

インストーラーが残した記録も消すなら、次を流します。

```sh
pkgutil --forget io.github.kanaemi-app.kanaemi
```

## 更新とアンインストール

```sh
brew upgrade --cask kanaemi
brew uninstall --cask kanaemi
```

`brew uninstall --zap --cask kanaemi` は、辞書・設定・ログまで消します。

cask は Kanaemi のリリースのたびに、`.github/workflows/update.yml` が書き直します。
