# プロジェクト名
$projectName = "my-portfolio"
$githubUser = "Seiryuu-BD"  # ← GitHubのユーザー名に変更してください

# Vite プロジェクト作成
npm create vite@latest $projectName -- --template react-ts
Set-Location $projectName

# Tailwind CSS 導入
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# gh-pages 導入
npm install gh-pages --save-dev

# Tailwind config 書き換え
(Get-Content tailwind.config.js) -replace 'content: \[\]', 'content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"]' | Set-Content tailwind.config.js

# index.css 作成
New-Item -ItemType Directory -Path "src\styles" -Force
@"
@tailwind base;
@tailwind components;
@tailwind utilities;
"@ | Out-File "src\styles\index.css" -Encoding utf8

# main.tsx にCSSインポート追加
(Get-Content src\main.tsx) -replace 'import React from', "import './styles/index.css'`nimport React from" | Set-Content src\main.tsx

# vite.config.ts 修正
@"
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  base: '/$projectName/',
  plugins: [react()],
})
"@ | Set-Content vite.config.ts -Encoding utf8

# package.json 更新
$json = Get-Content package.json | ConvertFrom-Json
$json.homepage = "https://$githubUser.github.io/$projectName"
$json.scripts.predeploy = "npm run build"
$json.scripts.deploy = "gh-pages -d dist"
$json | ConvertTo-Json -Depth 10 | Set-Content package.json -Encoding utf8

# フォルダ構成作成
New-Item -ItemType Directory -Path "src\components", "src\pages", "src\data", "src\assets" -Force | Out-Null
New-Item -ItemType File -Path `
  "src\components\Header.tsx", `
  "src\components\ProjectCard.tsx", `
  "src\pages\Home.tsx", `
  "src\pages\About.tsx", `
  "src\data\projects.ts" -Force | Out-Null

Write-Host "=== プロジェクトの初期化が完了しました ==="
Write-Host "次のステップ:"
Write-Host "1. cd $projectName"
Write-Host "2. GitHub ユーザー名を package.json に設定"
Write-Host "3. 必要なページやコンポーネントを編集"
Write-Host "4. npm run deploy で GitHub Pages に公開"
