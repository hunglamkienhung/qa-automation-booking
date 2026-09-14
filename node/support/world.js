'use strict';

// Wire the shared Cucumber harness to this domain. The World is the core
// Recorder plus the slots this domain's steps fill: the mini-stay DB, an HTTP
// response, and the screen for one of the app pages.
require('@portfolio/core/harness/cucumber').install({
  browserTag: '@fe',
  viewport: { width: 1440, height: 900 },
  extendWorld(world) {
    world.store = null;    // rows read from the mini-stay SQLite
    world.quote = null;    // a stay just priced
    world.booking = null;  // a booking just held / acted on
    world.api = null;      // an HTTP response (mini-stay or the live Frankfurter)
    world.screen = {};     // values read off an app page
  },
});
