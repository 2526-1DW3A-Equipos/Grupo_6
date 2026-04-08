<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <xsl:param name="anoInicio"/>
    <xsl:param name="anoFin"/>

    <xsl:template match="/">
        <html lang="es-ES">
            <div class="tabla-equipos">
                <xsl:apply-templates select="federacion/temporadas/temporada[@anoInicio=$anoInicio and @anoFin=$anoFin]"/>
            </div>
        </html>
    </xsl:template>

    <xsl:template match="temporada">
        <xsl:for-each select="plantillas/equipo">
            <xsl:sort select="count(../../jornadas/jornada/partido[equipoLocal/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '' and number(puntosLocal) &gt; number(puntosVisitante)]) + count(../../jornadas/jornada/partido[equipoVisitante/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '' and number(puntosVisitante) &gt; number(puntosLocal)])" data-type="number" order="descending"/>
            <xsl:sort select="(sum(../../jornadas/jornada/partido[equipoLocal/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosLocal) + sum(../../jornadas/jornada/partido[equipoVisitante/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosVisitante)) - (sum(../../jornadas/jornada/partido[equipoLocal/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosVisitante) + sum(../../jornadas/jornada/partido[equipoVisitante/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosLocal))" data-type="number" order="descending"/>
            <xsl:sort select="sum(../../jornadas/jornada/partido[equipoLocal/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosLocal) + sum(../../jornadas/jornada/partido[equipoVisitante/@ref=current()/@ref and normalize-space(puntosLocal) != '' and normalize-space(puntosVisitante) != '']/puntosVisitante)" data-type="number" order="descending"/>

            <xsl:call-template name="mostrar-equipo">
                <xsl:with-param name="posicion" select="position()"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="mostrar-equipo">
        <xsl:param name="posicion"/>

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
                <a href="?equipos&amp;eq={$equipoRef}">
                    <img class="equipo-escudo" src="{$escudoSrc}" alt="Escudo de {$equipoNombre}" onerror="this.onerror=null;this.src='./assets/img/iconos/escudo.png';"/>
                    
                </a>
                <a href="?equipos&amp;eq={$equipoRef}">
                    <h3>
                        <xsl:value-of select="$equipoNombre"/>
                    </h3>
                </a>
            </div>
            <div class="equipo-datos">
                <ul>
                    <li class="posicion-valor">
                        <strong>Posicion:</strong>
                        <xsl:value-of select="$posicion"/>
                    </li>
                    <li>
                        <strong>Jugadores:</strong>
                        <xsl:value-of select="count(jugador)"/>
                    </li>
                </ul>
            </div>
        </div>
        
    </xsl:template>

</xsl:stylesheet>