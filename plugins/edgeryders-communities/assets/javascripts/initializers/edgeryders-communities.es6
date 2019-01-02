import { withPluginApi } from "discourse/lib/plugin-api";

function initializeEdgerydersCommunities(api) {

  // see app/assets/javascripts/discourse/lib/plugin-api
  // for the functions available via the api object

}

export default {
  name: "edgeryders-communities",

  initialize() {
    withPluginApi("0.8.24", initializeEdgerydersCommunities);
  }
};
