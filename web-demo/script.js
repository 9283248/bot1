// Данные для демонстрации
const presentations = {
    'ai-trends': {
        title: 'Тренды в ИИ 2024',
        slides: [
            { title: 'Тренды в ИИ 2024', content: 'Обзор ключевых направлений развития искусственного интеллекта' },
            { title: 'Машинное обучение', content: 'Новые алгоритмы и подходы к обучению моделей' },
            { title: 'Генеративный ИИ', content: 'ChatGPT, DALL-E и другие генеративные модели' },
            { title: 'Компьютерное зрение', content: 'Распознавание изображений и видео' },
            { title: 'Обработка языка', content: 'NLP и понимание естественного языка' },
            { title: 'Автономные системы', content: 'Роботы и беспилотные автомобили' },
            { title: 'Этические вопросы', content: 'Ответственное использование ИИ' },
            { title: 'Заключение', content: 'Будущее искусственного интеллекта' }
        ]
    },
    'mobile-dev': {
        title: 'Мобильная разработка',
        slides: [
            { title: 'Мобильная разработка', content: 'Современные подходы к созданию мобильных приложений' },
            { title: 'iOS разработка', content: 'Swift, SwiftUI и экосистема Apple' },
            { title: 'Android разработка', content: 'Kotlin, Jetpack Compose и Google' },
            { title: 'Кроссплатформенные решения', content: 'React Native, Flutter, Xamarin' },
            { title: 'UI/UX дизайн', content: 'Принципы создания удобных интерфейсов' },
            { title: 'Заключение', content: 'Выбор технологии для вашего проекта' }
        ]
    }
};

let currentPresentation = null;
let currentSlideIndex = 0;
let isPresentationMode = false;

// Переключение табов
function switchTab(tabIndex) {
    // Убираем активный класс со всех табов
    document.querySelectorAll('.tab-item').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach(panel => panel.classList.remove('active'));
    
    // Добавляем активный класс к выбранному табу
    document.querySelectorAll('.tab-item')[tabIndex].classList.add('active');
    document.querySelectorAll('.tab-panel')[tabIndex].classList.add('active');
}

// Отправка сообщения в чат
function sendMessage() {
    const input = document.getElementById('messageInput');
    const message = input.value.trim();
    
    if (!message) return;
    
    // Добавляем сообщение пользователя
    addMessage(message, true);
    
    // Очищаем поле ввода
    input.value = '';
    
    // Симулируем ответ AI
    setTimeout(() => {
        const responses = [
            "Отлично! Я создам для вас презентацию на эту тему. Дайте мне несколько секунд...",
            "Интересная тема! Сейчас сгенерирую структуру презентации.",
            "Понял! Создаю презентацию с учетом ваших требований.",
            "Отличная идея! Готовлю презентацию для вас."
        ];
        
        const randomResponse = responses[Math.floor(Math.random() * responses.length)];
        addMessage(randomResponse, false);
        
        // Через 2 секунды показываем превью презентации
        setTimeout(() => {
            showPresentationPreview();
        }, 2000);
    }, 1000);
}

// Добавление сообщения в чат
function addMessage(text, isUser) {
    const messagesContainer = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${isUser ? 'user-message' : 'ai-message'}`;
    
    const now = new Date();
    const timeString = now.toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' });
    
    messageDiv.innerHTML = `
        <div class="message-bubble">
            <p>${text}</p>
        </div>
        <div class="message-time">${timeString}</div>
    `;
    
    messagesContainer.appendChild(messageDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Показ превью презентации
function showPresentationPreview() {
    const messagesContainer = document.getElementById('chatMessages');
    const previewDiv = document.createElement('div');
    previewDiv.className = 'message ai-message';
    
    previewDiv.innerHTML = `
        <div class="message-bubble">
            <div style="background: #e3f2fd; padding: 16px; border-radius: 12px; margin: 8px 0;">
                <div style="display: flex; align-items: center; margin-bottom: 8px;">
                    <span style="font-size: 20px; margin-right: 8px;">📄</span>
                    <strong style="color: #1976d2;">Новая презентация создана!</strong>
                </div>
                <div style="font-weight: 600; margin-bottom: 4px;">Искусственный интеллект в 2024</div>
                <div style="font-size: 14px; color: #666; margin-bottom: 8px;">8 слайдов • 12 минут • Синяя тема</div>
                <button onclick="openPresentation('ai-trends')" style="background: #1976d2; color: white; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer; font-size: 14px;">
                    Открыть презентацию
                </button>
            </div>
        </div>
        <div class="message-time">${new Date().toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' })}</div>
    `;
    
    messagesContainer.appendChild(previewDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Обработка нажатия Enter в поле ввода
function handleKeyPress(event) {
    if (event.key === 'Enter') {
        sendMessage();
    }
}

// Открытие презентации
function openPresentation(presentationId) {
    currentPresentation = presentations[presentationId];
    currentSlideIndex = 0;
    
    // Скрываем главный экран и показываем экран презентации
    document.getElementById('mainScreen').style.display = 'none';
    document.getElementById('presentationScreen').style.display = 'flex';
    
    // Обновляем заголовок и содержимое
    document.getElementById('presentationTitle').textContent = currentPresentation.title;
    updateSlide();
}

// Закрытие презентации
function closePresentation() {
    document.getElementById('mainScreen').style.display = 'flex';
    document.getElementById('presentationScreen').style.display = 'none';
    currentPresentation = null;
    currentSlideIndex = 0;
}

// Обновление слайда
function updateSlide() {
    if (!currentPresentation) return;
    
    const slide = currentPresentation.slides[currentSlideIndex];
    const slideContainer = document.getElementById('currentSlide');
    
    slideContainer.innerHTML = `
        <div class="slide-number">Слайд ${currentSlideIndex + 1} из ${currentPresentation.slides.length}</div>
        <div class="slide-content">
            <h1 class="slide-title">${slide.title}</h1>
            <p class="slide-text">${slide.content}</p>
        </div>
    `;
    
    // Обновляем индикаторы
    document.getElementById('currentSlideNum').textContent = currentSlideIndex + 1;
    document.getElementById('totalSlides').textContent = currentPresentation.slides.length;
    
    // Обновляем кнопки навигации
    document.getElementById('prevButton').disabled = currentSlideIndex === 0;
    document.getElementById('nextButton').disabled = currentSlideIndex === currentPresentation.slides.length - 1;
}

// Предыдущий слайд
function previousSlide() {
    if (currentSlideIndex > 0) {
        currentSlideIndex--;
        updateSlide();
    }
}

// Следующий слайд
function nextSlide() {
    if (currentSlideIndex < currentPresentation.slides.length - 1) {
        currentSlideIndex++;
        updateSlide();
    }
}

// Переключение режима презентации
function togglePresentationMode() {
    isPresentationMode = !isPresentationMode;
    const button = document.querySelector('.present-button');
    
    if (isPresentationMode) {
        button.textContent = 'Редактировать';
        // Здесь можно добавить полноэкранный режим
        document.body.style.background = '#000';
        document.querySelector('.iphone-mockup').style.boxShadow = '0 0 0 4px #007AFF';
    } else {
        button.textContent = 'Презентация';
        document.body.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
        document.querySelector('.iphone-mockup').style.boxShadow = '0 20px 60px rgba(0, 0, 0, 0.3)';
    }
}

// Демо функции
function demoChat() {
    const input = document.getElementById('messageInput');
    input.value = 'Создай презентацию о мобильной разработке';
    sendMessage();
}

function demoPresentation() {
    openPresentation('ai-trends');
}

function resetDemo() {
    // Очищаем чат
    document.getElementById('chatMessages').innerHTML = `
        <div class="message ai-message">
            <div class="message-bubble">
                <p>Привет! Я помогу вам создать презентацию. Опишите, какую презентацию вы хотите создать?</p>
            </div>
            <div class="message-time">9:42</div>
        </div>
    `;
    
    // Возвращаемся на главный экран
    closePresentation();
    switchTab(0);
    
    // Очищаем поле ввода
    document.getElementById('messageInput').value = '';
}

// Инициализация
document.addEventListener('DOMContentLoaded', function() {
    // Добавляем обработчики для кнопок навигации слайдов
    document.addEventListener('keydown', function(event) {
        if (currentPresentation) {
            if (event.key === 'ArrowLeft') {
                previousSlide();
            } else if (event.key === 'ArrowRight') {
                nextSlide();
            } else if (event.key === 'Escape') {
                closePresentation();
            }
        }
    });
    
    // Добавляем анимацию при загрузке
    document.querySelector('.iphone-mockup').style.animation = 'slideIn 0.6s ease';
});

// Анимация появления
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateY(30px) scale(0.9);
        }
        to {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
    }
    
    .message {
        animation: slideIn 0.3s ease;
    }
    
    .presentation-item:hover {
        transform: translateY(-2px);
        transition: transform 0.2s ease;
    }
    
    .nav-button:hover {
        transform: scale(1.1);
        transition: transform 0.2s ease;
    }
`;
document.head.appendChild(style);