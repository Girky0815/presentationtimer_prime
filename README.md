# presentationtimer_prime(プレゼンタイマー Prime(仮))
Material 3 Expressive 風 プレゼンテーション用タイマー

## 機能
- プレゼンテーション(発表/LT/発表練習)用のストップウォッチとタイマー機能
- 自由に定義可能なベル設定(ベルの鳴る時間，鳴る回数)
- [このiOSアプリ](https://apps.apple.com/jp/app/%E3%83%97%E3%83%AC%E3%82%BC%E3%83%B3%E3%82%BF%E3%82%A4%E3%83%9E%E3%83%BC/id291171573)をパクリスペクトしたもの
  - 現状 Windows x64, Android arm64 で動作
- ライトテーマ/ダークテーマ 両対応
  - v1.1.2+: 既定ではOSの設定に従うように．
- **Material 3 Expressive** 風のデザインを使用し，見やすく使いやすいUIを目指した．
  - まだ試験段階ではあるものの，**ダイナミックカラー**(システムのアクセントカラーに従いアプリのカラーパレットを決める設定)に対応している．
- (Windows x64)インストール不要．
- 広告無し，課金なし(完全無料)
  - 作者は広告や課金制が嫌いなため，ここは徹底している．

## 推奨環境
- Windows 11 24H2/25H2
- Android 15/16
  - アプリ自体はAndroid 12L以上で起動できるように設計されている

その他環境は未検証(おそらくDebianはビルドすれば使える可能性はある)

MacOS/iOS/iPadOS: 対応予定なし(作者は該当OSのデバイスを持っておらず，検証不可能)

## インストール方法
### Windows x64の場合
- リリースページのx64のZIPファイルを解凍して，任意の場所に配置する
- .exeを実行する
### Android arm64の場合
- (おすすめ)Obtainium を使用してインストールする
  - ↓ここからどうぞ(日本語漢字が中国語フォントで表示されるため文字が見づらいが)
  - <a href="https://apps.obtainium.imranr.dev/redirect?r=obtainium://add/https://github.com/girky0815/presentationtimer_prime"><img src="https://github.com/ImranR98/Obtainium/blob/main/assets/graphics/badge_obtainium.png" alt="Obtainiumからインストール" height="50"></a>
- リリースページのarm用.apkファイルをダウンロードし，インストールする
  - この際，「提供元不明のアプリをインストールする」権限を許可する必要がある

## 免責事項
- Google Antigravity(Gemini 3 Pro)を使用して作成した．
  - 作者はコードの品質は保証しない．
  - 本ソフトウェアはGoogle Antigravityの実験および作者のアプリ開発における自己満足のために作成している．
- 本ソフトウェア使用により利用者に発生した損害について，作者はいかなる責任も負わない(要するに自己責任)．
- 本ソフトウェアの使用によるいかなる損失も補償しない．

### Android 版の制限
- アプリの設定データが編集できない．
- ~~Flutter が Material 3 Expressive に完全対応していないため，ダイナミックカラーをONにすると背景色とカードが一体化して見づらくなることがある．~~
  - ~~Android 版では無効化推奨(Windows 版では問題がないのでお好みで)．~~
  - 本問題はv4.1.2で修正済．ダイナミックカラーの使用はお好みでどうぞ．

## できること/できないこと
### できること
- プレゼンテーション用の計時
- ダークテーマ対応により，ダークテーマが好きな人でも使える(OSでダークテーマを使用している場合は起動時からダークテーマが適用される)

### できないこと
- PowerPoint / LibreOffice Impress 等プレゼンテーションソフトとの連携機能
  - スライドごとの発表時間を掲示するなど．

### 今後やりたいこと
- アプリ設定の永続化/カスタム可能へ
  - カラースキームのカスタムもできれば実装したい
- Flutter の Material 3 Expressive 対応が拡張された場合，より Material 3 Expressive 風デザインにする(UI リワーク)
- ラップ機能(擬似的なスライドごとの所要時間計時)

## ライセンス
- 現在，コードのライセンス未指定．MIT Licenseにする予定
- 使用しているフォントは現状で Google Fonts にあるものを使用しており，いずれもOFL(SIL Open Font License)ライセンスで提供されている
  - 日本語フォント: [Noto Sans JP](https://fonts.google.com/noto/specimen/Noto+Sans+JP?query=noto+sans+jp)
  - 英語フォント(日本語が混じる箇所): [QuickSand](https://fonts.google.com/specimen/Quicksand)
  - 英語フォント(時刻など，日本語が混じらない箇所): [Google Sans Flex](https://fonts.google.com/specimen/Google+Sans+Flex)
    - 現時点でGoogle Sans FlexにFlutterが対応していないため，リポジトリに本フォントを埋め込んでいる
- 現在，ベルの音はポケットサウンド様の音源を使用している．
  - https://pocket-se.info
- Flutter はBSDライセンスのもと提供されている．

## スクリーンショット集
v1.0.5時点

<img width="40%" height="713" alt="image" src="https://github.com/user-attachments/assets/cec1e898-334a-451d-b67f-89d8a45cca18" alt="デフォルト画面" />
<img width="40%" height="713" alt="image" src="https://github.com/user-attachments/assets/bf11d495-63ab-4c56-82bd-81144a53fdcf" alt="ベル設定UI"/>
<img width="40%" height="713" alt="image" src="https://github.com/user-attachments/assets/4f5b6b29-2624-4917-b418-d7ad096a72d4" alt="アプリ設定UI"/>
<img width="40%" height="713" alt="image" src="https://github.com/user-attachments/assets/8216543b-588e-496a-88c9-284f03ead0b7" alt="ダークテーマ有効化"/>


## 開発関連
- CI/CDを導入．
  - タグを設定すると自動でビルドし，リリースを下書き状態にするように．
  - プライベートリポジトリにする場合，プライベートリポジトリではGitHub Actionsが有料となるため，`/.github/workflows/release.yml`を削除する必要がある．

---
#### 以下FlutterデフォルトのREADME
# presentationtimer_prime

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
