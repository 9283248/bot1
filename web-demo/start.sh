#!/bin/bash

# AI Presentation App - Веб демо запуск
echo "🚀 Запуск AI Presentation App Demo..."

# Проверяем Python
if command -v python3 &> /dev/null; then
    echo "✅ Python3 найден"
    python3 server.py
elif command -v python &> /dev/null; then
    echo "✅ Python найден"
    python server.py
else
    echo "❌ Python не найден. Установите Python 3.x"
    echo "   macOS: brew install python3"
    echo "   Ubuntu: sudo apt install python3"
    echo "   Windows: https://python.org/downloads"
    exit 1
fi