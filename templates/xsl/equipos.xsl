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
                <style>
                    body { font-family: Arial, sans-serif; background: #252e3e; color: white; padding: 20px; }
                    h1, h2, h3 { color: #d4941c; }
                    .equipo-container { margin: 30px 0; padding: 20px; background: rgba(255,255,255,0.05); border-radius: 8px; }
                    .equipo-header { display: flex; align-items: center; gap: 20px; margin-bottom: 15px; }
                    .equipo-escudo { width: 80px; height: 80px; object-fit: contain; }
                    .jugadores-horizontal { display: flex; flex-wrap: nowrap; overflow-x: auto; gap: 15px; padding: 15px 0; }
                    .jugador-card { flex: 0 0 auto; width: 120px; background: rgba(255,255,255,0.08); border-radius: 8px; padding: 10px; text-align: center; }
                    .jugador-foto { width: 80px; height: 80px; border-radius: 50%; object-fit: cover; background: rgba(255,255,255,0.1); margin: 0 auto 10px; }
                    .jugador-dorsal { color: #d4941c; font-size: 1.2em; font-weight: bold; }
                    .jugador-nombre { font-size: 0.9em; margin-top: 5px; }
                </style>
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
                    <xsl:variable name="jugadorNombre" select="/federacion/jugadores/jugador[@id=$jugadorRef]/nombreJugador"/>
                    <xsl:variable name="jugadorApellidos" select="/federacion/jugadores/jugador[@id=$jugadorRef]/apellidosJugador"/>
                    <xsl:variable name="foto" select="@foto"/>
                    <xsl:variable name="dorsal" select="@dorsal"/>

                    <div class="jugador-card">
                        <xsl:choose>
                            <xsl:when test="$foto != ''">
                                <img class="jugador-foto" src="{$foto}" alt="Foto de {$jugadorNombre}"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="jugador-foto" style="display: flex; align-items: center; justify-content: center; color: #666;">
                                    Sin foto
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                        <div class="jugador-dorsal">#<xsl:value-of select="$dorsal"/></div>
                        <div class="jugador-nombre">
                            <xsl:value-of select="$jugadorNombre"/>
                            <xsl:if test="$jugadorApellidos != ''">
                                <br/><xsl:value-of select="$jugadorApellidos"/>
                            </xsl:if>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>
