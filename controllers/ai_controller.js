document.addEventListener('DOMContentLoaded', () => {
    const CHAT_FORM = document.getElementById('chat-form');
    const CHAT_INPUT = document.getElementById('chat-input');
    const CHAT_MESSAGES = document.getElementById('chat-messages');

    if (!CHAT_FORM) return;

    CHAT_FORM.addEventListener('submit', handleFormSubmit);

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
            if (!nombreTemp) {
                return "DATOS_OFICIALES:\nNo hay temporadas disponibles.";
            }

            const temp = temporadas[nombreTemp] || {};
            const iden = data.identidades || {};
            const equiposMap = iden.equipos || {};
            const jugadoresMap = iden.jugadores || {};
            const plantillas = temp.plantillas || {};
            const jornadas = temp.jornadas || {};

            const preguntaNorm = normalizarTexto(preguntaUsuario);
            const equiposOrdenados = Object.keys(plantillas).sort((a, b) => {
                const nombreA = equiposMap[a] || a;
                const nombreB = equiposMap[b] || b;
                return nombreA.localeCompare(nombreB, "es");
            });
            const jornadasOrdenadas = Object.keys(jornadas).sort((a, b) => {
                return extraerNumeroJornada(a) - extraerNumeroJornada(b);
            });

            let equipoObjetivoId = null;
            for (const eqId of equiposOrdenados) {
                const nombreEquipoNorm = normalizarTexto(equiposMap[eqId] || eqId);
                const eqIdNorm = normalizarTexto(eqId);
                if (preguntaNorm.includes(nombreEquipoNorm) || preguntaNorm.includes(eqIdNorm)) {
                    equipoObjetivoId = eqId;
                    break;
                }
            }

            let jornadaObjetivo = null;
            const jornadaMatch = preguntaNorm.match(/(?:jornada|\bj)\s*(\d+)/);
            if (jornadaMatch) {
                const numero = parseInt(jornadaMatch[1], 10);
                jornadaObjetivo = jornadasOrdenadas.find((j) => extraerNumeroJornada(j) === numero) || null;
            }

            const quiereResultados = /(resultado|partido|marcador|jornada|gano|perdio)/.test(preguntaNorm);
            const quierePlantillas = /(jugador|plantilla|equipo|dorsal|alineacion)/.test(preguntaNorm);

            let modo = "general";
            if (jornadaObjetivo) modo = "jornada";
            else if (equipoObjetivoId) modo = "equipo";
            else if (quiereResultados && !quierePlantillas) modo = "resultados";
            else if (quierePlantillas && !quiereResultados) modo = "plantillas";

            const totalJugadores = equiposOrdenados.reduce((acum, eqId) => {
                return acum + (Array.isArray(plantillas[eqId]) ? plantillas[eqId].length : 0);
            }, 0);
            const jornadasConResultado = jornadasOrdenadas.filter((j) => {
                return (jornadas[j] || []).some((p) => p.res && p.res !== "Pendiente");
            }).length;

            let texto = `DATOS OFICIALES FEDERACION (${nombreTemp}):\n`;
            texto += `MODO_CONTEXTO: ${modo}\n`;
            texto += `TOTAL_EQUIPOS: ${equiposOrdenados.length}\n`;
            texto += `TOTAL_JUGADORES_LISTADOS: ${totalJugadores}\n`;
            texto += `JORNADAS_CON_RESULTADOS: ${jornadasConResultado}\n\n`;

            const escribirPlantillaEquipo = (eqId) => {
                const nombreEquipo = equiposMap[eqId] || eqId;
                const jugadores = (plantillas[eqId] || [])
                    .slice()
                    .sort((a, b) => {
                        const nombreA = jugadoresMap[a.id] || "Desconocido";
                        const nombreB = jugadoresMap[b.id] || "Desconocido";
                        return nombreA.localeCompare(nombreB, "es");
                    })
                    .map((j) => {
                        const nombreJugador = jugadoresMap[j.id] || "Desconocido";
                        return `${nombreJugador} (#${j.d})`;
                    })
                    .join(", ");
                texto += `- ${nombreEquipo}: ${jugadores || "Sin jugadores registrados"}\n`;
            };

            const construirLineaResultados = (jor, partidos) => {
                const partes = partidos.map((p) => {
                    const local = equiposMap[p.el] || p.el;
                    const visitante = equiposMap[p.ev] || p.ev;
                    const resultado = p.res || "Pendiente";
                    return `${local} ${resultado} ${visitante}`;
                });
                return `${jor}: ${partes.join(" | ")}`;
            };

            if (modo === "equipo") {
                texto += "EQUIPO Y JUGADORES:\n";
                escribirPlantillaEquipo(equipoObjetivoId);

                texto += "\nRESULTADOS DEL EQUIPO:\n";
                const lineas = [];
                jornadasOrdenadas.forEach((jor) => {
                    const partidos = (jornadas[jor] || []).filter((p) => {
                        return p.res && p.res !== "Pendiente" && (p.el === equipoObjetivoId || p.ev === equipoObjetivoId);
                    });
                    if (partidos.length) {
                        lineas.push(construirLineaResultados(jor, partidos));
                    }
                });
                texto += (lineas.slice(-6).join("\n") || "Sin resultados finalizados para ese equipo.") + "\n";
            } else if (modo === "jornada") {
                texto += `JORNADA OBJETIVO: ${jornadaObjetivo}\n`;
                const partidos = (jornadas[jornadaObjetivo] || []).slice();
                if (!partidos.length) {
                    texto += "Sin partidos en la jornada solicitada.\n";
                } else {
                    texto += construirLineaResultados(jornadaObjetivo, partidos) + "\n";
                }
            } else if (modo === "resultados") {
                texto += "RESULTADOS DE PARTIDOS:\n";
                const jornadasConPartidos = jornadasOrdenadas.filter((jor) => {
                    return (jornadas[jor] || []).some((p) => p.res && p.res !== "Pendiente");
                });
                const recientes = jornadasConPartidos.slice(-6);
                if (!recientes.length) {
                    texto += "Sin resultados finalizados.\n";
                } else {
                    recientes.forEach((jor) => {
                        const partidos = (jornadas[jor] || []).filter((p) => p.res && p.res !== "Pendiente");
                        texto += construirLineaResultados(jor, partidos) + "\n";
                    });
                }
            } else if (modo === "plantillas") {
                texto += "EQUIPOS Y JUGADORES:\n";
                equiposOrdenados.forEach(escribirPlantillaEquipo);
            } else {
                texto += "EQUIPOS Y JUGADORES:\n";
                equiposOrdenados.forEach(escribirPlantillaEquipo);

                texto += "\nRESULTADOS DE PARTIDOS (ULTIMAS 5 JORNADAS CON RESULTADO):\n";
                const jornadasConPartidos = jornadasOrdenadas.filter((jor) => {
                    return (jornadas[jor] || []).some((p) => p.res && p.res !== "Pendiente");
                });
                jornadasConPartidos.slice(-5).forEach((jor) => {
                    const partidos = (jornadas[jor] || []).filter((p) => p.res && p.res !== "Pendiente");
                    texto += construirLineaResultados(jor, partidos) + "\n";
                });
            }

            return texto;
        } catch (error) {
            return "DATOS_OFICIALES:\nNo se pudieron preparar los datos de la temporada actual.";
        }
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
        const promptText = `DATOS_OFICIALES:\n${datosPlanos}\n\nPREGUNTA_USUARIO:\n${preguntaUsuario}\n\nINSTRUCCION_FINAL:\nResponde en espanol natural y en maximo 2 frases.`;
        const system =
            `Eres el analista oficial de la federacion.
            Usa exclusivamente DATOS_OFICIALES para responder.
            No inventes nombres, partidos, jornadas, marcadores ni estadisticas.
            Si el dato no aparece de forma explicita, responde exactamente: No tengo ese dato en la temporada actual.
            Si la pregunta es ambigua, responde exactamente: ¿Puedes concretar equipo, jugador o jornada?
            No menciones reglas internas, formato de datos ni que eres una IA.`;

        try {
            const response = await fetch(URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    model: "qwen2.5:3b",
                    // Enviamos el texto plano ya procesado
                    prompt: promptText,
                    system: system,
                    stream: false,
                    options: {
                        temperature: 0.1,
                        top_p: 0.9,
                        repeat_penalty: 1.1,
                        num_predict: 120
                    } // Ajustes conservadores para reducir alucinaciones
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