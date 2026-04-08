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
        <xsl:for-each select="plantillas/equipo">
            <xsl:call-template name="mostrar-equipo"/>
        </xsl:for-each>
    </xsl:template>

    <!-- Plantilla para mostrar un equipo -->
    <xsl:template name="mostrar-equipo">
        <xsl:variable name="equipoRef" select="@ref"/>
        <xsl:variable name="equipoNombre" select="/federacion/equipos/equipo[@id=$equipoRef]/nombreEquipo"/>
        <xsl:variable name="equipoNombreArchivo" select="translate(normalize-space($equipoNombre), ' áéíóúÁÉÍÓÚñÑ', '_aeiouAEIOUnN')"/>

        <xsl:variable name="escudoSrc">
            <xsl:choose>
                <xsl:when test="normalize-space(@escudo) != ''">
                    <xsl:value-of select="@escudo"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('./fotos/equipos/', $anoInicio, ' - ', $anoFin, '/', substring-after($equipoRef, 'E'), '_', $equipoNombreArchivo, '.jpg')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div class="equipo-container" id="eq-{$equipoRef}">
            <div class="equipo-header">
                <img class="equipo-escudo" src="{$escudoSrc}" alt="Escudo de {$equipoNombre}" onerror="this.onerror=null;this.src='./assets/img/iconos/escudo.png';"/>
                <h3>
                    <xsl:value-of select="$equipoNombre"/>
                </h3>
            </div>
            <a class="cabeceraCnt" href="?equipos">Vista anterior</a>
            <h4>Plantilla (<xsl:value-of select="count(jugador)"/>
 jugadores)</h4>
        </div>
        <div class="jugadores-container jugadores-container-detalle">
            <div class="jugadores-vertical jugadores-vertical-detalle">
                <xsl:for-each select="jugador">
                    <xsl:variable name="jugadorRef" select="@ref"/>
                    <xsl:variable name="jugadorData" select="/federacion/jugadores/jugador[@id=$jugadorRef]"/>
                    <xsl:variable name="foto" select="@foto"/>
                    <xsl:variable name="dorsal" select="@dorsal"/>

                    <a href="#modal-{$jugadorRef}" class="jugador-card-link">
                        <div class="jugador-card">
                            <xsl:choose>
                                <xsl:when test="$foto != ''">
                                    <img class="jugador-foto" src="{$foto}" alt="Foto de {$jugadorData/nombreJugador}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <div class="jugador-foto" style="display: flex; align-items: center; justify-content: center; color: #666;">Sin foto</div>
                                </xsl:otherwise>
                            </xsl:choose>
                            <div class="jugador-dorsal">#                                <xsl:value-of select="$dorsal"/>
                            </div>
                            <div class="jugador-nombre">
                                <xsl:value-of select="$jugadorData/nombreJugador"/>
                                <br/>
                                <xsl:value-of select="$jugadorData/apellidosJugador"/>
                            </div>
                        </div>
                    </a>

                    <div id="modal-{$jugadorRef}" class="modal-overlay">
                        <div class="modal-content">
                            <a href="#" class="close-btn">×</a>
                            <xsl:if test="$foto != ''">
                                <img class="modal-img" src="{$foto}" alt="{$jugadorData/nombreJugador}"/>
                            </xsl:if>
                            <h2>
                                <xsl:value-of select="$jugadorData/nombreJugador"/>
                                <xsl:value-of select="$jugadorData/apellidosJugador"/>
                            </h2>
                            <div class="modal-info">
                                <p>
                                    <strong>Dorsal:</strong>
                                    <xsl:value-of select="$dorsal"/>
                                </p>
                            </div>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>
