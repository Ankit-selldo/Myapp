(() => {
  // app/javascript/late-registration.js
  var application = window.Stimulus;
  if (window.Avo.configuration.stimulus_controllers) {
    window.Avo.configuration.stimulus_controllers.forEach(([name, controller]) => {
      application.register(name, window[controller]);
    });
  }
})();
//# sourceMappingURL=/assets/late-registration-aacf5a3a.js.map
