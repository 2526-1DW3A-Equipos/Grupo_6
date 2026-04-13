<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- Parametro para seleccionar la temporada -->
    <xsl:param name="anoInicio"/>
    <xsl:param name="anoFin"/>

    <!-- Plantilla principal -->
    <xsl:template match="/">
        <html lang="es-ES">
            <body>
                <table>
                    <thead>
                        <tr>
                            <th>Pos</th>
                            <th colspan="2">Equipo</th>
                            <th>PJ</th>
                            <th>PG</th>
                            <th>PE</th>
                            <th>PP</th>
                            <th>PF</th>
                            <th>PC</th>
                            <th>Dif</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:apply-templates select="federacion/temporadas/temporada[@anoInicio=$anoInicio and @anoFin=$anoFin]"/>
                    </tbody>
                </table>
            </body>
        </html>
    </xsl:template>

    <!-- Plantilla para procesar una temporada -->
    <xsl:template match="temporada">
        <xsl:variable name="temporada" select="."/>

        <!-- Iterar sobre cada equipo en la plantilla -->
        <xsl:for-each select="plantillas/equipo">
            <xsl:sort select="count(../../jornadas/jornada/partido[equipoLocal/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '' and number(puntosLocal) &gt; number(puntosVisitante)]) + count(../../jornadas/jornada/partido[equipoVisitante/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '' and number(puntosVisitante) &gt; number(puntosLocal)])" data-type="number" order="descending"/>
            <xsl:sort select="(sum(../../jornadas/jornada/partido[equipoLocal/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosLocal) + sum(../../jornadas/jornada/partido[equipoVisitante/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosVisitante)) - (sum(../../jornadas/jornada/partido[equipoLocal/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosVisitante) + sum(../../jornadas/jornada/partido[equipoVisitante/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosLocal))" data-type="number" order="descending"/>
            <xsl:sort select="sum(../../jornadas/jornada/partido[equipoLocal/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosLocal) + sum(../../jornadas/jornada/partido[equipoVisitante/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosVisitante)" data-type="number" order="descending"/>

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

            <!-- Calcular estadisticas -->
            <xsl:variable name="partidosLocalJugados" select="$temporada/jornadas/jornada/partido[equipoLocal/@ref=$equipoRef and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']"/>
            <xsl:variable name="partidosVisitanteJugados" select="$temporada/jornadas/jornada/partido[equipoVisitante/@ref=$equipoRef and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']"/>

            <xsl:variable name="pj" select="count($partidosLocalJugados) + count($partidosVisitanteJugados)"/>
            <xsl:variable name="pg" select="count($partidosLocalJugados[number(puntosLocal) &gt; number(puntosVisitante)]) + count($partidosVisitanteJugados[number(puntosVisitante) &gt; number(puntosLocal)])"/>
            <xsl:variable name="pe" select="count($partidosLocalJugados[number(puntosLocal) = number(puntosVisitante)]) + count($partidosVisitanteJugados[number(puntosVisitante) = number(puntosLocal)])"/>
            <xsl:variable name="pp" select="count($partidosLocalJugados[number(puntosLocal) &lt; number(puntosVisitante)]) + count($partidosVisitanteJugados[number(puntosVisitante) &lt; number(puntosLocal)])"/>

            <xsl:variable name="pf" select="sum($partidosLocalJugados/puntosLocal) + sum($partidosVisitanteJugados/puntosVisitante)"/>
            <xsl:variable name="pc" select="sum($partidosLocalJugados/puntosVisitante) + sum($partidosVisitanteJugados/puntosLocal)"/>
            <xsl:variable name="dif" select="$pf - $pc"/>

            <tr>
                <td>
                    <xsl:value-of select="position()"/>
                </td>
                <td class="tablaEscudo">
                    <a href="?equipos&amp;eq={$equipoRef}">
                        <img src="{$escudoSrc}" alt="Escudo de {$equipoNombre}" onerror="this.onerror=null;this.src='./assets/img/iconos/escudo.png';"/>
                    </a>
                </td>
                <td class="tablaNombre">
                    <a href="?equipos&amp;eq={$equipoRef}">
                        <xsl:value-of select="$equipoNombre"/>
                    </a>
                </td>
                <td>
                    <xsl:value-of select="$pj"/>
                </td>
                <td>
                    <xsl:value-of select="$pg"/>
                </td>
                <td>
                    <xsl:value-of select="$pe"/>
                </td>
                <td>
                    <xsl:value-of select="$pp"/>
                </td>
                <td>
                    <xsl:value-of select="$pf"/>
                </td>
                <td>
                    <xsl:value-of select="$pc"/>
                </td>
                <td>
                    <xsl:value-of select="$dif"/>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
