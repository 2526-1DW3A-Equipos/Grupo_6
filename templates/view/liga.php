<?php
require_once "./controllers/URLController.php";
$ruta = URLController::getPaginaActual();
$rutaSegura = preg_replace('/[^a-z]/', '', $ruta);
$xslPath = './templates/xsl/' . $rutaSegura . '.xsl';
$equipoSeleccionado = '';
$mostrarTemporadaHeader = $mostrarTemporadaHeader ?? false;

require_once './utils/temporada_selector.php';

if (isset($temporadaContextoHeader) && is_array($temporadaContextoHeader)) {
    $temporadaContexto = $temporadaContextoHeader;
} else {
    $temporadaContexto = obtenerContextoTemporada('./liga/datos/datos-liga.xml');
}

$xml = $temporadaContexto['xml'];
$xpath = $temporadaContexto['xpath'];
$temporadas = $temporadaContexto['temporadas'];
$seleccionada = $temporadaContexto['seleccionada'];
$mostrarTituloTemporadaEnHeader = in_array($rutaSegura, ['clasificacion', 'calendario', 'resultados', 'equipos'], true);
$jornadasTemporada = $xpath->query("/federacion/temporadas/temporada[@anoInicio='$seleccionada']/jornadas/jornada");
$totalJornadas = $jornadasTemporada !== false ? $jornadasTemporada->length : 0;

$jornadaSeleccionada = 'all';
if (isset($_GET['jornada'])) {
    $jornadaSolicitada = trim((string) $_GET['jornada']);
    if ($jornadaSolicitada !== '') {
        $jornadaSeleccionada = $jornadaSolicitada === 'all' ? 'all' : preg_replace('/[^0-9]/', '', $jornadaSolicitada);
    }
}

$accionJornada = isset($_GET['accionJornada']) ? trim((string) $_GET['accionJornada']) : '';
if ($accionJornada === 'prev' || $accionJornada === 'next') {
    if ($totalJornadas > 0) {
        if ($jornadaSeleccionada === 'all' || $jornadaSeleccionada === '') {
            $jornadaActual = $accionJornada === 'next' ? 1 : $totalJornadas;
        } else {
            $jornadaActual = (int) $jornadaSeleccionada;
            $jornadaActual += $accionJornada === 'next' ? 1 : -1;

            if ($jornadaActual > $totalJornadas) {
                $jornadaActual = 1;
            } elseif ($jornadaActual < 1) {
                $jornadaActual = $totalJornadas;
            }
        }

        $jornadaSeleccionada = (string) $jornadaActual;
    } else {
        $jornadaSeleccionada = 'all';
    }
} elseif ($jornadaSeleccionada !== 'all' && ($jornadaSeleccionada === '' || (int) $jornadaSeleccionada < 1 || (int) $jornadaSeleccionada > $totalJornadas)) {
    $jornadaSeleccionada = 'all';
}
?>

    <?php
        // Gestionar si estamos buscando informacion especifica de un equipo
        if ($rutaSegura === 'equipos' && !empty($_GET['eq']) && preg_match('/^E\d+$/', $_GET['eq'])) {
            $equipoSeleccionado = $_GET['eq'];
            $xslPath = './templates/xsl/detalles_equipo.xsl';
        }
    ?>


    
<section class="contenedor-<?php echo htmlspecialchars($rutaSegura, ENT_QUOTES, 'UTF-8'); ?>">
        <?php
            
            $queryTemp = $xpath->query("/federacion/temporadas/temporada[@anoInicio='$seleccionada']");

            if (!file_exists($xslPath)) {
                echo '<p>No se encontro el archivo XSL para la pagina actual.</p>';
            } elseif ($queryTemp->length > 0) {
                $nodoActual = $queryTemp->item(0);
                $anioInicio = $nodoActual->getAttribute('anoInicio');
                $anioFin = $nodoActual->getAttribute('anoFin');
                $xmlParaTransformar = $xml;

                // Si estamos en equipos con eq, reducimos el XML a: temporada actual + equipo seleccionado.
                if ($rutaSegura === 'equipos' && $equipoSeleccionado !== '') {
                    $equipoEnTemporada = $xpath->query("./plantillas/equipo[@ref='$equipoSeleccionado']", $nodoActual);
                    $queryEquipo = "/federacion/equipos/equipo[@id='$equipoSeleccionado']";
                    $nodoEquipoGlobal = $xpath->query($queryEquipo)->item(0);

                    if ($equipoEnTemporada->length > 0 && $nodoEquipoGlobal !== null) {
                        $xmlReducido = new DOMDocument('1.0', 'UTF-8');
                        $federacion = $xmlReducido->appendChild($xmlReducido->createElement('federacion'));

                        $equiposReducidos = $federacion->appendChild($xmlReducido->createElement('equipos'));
                        $equiposReducidos->appendChild($xmlReducido->importNode($nodoEquipoGlobal, true));

                        // Reducimos jugadores solo a los que pertenecen al equipo en la temporada seleccionada.
                        $jugadoresReducidos = $federacion->appendChild($xmlReducido->createElement('jugadores'));
                        $jugadoresEquipo = $xpath->query("./jugador/@ref", $equipoEnTemporada->item(0));
                        foreach ($jugadoresEquipo as $jugadorRefAttr) {
                            $jugadorId = $jugadorRefAttr->nodeValue;
                            $nodoJugador = $xpath->query("/federacion/jugadores/jugador[@id='$jugadorId']")->item(0);
                            if ($nodoJugador !== null) {
                                $jugadoresReducidos->appendChild($xmlReducido->importNode($nodoJugador, true));
                            }
                        }

                        $temporadasReducidas = $federacion->appendChild($xmlReducido->createElement('temporadas'));
                        $temporadaReducida = $temporadasReducidas->appendChild($xmlReducido->createElement('temporada'));
                        $temporadaReducida->setAttribute('anoInicio', $anioInicio);
                        $temporadaReducida->setAttribute('anoFin', $anioFin);

                        $plantillasReducidas = $temporadaReducida->appendChild($xmlReducido->createElement('plantillas'));
                        $plantillasReducidas->appendChild($xmlReducido->importNode($equipoEnTemporada->item(0), true));

                        $xmlParaTransformar = $xmlReducido;
                    }
                }

                if (!$mostrarTituloTemporadaEnHeader) {
                    echo '<h1>'. ucfirst($rutaSegura) .'</h1>';
                    echo '<h2>Temporada ' . $seleccionada . ' - ' . $anioFin . '</h2>';
                }
                echo '<article class="tabla-resultados contenido">';
                $xsl = new DOMDocument();
                $xsl->load($xslPath);

                $proc = new XSLTProcessor();
                $proc->importStylesheet($xsl);
                $proc->setParameter('', 'anoInicio', $anioInicio);
                $proc->setParameter('', 'anoFin', $anioFin);
                $proc->setParameter('', 'jornadaSeleccionada', $jornadaSeleccionada);

                echo $proc->transformToXml($xmlParaTransformar);
                echo '</article>';
            } else {
                echo '<p>No se encontraron datos para la temporada seleccionada.</p>';
            }
        ?>
</section>