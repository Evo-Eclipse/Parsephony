# Parsephony

## Overview / Обзор

**Parsephony** is a command-line tool for converting XML configurations into a custom configuration file format. It provides a structured way to parse XML files and generate easy-to-read configuration files.

**Parsephony** — это инструмент командной строки, предназначенный для преобразования XML-конфигураций в кастомный формат конфигурационных файлов. Он обеспечивает структурированный способ парсинга XML и генерации удобночитаемых конфигурационных файлов.

## Features / Особенности

- **XML Parsing / Парсинг XML:**
   - Parses XML files into a tree of configuration elements.
   - Преобразует XML-файлы в дерево конфигурационных элементов.
- **Custom Format Conversion / Преобразование в кастомный формат:**
   - Converts parsed XML to a custom format with attributes and nested elements.
   - Преобразует парсированные XML-данные в кастомный формат с атрибутами и вложенными элементами.
- **Error Reporting / Отчет об ошибках:**
   - Detects syntax errors and provides a detailed report.
   - Обнаруживает ошибки синтаксиса и предоставляет детальный отчет.

## Prerequisites / Требования

- **Swift:** Ensure that Swift compiler is installed to build theapp. / Убедитесь, что у вас установлен компилятор Swift для сборки приложения.

## Installation / Установка

1. Clone the repository / Клонируйте репозиторий:

```shell
git clone https://github.com/yourusername/parsephony.git
cd parsephony
```

2. Build the project / Соберите проект:

```shell
swift build -c release
```

## Usage / Использование

Run the `Parsephony` tool with the following arguments / Запустите инструмент `Parsephony` со следующими аргументами:

```shell
./Parsephony <input.xml> <output.cfg>
```

- `<input.xml>`: Path to the input XML file / Путь к файлу XML для обработки.
- `<output.cfg>`: Path to the generated configuration file / Путь к сгенерированному файлу конфигурации.

**Example / Пример:**

```shell
./Parsephony config.xml output.cfg
```

## Testing / Тестирование

Run the test suite to ensure that everything is functioning correctly / Запустите набор тестов, чтобы убедиться, что всё работает корректно:

```shell
swift test
```

## Disclaimer / Ответственность

- This project was developed for educational purposes as part of an assignment. The code is not optimized for production.
   - Данный проект создан исключительно в образовательных целях в рамках выполнения задания. Код не оптимизирован для продакшн-использования.

