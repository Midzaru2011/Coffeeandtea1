#!/usr/bin/env python3

from ruamel.yaml import YAML
import sys
import json

# Получаем путь к файлу и новое значение из аргументов командной строки
file_path = sys.argv[1]
new_value = sys.argv[2]

# Инициализируем YAML-парсер
yaml = YAML()
yaml.preserve_quotes = True  # Сохраняем кавычки
yaml.indent(mapping=2, sequence=4, offset=2)  # Настройка отступов

try:
# Читаем существующий YAML-файл
    with open(file_path, 'r') as file:
        data = yaml.load(file)

# Обновляем значение
    data['supplementary_addresses_in_ssl_keys'] = [new_value]

# Записываем обновленный YAML обратно в файл
    with open(file_path, 'w') as file:
        # Принудительно используем потоковый стиль (flow style) для списка
        def flow_style_list(dumper, data):
            return dumper.represent_sequence('tag:yaml.org,2002:seq', data, flow_style=True)

        yaml.representer.add_representer(list, flow_style_list)
        yaml.dump(data, file)
    
    print(json.dumps({"status": "success"}))
except Exception as e:
    print(json.dumps({"error": str(e)}))
    sys.exit(1)