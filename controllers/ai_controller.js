document.addEventListener('DOMContentLoaded', () => {
    const CHAT_FORM = document.getElementById('chat-form');
    const CHAT_INPUT = document.getElementById('chat-input');
    const CHAT_MESSAGES = document.getElementById('chat-messages');

    if (!CHAT_FORM) return;

    CHAT_FORM.addEventListener('submit', handleFormSubmit);

    //NUEVA FUNCIÓN: Simplifica el JSON a texto plano para la IA
    function simplificarDatosParaIA(jsonRaw) {
        const data = JSON.parse(jsonRaw);
        const iden = data.identidades;
        // Obtenemos la primera temporada disponible (ej: 2026-2027)
        const nombreTemp = Object.keys(data.temporada)[0];
        const temp = data.temporada[nombreTemp];
        
        let texto = `DATOS OFICIALES FEDERACIÓN (${nombreTemp}):\n\n`;

        // 1. Mapeo de Plantillas con Nombres Reales
        texto += "EQUIPOS Y JUGADORES:\n";
        for (let eqId in temp.plantillas) {
            const nombreEquipo = iden.equipos[eqId] || eqId;
            const jugadores = temp.plantillas[eqId].map(j => {
                const nombreJugador = iden.jugadores[j.id] || "Desconocido";
                return `${nombreJugador} (#${j.d})`;
            }).join(", ");
            texto += `- ${nombreEquipo}: ${jugadores}\n`;
        }

        // 2. Mapeo de Resultados con Nombres Reales
        texto += "\nRESULTADOS DE PARTIDOS:\n";
        for (let jor in temp.jornadas) {
            const partidosFinalizados = temp.jornadas[jor].filter(p => p.res !== "Pendiente");
            if (partidosFinalizados.length > 0) {
                texto += `${jor}: ` + partidosFinalizados.map(p => {
                    const loc = iden.equipos[p.el] || p.el;
                    const vis = iden.equipos[p.ev] || p.ev;
                    return `${loc} ${p.res} ${vis}`;
                }).join(" | ") + "\n";
            }
        }
        return texto;
    }

    async function handleFormSubmit(e) {
        e.preventDefault();
        const userQuestion = CHAT_INPUT.value.trim();
        if (!userQuestion) return; 

        console.group("Consulta del Analista");
        writeMessage("user", userQuestion);
        CHAT_INPUT.value = ""; 

        const datosLigaRaw = await getFederationData();
        if (!datosLigaRaw) {
            writeMessage("ia", "Error: No se pudo obtener la información de la liga.", true);
            console.groupEnd();
            return;
        }

        const loadingMessage = writeMessage("ia", "Analizando datos de la federación...");
        loadingMessage.classList.add("typing-effect");

        // Simplificamos los datos antes de enviarlos
        const datosSimplificados = simplificarDatosParaIA(datosLigaRaw);

        console.time("⏱ Respuesta IA");
        const iaResponse = await sendPrompt(datosSimplificados, userQuestion);
        console.timeEnd("⏱ Respuesta IA");

        loadingMessage.remove(); 
        
        if (!iaResponse) {
            writeMessage("ia", "El analista no responde. Verifica Ollama.", true);
        } else {
            writeMessage("ia", iaResponse);
        }
        console.groupEnd();
    }

    // ... (Tu función writeMessage se mantiene igual) ...
    function writeMessage(rol, text, isError = false) {
        if (!rol || !text) return;
        let messageContainer = document.createElement("div");
        messageContainer.classList.add("chatbot-message", rol);
        if (isError) messageContainer.classList.add("chatbot-error");
        CHAT_MESSAGES.appendChild(messageContainer);
        let mensajeElement = document.createElement("p");
        mensajeElement.innerText = text; 
        messageContainer.appendChild(mensajeElement);
        CHAT_MESSAGES.scrollTop = CHAT_MESSAGES.scrollHeight;
        return messageContainer; 
    }

    async function getFederationData() {
        try {
            const response = await fetch('./api/get_federacion_data.php');
            if (!response.ok) return null;
            const data = await response.json();
            return JSON.stringify(data);
        } catch (error) {
            return null;
        }
    }

    async function sendPrompt(datosPlanos, preguntaUsuario) {
        const URL = 'http://localhost:11434/api/generate';
        try {
            const response = await fetch(URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    model: "qwen2.5:3b",
                    // Enviamos el texto plano ya procesado
                    prompt: `CONVENIO DE DATOS:\n${datosPlanos}\n\nPREGUNTA DEL USUARIO: ${preguntaUsuario}\nANALISTA:`,
                    system: `Eres el analista oficial de esta federación. 
                    REGLAS:
                    1. Usa exclusivamente los datos proporcionados arriba.
                    2. Responde de forma natural y breve.
                    3. Si te preguntan por jugadores de "la federación", entiende que se refieren a todos los que aparecen en la lista de equipos.
                    4. No menciones que eres una IA ni el formato de los datos.`,
                    stream: false,
                    options: { temperature: 0.1 } // Más determinista para evitar inventos
                })
            });

            if (!response.ok) return null;
            const result = await response.json();
            return result.response ? result.response.trim() : null;
        } catch (error) {
            return null;
        }
    }
});