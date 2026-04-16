<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Cache-Control: no-cache, must-revalidate');

// Evitar que cualquier warning previo ensucie el JSON
ob_start();

$xmlFilePath = '../liga/datos/datos-liga.xml';

function cargarXML($path) {
    if(!file_exists($path)) return null;
    $dom = new DOMDocument();
    // Carga silenciosa para evitar errores de parseo en la salida
    libxml_use_internal_errors(true);
    if (!$dom->load($path, LIBXML_NOBLANKS | LIBXML_COMPACT)) {
        return null;
    }
    return $dom;
}

function extraerMapa($xml, $tagName, $idAttr, $nameTag) {
    $map = [];
    if (!$xml) return $map;
    foreach ($xml->getElementsByTagName($tagName) as $item) {
        $id = $item->getAttribute($idAttr);
        $nodosNombre = $item->getElementsByTagName($nameTag);
        $map[$id] = ($nodosNombre->length > 0) ? $nodosNombre->item(0)->nodeValue : "Desconocido ($id)";
    }
    return $map;
}

function extraerTemporadasCompletas($xml) {
    $resultado = [];
    if (!$xml) return $resultado;
    foreach ($xml->getElementsByTagName('temporada') as $temp) {
        $ano = $temp->getAttribute('anoInicio') . "-" . $temp->getAttribute('anoFin');
        $resultado[$ano] = [
            "plantillas" => extraerPlantillas($temp),
            "jornadas"   => extraerJornadas($temp)
        ];
    }
    return $resultado;
}

function extraerPlantillas($tempNode) {
    $plantillas = [];
    foreach ($tempNode->getElementsByTagName('equipo') as $equipo) {
        $eqId = $equipo->getAttribute('ref');
        $jugadores = [];
        foreach ($equipo->getElementsByTagName('jugador') as $jug) {
            $jugadores[] = [
                "id" => $jug->getAttribute('ref'),
                "d"  => $jug->getAttribute('dorsal')
            ];
        }
        $plantillas[$eqId] = $jugadores;
    }
    return $plantillas;
}

function extraerUltimaTemporada($xml) {
    $temporadas = $xml->getElementsByTagName('temporada');
    if ($temporadas->length === 0) return [];

    // Obtenemos la última temporada del archivo XML
    $ultimaTemp = $temporadas->item($temporadas->length - 1);
    
    $ano = $ultimaTemp->getAttribute('anoInicio') . "-" . $ultimaTemp->getAttribute('anoFin');
    
    return [
        $ano => [
            "plantillas" => extraerPlantillas($ultimaTemp),
            "jornadas"   => extraerJornadas($ultimaTemp)
        ]
    ];
}

function extraerJornadas($tempNode) {
    $jornadasOut = [];
    foreach ($tempNode->getElementsByTagName('jornada') as $idx => $jornada) {
        $partidos = [];
        foreach ($jornada->getElementsByTagName('partido') as $p) {
            $pLocNode = $p->getElementsByTagName('puntosLocal')->item(0);
            $pVisNode = $p->getElementsByTagName('puntosVisitante')->item(0);
            
            $pLoc = $pLocNode ? $pLocNode->nodeValue : "";
            $pVis = $pVisNode ? $pVisNode->nodeValue : "";

            $partidos[] = [
                "el" => $p->getElementsByTagName('equipoLocal')->item(0)->getAttribute('ref'),
                "ev" => $p->getElementsByTagName('equipoVisitante')->item(0)->getAttribute('ref'),
                "res" => ($pLoc !== "") ? "$pLoc-$pVis" : "Pendiente"
            ];
        }
        $jornadasOut["J" . ($idx + 1)] = $partidos;
    }
    return $jornadasOut;
}

$xml = cargarXML($xmlFilePath);

if (!$xml) {
    ob_clean();
    echo json_encode(['error' => 'No se pudo cargar el archivo XML']);
    exit;
}

/* No se recomienda usar esta version si los recursos del sistema son limitados
$baseDeDatos = [
    "identidades" => [
        "equipos"   => extraerMapa($xml, 'equipo', 'id', 'nombreEquipo'),
        "jugadores" => extraerMapa($xml, 'jugador', 'id', 'nombreJugador')
    ],
    "temporada" => extraerTemporadasCompletas($xml)
];

*/

$baseDeDatos = [
    "identidades" => [
        "equipos"   => extraerMapa($xml, 'equipo', 'id', 'nombreEquipo'),
        "jugadores" => extraerMapa($xml, 'jugador', 'id', 'nombreJugador')
    ],
    "temporada" => extraerUltimaTemporada($xml)
];


// Limpiar cualquier buffer (espacios en blanco) y soltar el JSON
ob_clean();
echo json_encode($baseDeDatos, JSON_UNESCAPED_UNICODE);
exit;