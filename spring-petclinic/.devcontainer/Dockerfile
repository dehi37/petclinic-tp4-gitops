# --- Étape 1 : Build ---
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# Copier uniquement le pom.xml et télécharger les dépendances (optimise le cache Docker)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copier le code source et builder le package JAR sans exécuter les tests
COPY src ./src
RUN mvn package -DskipTests

# --- Étape 2 : Runtime léger et sécurisé ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Sécurité : Exécuter l'application sous un utilisateur non-root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copier le JAR généré lors de la phase de build
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

# Variables d'environnement par défaut
ENV SPRING_PROFILES_ACTIVE=postgres

ENTRYPOINT ["java", "-jar", "app.jar"]