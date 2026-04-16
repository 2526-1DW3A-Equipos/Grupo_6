<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- Parametros para seleccionar la temporada -->
    <xsl:param name="anoInicio"/>
    <xsl:param name="anoFin"/>

    <!-- Plantilla principal -->
    <xsl:template match="/">
        <xsl:apply-templates select="federacion/temporadas/temporada[@anoInicio=$anoInicio and @anoFin=$anoFin]"/>
    </xsl:template>

    <!-- Plantilla para procesar una temporada -->
    <xsl:template match="temporada">
        <xsl:variable name="totalPartidos" select="count(jornadas/jornada/partido)"/>

        <xsl:choose>
            <xsl:when test="$totalPartidos = 0">
                <p class="no-partidos">No hay partidos en esta temporada.</p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="jornadas/jornada">
                    <xsl:variable name="jornadaNum" select="position()"/>
                    <xsl:variable name="partidosJornada" select="partido"/>

                    <xsl:if test="count($partidosJornada) > 0">
                        <div class="jornada">
                            <h3>Jornada <xsl:value-of select="$jornadaNum"/>
                            </h3>

                            <div class="jornadaPartidos">
                                <xsl:for-each select="$partidosJornada">
                                    <xsl:call-template name="mostrar-partido"/>
                                </xsl:for-each>
                            </div>
                        </div>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Plantilla para mostrar un partido (pendiente o jugado) -->
    <xsl:template name="mostrar-partido">
        <xsl:variable name="localRef" select="equipoLocal/@ref"/>
        <xsl:variable name="visitanteRef" select="equipoVisitante/@ref"/>
        <xsl:variable name="localNombre" select="/federacion/equipos/equipo[@id=$localRef]/nombreEquipo"/>
        <xsl:variable name="visitanteNombre" select="/federacion/equipos/equipo[@id=$visitanteRef]/nombreEquipo"/>
        <xsl:variable name="puntosLocalTexto" select="normalize-space(puntosLocal)"/>
        <xsl:variable name="puntosVisitanteTexto" select="normalize-space(puntosVisitante)"/>
        <xsl:variable name="pLocal" select="number(puntosLocal)"/>
        <xsl:variable name="pVisitante" select="number(puntosVisitante)"/>

        <xsl:choose>
            <xsl:when test="$puntosLocalTexto = '' or $puntosVisitanteTexto = ''">
                <div class="partido">
                    <div class="equipo local">
                        <strong>
                            <xsl:value-of select="$localNombre"/>
                        </strong>
                        <br/>
                        <small>(Local)</small>
                    </div>
                    <div class="vs">VS</div>
                    <div class="equipo visitante">
                        <strong>
                            <xsl:value-of select="$visitanteNombre"/>
                        </strong>
                        <br/>
                        <small>(Visitante)</small>
                    </div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="jornadaPartido">
                    <div class="jornadaEquipo">
                        <p>
                            <xsl:value-of select="$localNombre"/>
                        </p>
                    </div>

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

                    <div class="jornadaEquipo local">
                        <p>
                            <xsl:value-of select="$visitanteNombre"/>
                        </p>
                    </div>
                </div>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
