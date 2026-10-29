(function ($) {
    "use strict";

    // Standardize the navigation across every page.
    // This keeps the same menu everywhere and makes Sourcing easy to find.
    var currentPage = window.location.pathname.split('/').pop() || 'index.html';
    if (currentPage === '') currentPage = 'index.html';

    var navItems = [
        { href: 'index.html', label: 'Home', page: 'index.html' },
        { href: 'about.html', label: 'About Zuri', page: 'about.html' },
        { href: 'service.html', label: 'Services', page: 'service.html' },
        { href: 'sourcing.html', label: 'Sourcing', page: 'sourcing.html' },
        { href: 'quote.html', label: 'Request a Quote', page: 'quote.html' },
        { href: 'contact.html', label: 'Contact', page: 'contact.html' }
    ];

    var navLinks = navItems.map(function (item) {
        var active = currentPage === item.page ? ' active' : '';
        return '<a href="' + item.href + '" class="nav-item nav-link' + active + '">' + item.label + '</a>';
    }).join('');

    var navbar = document.querySelector('.navbar');
    if (navbar) {
        var collapse = navbar.querySelector('#navbarCollapse');
        if (collapse) {
            var navContainer = collapse.querySelector('.navbar-nav');
            if (navContainer) {
                navContainer.innerHTML = navLinks + '<div class="nav-item d-flex align-items-center px-3" id="language-switcher"><span class="me-2 small">Language</span><div id="google_translate_element"></div></div>';
            }

            var phone = collapse.querySelector('h4');
            if (phone) {
                phone.innerHTML = '<i class="fa fa-headphones text-primary me-3"></i>063 836 6355';
            }

            var login = collapse.querySelector('h6');
            if (login) {
                login.remove();
            }
        }
    }

    // Automatic English/French translation.
    // French-speaking browser visitors are offered French automatically on first visit.
    var browserLanguage = ((navigator.languages && navigator.languages[0]) || navigator.language || 'en').toLowerCase();
    var prefersFrench = browserLanguage.indexOf('fr') === 0;
    var hasTranslationChoice = document.cookie.split(';').some(function (cookie) {
        return cookie.trim().indexOf('googtrans=') === 0;
    });

    if (prefersFrench && !hasTranslationChoice) {
        document.cookie = 'googtrans=/en/fr; path=/; SameSite=Lax';
    }

    window.googleTranslateElementInit = function () {
        if (!document.getElementById('google_translate_element') || !window.google || !google.translate) return;
        new google.translate.TranslateElement({
            pageLanguage: 'en',
            includedLanguages: 'en,fr',
            autoDisplay: false,
            layout: google.translate.TranslateElement.InlineLayout.SIMPLE
        }, 'google_translate_element');
    };

    var translateScript = document.createElement('script');
    translateScript.src = 'https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit';
    translateScript.async = true;
    document.head.appendChild(translateScript);

    // Spinner
    var spinner = function () {
        setTimeout(function () {
            if ($('#spinner').length > 0) {
                $('#spinner').removeClass('show');
            }
        }, 1);
    };
    spinner();

    // Initiate the wowjs
    new WOW().init();

    // Sticky Navbar
    $(window).scroll(function () {
        if ($(this).scrollTop() > 300) {
            $('.sticky-top').css('top', '0px');
        } else {
            $('.sticky-top').css('top', '-100px');
        }
    });

    // Dropdown on mouse hover
    const $dropdown = $(".dropdown");
    const $dropdownToggle = $(".dropdown-toggle");
    const $dropdownMenu = $(".dropdown-menu");
    const showClass = "show";

    $(window).on("load resize", function() {
        if (this.matchMedia("(min-width: 992px)").matches) {
            $dropdown.hover(
            function() {
                const $this = $(this);
                $this.addClass(showClass);
                $this.find($dropdownToggle).attr("aria-expanded", "true");
                $this.find($dropdownMenu).addClass(showClass);
            },
            function() {
                const $this = $(this);
                $this.removeClass(showClass);
                $this.find($dropdownToggle).attr("aria-expanded", "false");
                $this.find($dropdownMenu).removeClass(showClass);
            }
            );
        } else {
            $dropdown.off("mouseenter mouseleave");
        }
    });

    // Back to top button
    $(window).scroll(function () {
        if ($(this).scrollTop() > 300) {
            $('.back-to-top').fadeIn('slow');
        } else {
            $('.back-to-top').fadeOut('slow');
        }
    });
    $('.back-to-top').click(function () {
        $('html, body').animate({scrollTop: 0}, 1500, 'easeInOutExpo');
        return false;
    });

    // Facts counter
    $('[data-toggle="counter-up"]').counterUp({
        delay: 10,
        time: 2000
    });

    // Header carousel
    $(".header-carousel").owlCarousel({
        autoplay: false,
        smartSpeed: 1500,
        items: 1,
        dots: false,
        loop: true,
        nav : true,
        navText : [
            '<i class="bi bi-chevron-left"></i>',
            '<i class="bi bi-chevron-right"></i>'
        ]
    });

    // Testimonials carousel
    $(".testimonial-carousel").owlCarousel({
        autoplay: false,
        smartSpeed: 1000,
        center: true,
        dots: true,
        loop: true,
        responsive: {
            0:{ items:1 },
            768:{ items:2 },
            992:{ items:3 }
        }
    });

})(jQuery);
