<?php
    // Si la sesión no existe, $rol será 'invitado' y NO lanzará error.
    $rol = $_SESSION['usuario_rol'] ?? 'invitado';

    // Si no es admin, usamos JavaScript para redirigir.
    // Por qué JavaScript? Porque los headers de PHP ya se enviaron en index.php y lanzaria un error
    if (strtolower($rol) !== "admin") {
        echo "<script>window.location.href='./?inicio';</script>";
        exit;
    }

    // 3. Si llega aquí, es admin. Cargamos datos.
    $xml = new DOMDocument();
    $xml->load('./data/datos.xml');    
    $xpath = new DOMXPath($xml);
    
    // XPath corregido según tu estructura de datos.xml
    $usuarios = $xpath->query('/federacion/usuarios');
?>

<section class="admin-panel">
    <h1>Listado de usuarios:</h1>
    <?php
        $xsl = new DOMDocument();
        $xsl->load('./templates/xsl/users.xsl');

        $proc = new XSLTProcessor();
        $proc->importStylesheet($xsl);
        
        // Pasamos el $xml completo para que el XSLT tenga el contexto raíz
        echo $proc->transformToXml($xml);
    ?>
</section>