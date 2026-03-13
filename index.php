<?php 
  require_once './controllers/URLController.php';
  $controller = new URLController();
  // Obtenemos el título antes de que empiece el HTML
  $tituloPagina = $controller->getPaginaActual(); 
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
      Prima League - 
      <?php echo $tituloPagina; ?>
    </title>

    <!-- Importamos fuentes de google -->
    <link
      href="https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,100..900;1,100..900&family=Rajdhani:wght@300;400;500;600;700&display=swap"
      rel="stylesheet"
    />
    <link rel="icon" href="assets/img/prima-league-logo-transparente.png" />

    <!-- Estilos -->
    <link rel="stylesheet" href="./css/app.css" />
    <link rel="stylesheet" href="./css/global.css" />
    <link rel="stylesheet" href="./css/inicio.css" />
    <link rel="stylesheet" href="./css/clasificacion.css" />
    <link rel="stylesheet" href="./css/calendario.css" />
    <link rel="stylesheet" href="./css/resultados.css" />
    <link rel="stylesheet" href="./css/equipos.css" />
    <link rel="stylesheet" href="./css/jugadores.css" />
    <link rel="stylesheet" href="./css/informacion.css" />



</head>
<body>
      <header id="header" class="cabecera">
      <a href="#" class="cabeceraLogo" data-page="inicio">
        <img
          class="cabeceraLogoImg"
          src="assets/img/prima-league-logo-transparente.png"
          alt="Prima League"
        />
      </a>
      <input type="checkbox" id="menulateral-check" />
      <label for="menulateral-check" class="abrir-menulateral">
        <img src="assets/img/iconos/menu.svg" />
      </label>
      <nav class="cabeceraNav">
        <ul>
          <label for="menulateral-check" class="cerrar-menulateral">
            <img src="assets/img/iconos/cross.svg" />
          </label>
          <li>
            <a class="menuItem" href="?inicio" data-page="inicio">Inicio</a>
          </li>
          <li>
            <a class="menuItem" href="?clasificacion" data-page="clasificacion">Clasificacion</a>
          </li>
          <li>
            <a class="menuItem" href="?calendario" data-page="calendario">Calendario</a>
          </li>
          <li>
            <a class="menuItem" href="?resultados" data-page="resultados">Resultados</a>
          </li>
          <li>
            <a class="menuItem" href="?equipos" data-page="equipos">Equipos</a>
          </li>
          <li>
            <a class="menuItem" href="?jugadores" data-page="jugadores">Jugadores</a>
          </li>
          <li>
            <a class="menuItem" href="?informacion" data-page="informacion">Informacion</a>
          </li>
          <li>
            <label for="contacto-check" class="abrir-contacto">
              <a class="cabeceraCnt">Contacto</a>
            </label>
          </li>
        </ul>
      </nav>
    </header>
    <main>
        <?php
            $controller->init();
        ?>
    </main>
    <footer>
      <!-- Zona alta del footer -->
      <nav class="footerNav">
        <ul>
          <li>
            <a id="botonArriba" href="" target="_top">Volver arriba</a>
          </li>
          <li>
            <a>Politicas de privacidad</a>
          </li>
          <li>
            <a>Aviso legal</a>
          </li>
          <li>
            <a>Politica de cookies</a>
          </li>
        </ul>

        <p class="footerCopy">
          Copyright &copy; 2025 | Prima League. Desarrollado por Grupo 6
        </p>
      </nav>
      <hr />

      <!-- Zona baja del footer -->
      <nav class="footerNav">
        <ul>
          <li>
            <a href="#" data-page="inicio">Inicio</a>
          </li>
          <li>
            <a href="#" data-page="clasificacion">Clasificacion</a>
          </li>
          <li>
            <a href="#" data-page="calendario">Calendario</a>
          </li>
          <li>
            <a href="#" data-page="equipos">Equipos</a>
          </li>
          <li>
            <a href="#" data-page="jugadores">Jugadores</a>
          </li>
          <li>
            <a href="#" data-page="resultados">Resultados</a>
          </li>
          <li>
            <a href="#" data-page="informacion">Informacion</a>
          </li>
        </ul>
        <!-- Lista de Redes Sociales -->
        <ul class="footerRRSS">
          <li>
            <a>
              <img loading="lazy"
                src="assets/img/redes_sociales/instagram_logo.png"
                alt="Instagram"
              />
            </a>
          </li>
          <li>
            <a>
              <img loading="lazy"
                src="assets/img/redes_sociales/facebook_logo.png"
                alt="Facebook"
              />
            </a>
          </li>
          <li>
            <a>
              <img loading="lazy"
                src="assets/img/redes_sociales/linkedin_logo.png"
                alt="LinkedIn"
              />
            </a>
          </li>
          <li>
            <a>
              <img loading="lazy" src="assets/img/redes_sociales/x_logo.png" alt="X" />
            </a>
          </li>
          <li>
            <a>
              <img loading="lazy"
                src="assets/img/redes_sociales/tiktok_logo.png"
                alt="Icono de la red social TikTok"
              />
            </a>
          </li>
        </ul>
      </nav>
    </footer>
</body>
</html>