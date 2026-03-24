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
                <title>Prima League - Equipos</title>
                <link rel="stylesheet" type="text/css" href="../css/global.css"/>
                <link rel="stylesheet" type="text/css" href="../css/equipos.css"/>
            </head>
            <body>
                <h1>Equipos</h1>
                <h2>Temporada <xsl:value-of select="$anoInicio"/> - <xsl:value-of select="$anoFin"/></h2>

                <xsl:apply-templates select="federacion/temporadas/temporada[@anoInicio=$anoInicio and @anoFin=$anoFin]"/>
            </body>
        </html>
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
        <xsl:variable name="escudo" select="@escudo"/>

        <div class="equipo-container">
            <div class="equipo-header">
                <xsl:if test="$escudo != ''">
                    <img class="equipo-escudo" src="{$escudo}" alt="Escudo de {$equipoNombre}"/>
                </xsl:if>
                <h3><xsl:value-of select="$equipoNombre"/></h3>
            </div>

            <h4>Plantilla (<xsl:value-of select="count(jugador)"/> jugadores)</h4>

            <div class="jugadores-horizontal">
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
                            <div class="jugador-dorsal">#<xsl:value-of select="$dorsal"/></div>
                            <div class="jugador-nombre">
                                <xsl:value-of select="$jugadorData/nombreJugador"/><br/>
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
                            <h2><xsl:value-of select="$jugadorData/nombreJugador"/> <xsl:value-of select="$jugadorData/apellidosJugador"/></h2>
                            <div class="modal-info">
                                <p><strong>Dorsal:</strong> <xsl:value-of select="$dorsal"/></p>
                            </div>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>
