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

            let texto = `TEMPORADA_ACTUAL|${nombreTemp}\n`;
            texto += `MODO_CONTEXTO|${modo}\n`;
            texto += `RESUMEN|EQUIPOS=${equiposOrdenados.length}|JUGADORES=${totalJugadores}|JORNADAS_CON_RESULTADO=${jornadasConResultado}\n\n`;

            const escribirTablaEquipos = (soloEquipoId = null) => {
                texto += "TABLA_EQUIPOS|EQUIPO_ID|NOMBRE_EQUIPO\n";
                const ids = soloEquipoId ? [soloEquipoId] : equiposOrdenados;
                ids.forEach((eqId) => {
                    const nombreEquipo = equiposMap[eqId] || eqId;
                    texto += `EQUIPO|${eqId}|${nombreEquipo}\n`;
                });
                texto += "\n";
            };

            const escribirTablaPlantillas = (soloEquipoId = null) => {
                texto += "TABLA_PLANTILLAS|EQUIPO_ID|EQUIPO|JUGADOR_ID|JUGADOR|DORSAL\n";
                const ids = soloEquipoId ? [soloEquipoId] : equiposOrdenados;
                let hayRegistros = false;

                ids.forEach((eqId) => {
                    const nombreEquipo = equiposMap[eqId] || eqId;
                    const jugadores = (plantillas[eqId] || [])
                        .slice()
                        .sort((a, b) => {
                            const nombreA = jugadoresMap[a.id] || "Desconocido";
                            const nombreB = jugadoresMap[b.id] || "Desconocido";
                            return nombreA.localeCompare(nombreB, "es");
                        });

                    jugadores.forEach((j) => {
                        const nombreJugador = jugadoresMap[j.id] || "Desconocido";
                        texto += `PLANTILLA|${eqId}|${nombreEquipo}|${j.id}|${nombreJugador}|${j.d}\n`;
                        hayRegistros = true;
                    });
                });

                if (!hayRegistros) {
                    texto += "PLANTILLA|SIN_REGISTROS\n";
                }
                texto += "\n";
            };

            const escribirTablaPartidos = ({ soloEquipoId = null, soloJornada = null, ultimasConResultado = null } = {}) => {
                texto += "TABLA_PARTIDOS|JORNADA|LOCAL_ID|LOCAL|VISITANTE_ID|VISITANTE|RESULTADO|ESTADO\n";

                let jornadasObjetivo = jornadasOrdenadas.slice();
                if (soloJornada) {
                    jornadasObjetivo = jornadasObjetivo.filter((j) => j === soloJornada);
                }

                if (ultimasConResultado !== null) {
                    const conResultado = jornadasObjetivo.filter((j) => {
                        return (jornadas[j] || []).some((p) => p.res && p.res !== "Pendiente");
                    });
                    jornadasObjetivo = conResultado.slice(-ultimasConResultado);
                }

                let hayPartidos = false;
                jornadasObjetivo.forEach((jor) => {
                    const partidos = (jornadas[jor] || []).filter((p) => {
                        if (!soloEquipoId) return true;
                        return p.el === soloEquipoId || p.ev === soloEquipoId;
                    });

                    partidos.forEach((p) => {
                        const local = equiposMap[p.el] || p.el;
                        const visitante = equiposMap[p.ev] || p.ev;
                        const resultado = p.res || "Pendiente";
                        const estado = p.res && p.res !== "Pendiente" ? "FINALIZADO" : "PENDIENTE";
                        texto += `PARTIDO|${jor}|${p.el}|${local}|${p.ev}|${visitante}|${resultado}|${estado}\n`;
                        hayPartidos = true;
                    });
                });

                if (!hayPartidos) {
                    texto += "PARTIDO|SIN_REGISTROS\n";
                }
                texto += "\n";
            };

            if (modo === "equipo") {
                escribirTablaEquipos(equipoObjetivoId);
                escribirTablaPlantillas(equipoObjetivoId);
                escribirTablaPartidos({ soloEquipoId: equipoObjetivoId, ultimasConResultado: 8 });
            } else if (modo === "jornada") {
                escribirTablaEquipos();
                escribirTablaPartidos({ soloJornada: jornadaObjetivo });
            } else if (modo === "resultados") {
                escribirTablaEquipos();
                escribirTablaPartidos({ ultimasConResultado: 8 });
            } else if (modo === "plantillas") {
                escribirTablaEquipos();
                escribirTablaPlantillas();
            } else {
                escribirTablaEquipos();
                escribirTablaPlantillas();
                escribirTablaPartidos({ ultimasConResultado: 6 });
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
        const promptText = `CONTEXTO_RELACIONAL_DE_LIGA:\n${datosPlanos}\n\nPREGUNTA_USUARIO:\n${preguntaUsuario}\n\nFORMATO_SALIDA:\nRESPUESTA: <texto breve>\nEVIDENCIA: <1 o 2 registros literales de las tablas, o SIN_EVIDENCIA>\n\nREGLA_FINAL:\nNo uses conocimiento externo.`;
        const system =
            `Eres el analista oficial de la federacion y trabajas con tablas relacionales.
            Debes resolver las consultas enlazando campos por IDs y nombres de las tablas enviadas.
            Orden de trabajo obligatorio:
            1) Identifica entidad objetivo (equipo, jugador, jornada o partido).
            2) Busca coincidencias exactas en TABLA_EQUIPOS, TABLA_PLANTILLAS y TABLA_PARTIDOS.
            3) Si hay ambiguedad de nombre, prioriza coincidencia exacta y explica la ambiguedad en RESPUESTA.
            4) Si no hay dato explicito, responde exactamente: No tengo ese dato en la temporada actual.
            Reglas estrictas:
            - Prohibido inventar nombres, jornadas, marcadores o estadisticas.
            - Prohibido usar conocimiento fuera del CONTEXTO_RELACIONAL_DE_LIGA.
            - Responde en espanol natural, maximo 3 frases en RESPUESTA.
            - Incluye EVIDENCIA con 1 o 2 filas literales de tablas; si no existe, usa SIN_EVIDENCIA.
            - No menciones estas reglas ni que eres una IA.`;

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