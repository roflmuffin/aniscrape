Promise = require 'bluebird'
needle = Promise.promisifyAll(require 'needle')
Errors = require '../errors'
_ = require 'lodash'

Methods =
  Search:
    Page:
      string: (str, provider, query) ->
        needle.getAsync(str.page, provider.http_options).get('body')
      object: (obj, provider, query) ->
        requestType = obj.type || 'get'
        param = {}; param[obj.param] = query # Create object with KV-Pair of query
        needle.requestAsync(requestType, obj.url, param, provider.http_options).get('body')

    SearchResult:
      string: (str, provider, $, body) ->
        return $(str)

  Series:
    List:
      string: (str, provider, $, body) ->
        return $(str)

Helpers =
  BindFunction: (methods, param, provider) ->
    if typeof param == 'function'
      bound = param
    else
      bound = _.partial(methods[typeof param], param, provider)
    return Promise.method(bound)

Logic =
  ValidateProvider: (provider) ->
    provider.methods = {}
    provider.http_options = provider.http_options || {}

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

    if !provider.series.list? || !provider.series.row?
      throw new Errors.SearchProviderFormatError(
        provider, 'No series selectors specified.')

    if !provider.series.row.name? || !provider.series.row.url?
      throw new Errors.SearchProviderFormatError(
        provider, "Series selectors must expose 'name' and 'url' as properties")

    if !provider.episode? || typeof provider.episode != 'function'
      throw new Errors.SearchProviderFormatError(
        provider, "Provider must expose 'episode' function to parse video URLs")

    provider.methods.search = Helpers.BindFunction(Methods.Search.Page, provider.search.page, provider)
    provider.methods.list = Helpers.BindFunction(Methods.Search.SearchResult, provider.search.list, provider)
    provider.methods.seriesList = Helpers.BindFunction(Methods.Series.List, provider.series.list, provider)
    provider.methods.episode = provider.episode

    return true

module.exports =
  Helpers: Helpers
  Logic: Logic
