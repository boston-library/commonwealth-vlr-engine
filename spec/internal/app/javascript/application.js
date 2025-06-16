// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@popperjs/core"
// import "bootstrap"
import "controllers"

import * as bootstrap from "bootstrap"
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from "blacklight"

import 'jquery'
// universalviewer MUST be after jquery and before blacklight-gallery
import "universalviewer"
import 'blacklight-gallery'

import "openseadragon"
import "openseadragon-rails"

Blacklight.onLoad(function() {
    $('.documents-masonry').BlacklightMasonry();
    $('.documents-slideshow').slideshow();
});

import BlacklightRangeLimit from "blacklight-range-limit";
BlacklightRangeLimit.init({onLoadHandler: Blacklight.onLoad});

import "@fortawesome/fontawesome-free"

import 'commonwealth-vlr-engine'
