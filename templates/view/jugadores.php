<?php
function transformarXSL($filtro = "") {
    $xml = new DOMDocument();
    $xml->load("./liga/liga/datos/datos-liga.xml");

    $xsl = new DOMDocument();
    $xsl->load("./templates/xsl/jugadores.xsl");

    $proc = new XSLTProcessor();
    $proc->importStylesheet($xsl);

    return $proc->transformToXml($xml);
}
?>

<section id="pagina-jugadores">
    <nav>
        <input type="text" id="search_bar" placeholder="Buscar nombre...">
        <input type="text" id="search_bar_lastname" placeholder="Buscar apellido...">
    </nav>
    <article id="lista-jugadores-container">
        <?php echo transformarXSL(); ?>
    </article>
</section>

<script src="./utils/handle_name_search_bar.js"></script>