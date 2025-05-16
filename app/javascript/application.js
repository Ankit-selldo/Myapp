// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "trix"
import "@rails/actiontext"

// Debug Turbo events
document.addEventListener("turbo:load", () => {
  console.log("Turbo loaded!");
});

document.addEventListener("turbo:before-fetch-request", (event) => {
  console.log("Turbo request starting:", event.detail.url);
});

document.addEventListener("turbo:before-fetch-response", (event) => {
  console.log("Turbo response received:", event.detail.url);
});

document.addEventListener("turbo:submit-start", (event) => {
  console.log("Form submission starting:", event.target.action);
  console.log("Form data:", new FormData(event.target));
});

document.addEventListener("turbo:submit-end", (event) => {
  console.log("Form submission completed:", event.detail);
});

document.addEventListener("turbo:before-cache", () => {
  console.log("Page about to be cached");
});

document.addEventListener("turbo:before-render", (event) => {
  console.log("About to render response:", event.detail);
});

document.addEventListener("turbo:render", () => {
  console.log("Response rendered");
});
