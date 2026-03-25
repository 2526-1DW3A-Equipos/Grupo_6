<?php
$ruta = $ruta ?? 'inicio';
$rutaSegura = preg_replace('/[^a-z]/', '', $ruta);
$xslPath = './templates/xsl/' . $rutaSegura . '.xsl';
?>
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
                    $ultimaTemporada = $xpath->evaluate('string(/federacion/temporadas/temporada[last()]/@anoInicio)');
                    $temporadasValidas = [];

                    foreach ($temporadas as $nodo) {
                        $temporadasValidas[] = $nodo->getAttribute('anoInicio');
                    }

                    if (!empty($_GET['inicio'])) {
                        $candidata = $_GET['inicio'];
                    } elseif (!empty($_SESSION['temporada_seleccionada'])) {
                        $candidata = $_SESSION['temporada_seleccionada'];
                    } else {
                        $candidata = $ultimaTemporada;
                    }

                    if (!in_array($candidata, $temporadasValidas, true)) {
                        $seleccionada = $ultimaTemporada;
                    } else {
                        $seleccionada = $candidata;
                    }

                    $_SESSION['temporada_seleccionada'] = $seleccionada;

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

    
<section class="contenedor-<?php echo htmlspecialchars($rutaSegura, ENT_QUOTES, 'UTF-8'); ?>">



        <?php

            $queryTemp = $xpath->query("/federacion/temporadas/temporada[@anoInicio='$seleccionada']");

            if (!file_exists($xslPath)) {
                echo '<p>No se encontro la plantilla para la pagina actual.</p>';
            } elseif ($queryTemp->length > 0) {
                $nodoActual = $queryTemp->item(0);
                $anioInicio = $nodoActual->getAttribute('anoInicio');
                $anioFin = $nodoActual->getAttribute('anoFin');

                echo '<h1>'. ucfirst($rutaSegura) .'</h1>';
                echo '<h2>Temporada ' . $seleccionada . ' - ' . $anioFin . '</h2>';
                echo '<article class="tabla-resultados contenido">';
                $xsl = new DOMDocument();
                $xsl->load($xslPath);

                $proc = new XSLTProcessor();
                $proc->importStylesheet($xsl);
                $proc->setParameter('', 'anoInicio', $anioInicio);
                $proc->setParameter('', 'anoFin', $anioFin);

                echo $proc->transformToXml($xml);
                echo '</article>';
            } else {
                echo '<p>No se encontraron datos para la temporada seleccionada.</p>';
            }
        ?>
</section>