Promise = require 'bluebird'
needle = Promise.promisifyAll(require 'needle')
_ = require 'lodash'

Helpers =
  SearchFromPage: (query) ->
    needle.getAsync(this.page).get('body')

  SearchWithParam: (query) ->
    requestType = this.page.type || 'get'
    object = {}; object[this.page.param] = query # Need to use to get param name
    needle.requestAsync(requestType, this.page.url, object).get('body')

  ListFromSearchPage: ($, body) ->
    return $(this.list)

Logic =
  ValidateProvider: (provider) ->
    provider._methods = {}

    if !provider.name? || provider.name == ''
      throw new Errors.SearchProviderFormatError(
        provider, 'No name specified for provider')

    if !provider.search? || provider.search == null
      throw new Errors.SearchProviderFormatError(
        provider, 'No search function/string specified.')

    if !provider.search.page? || !provider.search.list? || !provider.search.row?
      throw new Errors.SearchProviderFormatError(
        provider, 'No search selectors specified.')

    if !provider.search.row.name? || !provider.search.row.url?
      throw new Errors.SearchProviderFormatError(
        provider, "Search selectors must expose 'name' and 'url' as properties")

    # BYO Search Function
    if typeof provider.search.page == 'function'
      provider._methods.search = provider.search.page

    # Entire List Search
    else if typeof provider.search.page == 'string'
      provider._methods.search = _.bind(Helpers.SearchFromPage, provider.search)

    # Custom GET Query
    else if typeof provider.search.page == 'object'
      provider._methods.search = _.bind(
        Helpers.SearchWithParam, provider.search)

    if !provider.series.list? || !provider.series.row?
      throw new Errors.SearchProviderFormatError(
        provider, 'No series selectors specified.')

    # BYO Search Result function
    if typeof provider.search.list == 'function'
      provider._methods.list = provider.search.list

    # jQuery selector specified
    else if typeof provider.search.list == 'string'
      provider._methods.list = _.bind(Helpers.ListFromSearchPage, provider.search)

    if !provider.series.row.name? || !provider.series.row.url?
      throw new Errors.SearchProviderFormatError(
        provider, "Series selectors must expose 'name' and 'url' as properties")

    if !provider.episode? || typeof provider.episode != 'function'
      throw new Errors.SearchProviderFormatError(
        provider, "Provider must expose 'episode' function to parse video URLs")

    return true

module.exports =
  Helpers: Helpers
  Logic: Logic
