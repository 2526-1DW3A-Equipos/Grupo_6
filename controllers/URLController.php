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
            'clasificacion' => 'view/clasificacion.php',
            'calendario'    => 'view/calendario.php',
            'resultados'    => 'view/resultados.php',
            'equipos'       => 'view/equipos.php',
            'jugadores'     => 'view/jugadores.php',
            'informacion'   => 'view/informacion.html',
            'login'         => 'view/login.html',
        ];

        if(array_key_exists($pagina, $rutas)){
            $archivo = $rutas[$pagina];
            // Pasamos el título a la vista por si acaso lo usa dentro
            $titulo = ucfirst($pagina); 
            $this->renderizar("./templates/" . $archivo, $titulo);
        } else {
            $this->error404();
        }
    }

    private function renderizar($rutaCompleta, $titulo) {
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