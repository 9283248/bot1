# 🚀 Развертывание на GitHub Pages

## Быстрое развертывание

### 1. Создайте репозиторий на GitHub
1. Перейдите на [github.com](https://github.com)
2. Нажмите "New repository"
3. Назовите репозиторий (например, `ai-presentation-demo`)
4. Выберите "Public"
5. Создайте репозиторий

### 2. Загрузите файлы
```bash
# Клонируйте репозиторий
git clone https://github.com/YOUR_USERNAME/ai-presentation-demo.git
cd ai-presentation-demo

# Скопируйте файлы веб-демо
cp -r /workspace/web-demo/* .

# Добавьте и закоммитьте
git add .
git commit -m "Add AI Presentation App demo"
git push origin main
```

### 3. Включите GitHub Pages
1. Перейдите в Settings репозитория
2. Найдите раздел "Pages"
3. В "Source" выберите "Deploy from a branch"
4. Выберите "main" branch и "/ (root)"
5. Нажмите "Save"

### 4. Получите ссылку
Ваше демо будет доступно по адресу:
`https://YOUR_USERNAME.github.io/ai-presentation-demo`

## Альтернативные платформы

### Netlify
1. Перейдите на [netlify.com](https://netlify.com)
2. Нажмите "New site from Git"
3. Подключите GitHub репозиторий
4. Настройки по умолчанию
5. Нажмите "Deploy site"

### Vercel
1. Перейдите на [vercel.com](https://vercel.com)
2. Нажмите "New Project"
3. Импортируйте GitHub репозиторий
4. Нажмите "Deploy"

### Firebase Hosting
```bash
# Установите Firebase CLI
npm install -g firebase-tools

# Инициализируйте проект
firebase init hosting

# Выберите папку с файлами
# Настройте как статический сайт

# Разверните
firebase deploy
```

## Автоматическое обновление

### GitHub Actions
Создайте файл `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./
```

## Настройка домена

### Пользовательский домен
1. В настройках GitHub Pages добавьте свой домен
2. Создайте CNAME файл с вашим доменом
3. Настройте DNS записи у провайдера

### HTTPS
GitHub Pages автоматически предоставляет SSL сертификаты для всех сайтов.

## Мониторинг и аналитика

### Google Analytics
Добавьте в `index.html`:
```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

### Мониторинг производительности
- Используйте Google PageSpeed Insights
- Настройте Lighthouse CI
- Мониторьте Core Web Vitals

## Оптимизация

### Сжатие файлов
```bash
# Сожмите CSS и JS
npx clean-css-cli styles.css -o styles.min.css
npx terser script.js -o script.min.js
```

### Кэширование
Добавьте в `.htaccess`:
```apache
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
</IfModule>
```

## Безопасность

### Content Security Policy
Добавьте в `<head>`:
```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline'; 
               style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;">
```

### HTTPS только
Настройте редирект с HTTP на HTTPS в настройках GitHub Pages.

---

**Ваше демо готово к публикации! 🌐**