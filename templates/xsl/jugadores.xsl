<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <xsl:variable name="filtroNombre" select="federacion/filtroNombre"/>
        <xsl:variable name="filtroApellido" select="federacion/filtroApellido"/>
        <xsl:variable name="filtroNombreNorm" select="translate($filtroNombre, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÜÑáéíóúüñ', 'abcdefghijklmnopqrstuvwxyzaeiouunaeiouun')"/>
        <xsl:variable name="filtroApellidoNorm" select="translate($filtroApellido, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÜÑáéíóúüñ', 'abcdefghijklmnopqrstuvwxyzaeiouunaeiouun')"/>
        <xsl:variable name="ultimaTemporada" select="/federacion/temporadas/temporada[not(@anoInicio &lt; /federacion/temporadas/temporada/@anoInicio)][1]/@anoInicio"/>

        <xsl:for-each select="federacion/jugadores/jugador[
            contains(translate(nombreJugador, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÜÑáéíóúüñ', 'abcdefghijklmnopqrstuvwxyzaeiouunaeiouun'), $filtroNombreNorm)
            and
            contains(translate(apellidosJugador, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÜÑáéíóúüñ', 'abcdefghijklmnopqrstuvwxyzaeiouunaeiouun'), $filtroApellidoNorm)
        ]">
            <xsl:variable name="jugadorId" select="@id"/>
            <xsl:variable name="fotoJugadorTemporada" select="/federacion/temporadas/temporada[not(@anoInicio &lt; /federacion/temporadas/temporada/@anoInicio)][1]/plantillas/equipo/jugador[@ref=$jugadorId]/@foto"/>
            <xsl:variable name="fotoJugador">
                <xsl:choose>
                    <xsl:when test="normalize-space($fotoJugadorTemporada) != ''">
                        <xsl:value-of select="$fotoJugadorTemporada"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('.//liga/fotos/jugadores/', $ultimaTemporada, '/', $jugadorId, '.jpg')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <section class="jugadores-card">
                <img class="jugador-foto" src="{$fotoJugador}" alt="Foto de {concat(nombreJugador, ' ', apellidosJugador)}" onerror="this.onerror=null;this.src='./assets/img/iconos/usuario.png';" />

                <p>
                    <xsl:value-of select="concat(nombreJugador, ' ', apellidosJugador)"/>
                </p>
            </section>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>