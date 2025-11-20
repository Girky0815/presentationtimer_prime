---
trigger: always_on
---

# Project Context & Rules
以下の要件に従い、Windowsデスクトップ向けのプレゼンテーションタイマーアプリを開発して

## 1. プロジェクト概要
- **アプリ名**: Presentation Timer (Material 3 Expressive)
- **目的**: 学会やLTで使用する、視認性が高く美しいタイマーアプリ。
- **ターゲット**: Windows Desktop (`flutter run -d windows`)
  - モバイル向けではなく、PCの横長画面を前提としたUI構築を行うこと。

## 2. デザインガイドライン (最重要)
- **デザインシステム**: **Material 3 Expressive** を採用する。
  - 単なるMaterial 3ではなく、"Expressive"（表現豊か）であることを重視する。
  - 大胆なタイポグラフィ、丸みを帯びた形状（Large Rounded Corners）、スムーズなアニメーションを使用する。
- **フォント**:
  - 時間表示（巨大な数字）: `GoogleFonts.robotoMono`
  - テキスト: `GoogleFonts.roboto`
  - フォントは現時点でのもの．今後フォント埋め込みにより変更する可能性がある．
- **テーマ**: ライト/ダークモード両対応。
- **アイコン**: Flutter標準の `Icons` クラスを使用する（`lucide_icons`等は使用しない）。
  - 例: 設定には `Icons.settings_outlined`、リセットには `Icons.restart_alt` など、意味に即したモダンなものを選ぶ。
- **表示言語**: 初期の段階で英語だが，日本語へ変更すること．

## 3. 機能要件 & ロジック
- **状態管理**: `provider` パッケージ (`ChangeNotifier`) を使用する。
- **時間管理 (Single Source of Truth)**:
  - 「経過時間 (`elapsedSeconds`)」のみを正として管理する。
  - **ストップウォッチモード**: `elapsedSeconds` をそのまま表示。
  - **タイマーモード**: `設定時間 - elapsedSeconds` を表示。
  - これにより、モード切替時も時間は常に同期され、止まることなくカウントされる。
- **ベル機能 (重要)**:
  - 配列 (`List<BellConfig>`) で管理し、任意の数だけ追加・削除・編集可能にする。
  - 各ベルは「設定時間（経過時間基準）」と「鳴動回数」を持つ。
  - 設定時刻になったら `audioplayers` パッケージを使って音を鳴らす（`assets/sounds/bell.mp3` を再生）。
- **超過表示**:
  - タイマーモードで0秒未満、またはストップウォッチモードで設定時間を超えた場合、時間表示を赤色 (`ColorScheme.error`) に変更し、テキストを "OVERTIME" 等に変更する。
- **設定UI**:
  - 時間入力はスピンボタンではなく、2桁数字 (`08`) で表示される入力フィールドとする。

## 4. コーディング規約
- **言語**: Dart
- **コメント**: 複雑なロジック部分には**日本語**でコメントを残すこと。
- **ファイル構成**: 
  - プロトタイプ段階のため `lib/main.dart` に主要コードをまとめて記述してよいが、可読性を保つこと。
  - 音声アセットは `pubspec.yaml` に `assets/sounds/` を登録すること。

## 5. 環境情報 (User Environment)
- OS: Windows 11 Home (Dell Inspiron 5430)
- 解像度: FHD+ (1920x1200)
- 開発ツール: Google Antigravity / Flutter (Latest Stable)

## 6. AIへの振る舞い指示
- コードを修正する際は、既存の「Material 3 Expressive」なデザインを絶対に劣化させないこと。
- エラーが発生した場合は、Windowsデスクトップ特有の問題（C++ビルド設定など）も考慮して解決策を提示すること。
- コードブロックは、そのまま `lib/main.dart` に貼り付ければ動く完全な形で提示することを基本とする（部分修正の場合は明記する）。