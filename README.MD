# 🏀 Proyecto Federación: Analista IA (Rama Experimental)

Esta rama integra un **asistente de inteligencia artificial** diseñado para interactuar con los datos oficiales de la federación en tiempo real. Permite a los usuarios realizar consultas en lenguaje natural y recibir respuestas precisas sobre equipos, plantillas y resultados.

---

## 🚀 Características
* **Interacción Natural**: Consulta datos complejos sin necesidad de navegar por tablas.
* **Procesamiento Local**: Privacidad garantizada al ejecutar el modelo en tu propia máquina.
* **Contexto Dinámico**: La IA analiza el XML de la federación (convertido a JSON) para dar respuestas actualizadas.

## ⚠️ Nota sobre Versión Experimental
> **LA IA PUEDE COMETER ERRORES**: Dado que el modelo se encuentra en fase de pruebas, algunas respuestas pueden ser inexactas o contener "alucinaciones". Se recomienda verificar datos críticos. El rendimiento depende directamente de la potencia de tu hardware (CPU/GPU).

---

## 🛠️ Requerimientos del Sistema

Para ejecutar esta versión, es necesario configurar un entorno de IA local:

1. **Ollama**: [Descargar e instalar](https://ollama.com/) el motor de ejecución.
2. **Modelo Qwen 2.5 (3B)**: Una vez instalado Ollama, ejecuta el siguiente comando en tu terminal:
   ```bash
   ollama run qwen2.5:3b