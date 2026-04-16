window.addEventListener('DOMContentLoaded', () => {
    const fullPath = window.location.pathname;
    const ultimoSegmento = fullPath.substring(fullPath.lastIndexOf("/") + 1);
    /*Los parametros de las query strings ?clasificacion... no se tiene encuenta
        entonces si hay algo esque la ruta esta mal    
    */
    if (ultimoSegmento !== "" && !== "index.php") {
        console.error("Detectada ruta 'fantasma' sin parámetro (?):", ultimoSegmento);

        // Obtenemos la base (todo hasta la última barra) para volver atrás
        const baseDir = fullPath.substring(0, fullPath.lastIndexOf("/") + 1);
        window.location.href = baseDir + "?404";
    }
});
