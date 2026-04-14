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
                    <xsl:value-of select="concat('./fotos/equipos/', $anoInicio, '/', substring-after($equipoRef, 'E'), '_', $equipoNombreArchivo, '.jpg')"/>
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
            <a class="cabeceraCnt" href="?equipos">Ir a Equipos</a>
            <h4>Plantilla (<xsl:value-of select="count(jugador)"/>
 jugadores)</h4>
        </div>
        <div class="jugadores-container jugadores-container-detalle">
            <table class="tabla-jugadores">
                <thead>
                    <tr>
                        <th>Foto</th>
                        <th>Nombre y Apellidos</th>
                        <th>Dorsal</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="jugador">
                        <xsl:sort select="number(@dorsal)" data-type="number" order="ascending"/>
                        <xsl:sort select="normalize-space(/federacion/jugadores/jugador[@id=current()/@ref]/nombreJugador)" data-type="text" order="ascending"/>
                        <xsl:variable name="jugadorRef" select="@ref"/>
                        <xsl:variable name="jugadorData" select="/federacion/jugadores/jugador[@id=$jugadorRef]"/>
                        <xsl:variable name="foto" select="@foto"/>
                        <xsl:variable name="dorsal" select="@dorsal"/>

                        <xsl:variable name="fotoJugador">
                            <xsl:choose>
                                <xsl:when test="normalize-space($foto) != ''">
                                    <xsl:value-of select="$foto"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('./fotos/jugadores/', $anoInicio, '/', $jugadorRef, '.jpg')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <tr>
                            <td>
                                <img class="jugador-foto" src="{$fotoJugador}" alt="Foto de {$jugadorData/nombreJugador}" onerror="this.onerror=null;this.src='./assets/img/iconos/usuario.png';"/>
                            </td>
                            <td>
                                <xsl:value-of select="$jugadorData/nombreJugador"/>
                            </td>
                            <td>
                                <xsl:value-of select="$dorsal"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>

</xsl:stylesheet>
