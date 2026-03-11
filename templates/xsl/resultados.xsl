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
                <title>Prima League - Resultados</title>
                <style>
                    body { font-family: Arial, sans-serif; background: #252e3e; color: white; padding: 20px; }
                    h1, h2 { color: #d4941c; }
                    .jornada { margin: 20px 0; padding: 15px; background: rgba(255,255,255,0.05); border-radius: 8px; }
                    .partido { display: flex; justify-content: space-between; align-items: center; padding: 10px; margin: 5px 0; background: rgba(255,255,255,0.05); border-radius: 4px; }
                    .equipo { flex: 1; text-align: center; }
                    .marcador { font-size: 1.5em; font-weight: bold; color: #d4941c; min-width: 80px; text-align: center; }
                    .ganador { color: #4CAF50; }
                </style>
            </head>
            <body>
                <h1>Resultados</h1>
                <h2>Temporada <xsl:value-of select="$anoInicio"/> - <xsl:value-of select="$anoFin"/></h2>

                <xsl:apply-templates select="federacion/temporadas/temporada[@anoInicio=$anoInicio and @anoFin=$anoFin]"/>
            </body>
        </html>
    </xsl:template>

    <!-- Plantilla para procesar una temporada -->
    <xsl:template match="temporada">
        <xsl:for-each select="jornadas/jornada">
            <xsl:variable name="jornadaNum" select="position()"/>
            <xsl:variable name="partidosJugados" select="partido[puntosLocal != '' and puntosVisitante != '']"/>

            <!-- Solo mostrar jornadas con partidos jugados -->
            <xsl:if test="count($partidosJugados) > 0">
                <div class="jornada">
                    <h3>Jornada <xsl:value-of select="$jornadaNum"/></h3>

                    <xsl:for-each select="$partidosJugados">
                        <xsl:call-template name="mostrar-partido"/>
                    </xsl:for-each>
                </div>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Plantilla para mostrar un partido -->
    <xsl:template name="mostrar-partido">
        <xsl:variable name="localRef" select="equipoLocal/@ref"/>
        <xsl:variable name="visitanteRef" select="equipoVisitante/@ref"/>
        <xsl:variable name="localNombre" select="/federacion/equipos/equipo[@id=$localRef]/nombreEquipo"/>
        <xsl:variable name="visitanteNombre" select="/federacion/equipos/equipo[@id=$visitanteRef]/nombreEquipo"/>
        <xsl:variable name="pLocal" select="number(puntosLocal)"/>
        <xsl:variable name="pVisitante" select="number(puntosVisitante)"/>

        <div class="partido">
            <div class="equipo">
                <xsl:attribute name="class">
                    equipo <xsl:if test="$pLocal > $pVisitante">ganador</xsl:if>
                </xsl:attribute>
                <xsl:value-of select="$localNombre"/>
            </div>
            <div class="marcador">
                <xsl:value-of select="puntosLocal"/> - <xsl:value-of select="puntosVisitante"/>
            </div>
            <div class="equipo">
                <xsl:attribute name="class">
                    equipo <xsl:if test="$pVisitante > $pLocal">ganador</xsl:if>
                </xsl:attribute>
                <xsl:value-of select="$visitanteNombre"/>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>
