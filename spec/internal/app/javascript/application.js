// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@popperjs/core"
// import "bootstrap"
import "jquery"
import "controllers"

import * as bootstrap from "bootstrap"
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from "blacklight"

import BlacklightRangeLimit from "blacklight-range-limit";
BlacklightRangeLimit.init({onLoadHandler: Blacklight.onLoad});

import 'blacklight-gallery'

import 'commonwealth-vlr-engine'

import "openseadragon"
import "openseadragon-rails"

import "@fortawesome/fontawesome-free"
