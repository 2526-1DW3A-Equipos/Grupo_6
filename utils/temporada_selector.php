<?php

function obtenerContextoTemporada(string $xmlPath = './data/datos.xml'): array
{
    $xml = new DOMDocument();
    $xml->load($xmlPath);

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

    return [
        'xml' => $xml,
        'xpath' => $xpath,
        'temporadas' => $temporadas,
        'seleccionada' => $seleccionada,
        'ultima' => $ultimaTemporada,
    ];
}

function renderSelectorTemporada(string $rutaSegura, DOMNodeList $temporadas, string $seleccionada, string $equipoSeleccionado = ''): string
{
    ob_start();
    ?>
    <form method="GET" action="" class="form-selector">
        <input type="hidden" name="<?php echo htmlspecialchars($rutaSegura, ENT_QUOTES, 'UTF-8'); ?>" value="" />
        <div class="temporada-selector">
            <label for="temporada-select">Temporada:</label>
            <select id="temporada-select" name="inicio" onchange="this.form.submit()">
                <?php foreach ($temporadas as $nodo): ?>
                    <?php
                        $valInicio = $nodo->getAttribute('anoInicio');
                        $valFin = $nodo->getAttribute('anoFin');
                        $isSel = ($valInicio === $seleccionada) ? 'selected' : '';
                    ?>
                    <option value="<?php echo htmlspecialchars($valInicio, ENT_QUOTES, 'UTF-8'); ?>" <?php echo $isSel; ?>>
                        <?php echo htmlspecialchars($valInicio, ENT_QUOTES, 'UTF-8'); ?> - <?php echo htmlspecialchars($valFin, ENT_QUOTES, 'UTF-8'); ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </div>
        <?php if ($equipoSeleccionado !== ''): ?>
            <input type="hidden" name="eq" value="<?php echo htmlspecialchars($equipoSeleccionado, ENT_QUOTES, 'UTF-8'); ?>" />
        <?php endif; ?>
    </form>
    <?php

    return (string) ob_get_clean();
}
