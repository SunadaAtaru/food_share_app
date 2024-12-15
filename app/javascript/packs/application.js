// Rails関連の基本的なライブラリのインポート
import Rails from "@rails/ujs"         // Rails の非同期通信やリモートフォームなどの機能を提供
import Turbolinks from "turbolinks"    // ページ遷移を高速化するライブラリ
import * as ActiveStorage from "@rails/activestorage"  // ファイルアップロード機能（現在は未使用）
import "channels"                      // Action Cable用（リアルタイム通信機能）

// フロントエンドフレームワークとその依存関係のインポート
import 'jquery'              // JavaScriptライブラリ（DOM操作やAjax通信を簡単に）
import '@popperjs/core'      // ツールチップやポップオーバーの位置決めライブラリ（Bootstrapの依存）
import 'bootstrap'           // CSSフレームワーク（UIコンポーネントやグリッドシステムを提供）

// スタイルシートのインポート
import "../stylesheets/application.scss"  // アプリケーション全体のスタイル定義

// 各機能の初期化
Rails.start()       // Rails UJSの機能を有効化
Turbolinks.start()  // Turbolinksの機能を有効化
ActiveStorage.start()  // ActiveStorageの初期化（実際にはCarrierWaveを使用中）

// Turbolinksによるページ読み込み完了時に実行されるイベントリスナー
document.addEventListener("turbolinks:load", () => {
  // datepickerクラスを持つすべての日付入力フィールドを取得
  const dateFields = document.querySelectorAll('.datepicker')
  
  // 各日付フィールドに対して処理を実行
  dateFields.forEach(field => {
    // 初期状態をテキストフィールドに設定（プレースホルダーを表示するため）
    field.type = 'text'
    
    // フィールドクリック時の処理
    field.addEventListener('click', function() {
      // クリックされたらdate型に変更（ブラウザのカレンダーを表示）
      this.type = 'date'
    })
    
    // フィールドからフォーカスが外れた時の処理
    field.addEventListener('blur', function() {
      if (!this.value) {
        // 値が空の場合はテキストフィールドに戻す（プレースホルダーを表示）
        this.type = 'text'
      } else {
        // 日付が入力されている場合のフォーマット処理
        try {
          // 入力された日付をJavaScriptのDateオブジェクトに変換
          const date = new Date(this.value)
          
          // フィールドの名前に'gteq'が含まれているかで処理を分岐（検索フォームかどうかの判定）
          if (this.name.includes('gteq')) {
            // 検索フォームの場合は日付フォーマットを変更しない
            this.value = this.value
          } else {
            // 入力フォームの場合は日本語フォーマットに変換
            const year = date.getFullYear()
            // 月は0から始まるため+1する。padStartで2桁になるよう0埋め
            const month = (date.getMonth() + 1).toString().padStart(2, '0')
            // 日も2桁になるよう0埋め
            const day = date.getDate().toString().padStart(2, '0')
            // データ属性に日本語フォーマットの日付を設定
            this.dataset.formattedDate = `${year}年${month}月${day}日`
          }
        } catch (e) {
          // 日付の変換に失敗した場合はエラーをコンソールに出力
          console.error('Invalid date format:', e)
        }
      }
    })
  })
 
  // 詳細ページの日付フォーマット処理
  // formatted-dateクラスを持つ要素（詳細表示用の日付）をすべて取得
  const formattedDates = document.querySelectorAll('.formatted-date')
  
  // 各日付表示要素に対して処理を実行
  formattedDates.forEach(element => {
    try {
      // 表示されている日付をDateオブジェクトに変換
      const date = new Date(element.textContent)
      // 年を取得
      const year = date.getFullYear()
      // 月を取得（2桁になるよう0埋め）
      const month = (date.getMonth() + 1).toString().padStart(2, '0')
      // 日を取得（2桁になるよう0埋め）
      const day = date.getDate().toString().padStart(2, '0')
      // 日本語フォーマットで表示を更新
      element.textContent = `${year}年${month}月${day}日`
    } catch (e) {
      // 日付の変換に失敗した場合はエラーをコンソールに出力
      console.error('Invalid date format:', e)
    }
  })
 })