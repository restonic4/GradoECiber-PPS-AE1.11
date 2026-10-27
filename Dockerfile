# ---------- Etapa 1: compilación ----------
FROM eclipse-temurin:17.0.20.1_1-jdk-jammy AS build

WORKDIR /workspace

# Dependencias
COPY gradlew settings.gradle build.gradle gradle.lockfile ./
COPY gradle/ gradle/
RUN ./gradlew --no-daemon dependencies > /dev/null

# El código fuente se copia después para no invalidar la capa anterior.
COPY src/ src/
RUN ./gradlew --no-daemon jar

# ---------- Etapa 2: ejecución ----------
# Solo JRE, sin compilador ni Gradle: menor superficie de ataque.
FROM eclipse-temurin:17.0.20.1_1-jre-jammy

# Usuario y grupo sin privilegios.
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app
COPY --from=build --chown=app:app /workspace/build/libs/app.jar app.jar

# A partir de aquí ya no es root
USER 10001:10001

EXPOSE 8080

# Exec form: la JVM es PID 1 y recibe las señales directamente.
CMD ["java", "-jar", "/app/app.jar"]
