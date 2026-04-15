<?php

session_start();

require_once __DIR__ . '/utils/temporada_selector.php';

// Compatibilidad con sesiones antiguas: migramos array a variables separadas.
if (isset($_SESSION['usuario']) && is_array($_SESSION['usuario'])) {
  $_SESSION['usuario_nombre'] = $_SESSION['usuario']['username'] ?? ($_SESSION['usuario_nombre'] ?? '');
  $_SESSION['usuario_rol'] = $_SESSION['usuario']['rol'] ?? ($_SESSION['usuario_rol'] ?? 'invitado');
  unset($_SESSION['usuario']);
}

$isLogged = !empty($_SESSION['usuario_nombre']);
$isAdmin = ($isLogged && strtolower($_SESSION['usuario_rol'] ?? '') === 'admin');

if (isset($_GET['logout'])) {
  session_destroy();
  header("Location: ./");
  exit;
}

// ----- INICIO DE SESION -----
$login_error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['email']) && isset($_POST['password'])) {
  $email_post = $_POST['email'];
  $pass_post = $_POST['password'];

  // Load XML
  $xml_path = './data/datos.xml';
  if (file_exists($xml_path)) {
    $xml = simplexml_load_file($xml_path);
    $login_success = false;
    
    // Check credentials
    if (isset($xml->usuarios->usuario)) {
      foreach ($xml->usuarios->usuario as $user) {
        $u_name = (string)$user->user;
        $u_pass = (string)$user->pass;
        if ($u_name === $email_post && $u_pass === $pass_post) {
          $_SESSION['usuario_nombre'] = $u_name;
          $_SESSION['usuario_rol'] = (string)$user->rol;

          $isAdmin = (strtolower($_SESSION['usuario_rol']) === 'admin');

          if($isAdmin){
            header("Location: ./?pl_admin");
          } else{
            header("Location: ./");
          }
            $login_success = true;
            $isLogged = true;
            exit;
        }
      }
    }
    if (!$login_success) {
      $login_error = 'Usuario o contraseña incorrectos.';
    }
  } else {
    $login_error = 'Error interno: no se encuentra el archivo de datos.';
  }
}

require_once __DIR__ . '/controllers/URLController.php';
$controller = new URLController();
$tituloPagina = $controller->getPaginaActual();
$pagina = array_keys($_GET)[0] ?? 'inicio';

$paginasConTemporada = ['clasificacion', 'calendario', 'resultados', 'equipos'];
$mostrarTemporadaHeader = in_array($pagina, $paginasConTemporada, true);
$temporadaContextoHeader = null;
$equipoSeleccionadoHeader = '';
$rutaSeguraHeader = preg_replace('/[^a-z]/', '', $pagina);
$tituloLigaHeader = '';
$subtituloLigaHeader = '';

if ($mostrarTemporadaHeader) {
  $temporadaContextoHeader = obtenerContextoTemporada('./data/datos.xml');
  if ($rutaSeguraHeader === 'equipos' && !empty($_GET['eq']) && preg_match('/^E\d+$/', $_GET['eq'])) {
    $equipoSeleccionadoHeader = $_GET['eq'];
  }

  $queryTempHeader = $temporadaContextoHeader['xpath']->query(
    "/federacion/temporadas/temporada[@anoInicio='" . $temporadaContextoHeader['seleccionada'] . "']"
  );
  if ($queryTempHeader->length > 0) {
    $anioFinHeader = $queryTempHeader->item(0)->getAttribute('anoFin');
    $tituloLigaHeader = ucfirst($rutaSeguraHeader);
    $subtituloLigaHeader = 'Temporada ' . $temporadaContextoHeader['seleccionada'] . ' - ' . $anioFinHeader;
  }
}
?>

<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>
    Prima League -
    <?php echo ucfirst($tituloPagina); ?>
  </title>

  <link rel="icon" href="assets/img/prima-league-logo-transparente.png" />

  <!-- Estilos -->
  <link rel="stylesheet" href="./css/global.css" />

</head>

<body>
  <header id="header" class="cabecera">
    <a href="?inicio" class="cabeceraLogo" data-page="inicio">
      <img
        class="cabeceraLogoImg"
        src="assets/img/prima-league-logo-transparente.png"
        alt="Prima League" />
    </a>

    <?php if ($mostrarTemporadaHeader && $tituloLigaHeader !== '' && $subtituloLigaHeader !== ''): ?>
      <div class="header-info-slot">
        <h1><?php echo htmlspecialchars($tituloLigaHeader, ENT_QUOTES, 'UTF-8'); ?></h1>
        <h2><?php echo htmlspecialchars($subtituloLigaHeader, ENT_QUOTES, 'UTF-8'); ?></h2>
      </div>
    <?php endif; ?>

    <?php if ($mostrarTemporadaHeader && $temporadaContextoHeader !== null): ?>
      <div class="header-temporada-slot">
        <?php
          echo renderSelectorTemporada(
            $rutaSeguraHeader,
            $temporadaContextoHeader['temporadas'],
            $temporadaContextoHeader['seleccionada'],
            $equipoSeleccionadoHeader
          );
        ?>
      </div>
    <?php endif; ?>

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
          <a class="menuItem 
              <?php if (isset($pagina) && $pagina === 'inicio')
                echo 'isActive';
              ?>" href="?inicio" data-page="inicio">Inicio</a>
        </li>
        <li>
          <a class="menuItem 
              <?php if (isset($pagina) && $pagina === 'clasificacion')
                echo 'isActive';
              ?>" href="?clasificacion" data-page="clasificacion">Clasificacion</a>
        </li>
        <li>
          <a class="menuItem 
            <?php if (isset($pagina) && $pagina === 'calendario')
              echo 'isActive';
            ?>" href="?calendario" data-page="calendario">Calendario</a>
        </li>
        <li>
          <a class="menuItem 
            <?php if (isset($pagina) && $pagina === 'resultados')
              echo 'isActive';
            ?>" href="?resultados" data-page="resultados">Resultados</a>
        </li>
        <li>
          <a class="menuItem 
            <?php if (isset($pagina) && $pagina === 'equipos')
              echo 'isActive';
            ?>" href="?equipos" data-page="equipos">Equipos</a>
        </li>

        <li>
          <?php if($isLogged):?>
              <?php if($isAdmin): ?>
                <li>
                    <a class="menuItem <?php echo ($pagina === 'pl_admin') ? 'isActive' : ''; ?>" 
                      href="?pl_admin">Panel Admin</a>
                </li>
    
            <?php endif; ?>
            
            <span class="profile-info">
              <p class="profile-username"><?php echo ucfirst(explode('@', $_SESSION['usuario_nombre'])[0]); ?></p>
              <p class="profile-role"><?php echo 'Rol: ' . ucfirst(explode('@', $_SESSION['usuario_rol'])[0]); ?></p>
            </span>

             <li>
              <a class="logout-icon" href="?logout=1"><img src="assets/img/iconos/logout.png" alt="X" /></a>
            </li>

          <?php else: ?>
            <label for="contacto-check" class="abrir-contacto">
            <a class="cabeceraCnt">Iniciar Sesión</a>
            </label>            
          <?php endif; ?>
        </li>
      </ul>
    </nav>
  </header>
  <main>

    <!-- Dialogo de login -->
    <?php if (!$isLogged): ?>
      <input type="checkbox" id="contacto-check" />
      <dialog class="overlayContacto">
        <div class="contacto">
          <label for="contacto-check" class="btnCerrarContacto" aria-label="Cerrar">
            <svg viewBox="0 0 24 24" fill="none" class="iconoCerrar" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18"></line>
              <line x1="6" y1="6" x2="18" y2="18"></line>
            </svg>
          </label>
          <div class="contacto-header">
            <img src="assets/img/prima-league-logo-transparente.png" alt="Logo Prima League" class="contacto-logo" />
            <h1>Iniciar sesión</h1>
            <p>Accede con tu cuenta</p>
          </div>
          <form
            class="formContacto"
            action="index.php?"
            method="post">
            <?php if (!empty($login_error)): ?>
              <div class="login-error">
                <?php echo $login_error; ?>
              </div>
            <?php
            endif; ?>
            <div class="input-group">
              <label for="login_email">Usuario</label>
              <input required type="text" id="login_email" name="email" placeholder="Usuario" />
            </div>

            <div class="input-group">
              <label for="login_pass">Contraseña</label>
              <div class="password-input-wrapper">
                <input required type="password" id="login_pass" name="password" placeholder="••••••••" />
                <span id="togglePassword" class="password-toggle" title="Mostrar contraseña">
                  <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                    <circle cx="12" cy="12" r="3"></circle>
                  </svg>
                </span>
              </div>
            </div>

            <div class="opciones-login">
              <label class="remember-me">
                <input type="checkbox" name="remember" />
                <span class="checkmark"></span>
                Mantener sesión
              </label>
              <a href="?soporte" class="link-recuperar">¿Olvidaste tu contraseña?</a>
            </div>

            <div class="contacto-footer">
              <button type="submit" class="boton btn-primary">Entrar a mi cuenta</button>
            </div>

            <p class="registro-text">¿No tienes cuenta? <a href="?soporte">Regístrate ahora</a></p>
          </form>
        </div>
      </dialog>
    <?php
    endif; ?>

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
          <a href="?soporte">Soporte</a>
        </li>
      </ul>

      <p class="footerCopy">
        Copyright &copy; 2026 | Prima League. Desarrollado por Grupo 6
      </p>
    </nav>
    <hr />

    <!-- Zona baja del footer -->
    <nav class="footerNav">
      <ul>
        <li>
          <a href="?inicio" data-page="inicio">Inicio</a>
        </li>
        <li>
          <a href="?clasificacion" data-page="clasificacion">Clasificacion</a>
        </li>
        <li>
          <a href="?calendario" data-page="calendario">Calendario</a>
        </li>
        <li>
          <a href="?resultados" data-page="resultados">Resultados</a>
        </li>
        <li>
          <a href="?equipos" data-page="equipos">Equipos</a>
        </li>
      </ul>
      <!-- Lista de Redes Sociales -->
      <ul class="footerRRSS">
        <li>
          <a>
            <img loading="lazy"
              src="assets/img/redes_sociales/instagram_logo.png"
              alt="Instagram" />
          </a>
        </li>
        <li>
          <a>
            <img loading="lazy"
              src="assets/img/redes_sociales/facebook_logo.png"
              alt="Facebook" />
          </a>
        </li>
        <li>
          <a>
            <img loading="lazy"
              src="assets/img/redes_sociales/linkedin_logo.png"
              alt="LinkedIn" />
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
              alt="Icono de la red social TikTok" />
          </a>
        </li>
      </ul>
    </nav>
  </footer>


  <!-- Boton Volver Arriba Flotante -->
  <button id="btnScrollUp" class="btn-scroll-up" aria-label="Volver arriba">
    <svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2.5" fill="none" stroke-linecap="round" stroke-linejoin="round">
      <polyline points="18 15 12 9 6 15"></polyline>
    </svg>
  </button>
  <!-- Script para Toggle Password y Modales -->
  <script>
    document.addEventListener("DOMContentLoaded", function() {
      // Toggle ojito
      const togglePassword = document.getElementById('togglePassword');
      const passwordInput = document.getElementById('login_pass');

      if (togglePassword && passwordInput) {
        togglePassword.addEventListener('click', function() {
          const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
          passwordInput.setAttribute('type', type);

          // Cambiar icono
          if (type === 'text') {
            this.innerHTML = '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>';
            this.style.color = "var(--naranja)";
          } else {
            this.innerHTML = '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>';
            this.style.color = "rgba(255,255,255,0.6)";
          }
        });
      }

      // Mantener modal abierto si hay error de login
      <?php if (!empty($login_error)): ?>
        var chk = document.getElementById('contacto-check');
        if (chk) chk.checked = true;
      <?php
      endif; ?>
      // Logica para Boton Volver a Arriba Flotante
      const btnScrollUp = document.getElementById('btnScrollUp');
      if (btnScrollUp) {
        window.addEventListener('scroll', () => {
          // Aparece si bajamos mas de 300px
          if (window.scrollY > 300) {
            btnScrollUp.classList.add('show');
          } else {
            btnScrollUp.classList.remove('show');
          }
        });

        btnScrollUp.addEventListener('click', () => {
          window.scrollTo({
            top: 0,
            behavior: 'smooth'
          });
        });
      }

    });
  </script>
</body>

</html>