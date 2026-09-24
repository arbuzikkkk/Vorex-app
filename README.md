# VOREX — маркетплейс игровых товаров и подписок

Полноценное Android-приложение на Flutter (не сайт, не Telegram Mini App).
Тёмный Y2K-дизайн, glassmorphism, полностью офлайн (SQLite), готово к
подключению backend API позже.

## ⚠️ Важно: где это собирать

Flutter-сборка APK требует **Android SDK + Gradle + Android Studio**.
Это НЕ поднимется в Termux (как твои Python/aiogram проекты) без
полноценной установки Android toolchain, которая на телефоне
практически невозможна. Используй это на ПК/ноутбуке с Android Studio,
либо в облачной IDE (например, FlutHub, Codemagic CI, или GitHub
Codespaces с Flutter-образом).

## Первый запуск

```bash
flutter create --org com.vorex --project-name vorex_app vorex_scaffold
# скопируй файлы этого проекта (lib/, pubspec.yaml, assets/) поверх
# сгенерированной структуры vorex_scaffold/, заменяя дефолтные lib/main.dart
cd vorex_scaffold
flutter pub get
flutter run
```

## Структура

```
lib/
  main.dart              — точка входа, MaterialApp, роуты
  theme/                 — цвета, Material 3 тема (Luxury Y2K)
  models/                — User, Product, Order, WalletTransaction, ChatMessage
  database/               — SQLite схема (sqflite), db_helper.dart
  services/               — вся бизнес-логика: auth, product, order, wallet, chat, settings
  screens/
    splash_screen.dart    — анимированный логотип (fade + elastic scale)
    auth/                 — вход / регистрация
    main_nav_screen.dart  — нижняя навигация (5 вкладок)
    home/                 — главная, баланс, витрина
    catalog/               — каталог с поиском/фильтрами, карточка товара
    sell/                  — форма продажи, до 10 фото (image_picker)
    orders/                — список заказов, чат, жалобы
    chat/                  — чат покупатель↔продавец (SQLite-хранимый)
    profile/               — профиль, пополнение баланса, история операций
    admin/                 — секретная админ-панель
  widgets/                — GlassCard, ProductCard, SkeletonBox (переиспользуемые)
```

## Админ-режим (секретный вход)

1. На экране входа **5 раз нажми на логотип VOREX** — появится ссылка
   "Вход для администратора".
2. Стартовый аккаунт админа создаётся автоматически при первом запуске:
   - Логин: `admin`
   - Пароль: `admin123`
   **Обязательно смени пароль** — либо через новый пароль-хэш в
   `lib/database/db_helper.dart` (sha256), либо добавь экран смены пароля.

Возможности админки: статистика прибыли и оборота, изменение комиссии
площадки, разбор жалоб (возврат/отклонение), управление товарами
(удаление), бан/разбан пользователей.

## Что уже работает по-настоящему (не заглушки)

- Регистрация/вход с sha256-хэшированием пароля, сессия через SharedPreferences
- SQLite-хранение: пользователи, товары, заказы, транзакции, чат, настройки
- Покупка товара: списание у покупателя, зачисление продавцу за вычетом комиссии, атомарные транзакции БД
- Пополнение баланса (платёжный шлюз симулирован — см. `services/wallet_service.dart`, легко подключить ЮKassa/Stripe)
- Загрузка фото до 10 штук через `image_picker`
- Чат по заказу, жалобы на сделку, возврат средств админом
- Hero-анимация карточка→детали, spring-анимация сплэша, shimmer skeleton при загрузке

## Что нужно доделать под реальный запуск

- Push-уведомления: структура готова (кнопка в профиле), нужен Firebase Cloud Messaging
- Реальный платёжный шлюз вместо симуляции в TopUpScreen
- Иконки/ассеты в `assets/icons/`, `assets/images/` — сейчас папки пустые, добавь свои
- `android/app/build.gradle` — после `flutter create` обнови `applicationId`, минимальный SDK, подпись релиза
