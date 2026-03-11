<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- Parametros para seleccionar la temporada -->
    <xsl:param name="anoInicio"/>
    <xsl:param name="anoFin"/>

    <!-- Plantilla principal -->
    <xsl:template match="/">
        <html lang="es-ES">
            <head>
                <meta charset="UTF-8"/>
                <title>Prima League - Calendario</title>
                <style>
                    body { font-family: Arial, sans-serif; background: #252e3e; color: white; padding: 20px; }
                    h1, h2 { color: #d4941c; }
                    .jornada { margin: 20px 0; padding: 15px; background: rgba(255,255,255,0.05); border-radius: 8px; }
                    .partido { display: flex; justify-content: space-between; align-items: center; padding: 15px; margin: 10px 0; background: rgba(255,255,255,0.08); border-radius: 4px; border-left: 3px solid #d4941c; }
                    .equipo { flex: 1; }
                    .equipo.local { text-align: right; padding-right: 20px; }
                    .equipo.visitante { text-align: left; padding-left: 20px; }
                    .vs { color: #d4941c; font-weight: bold; font-size: 1.2em; min-width: 50px; text-align: center; }
                    .no-partidos { text-align: center; padding: 30px; font-style: italic; opacity: 0.7; }
                </style>
            </head>
            <body>
                <h1>Calendario - Proximos Partidos</h1>
                <h2>Temporada <xsl:value-of select="$anoInicio"/> - <xsl:value-of select="$anoFin"/></h2>

                <xsl:apply-templates select="federacion/temporadas/temporada[@anoInicio=$anoInicio and @anoFin=$anoFin]"/>
            </body>
        </html>
    </xsl:template>

    <!-- Plantilla para procesar una temporada -->
    <xsl:template match="temporada">
        <xsl:variable name="partidosPendientes" select="jornadas/jornada/partido[puntosLocal = '' or puntosVisitante = '']"/>

        <xsl:choose>
            <xsl:when test="count($partidosPendientes) = 0">
                <p class="no-partidos">No hay partidos pendientes en esta temporada.</p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="jornadas/jornada">
                    <xsl:variable name="jornadaNum" select="position()"/>
                    <xsl:variable name="partidosNoJugados" select="partido[puntosLocal = '' or puntosVisitante = '']"/>

                    <!-- Solo mostrar jornadas con partidos no jugados -->
                    <xsl:if test="count($partidosNoJugados) > 0">
                        <div class="jornada">
                            <h3>Jornada <xsl:value-of select="$jornadaNum"/></h3>

                            <xsl:for-each select="$partidosNoJugados">
                                <xsl:call-template name="mostrar-partido-pendiente"/>
                            </xsl:for-each>
                        </div>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Plantilla para mostrar un partido pendiente -->
    <xsl:template name="mostrar-partido-pendiente">
        <xsl:variable name="localRef" select="equipoLocal/@ref"/>
        <xsl:variable name="visitanteRef" select="equipoVisitante/@ref"/>
        <xsl:variable name="localNombre" select="/federacion/equipos/equipo[@id=$localRef]/nombreEquipo"/>
        <xsl:variable name="visitanteNombre" select="/federacion/equipos/equipo[@id=$visitanteRef]/nombreEquipo"/>

        <div class="partido">
            <div class="equipo local">
                <strong><xsl:value-of select="$localNombre"/></strong>
                <br/>
                <small>(Local)</small>
            </div>
            <div class="vs">VS</div>
            <div class="equipo visitante">
                <strong><xsl:value-of select="$visitanteNombre"/></strong>
                <br/>
                <small>(Visitante)</small>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>
