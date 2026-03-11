<section class="contenedor-clasificacion">
    <form method="GET" action="" class="form-selector">
        <input type="hidden" name="clasificacion" value="" />
        <div class="temporada-selector">     
            <label for="temporada-select">Temporada:</label>
            <select id="temporada-select" name="inicio" onchange="this.form.submit()">
                <?php
                    $xml = new DOMDocument();
                    $xml->load('./data/datos.xml');
                    $xpath = new DOMXPath($xml);
                    
                    $temporadas = $xpath->query("/federacion/temporadas/temporada");

                    // 1. Detectamos cuál es la temporada seleccionada por el usuario
                    // Si no hay ninguna en la URL, buscamos la última del XML por defecto
                    $seleccionada = $_GET['inicio'] ?? $xpath->evaluate("string(/federacion/temporadas/temporada[last()]/@anoInicio)");

                    foreach ($temporadas as $nodo) {
                        $valInicio = $nodo->getAttribute('anoInicio');
                        $valFin    = $nodo->getAttribute('anoFin');
                        $isSel     = ($valInicio === $seleccionada) ? 'selected' : '';

                        echo "<option value='$valInicio' $isSel>$valInicio - $valFin</option>";
                    }
                ?>
            </select>
        </div>
    </form>

    <article class="tabla-resultados contenido">
        <?php
            // 2. Buscamos en el XML los datos específicos de la temporada seleccionada
            $queryTemp = $xpath->query("/federacion/temporadas/temporada[@anoInicio='$seleccionada']");
            
            if ($queryTemp->length > 0) {
                $nodoActual = $queryTemp->item(0);
                $anioInicio = $nodoActual->getAttribute('anoInicio');
                $anioFin    = $nodoActual->getAttribute('anoFin');

                // 3. Procesamos el XSLT
                $xsl = new DOMDocument();
                $xsl->load('./templates/xsl/clasificacion.xsl'); // Asegúrate de la ruta correcta

                $proc = new XSLTProcessor();
                $proc->importStylesheet($xsl);
                
                // Pasamos los parámetros correctos al XSL
                $proc->setParameter('', 'anoInicio', $anioInicio);
                $proc->setParameter('', 'anoFin', $anioFin);

                echo $proc->transformToXml($xml);
            } else {
                echo "<p>No se encontraron datos para la temporada seleccionada.</p>";
            }
        ?>
    </article>
</section>