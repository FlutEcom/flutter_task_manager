# Menadżer Zadań Osobistych

Aplikacja mobilna stworzona we Flutterze. Celem aplikacji jest umożliwienie użytkownikom tworzenia, organizowania i śledzenia codziennych zadań osobistych.

## Funkcjonalności

- **Tworzenie i Zarządzanie Zadaniami**: Użytkownicy mogą dodawać nowe zadania z tytułem, opcjonalnym opisem i terminem wykonania.  
- **Lista Zadań**: Przejrzysta lista zadań posortowana według najbliższego terminu.  
- **Oznaczanie jako Ukończone**: Możliwość odhaczania zadań, które są następnie przenoszone do osobnej sekcji.  
- **Edycja i Usuwanie**: Pełna obsługa CRUD dla zadań.  
- **Powiadomienia Lokalne**: Aplikacja wysyła przypomnienia o zbliżających się terminach zadań.  
- **Statystyki**: Prosty ekran pokazujący liczbę ukończonych zadań oraz najbardziej produktywny dzień tygodnia.  
- **(Opcjonalnie) Widget Pogody**: Wyświetlanie aktualnej pogody na podstawie lokalizacji użytkownika, z wykorzystaniem publicznego API.  

## Zastosowane Technologie

- **Flutter & Dart**  
- **BLoC** – do zarządzania stanem aplikacji  
- **sqflite** – jako lokalna baza danych  
- **flutter_local_notifications** – do obsługi powiadomień  
- **geolocator & http** – do pobierania lokalizacji i danych pogodowych  
- **Mocktail & bloc_test** – do testów jednostkowych

Jak Uruchomić Projekt
Sklonuj repozytorium:

git clone [https://github.com/TWOJA_NAZWA/flutter_task_manager.git](https://github.com/TWOJA_NAZWA/flutter_task_manager.git)

Przejdź do folderu projektu:

cd flutter_task_manager

Pobierz zależności:

flutter pub get

Uzyskaj klucz API do pogody:

Zarejestruj się na WeatherAPI.com, aby otrzymać darmowy klucz.

Wklej swój klucz w pliku lib/presentation/widgets/weather_widget.dart w miejscu const apiKey = 'YOUR_API_KEY';.

Uruchom aplikację:

flutter run
