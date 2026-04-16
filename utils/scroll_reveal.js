(function () {
    function getDirection(pattern, index, isMobile, mobileDirection) {
        if (isMobile && mobileDirection) {
            return mobileDirection;
        }

        if (pattern === 'alternate') {
            return index % 2 === 0 ? 'left' : 'right';
        }

        return pattern;
    }

    function tagElements(config, isMobile) {
        var nodes = document.querySelectorAll(config.selector);
        if (!nodes.length) {
            return [];
        }

        return Array.prototype.map.call(nodes, function (node, index) {
            var direction = getDirection(config.pattern, index, isMobile, config.mobileDirection);
            var delayMs = (config.baseDelay || 0) + index * (config.stagger || 0);

            node.classList.add('reveal-on-scroll');
            node.classList.add('reveal-' + direction);
            node.style.setProperty('--reveal-delay', delayMs + 'ms');
            return node;
        });
    }

    function initScrollReveal() {
        var prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        var isMobile = window.matchMedia('(max-width: 880px)').matches;

        var configs = [
            {
                selector: '.contenedor-calendario .tabla-resultados .jornada',
                pattern: 'alternate',
                mobileDirection: 'left',
                stagger: 40
            },
            {
                selector: '.contenedor-calendario .tabla-resultados .jornadaPartido, .contenedor-calendario .tabla-resultados .partido',
                pattern: 'up',
                mobileDirection: 'up',
                stagger: 20
            },
            {
                selector: '.tabla-equipos .equipo-container',
                pattern: 'alternate',
                mobileDirection: 'up',
                stagger: 35
            },
            {
                selector: '.jugadores-grid .jugador-card-cuadrada, #lista-jugadores-container .jugadores-card',
                pattern: 'up',
                mobileDirection: 'up',
                stagger: 18
            },
            {
                selector: '.infoContenido .noticia',
                pattern: 'alternate',
                mobileDirection: 'up',
                stagger: 30
            }
        ];

        var elements = [];
        configs.forEach(function (config) {
            elements = elements.concat(tagElements(config, isMobile));
        });

        if (!elements.length) {
            return;
        }

        if (prefersReducedMotion || !('IntersectionObserver' in window)) {
            elements.forEach(function (el) {
                el.classList.add('is-visible');
            });
            return;
        }

        var observer = new window.IntersectionObserver(
            function (entries) {
                entries.forEach(function (entry) {
                    if (!entry.isIntersecting) {
                        return;
                    }
                    entry.target.classList.add('is-visible');
                    observer.unobserve(entry.target);
                });
            },
            {
                threshold: 0.2,
                rootMargin: '0px 0px -8% 0px'
            }
        );

        elements.forEach(function (el) {
            observer.observe(el);
        });
    }

    document.addEventListener('DOMContentLoaded', initScrollReveal);
})();
