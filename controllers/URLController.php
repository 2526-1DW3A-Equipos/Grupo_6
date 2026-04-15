<?php
class URLController {
    private static $rutas = [
        'inicio'        => 'view/inicio.html',
        'clasificacion' => 'view/liga.php',
        'calendario'    => 'view/liga.php',
        'resultados'    => 'view/liga.php',
        'equipos'       => 'view/liga.php',
        'jugadores'     => 'view/jugadores.php',
        'informacion'   => 'view/informacion.html',
        'soporte'       => 'view/soporte.html',
        'pl_admin'      => 'view/panel_admin.php'
    ];

    public static function init(){
        $pagina = self::getPaginaActual();

        if(array_key_exists($pagina, self::$rutas)){
            $archivo = self::$rutas[$pagina];
            // Pasamos el título a la vista por si acaso lo usa dentro
            $titulo = ucfirst($pagina); 
            self::renderizar("./templates/" . $archivo, $titulo, $pagina);
        } else {
            self::error404();
        }
    }

     public static function getPaginaActual() {
        $requestedPage = array_keys($_GET)[0] ?? 'inicio';
        
        if(self::isValidUrl()){
            return $requestedPage;
        }

        $BASEPATH = self::getBaseUriPath();
        header("Location: {$BASEPATH}?404");
        exit;  
    }

    /*
    * Esta funcion es una funcion auxiliar para controlar los casos
    * en los que un usuario por ejemplo quiere ir ala ruta /asdadsasd, 
    * en ese caso deberia de ir ala direccion 404
    */
    private static function isValidUrl(){
        // Obtenermos la url solicitada
        $uri = $_SERVER['REQUEST_URI'];
        // Quitar query string ?inicio...
        $path = parse_url($uri, PHP_URL_PATH);
        // Separar partes
        $partes = explode('/', trim($path, '/'));
        // Obtener lo que va después del primer segmento (lo que va despues de Grupo6/...)
        $resultado = $partes[1] ?? '';

        // caso especial para que se pueda usar /equipos
        if(array_key_exists($resultado, self::$rutas)){
           self::redireccionEspecial($resultado);
           return true;
        }

        if ($resultado !== "" && $resultado !== "index.php") {
            return false;
        } else {
            return true;
        }
    }

    private static function redireccionEspecial($pagina){
        $BASEPATH = self::getBaseUriPath();
        header("Location: {$BASEPATH}?{$pagina}");
        exit;
    }

    /*
        Esta funcion se encarga de retornarnos la ruta
        base del sitio web (por defecto /Grupo_6)
    */
    private static function getBaseUriPath(){
        $uri = $_SERVER['REQUEST_URI'];
        $path = parse_url($uri, PHP_URL_PATH);
        $partes = explode('/', trim($path, '/'));
        return '/' . ($partes[0] ?? '') . '/';
    }

    private static function renderizar($rutaCompleta) {
        if (file_exists($rutaCompleta)) {
            include $rutaCompleta;
        } else {
            self::error404();
        }
    }



    private static function error404() {
        http_response_code(404);
        include './templates/view/404.html';
    }
}