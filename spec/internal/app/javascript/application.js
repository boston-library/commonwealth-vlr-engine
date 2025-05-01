// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// import "jquery"
// import jquery from "jquery"
// import jQuery from "jquery"
// window.jQuery = jQuery
// window.$ = jQuery
// import * as jQuery from "jquery"

import * as bootstrap from "bootstrap"
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from "blacklight"

import BlacklightRangeLimit from "blacklight-range-limit";
BlacklightRangeLimit.init({onLoadHandler: Blacklight.onLoad });

import "openseadragon"
import "openseadragon-rails"

import "@fortawesome/fontawesome-free"
