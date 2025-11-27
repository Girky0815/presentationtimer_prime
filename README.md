# presentationtimer_prime(プレゼンタイマー Prime(仮))
Material 3 Expressive 風 プレゼンテーション用タイマー

## 機能
- プレゼンテーション(発表/LT/発表練習)用のストップウォッチとタイマー機能
- 自由に定義可能なベル設定(ベルの鳴る時間，鳴る回数)
- [このiOSアプリ](https://apps.apple.com/jp/app/%E3%83%97%E3%83%AC%E3%82%BC%E3%83%B3%E3%82%BF%E3%82%A4%E3%83%9E%E3%83%BC/id291171573)をパクリスペクトしたもの
  - 現状 Windows で動作
- ライトテーマ/ダークテーマ 両対応
- Material 3 Expressive 風のデザインを使用し，見やすく使いやすいUIを目指した．
- (Windows x64)インストール不要．

## 推奨環境
- Windows 11 24H2/25H2
その他環境は未検証

## 免責事項
- Google Antigravity(Gemini 3 Pro)を使用して作成した
  - コードの品質は保証せず，バグが含まれている可能性がある．
- 本ソフトウェアは試験的に提供されている．
- 本ソフトウェア使用により利用者に発生した損害について，作者はいかなる責任も負わない(自己責任)．
- 本ソフトウェアの使用によるいかなる損失も補償しない．

## できること/できないこと
### できること
- プレゼンテーション用の計時
- ダークテーマ対応により，ダークテーマが好きな人でも使える

### できないこと(今後やりたいこと)
- アプリ設定の永続化/カスタム可能へ
  - カラースキームのカスタムもできれば実装したい
- Flutter の Material 3 Expressive 対応が拡張された場合，より Material 3 Expressive 風デザインにする(UI リワーク)

## ライセンス
- 現在，コードのライセンス未指定．MIT Licenseにする予定
- 使用しているフォントは現状で Google Fonts にあるものを使用しており，いずれもOFL(SIL Open Font License)ライセンスで提供されている
- 現在，ブザーはポケットサウンド様の音源を使用している．
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

---
#### 以下デフォルトのREADME
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
