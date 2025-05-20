#!/bin/bash

# Чтение входных данных из Terraform
INPUT=$(cat)
IP_ADDRESS=$(echo "$INPUT" | grep -oP '(?<="ip_address": ")[^"]+')
SSH_KEY=$(echo "$INPUT" | grep -oP '(?<="ssh_key": ")[^"]+')

# Проверка наличия необходимых параметров
if [[ -z "$IP_ADDRESS" || -z "$SSH_KEY" ]]; then
  echo "{\"error\": \"Missing required parameters\"}"
  exit 1
fi

# Получение пароля с удаленного сервера через SSH
PASSWORD=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@$IP_ADDRESS "cat /tmp/jenkins_password.txt")

# Проверка успешности выполнения команды
if [[ $? -ne 0 ]]; then
  echo "{\"error\": \"Failed to fetch Jenkins password\"}"
  exit 1
fi

# Вывод результата в формате JSON
echo "{\"password\": \"$PASSWORD\"}"