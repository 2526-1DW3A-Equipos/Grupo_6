<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- Plantilla principal - muestra resumen de la liga -->
    <xsl:template match="/">
        <html lang="es-ES">
            <head>
                <meta charset="UTF-8"/>
                <title>Prima League - Datos de la Liga</title>
                <style>
                    body { font-family: Arial, sans-serif; background: #252e3e; color: white; padding: 20px; }
                    h1 { color: #d4941c; }
                    h2 { color: #d4941c; margin-top: 30px; }
                    table { border-collapse: collapse; width: 100%; margin: 10px 0; }
                    th, td { border: 1px solid #555; padding: 8px; text-align: left; }
                    th { background: rgba(212, 148, 28, 0.3); }
                    tr:nth-child(even) { background: rgba(255, 255, 255, 0.05); }
                    .equipo-card { display: inline-block; margin: 10px; padding: 15px; background: rgba(255,255,255,0.1); border-radius: 8px; }
                </style>
            </head>
            <body>
                <h1>Prima League - Datos de la Liga</h1>

                <!-- Equipos -->
                <h2>Equipos (<xsl:value-of select="count(federacion/equipos/equipo)"/>)</h2>
                <div class="equipos-container">
                    <xsl:for-each select="federacion/equipos/equipo">
                        <div class="equipo-card">
                            <strong><xsl:value-of select="nombreEquipo"/></strong>
                            <br/>
                            <small>ID: <xsl:value-of select="@id"/></small>
                        </div>
                    </xsl:for-each>
                </div>

                <!-- Jugadores -->
                <h2>Jugadores (<xsl:value-of select="count(federacion/jugadores/jugador)"/>)</h2>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre</th>
                            <th>Apellidos</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="federacion/jugadores/jugador">
                            <tr>
                                <td><xsl:value-of select="@id"/></td>
                                <td><xsl:value-of select="nombreJugador"/></td>
                                <td><xsl:value-of select="apellidosJugador"/></td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>

                <!-- Temporadas -->
                <h2>Temporadas (<xsl:value-of select="count(federacion/temporadas/temporada)"/>)</h2>
                <xsl:for-each select="federacion/temporadas/temporada">
                    <xsl:call-template name="mostrar-temporada"/>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>

    <!-- Plantilla para mostrar una temporada -->
    <xsl:template name="mostrar-temporada">
        <div style="margin: 20px 0; padding: 15px; background: rgba(255,255,255,0.05); border-radius: 8px;">
            <h3 style="color: #d4941c;">
                Temporada <xsl:value-of select="@anoInicio"/> - <xsl:value-of select="@anoFin"/>
            </h3>

            <!-- Contar partidos jugados y no jugados -->
            <xsl:variable name="partidosJugados" select="count(jornadas/jornada/partido[puntosLocal != '' and puntosVisitante != ''])"/>
            <xsl:variable name="partidosNoJugados" select="count(jornadas/jornada/partido[puntosLocal = '' or puntosVisitante = ''])"/>
            <xsl:variable name="totalJornadas" select="count(jornadas/jornada)"/>

            <p>
                <strong>Jornadas:</strong> <xsl:value-of select="$totalJornadas"/>
                | <strong>Partidos jugados:</strong> <xsl:value-of select="$partidosJugados"/>
                | <strong>Partidos pendientes:</strong> <xsl:value-of select="$partidosNoJugados"/>
            </p>

            <!-- Plantillas de equipos -->
            <h4>Plantillas:</h4>
            <xsl:for-each select="plantillas/equipo">
                <xsl:variable name="equipoRef" select="@ref"/>
                <xsl:variable name="equipoNombre" select="/federacion/equipos/equipo[@id=$equipoRef]/nombreEquipo"/>

                <div style="margin: 10px 0; padding: 10px; background: rgba(255,255,255,0.05); border-radius: 4px;">
                    <strong><xsl:value-of select="$equipoNombre"/></strong>
                    (<xsl:value-of select="count(jugador)"/> jugadores)

                    <ul style="margin: 5px 0; padding-left: 20px;">
                        <xsl:for-each select="jugador">
                            <xsl:variable name="jugadorRef" select="@ref"/>
                            <xsl:variable name="jugadorNombre" select="/federacion/jugadores/jugador[@id=$jugadorRef]/nombreJugador"/>
                            <li>
                                #<xsl:value-of select="@dorsal"/> - <xsl:value-of select="$jugadorNombre"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>

</xsl:stylesheet>
