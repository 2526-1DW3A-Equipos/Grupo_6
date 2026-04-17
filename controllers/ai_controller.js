document.addEventListener('DOMContentLoaded', () => {
    const CHAT_FORM = document.getElementById('chat-form');
    const CHAT_INPUT = document.getElementById('chat-input');
    const CHAT_MESSAGES = document.getElementById('chat-messages');

    if (!CHAT_FORM) return;

    CHAT_FORM.addEventListener('submit', handleFormSubmit);

    let chatHistory = [];
    let contadorPeticiones = 0;
    const FRECUENCIA_REFRESCO = 5;

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
        const datosSimplificados = simplificarDatosParaIA(datosLigaRaw, userQuestion);

        console.log(datosSimplificados);

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

    /* Convierte el texto en minusculas */ 
    function normalizarTexto(texto) {
        return String(texto || "")
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "")
            .toLowerCase();
    }

    function extraerNumeroJornada(claveJornada) {
        const match = String(claveJornada || "").match(/\d+/);
        return match ? parseInt(match[0], 10) : Number.MAX_SAFE_INTEGER;
    }

    function obtenerTemporadaMasReciente(temporadas) {
        const claves = Object.keys(temporadas || {});
        if (!claves.length) return null;

        return claves.sort((a, b) => {
            const aAnio = parseInt((String(a).match(/\d{4}/) || ["0"])[0], 10);
            const bAnio = parseInt((String(b).match(/\d{4}/) || ["0"])[0], 10);
            if (aAnio !== bAnio) return bAnio - aAnio;
            return String(b).localeCompare(String(a), "es");
        })[0];
    }

    function simplificarDatosParaIA(jsonRaw, preguntaUsuario = "") {
        try {
            const data = JSON.parse(jsonRaw);
            const temporadas = data.temporada || {};
            const nombreTemp = obtenerTemporadaMasReciente(temporadas);
            if (!nombreTemp) return "SISTEMA|Error: Sin temporadas.";

            const temp = temporadas[nombreTemp] || {};
            const iden = data.identidades || {};
            const equiposMap = iden.equipos || {};
            const jugadoresMap = iden.jugadores || {};
            const plantillas = temp.plantillas || {};
            const jornadas = temp.jornadas || {};

            const preguntaNorm = normalizarTexto(preguntaUsuario);
            const equiposIds = Object.keys(equiposMap).sort();
            const esPrimeraVez = (chatHistory.length === 0);

            // --- 1. DETECCIÓN PERMISIVA DE EQUIPO ---
            let equipoObjetivoId = null;
            for (const id of equiposIds) {
                const nombreEquipo = normalizarTexto(equiposMap[id] || "");
                const idNorm = normalizarTexto(id);
                
                // Permisividad: detecta por ID exacto, nombre completo o si el nombre es lo suficientemente largo, por coincidencia parcial
                if (preguntaNorm.includes(idNorm) || preguntaNorm.includes(nombreEquipo) || 
                (nombreEquipo.length > 4 && preguntaNorm.includes(nombreEquipo.substring(0, 5)))) {
                    equipoObjetivoId = id;
                    break;
                }
            }

            // --- 2. DETECCIÓN DE INTENCIÓN (AMPLIADA) ---
            const quiereResultados = /(resultado|partido|marcador|gano|perdio|jugo|versus| vs |jornada|j\d+)/i.test(preguntaNorm);
            const quierePlantillas = /(jugador|quien|plantilla|alineacion|dorsal|numero|quien es|quienes son)/i.test(preguntaNorm);
            
            let modo = "general";
            if (equipoObjetivoId) modo = "especifico_equipo";
            else if (quiereResultados && !quierePlantillas) modo = "solo_resultados";
            else if (quierePlantillas && !quiereResultados) modo = "solo_plantillas";

            // --- 3. CONSTRUCCIÓN DEL CONTEXTO CON LEYENDA (Para modelos 3B) ---
            let texto = `### CONTEXTO_IA_FEDERACION ###\n`;
            texto += `INFO|Temporada:${nombreTemp} | Modo:${esPrimeraVez ? "INICIAL_COMPLETO" : modo}\n`;
            texto += `LEYENDA|P=Plantilla [ID_EQ|Nombre|Dorsal] | L=Partido [Jornada|Local|Visitante|Res]\n\n`;

            // SIEMPRE enviamos la lista de equipos para mantener la referencia global
            texto += "== EQUIPOS_REGISTRADOS ==\n";
            equiposIds.forEach(id => {
                texto += `${id}:${equiposMap[id]}\n`;
            });
            texto += "\n";

            // --- 4. TABLA DE PLANTILLAS (Lógica de filtrado) ---
            if (esPrimeraVez || quierePlantillas || equipoObjetivoId || modo === "general") {
                texto += "== PLANTILLAS ==\n";
                // Si es primera vez o consulta general, mandamos todo. Si hay equipo, solo ese.
                const listaIds = (equipoObjetivoId) ? [equipoObjetivoId] : (esPrimeraVez || modo === "general" ? equiposIds : []);
                
                listaIds.forEach(eqId => {
                    const jugadores = plantillas[eqId] || [];
                    jugadores.forEach(j => {
                        const n = jugadoresMap[j.id] || "Desconocido";
                        texto += `P|${eqId}|${n}|${j.d}\n`;
                    });
                });
                texto += "\n";
            }

            // --- 5. TABLA DE PARTIDOS (Lógica de filtrado) ---
            if (esPrimeraVez || quiereResultados || equipoObjetivoId || modo === "general") {
                texto += "== RESULTADOS_RECIENTES ==\n";
                let jorKeys = Object.keys(jornadas);
                // Si no es la primera vez, solo mandamos las últimas 3 jornadas para no saturar
                if (!esPrimeraVez && !quiereResultados) jorKeys = jorKeys.slice(-3);

                jorKeys.forEach(jor => {
                    const partidos = jornadas[jor] || [];
                    partidos.forEach(p => {
                        // Si buscamos un equipo, solo mostramos sus partidos
                        if (equipoObjetivoId && p.el !== equipoObjetivoId && p.ev !== equipoObjetivoId) return;
                        
                        const r = p.res || "Pendiente";
                        texto += `L|${jor}|${p.el}|${p.ev}|${r}\n`;
                    });
                });
            }

            return texto;
        } catch (e) {
            console.error("Error simplificando datos:", e);
            return "ERROR_SISTEMA|Datos corruptos.";
        }
    }

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
        const URL = 'http://localhost:11434/api/chat';
        contadorPeticiones++;

        const systemPrompt = `Actúa como un motor de base de datos relacional. 
        INSTRUCCIONES ESTRICTAS:
        1. Responde SOLO con la información presente en las tablas.
        2. Si el usuario pregunta "¿Quién juega en...?", enumera los nombres y dorsales.
        3. PROHIBIDO decir qué falta o pedir que se refresque la información. 
        4. PROHIBIDO mencionar posiciones (portero, defensa, etc.) si no están en la tabla.
        5. Si no hay datos, responde: "No hay registros".
        `;

        // DETERMINAMOS SI ENVIAMOS EL CONTEXTO O NO
        // Enviamos los datos solo si es la primera petición o si toca por el contador
        const debeEnviarContexto = chatHistory.length === 0 || (contadorPeticiones % FRECUENCIA_REFRESCO === 0);
        
        let contenidoMensaje = "";
        if (debeEnviarContexto) {
            console.log("Enviando contexto completo para refrescar memoria...");
            contenidoMensaje = `DATOS_LIGA_ACTUALIZADOS:\n${datosPlanos}\n\nPREGUNTA:\n${preguntaUsuario}`;
        } else {
            console.log("Petición rápida (sin envío de contexto)");
            contenidoMensaje = preguntaUsuario;
        }

        const mensajeUsuario = {
            role: "user",
            content: contenidoMensaje
        };

        try {
            const response = await fetch(URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    model: "qwen2.5:3b",
                    messages: [
                        { role: "system", content: systemPrompt },
                        ...chatHistory,
                        mensajeUsuario
                    ],
                    stream: false,
                    options: {
                        // PRECISIÓN
                        temperature: 0.0,
                        top_k: 15,
                        top_p: 0.1,
                        
                        // COHERENCIA
                        repeat_penalty: 1.3,
                        repeat_last_n: 64,
                        
                        // RECURSOS Y LÍMITES
                        num_ctx: 4096,
                        num_predict: 300,
                        num_thread: 4, // Ajusta según tu CPU
                        
                        // DESACTIVAR CREATIVIDAD EXTRA
                        mirostat: 0
                    }
                })
            });

            if (!response.ok) return null;
            const result = await response.json();
            const respuestaTexto = result.message.content.trim();

            // Guardamos en el historial
            chatHistory.push(mensajeUsuario);
            chatHistory.push({ role: "assistant", content: respuestaTexto });

            // MANTENER EL HISTORIAL CONTROLADO
            // Para que la "memoria" funcione, no podemos borrar los mensajes viejos 
            // tan agresivamente, pero sí limitar para no saturar la CPU.
            if (chatHistory.length > 5) {
                // Eliminamos los dos mensajes más antiguos (pregunta y respuesta)
                chatHistory.splice(1, 2); 
            }

            return respuestaTexto;
        } catch (error) {
            console.error("Error:", error);
            return null;
        }
    }
});