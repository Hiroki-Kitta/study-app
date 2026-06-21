# Netlifyで自動更新する方法

Netlifyは、GitHubなどのGitリポジトリと接続すると、変更をpushしたタイミングで自動的にビルドして公開できます。

このWikiでは、Netlify側で `data.js` を暗号化し、公開用の `private_site` を作る設定にしています。

## 1. GitHubリポジトリを作る

GitHubで新しいリポジトリを作ります。

文書内容を他人に見られたくない場合は、必ずPrivateリポジトリにしてください。

このフォルダのファイルをGitHubへ入れます。`private_site`、`private_site.zip`、`public_site`、`public_site.zip` は入れなくて大丈夫です。

## 2. Netlifyに接続する

Netlifyで次の流れを選びます。

1. Add new project
2. Import an existing project
3. GitHubを選択
4. このWikiのリポジトリを選択

このフォルダには `netlify.toml` があるので、Netlifyのビルド設定は基本的に自動で読まれます。

- Build command: `node build-private-site.mjs`
- Publish directory: `private_site`

## 3. パスワードを環境変数に入れる

NetlifyのProject settingsで環境変数を追加します。

- Key: `STUDY_WIKI_PASSWORD`
- Value: サイトを開くときに入力する長めのパスワード

この値は公開ページにはそのまま出ません。Netlifyのビルド時に暗号化キーとして使われます。

## 4. 更新するとき

Codexが `data.js` を更新したあと、変更をGitHubへpushします。

pushするとNetlifyが自動的に次を実行します。

```text
node build-private-site.mjs
```

その結果、暗号化された `private_site` が公開されます。

## 注意

- PCの中のファイルを保存しただけではNetlifyは更新されません。
- 自動更新のきっかけはGitHubへのpushです。
- 文書内容を隠したい場合、GitHubリポジトリはPrivateにしてください。
- Netlifyに公開されるのは暗号化済みの `encrypted-data.js` です。
