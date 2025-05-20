# Шаг 1: Используем официальный JDK образ как этап сборки#
FROM maven:3.9.8-eclipse-temurin-17 AS build

# Копируем исходный код в контейнер
COPY . /app
WORKDIR /app

# Собираем приложение (получаем JAR-файл)
RUN mvn clean package -DskipTests && rm -rf ~/.m2

# Шаг 2: Создаем финальный образ с минимальным размером
FROM eclipse-temurin:17-jre-alpine

# Устанавливаем Liquibase (если используется)
# RUN apt-get update && apt-get install -y liquibase  # Опционально

# Копируем собранный JAR из первого этапа
COPY --from=build /app/target/*.jar /CoffeAndTea.jar

# Указываем порт, который будет открыт в контейнере
EXPOSE 8081

# Запускаем приложение
ENTRYPOINT ["java", "-jar", "/CoffeAndTea.jar"]
