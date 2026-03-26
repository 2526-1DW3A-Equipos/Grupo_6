<?php
class URLController {
    // Nueva función para obtener solo el nombre de la página
    public function getPaginaActual() {
        $pagina = array_keys($_GET)[0] ?? 'inicio';
        return ucfirst($pagina);
    }

    public function init(){
        $pagina = array_keys($_GET)[0] ?? 'inicio';

        $rutas = [
            'inicio'        => 'view/inicio.html',
            'clasificacion' => 'view/liga.php',
            'calendario'    => 'view/liga.php',
            'resultados'    => 'view/liga.php',
            'equipos'       => 'view/liga.php',
            'jugadores'     => 'view/liga.php',
            'informacion'   => 'view/informacion.html',
            'soporte'       => 'view/soporte.html',
            'pl_admin'      => 'view/panel_admin.php'   
        ];

        if(array_key_exists($pagina, $rutas)){
            $archivo = $rutas[$pagina];
            // Pasamos el título a la vista por si acaso lo usa dentro
            $titulo = ucfirst($pagina); 
            $this->renderizar("./templates/" . $archivo, $titulo, $pagina);
        } else {
            $this->error404();
        }
    }



    private function renderizar($rutaCompleta, $titulo, $ruta = null) {
        if (file_exists($rutaCompleta)) {
            include $rutaCompleta;
        } else {
            $this->error404();
        }
    }

    private function error404() {
        http_response_code(404);
        include './templates/view/404.html';
    }
}