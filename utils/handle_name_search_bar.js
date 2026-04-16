const SEARCH_BAR = document.getElementById("search_bar");
const SEARCH_BAR_LASTNAME = document.getElementById("search_bar_lastname");

if (SEARCH_BAR) {
    SEARCH_BAR.addEventListener('input', handleSearchBar);
}

if (SEARCH_BAR_LASTNAME) {
    SEARCH_BAR_LASTNAME.addEventListener('input', handleSearchBar);
}

function handleSearchBar() {
    const nombre = SEARCH_BAR ? SEARCH_BAR.value : "";
    const apellido = SEARCH_BAR_LASTNAME ? SEARCH_BAR_LASTNAME.value : "";
    sendFetch(nombre, apellido);
}

async function sendFetch(nombre, apellido) {
    const url = `${window.location.pathname}?jugadores&ajax=jugadores&nombre_jugador=${encodeURIComponent(nombre)}&apellido_jugador=${encodeURIComponent(apellido)}`;
    try {
        const response = await fetch(url);
        const html = await response.text();

        // Inyectamos el HTML que generó el XSLTProcessor
        document.getElementById("lista-jugadores-container").innerHTML = html;
    } catch (e) { console.error(e); }
}

document.addEventListener('DOMContentLoaded', () => {
    handleSearchBar();
});