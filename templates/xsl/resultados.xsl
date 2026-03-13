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
                <link rel="stylesheet" type="text/css" href="../css/resultados.css"/>
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
        <xsl:variable name="partidosJugados" select="jornadas/jornada/partido[puntosLocal != '' and puntosVisitante != '']"/>

        <xsl:choose>
            <xsl:when test="count($partidosJugados) = 0">
                <p class="no-partidos">No hay resultados disponibles en esta temporada.</p>
            </xsl:when>
            <xsl:otherwise>
                <div class="resultadosContenedor">
                    <xsl:for-each select="jornadas/jornada">
                        <xsl:variable name="jornadaNum" select="position()"/>
                        <xsl:variable name="jugados" select="partido[puntosLocal != '' and puntosVisitante != '']"/>

                        <xsl:if test="count($jugados) > 0">
                            <div class="resultadosJornada">
                                <h3>Jornada <xsl:value-of select="$jornadaNum"/></h3>
                                <div class="jornadaPartidos">
                                    <xsl:for-each select="$jugados">
                                        <xsl:call-template name="mostrar-partido"/>
                                    </xsl:for-each>
                                </div>
                            </div>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Plantilla para mostrar un partido jugado con marcador -->
    <xsl:template name="mostrar-partido">
        <xsl:variable name="localRef" select="equipoLocal/@ref"/>
        <xsl:variable name="visitanteRef" select="equipoVisitante/@ref"/>
        <xsl:variable name="localNombre" select="/federacion/equipos/equipo[@id=$localRef]/nombreEquipo"/>
        <xsl:variable name="visitanteNombre" select="/federacion/equipos/equipo[@id=$visitanteRef]/nombreEquipo"/>
        <xsl:variable name="pLocal" select="number(puntosLocal)"/>
        <xsl:variable name="pVisitante" select="number(puntosVisitante)"/>

        <div class="jornadaPartido">
            <!-- Equipo local -->
            <div class="jornadaEquipo">
                <p><xsl:value-of select="$localNombre"/></p>
            </div>

            <!-- Marcador -->
            <div class="jornadaMarcador">
                <div>
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="$pLocal > $pVisitante">jornadaPuntos ganador</xsl:when>
                            <xsl:otherwise>jornadaPuntos</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="puntosLocal"/>
                </div>
                <span class="marcadorSeparador">-</span>
                <div>
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="$pVisitante > $pLocal">jornadaPuntos ganador</xsl:when>
                            <xsl:otherwise>jornadaPuntos</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="puntosVisitante"/>
                </div>
            </div>

            <!-- Equipo visitante -->
            <div class="jornadaEquipo local">
                <p><xsl:value-of select="$visitanteNombre"/></p>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>
