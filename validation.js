var Helpers, Logic, Promise, _, needle;

Promise = require('bluebird');

needle = Promise.promisifyAll(require('needle'));

_ = require('lodash');

Helpers = {
  SearchFromPage: function(query) {
    return needle.getAsync(this.page).get('body');
  },
  SearchWithParam: function(query) {
    var object, requestType;
    requestType = this.page.type || 'get';
    object = {};
    object[this.page.param] = query;
    return needle.requestAsync(requestType, this.page.url, object).get('body');
  }
};

Logic = {
  ValidateProvider: function(provider) {
    provider._methods = {};
    if ((provider.name == null) || provider.name === '') {
      throw new Errors.SearchProviderFormatError(provider, 'No name specified for provider');
    }
    if ((provider.search == null) || provider.search === null) {
      throw new Errors.SearchProviderFormatError(provider, 'No search function/string specified.');
    }
    if ((provider.search.page == null) || (provider.search.list == null) || (provider.search.row == null)) {
      throw new Errors.SearchProviderFormatError(provider, 'No search selectors specified.');
    }
    if ((provider.search.row.name == null) || (provider.search.row.url == null)) {
      throw new Errors.SearchProviderFormatError(provider, "Search selectors must expose 'name' and 'url' as properties");
    }
    if (typeof provider.search.page === 'function') {
      provider._methods.search = provider.search.page;
    } else if (typeof provider.search.page === 'string') {
      provider._methods.search = _.bind(Helpers.SearchFromPage, provider.search);
    } else if (typeof provider.search.page === 'object') {
      provider._methods.search = _.bind(Helpers.SearchWithParam, provider.search);
    }
    if ((provider.series.list == null) || (provider.series.row == null)) {
      throw new Errors.SearchProviderFormatError(provider, 'No series selectors specified.');
    }
    if ((provider.series.row.name == null) || (provider.series.row.url == null)) {
      throw new Errors.SearchProviderFormatError(provider, "Series selectors must expose 'name' and 'url' as properties");
    }
    if ((provider.episode == null) || typeof provider.episode !== 'function') {
      throw new Errors.SearchProviderFormatError(provider, "Provider must expose 'episode' function to parse video URLs");
    }
    return true;
  }
};

module.exports = {
  Helpers: Helpers,
  Logic: Logic
};
