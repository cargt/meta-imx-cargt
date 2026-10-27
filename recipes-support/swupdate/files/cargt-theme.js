/*
 * Cargt SWUpdate web UI: light/dark theme.
 * Loaded synchronously in <head> before the stylesheets so the page never
 * flashes light. Dark is the default; the navbar toggle switches to light and
 * the choice is remembered per browser.
 */
(function () {
  var root = document.documentElement;
  var theme = 'dark';
  try {
    theme = localStorage.getItem('cargt-theme') || 'dark';
  } catch (e) {}
  root.setAttribute('data-bs-theme', theme);

  document.addEventListener('click', function (e) {
    if (!e.target.closest('#cargt-theme-toggle'))
      return;
    var next = root.getAttribute('data-bs-theme') === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-bs-theme', next);
    try {
      localStorage.setItem('cargt-theme', next);
    } catch (e) {}
  });
})();
