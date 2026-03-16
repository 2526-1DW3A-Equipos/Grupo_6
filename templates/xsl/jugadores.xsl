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
                <title>Prima League - Jugadores</title>
            </head>
            <body>
                <h1>Jugadores</h1>
                <h2>Temporada <xsl:value-of select="$anoInicio"/> - <xsl:value-of select="$anoFin"/></h2>

                <xsl:apply-templates select="federacion/temporadas/temporada[@anoInicio=$anoInicio and @anoFin=$anoFin]"/>
            </body>
        </html>
    </xsl:template>

    <!-- Plantilla para procesar una temporada -->
    <xsl:template match="temporada">
        <xsl:variable name="jugadoresTemporada" select="plantillas/equipo/jugador[not(@ref = preceding::temporada[@anoInicio = current()/@anoInicio and @anoFin = current()/@anoFin]/plantillas/equipo/jugador/@ref)]"/>

        <xsl:choose>
            <xsl:when test="count($jugadoresTemporada) = 0">
                <p class="no-jugadores">No hay jugadores disponibles para esta temporada.</p>
            </xsl:when>
            <xsl:otherwise>
                <div class="jugadores-grid">
                    <xsl:for-each select="$jugadoresTemporada">
                        <xsl:variable name="jugadorRef" select="@ref"/>
                        <xsl:variable name="jugadorNombre" select="/federacion/jugadores/jugador[@id=$jugadorRef]/nombreJugador"/>
                        <xsl:variable name="jugadorApellidos" select="/federacion/jugadores/jugador[@id=$jugadorRef]/apellidosJugador"/>
                        <xsl:variable name="jugadorPosicion" select="@posicion | @demarcacion"/>
                        <xsl:variable name="foto" select="@foto"/>

                        <div class="jugador-card-cuadrada">
                            <div class="jugador-media">
                                <xsl:choose>
                                    <xsl:when test="$foto != ''">
                                        <img class="jugador-foto" src="{$foto}" alt="Foto de {$jugadorNombre}"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <img class="jugador-foto jugador-foto-placeholder" src="./assets/img/iconos/usuario.png" alt="No hay imagen disponible"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>

                            <div class="jugador-info">
                                <p class="jugador-nombre"><xsl:value-of select="$jugadorNombre"/></p>
                                <p class="jugador-apellido">
                                    <xsl:choose>
                                        <xsl:when test="$jugadorApellidos != ''">
                                            <xsl:value-of select="$jugadorApellidos"/>
                                        </xsl:when>
                                        <xsl:otherwise>Sin apellido</xsl:otherwise>
                                    </xsl:choose>
                                </p>
                                <p class="jugador-posicion">
                                    <xsl:choose>
                                        <xsl:when test="string($jugadorPosicion) != ''">
                                            <xsl:value-of select="$jugadorPosicion"/>
                                        </xsl:when>
                                        <xsl:otherwise>Sin posición</xsl:otherwise>
                                    </xsl:choose>
                                </p>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
