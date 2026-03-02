.PHONY: help run test notify-test clean format analyze build-runner watch-build build-apk build-ios prepare-build

help:
	@echo "📱 Daily Todo App - コマンド一覧"
	@echo ""
	@echo "  make run           - アプリを起動"
	@echo "  make test          - 全テスト実行"
	@echo "  make notify-test   - 通知サービスのテスト"
	@echo "  make build-runner  - コード生成"
	@echo "  make watch-build   - コード生成 (watch mode)"
	@echo "  make prepare-build - ビルド前準備"
	@echo "  make build-apk     - APKビルド (準備処理込み)"
	@echo "  make clean         - キャッシュクリア"

run:
	flutter run

test:
	flutter test

notify-test:
	flutter test test/services/notification_service_test.dart

runner:
	dart run build_runner build --delete-conflicting-outputs

watch-build:
	dart run build_runner watch --delete-conflicting-outputs

prepare-build:
	@echo "🔄 依存関係の取得..."
	flutter pub get
	@echo "✨ コード整形..."
	dart format lib/ test/
	@echo "🔍 静的解析..."
	flutter analyze

# APKビルド（準備処理込み）
build-apk: prepare-build
	@echo "📦 APKをビルド中..."
	flutter build apk --release

# iOSビルド（準備処理込み）
build-ios: prepare-build
	@echo "📦 iOSをビルド中..."
	flutter build ios --release

clean:
	flutter clean
	flutter pub get

format:
	dart format lib/ test/

analyze:
	flutter analyze
