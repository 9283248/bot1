# 🚀 Быстрый старт - AI Presentation App

## ⚡ За 5 минут

### 1. Установите Xcode
```bash
# Скачайте с App Store или developer.apple.com
# Установите дополнительные компоненты при первом запуске
```

### 2. Получите OpenAI API ключ
1. Зарегистрируйтесь на [platform.openai.com](https://platform.openai.com)
2. Создайте API ключ в разделе "API Keys"
3. Пополните баланс минимум на $5

### 3. Настройте проект
```bash
# Откройте проект
open AIPresentationApp.xcodeproj
```

### 4. Добавьте API ключ
В файле `AIService.swift` замените:
```swift
private let apiKey = "YOUR_OPENAI_API_KEY"
```
на:
```swift
private let apiKey = "sk-your-actual-api-key-here"
```

### 5. Запустите приложение
- Выберите iPhone симулятор
- Нажмите ▶️ (Play)
- Готово! 🎉

## 🧪 Тестовый запрос
В чате отправьте: *"Создай презентацию о мобильной разработке"*

## ❗ Частые проблемы

| Проблема | Решение |
|----------|---------|
| "No such module" | `Product` → `Clean Build Folder` |
| API ошибка | Проверьте ключ и баланс OpenAI |
| Не запускается | Проверьте iOS 17.0+ в симуляторе |

## 📞 Нужна помощь?
Смотрите [подробную инструкцию](INSTALLATION_GUIDE.md)