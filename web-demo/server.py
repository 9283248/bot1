#!/usr/bin/env python3
"""
Простой HTTP сервер для демонстрации AI Presentation App
Запуск: python3 server.py
"""

import http.server
import socketserver
import webbrowser
import os
import sys
from pathlib import Path

# Настройки сервера
PORT = 8000
HOST = 'localhost'

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Добавляем CORS заголовки для корректной работы
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

def start_server():
    """Запуск веб-сервера"""
    try:
        # Переходим в директорию с файлами
        os.chdir(Path(__file__).parent)
        
        # Создаем сервер
        with socketserver.TCPServer((HOST, PORT), CustomHTTPRequestHandler) as httpd:
            print(f"🚀 AI Presentation App Demo запущен!")
            print(f"📱 Откройте в браузере: http://{HOST}:{PORT}")
            print(f"🛑 Для остановки нажмите Ctrl+C")
            print("-" * 50)
            
            # Автоматически открываем браузер
            try:
                webbrowser.open(f'http://{HOST}:{PORT}')
                print("🌐 Браузер открыт автоматически")
            except Exception as e:
                print(f"⚠️  Не удалось открыть браузер автоматически: {e}")
                print(f"   Откройте вручную: http://{HOST}:{PORT}")
            
            # Запускаем сервер
            httpd.serve_forever()
            
    except KeyboardInterrupt:
        print("\n🛑 Сервер остановлен")
        sys.exit(0)
    except OSError as e:
        if e.errno == 48:  # Address already in use
            print(f"❌ Порт {PORT} уже используется")
            print(f"   Попробуйте другой порт или остановите другой сервер")
        else:
            print(f"❌ Ошибка запуска сервера: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Неожиданная ошибка: {e}")
        sys.exit(1)

if __name__ == "__main__":
    start_server()