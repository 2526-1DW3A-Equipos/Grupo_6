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
                <style>
                    body { background-color: rgb(37, 46, 62); color: whitesmoke; }
                    
                    .equipo-container { 
                        background: rgba(30, 36, 51, 0.6); 
                        margin: 20px 0; 
                        padding: 20px; 
                        border-radius: 8px; 
                        border: 1px solid rgba(255, 255, 255, 0.05); 
                    }
                    .equipo-header { display: flex; align-items: center; gap: 15px; margin-bottom: 20px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); padding-bottom: 10px; }
                    .equipo-escudo { width: 50px; height: auto; }
                    .equipo-header h3 { margin: 0; color: #f8af27; }
                    
                    h4 { margin-bottom: 15px; color: rgba(255, 255, 255, 0.6); }

                    .jugadores-horizontal { display: flex; flex-wrap: wrap; gap: 20px; }
                    
                    /* Tarjeta de jugador (enlace para modal) */
                    .jugador-card-link { text-decoration: none; color: inherit; cursor: pointer; }
                    
                    .jugador-card { 
                        width: 140px; 
                        background: rgba(255, 255, 255, 0.03); 
                        border: 1px solid rgba(255, 255, 255, 0.1); 
                        padding: 15px 10px; 
                        text-align: center; 
                        border-radius: 8px; 
                        transition: all 0.2s ease;
                        height: 100%;
                        display: flex; 
                        flex-direction: column; 
                        align-items: center;
                    }
                    .jugador-card:hover { transform: translateY(-5px); background: rgba(255, 255, 255, 0.08); border-color: #f8af27; }
                    
                    .jugador-foto { width: 100px; height: 100px; object-fit: cover; background: #111; border-radius: 50%; margin-bottom: 10px; border: 2px solid rgba(255,255,255,0.1); }
                    .jugador-dorsal { color: #f8af27; font-weight: 700; font-family: "Rajdhani", sans-serif; font-size: 1.1rem; }
                    .jugador-nombre { font-size: 0.9rem; margin-top: 5px; line-height: 1.2; }

                    /* --- MODAL CSS --- */
                    .modal-overlay {
                        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                        background: rgba(0, 0, 0, 0.85); backdrop-filter: blur(4px);
                        display: none; justify-content: center; align-items: center; z-index: 1000;
                        opacity: 0; transition: opacity 0.3s;
                    }
                    .modal-overlay:target { display: flex; opacity: 1; }

                    .modal-content {
                        background: rgb(30, 36, 51); padding: 30px; border-radius: 12px;
                        max-width: 400px; width: 90%; position: relative; text-align: center;
                        border: 1px solid rgba(248, 175, 39, 0.3); box-shadow: 0 10px 40px rgba(0,0,0,0.5);
                    }
                    .close-btn {
                        position: absolute; top: 10px; right: 15px; font-size: 28px;
                        text-decoration: none; color: rgba(255, 255, 255, 0.5); line-height: 1;
                    }
                    .close-btn:hover { color: #f8af27; }
                    
                    .modal-img { width: 140px; height: 140px; border-radius: 50%; object-fit: cover; border: 3px solid #f8af27; margin-bottom: 15px; }
                    .modal-content h2 { color: #f8af27; margin-bottom: 20px; font-size: 1.5rem; }
                    .modal-info p { border-bottom: 1px solid rgba(255,255,255,0.1); padding: 10px 0; margin: 0; display: flex; justify-content: space-between; }
                    .modal-info p:last-child { border-bottom: none; }
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
