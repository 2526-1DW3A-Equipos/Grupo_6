<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- Parametro para seleccionar la temporada -->
    <xsl:param name="anoInicio"/>
    <xsl:param name="anoFin"/>

    <!-- Plantilla principal -->
    <xsl:template match="/">
        <html lang="es-ES">
            <body>
                <h1>Clasificacion</h1>
                <h2>Temporada <xsl:value-of select="$anoInicio"/> - <xsl:value-of select="$anoFin"/></h2>

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

            <!-- Calcular estadisticas -->
            <xsl:variable name="partidosLocal" select="$temporada/jornadas/jornada/partido[equipoLocal/@ref=$equipoRef]"/>
            <xsl:variable name="partidosVisitante" select="$temporada/jornadas/jornada/partido[equipoVisitante/@ref=$equipoRef]"/>

            <tr>
                <td><xsl:value-of select="position()"/></td>
                <td class="tablaEscudo">
                    <img src="{$escudoSrc}" alt="Escudo de {$equipoNombre}" onerror="this.onerror=null;this.src='./assets/img/iconos/escudo.png';"/>
                </td>
                <td class="tablaNombre"><xsl:value-of select="$equipoNombre"/></td>
                <td>
                    <xsl:value-of select="count($partidosLocal[puntosLocal != '']) + count($partidosVisitante[puntosVisitante != ''])"/>
                </td>
                <td>-</td>
                <td>-</td>
                <td>-</td>
                <td>-</td>
                <td>-</td>
                <td>-</td>
            </tr>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
