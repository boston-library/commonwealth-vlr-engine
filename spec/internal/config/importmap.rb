# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# jquery is needed for blacklight-gallery masonry view
pin 'jquery', to: 'https://code.jquery.com/jquery-3.7.1.min.js'

# pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.6/dist/umd/popper.min.js"
pin "bootstrap", to: "bootstrap.min.js"
pin "@popperjs/core", to: "popper.js"

pin "@github/auto-complete-element", to: "https://cdn.skypack.dev/@github/auto-complete-element"
# pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.3.3/dist/js/bootstrap.js"

# chart.js is dependency of blacklight-range-limit, currently is not working
# as vendored importmaps, but instead must be pinned to CDN. You may want to update
# versions periodically.
pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.2.0/dist/chart.js"
# single dependency of chart.js:
pin "@kurkle/color", to: "https://ga.jspm.io/npm:@kurkle/color@0.3.2/dist/color.esm.js"

pin "openseadragon"

pin "@fortawesome/fontawesome-free", to: "@fortawesome--fontawesome-free.js"

# TODO: use preload: false and selectively add to page?
pin "universalviewer", to: "https://cdn.jsdelivr.net/npm/universalviewer@4.2.0/dist/esm/index.js"
