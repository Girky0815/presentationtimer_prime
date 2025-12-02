# Presentation Timer アプリケーション詳細説明

このドキュメントは、AIエージェントが本アプリケーションの構造、機能、技術スタックを理解するための詳細なリファレンスです。

## 1. アプリケーション概要
**Presentation Timer** は、プレゼンテーション用のタイマーアプリケーションです。Material 3 Expressive デザインを採用し、視認性と操作性を重視しています。

### 主な機能
- **タイマー/ストップウォッチ**: カウントダウン（タイマー）とカウントアップ（ストップウォッチ）の切り替えが可能。
- **ベル機能**: 設定した時間（経過時間または残り時間）にベル音を鳴らす機能。複数設定可能。
- **テーマ設定**: ライト/ダークモードの切り替え、ダイナミックカラー（壁紙の色に合わせる）の対応。
- **設定の永続化**: 次回起動時に設定（時間、ベル、テーマなど）を復元。

## 2. 技術スタック
- **フレームワーク**: Flutter (SDK >=3.2.0 <4.0.0)
- **言語**: Dart
- **主要パッケージ**:
    - `provider`: 状態管理 (State Management)
    - `shared_preferences`: 設定データの永続化
    - `flutter_soloud`: 音声再生 (Audio Playback)
    - `dynamic_color`: Material 3 ダイナミックカラー対応
    - `google_fonts`: フォント (Google Sans Flex)
    - `package_info_plus`: アプリバージョン情報の取得

## 3. アーキテクチャとファイル構成
本プロジェクトは、比較的小規模な構成であり、主要なロジックとUIが `lib/main.dart` に集約されているのが特徴です。

### ディレクトリ構成
```
lib/
├── main.dart                  # エントリポイント、状態管理、UI実装（モノリシック）
└── services/
    └── preferences_service.dart # 設定データの保存・読み込みロジック
```

### 主要ファイル詳細

#### `lib/main.dart`
アプリケーションの中核となるファイルです。以下の要素が含まれています。

1.  **`TimerState` クラス (ChangeNotifier)**
    -   **役割**: アプリ全体の状態管理を行う中心的なクラス。
    -   **管理データ**:
        -   タイマーの状態（実行中、一時停止、リセット）
        -   現在の時間（分、秒）
        -   モード（タイマー/ストップウォッチ）
        -   ベル設定リスト (`List<BellConfig>`)
        -   テーマ設定（モード、ダイナミックカラー有効化）
    -   **主要メソッド**:
        -   `startStop()`: タイマーの開始・停止
        -   `reset()`: タイマーのリセット
        -   `addBell()`, `removeBell()`, `updateBell()`: ベルの管理
        -   `_checkBells()`: タイマー更新ごとのベル鳴動チェック
        -   `_loadSettings()`, `_saveSettings()`: 設定の読み書き

2.  **`PresentationTimerApp` クラス (StatelessWidget)**
    -   **役割**: アプリのルートウィジェット。
    -   **機能**:
        -   `DynamicColorBuilder` を使用したテーマ生成。
        -   `MaterialApp` の構成。
        -   カスタムフォント (`Google Sans Flex`) の適用。

3.  **`TimerScreen` クラス (StatefulWidget)**
    -   **役割**: メイン画面のUI。
    -   **構成**:
        -   時間表示（巨大なフォント）
        -   操作ボタン（スタート/ストップ、リセット）
        -   設定画面への遷移ボタン
        -   ベル情報の表示チップ

4.  **`BellConfig` クラス**
    -   **役割**: ベル設定のデータモデル。
    -   **プロパティ**: 時間（分、秒）、鳴らす回数 (`count`)。
    -   **機能**: JSON シリアライズ/デシリアライズ (`toJson`, `fromJson`)。

#### `lib/services/preferences_service.dart`
-   **役割**: `SharedPreferences` をラップしたデータ永続化サービス。
-   **保存キー**:
    -   `theme_mode`: テーマ設定 (int)
    -   `duration_min`, `duration_sec`: タイマー設定時間
    -   `bells`: ベル設定リスト (JSON文字列リスト)
    -   `use_dynamic_color`: ダイナミックカラー有効フラグ

## 4. デザインシステム
-   **Material 3 Expressive**: 最新のMaterial Designガイドラインに準拠。
-   **フォント**: `Google Sans Flex` を全面的に使用。
    -   数字の可読性を高めるため、`tnum` (Tabular Figures) などのOpenType機能を活用している箇所がある。
-   **カラー**:
    -   カスタム定義の `lightColorScheme`, `darkColorScheme` をベースに、ダイナミックカラーが有効な場合はシステムカラーをブレンドして使用。

## 5. 開発上の注意点
-   **モノリシックな構造**: `main.dart` が肥大化しているため、修正時は影響範囲に注意が必要。特に `TimerState` はロジックとUI状態が混在している。
-   **音声再生**: `flutter_soloud` を使用しており、アセット (`assets/sounds/`) のロードと再生管理が `TimerState` 内で行われている。
-   **非同期処理**: 設定の読み込みや音声の初期化は非同期で行われるため、アプリ起動時の挙動に注意。
