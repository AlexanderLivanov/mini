# MINI — Flutter-демка мессенджера

Порт дизайна MINI (экраны «Чаты» и «Переписка») на Flutter под Android и iOS.
Ниже — путь от нуля до приложения на iPhone 11 без macOS.

## Что внутри
- `lib/` — исходный код (см. структуру ниже)
- `pubspec.yaml` — зависимости (google_fonts для Caveat)
- `codemagic.yaml` — облачная сборка неподписанного IPA

## Структура lib/
```
lib/
├── main.dart                     точка входа, тема приложения
├── theme.dart                    токены дизайна: цвета, радиус, шрифты
├── models.dart                   классы данных: Chat, Message, Reaction
├── data/mock_data.dart           тестовые чаты
├── screens/
│   ├── chat_list_screen.dart     экран «Чаты»
│   └── conversation_screen.dart  экран «Переписка» (отправка, авто-ответ)
└── widgets/
    ├── chat_tile.dart            строка чата (аватар, имя, превью, бейдж)
    ├── message_bubble.dart       пузырь сообщения + реакции
    ├── typing_indicator.dart     анимированные точки «печатает»
    └── composer.dart             панель ввода (nudge, поле, schedule, отправка)
```

---

# Пошаговая инструкция

## 0. Что понадобится (Windows)
- Flutter SDK
- Android Studio (для эмулятора Android и Android-тулчейна)
- Git + аккаунт GitHub
- Аккаунт Codemagic (вход через GitHub)
- iPhone 11 + AltStore/Sideloadly для установки

## 1. Установка Flutter (Windows)
1. Скачай Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Распакуй, например, в `C:\src\flutter` (без пробелов и кириллицы в пути).
3. Добавь `C:\src\flutter\bin` в переменную среды PATH.
4. Установи Android Studio, при первом запуске — Android SDK + эмулятор.
5. Проверь окружение:
   ```
   flutter doctor
   ```
   Дожди зелёных галочек у Flutter и Android toolchain. Строку про Xcode/iOS
   на Windows можно игнорировать — iOS собираем в облаке.

## 2. Создать проект и вложить наши файлы
Flutter-проект содержит платформенные папки `android/` и `ios/`, которые
генерируются автоматически. Поэтому:

1. Создай пустой проект (он же сгенерирует android/ и ios/):
   ```
   flutter create mini_messenger
   cd mini_messenger
   ```
2. Замени содержимое папки `lib/` на нашу `lib/` из этого архива.
3. Замени `pubspec.yaml` на наш (в нём подключён google_fonts).
4. Скопируй `codemagic.yaml` в корень проекта.
5. Удали дефолтный тест, который ссылается на старый код:
   ```
   del test\widget_test.dart      (Windows)
   ```
6. Подтяни зависимости:
   ```
   flutter pub get
   ```

## 3. Запустить на Android (локально)
1. Запусти эмулятор из Android Studio (Device Manager) или подключи телефон.
2. Запусти приложение:
   ```
   flutter run
   ```
   Должен открыться список чатов; тапни чат — откроется переписка,
   отправь сообщение — собеседник «наберёт» ответ вживую.

## 4. Залить на GitHub
```
git init
git add .
git commit -m "MINI messenger demo"
git branch -M main
git remote add origin https://github.com/USERNAME/mini_messenger.git
git push -u origin main
```
(Сначала создай пустой репозиторий на github.com без README.)

## 5. Собрать iOS в Codemagic
1. Зайди на codemagic.io через GitHub.
2. **Add application** → выбери репозиторий → Codemagic найдёт `codemagic.yaml`.
3. **Start new build** → workflow `ios-unsigned`.
4. Через ~10 минут скачай `MINI-unsigned.ipa` из артефактов сборки.

## 6. Поставить на iPhone 11
1. На Windows установи AltStore (altstore.io) или Sideloadly.
2. Подключи iPhone по USB.
3. Скорми `MINI-unsigned.ipa` — программа подпишет его твоим бесплатным
   Apple ID и поставит на телефон.
4. На iPhone: Настройки → Основные → VPN и управление устройством →
   доверься своему сертификату разработчика.

> ⚠️ Бесплатная подпись живёт 7 дней. AltStore умеет авто-переподписывать,
> если AltServer запущен на ПК в той же Wi-Fi сети.

---

## Примечания
- Шрифт Caveat загружается пакетом google_fonts при первом запуске (нужен
  интернет однократно). Офлайн — логотип покажется системным шрифтом.
- Кнопки nudge / «письмо в будущее» / меню в этой версии — заглушки: они
  показывают, что фича задумана. Логику добавим на следующей итерации.
- В сборке 1.0.0+2 добавлены: онбординг, вкладки (Чаты/Настройки), настройки с
  переключателями, профиль и его редактирование, MINI+, комментарии канала,
  карточки участников, реакции по долгому нажатию, «письмо в будущее», «толк»
  с тряской и мягкое напоминание «вы обещали ответить».
