# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# jquery is needed for blacklight-gallery masonry view
# pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"
# pin 'jquery', to: 'https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.js'
pin 'jquery', to: 'https://code.jquery.com/jquery-3.7.1.min.js'
pin "bootstrap", to: "bootstrap.min.js"
pin "@github/auto-complete-element", to: "https://cdn.skypack.dev/@github/auto-complete-element"
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.6/dist/umd/popper.min.js"
# pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.3.3/dist/js/bootstrap.js"
# chart.js is dependency of blacklight-range-limit, currently is not working
# as vendored importmaps, but instead must be pinned to CDN. You may want to update
# versions perioidically.
pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.2.0/dist/chart.js"
# single dependency of chart.js:
pin "@kurkle/color", to: "https://ga.jspm.io/npm:@kurkle/color@0.3.2/dist/color.esm.js"
# The following pin is taken from https://github.com/projectblacklight/blacklight/pull/3502/commits/fea1f9c7d21a6c1a526c4aa488493e50cdf7b074
# This is in order to resolve an issue with the blacklight-gallery plugin and blacklight using blacklight as the module in their importmaps config but calling it blacklight-frontend in their npm config
# We should also pay attention to this issue in blacklight-gallery https://github.com/projectblacklight/blacklight-gallery/issues/202
pin "blacklight-frontend", to: "blacklight/index.js"
# pin "openseadragon", to: 'https://cdn.jsdelivr.net/npm/openseadragon@5.0/build/openseadragon/openseadragon.min.js'
pin "openseadragon"
pin "@fortawesome/fontawesome-free", to: "@fortawesome--fontawesome-free.js"
