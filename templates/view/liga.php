<?php
$ruta = $ruta ?? 'inicio';
$rutaSegura = preg_replace('/[^a-z]/', '', $ruta);
$xslPath = './templates/xsl/' . $rutaSegura . '.xsl';
?>

<section class="contenedor-<?php echo htmlspecialchars($rutaSegura, ENT_QUOTES, 'UTF-8'); ?>">
    <form method="GET" action="" class="form-selector">
        <input type="hidden" name="<?php echo htmlspecialchars($rutaSegura, ENT_QUOTES, 'UTF-8'); ?>" value="" />
        <div class="temporada-selector">
            <label for="temporada-select">Temporada:</label>
            <select id="temporada-select" name="inicio" onchange="this.form.submit()">
                <?php
                    $xml = new DOMDocument();
                    $xml->load('./data/datos.xml');
                    $xpath = new DOMXPath($xml);
                    $temporadas = $xpath->query('/federacion/temporadas/temporada');

                    $seleccionada = $_GET['inicio'] ?? $xpath->evaluate('string(/federacion/temporadas/temporada[last()]/@anoInicio)');

                    foreach ($temporadas as $nodo) {
                        $valInicio = $nodo->getAttribute('anoInicio');
                        $valFin = $nodo->getAttribute('anoFin');
                        $isSel = ($valInicio === $seleccionada) ? 'selected' : '';

                        echo "<option value='$valInicio' $isSel>$valInicio - $valFin</option>";
                    }
                ?>
            </select>
        </div>
    </form>

    <article class="tabla-resultados contenido">
        <?php
            $queryTemp = $xpath->query("/federacion/temporadas/temporada[@anoInicio='$seleccionada']");

            if (!file_exists($xslPath)) {
                echo '<p>No se encontro la plantilla para la pagina actual.</p>';
            } elseif ($queryTemp->length > 0) {
                $nodoActual = $queryTemp->item(0);
                $anioInicio = $nodoActual->getAttribute('anoInicio');
                $anioFin = $nodoActual->getAttribute('anoFin');

                $xsl = new DOMDocument();
                $xsl->load($xslPath);

                $proc = new XSLTProcessor();
                $proc->importStylesheet($xsl);
                $proc->setParameter('', 'anoInicio', $anioInicio);
                $proc->setParameter('', 'anoFin', $anioFin);

                echo $proc->transformToXml($xml);
            } else {
                echo '<p>No se encontraron datos para la temporada seleccionada.</p>';
            }
        ?>
    </article>
</section>