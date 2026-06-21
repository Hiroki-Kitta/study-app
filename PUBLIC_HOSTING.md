# 同じWi-Fi外から見る方法

このWikiは静的ファイルだけで動くため、無料の静的ホスティングに置けば、スマホからどこでも読めます。

## 一番おすすめ

`public_site` フォルダを作り、その中身を Netlify Drop、Cloudflare Pages、GitHub Pages などの無料静的ホスティングにアップロードします。

## 公開用ファイルを作る

PowerShellでこのフォルダを開き、次を実行します。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\build-public-site.ps1
```

`public_site` フォルダが作られます。中に入っている以下の4ファイルを公開します。

- `index.html`
- `styles.css`
- `app.js`
- `data.js`

同時に `public_site.zip` も作られます。フォルダのアップロードで権限エラーが出る場合は、このZIPをアップロードしてください。

## 更新するとき

Codexが `data.js` に文書を追加したら、もう一度 `build-public-site.ps1` を実行し、公開先へ再アップロードしてください。

## 注意

公開した `data.js` は誰でも読めます。個人的なメモや非公開情報を入れた文書は、公開用に分けてください。

知らない人に読まれたくない場合は、この公開版ではなく `PRIVATE_HOSTING.md` の暗号化版を使ってください。
