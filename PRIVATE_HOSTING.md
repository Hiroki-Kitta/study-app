# 知らない人に見られない公開方法

無料ホスティングにそのまま `data.js` を置くと、URLを知っている人は全文書を読めます。

知らない人に読まれにくくするには、公開用データを暗号化した `private_site` を使ってください。

## 暗号化版を作る

PowerShellでこのフォルダを開き、次を実行します。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\build-private-site.ps1
```

パスワードを聞かれるので、長めのパスワードを入力してください。

以下が作られます。

- `private_site`
- `private_site.zip`

この `private_site.zip` を Netlify Drop、Cloudflare Pages、GitHub Pages などへアップロードします。

## 仕組み

`private_site` には平文の `data.js` を入れません。代わりに、暗号化された `encrypted-data.js` を入れます。

ブラウザで開くとパスワード入力画面が表示され、正しいパスワードのときだけ文書データを復号します。

## Netlifyで自動更新する

Netlifyで自動更新したい場合は、GitHubなどのGitリポジトリにこのフォルダを入れて、Netlifyでそのリポジトリを接続します。

このフォルダには `netlify.toml` が入っているため、Netlifyは次の設定でビルドできます。

- Build command: `node build-private-site.mjs`
- Publish directory: `private_site`

Netlifyの環境変数に、必ず次を追加してください。

- Key: `STUDY_WIKI_PASSWORD`
- Value: 公開ページで入力する長めのパスワード

以後、`data.js` を更新してGitHubへpushすると、Netlifyが暗号化版を作り直して自動公開します。

文書内容をGitHubで見られたくない場合は、GitHubリポジトリをPrivateにしてください。

## 注意

- パスワードを忘れると公開版のデータは復号できません。
- 短いパスワードは推測されやすいです。
- パスワードを知っている人は全文書を読めます。
- 元のPC側の `data.js` は暗号化されていません。公開するのは `private_site` または `private_site.zip` だけにしてください。
