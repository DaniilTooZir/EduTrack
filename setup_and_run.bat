@echo off
set ENV_FILE=.env

echo Проверка конфигурации...
if not exist "%ENV_FILE%" (
    echo Ошибка: Файл .env не найден.
    echo Создайте файл .env и укажите SUPABASE_URL и SUPABASE_ANON_KEY.
    exit /b 1
)

echo Установка зависимостей...
call flutter pub get

echo Генерация кода для локальной БД Drift...
call dart run build_runner build --delete-conflicting-outputs

echo Запуск приложения...
call flutter run