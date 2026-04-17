<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- Parametros para seleccionar la temporada -->
    <xsl:param name="anoInicio"/>
    <xsl:param name="anoFin"/>
    <xsl:param name="jornadaSeleccionada" select="'all'"/>

    <!-- Plantilla principal -->
    <xsl:template match="/">
        <xsl:apply-templates select="federacion/temporadas/temporada[@anoInicio=$anoInicio and @anoFin=$anoFin]"/>
    </xsl:template>

    <!-- Plantilla para procesar una temporada -->
    <xsl:template match="temporada">
        <xsl:variable name="totalPartidos" select="count(jornadas/jornada/partido)"/>
        <xsl:variable name="totalJornadas" select="count(jornadas/jornada)"/>
        <xsl:variable name="soloUnaJornada" select="$totalJornadas = 1 or ($jornadaSeleccionada != 'all' and $jornadaSeleccionada != '')"/>

        <xsl:choose>
            <xsl:when test="$totalPartidos = 0">
                <p class="no-partidos">No hay partidos en esta temporada.</p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$totalJornadas &gt; 0">
                    <div class="calendario-controles">
                        <form method="GET" action="" class="calendario-controles-form">
                            <input type="hidden" name="calendario" value=""/>
                            <input type="hidden" name="inicio" value="{$anoInicio}"/>
                            <div class="calendario-navegacion">
                                <button type="submit" class="boton calendario-boton" name="accionJornada" value="prev">Anterior</button>

                                <div class="calendario-selector-grupo">
                                    <label for="jornada-select">Jornada</label>
                                    <select id="jornada-select" name="jornada" onchange="this.form.submit()">
                                        <option value="all">
                                            <xsl:if test="$jornadaSeleccionada = 'all'">
                                                <xsl:attribute name="selected">selected</xsl:attribute>
                                            </xsl:if>
                                            Todas las jornadas
                                        </option>

                                        <xsl:for-each select="jornadas/jornada">
                                            <xsl:variable name="jornadaNum" select="position()"/>
                                            <option>
                                                <xsl:attribute name="value">
                                                    <xsl:value-of select="$jornadaNum"/>
                                                </xsl:attribute>
                                                <xsl:if test="$jornadaSeleccionada = string($jornadaNum)">
                                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                                </xsl:if>
                                                <xsl:text>Jornada </xsl:text>
                                                <xsl:value-of select="$jornadaNum"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>

                                <button type="submit" class="boton calendario-boton" name="accionJornada" value="next">Siguiente</button>
                            </div>
                        </form>
                    </div>
                </xsl:if>

                <div>
                    <xsl:attribute name="class">
                        <xsl:text>calendario-jornadas</xsl:text>
                        <xsl:if test="$soloUnaJornada">
                            <xsl:text> calendario-jornadas--single</xsl:text>
                        </xsl:if>
                    </xsl:attribute>

                    <xsl:for-each select="jornadas/jornada">
                        <xsl:variable name="jornadaNum" select="position()"/>
                        <xsl:variable name="partidosJornada" select="partido"/>

                        <xsl:if test="count($partidosJornada) &gt; 0 and ($jornadaSeleccionada = 'all' or $jornadaSeleccionada = '' or string($jornadaNum) = $jornadaSeleccionada)">
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
                </div>
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
