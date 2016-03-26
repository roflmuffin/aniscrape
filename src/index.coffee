Promise = require 'bluebird'
needle = Promise.promisifyAll(require 'needle')
cheerio = require 'cheerio'
_ = require 'lodash'

Errors = require './errors'
Validation = require './provider/validation'

needle.defaults({
  follow_max: 10
})

class SearchResult
  constructor: (object) ->
    {@seriesName, @seriesUrl, @searchProvider, @episodes = [], @isSpecial = false} = object

class Episode
  constructor: (object) ->
    {@number, @title, @url, @searchProvider} = object

class Scraper
  constructor: ->
    @providers = {}

  use: (provider) ->
    if Validation.Logic.ValidateProvider(provider)
      @providers[provider.name] = provider
      provider.initialize()

  search: (name, provider) ->
    @fetchSearchResult(name, @providers[provider])

  searchAll: (name) ->
    Promise.map Object.keys(@providers), (provider) =>
      @fetchSearchResult(name, @providers[provider])

  fetchSearchResult: (query, provider) ->
    provider._methods.search(query).then (body) ->
      $ = cheerio.load(body)

      list = $(provider.search.list)

      list = list.map (i, el) ->
        return new SearchResult({
          seriesName: provider.search.row.name($(el))
          seriesUrl: provider.search.row.url($(el))
          searchProvider: provider.name
        })
      .get()

      list = _.filter list, (item) ->
        return item.seriesName.toUpperCase().indexOf(query.toUpperCase()) > -1

  fetchSeries: (searchResult) ->
    needle.getAsync(searchResult.seriesUrl).then (resp) =>
      $ = cheerio.load(resp.body)

      provider = @providers[searchResult.searchProvider]
      episodes = $(provider.series.list)

      episodes = episodes.map (i, el) ->
        if !provider.series.row.number?
          number = i+1
        else
          number = provider.series.row.number($(el))
        return new Episode({
          title: provider.series.row.name($(el))
          url: provider.series.row.url($(el))
          number: number
          searchProvider: provider.name
        })
      .get()

      searchResult.episodes = episodes
      return searchResult

  fetchVideo: (episode) ->
    needle.getAsync(episode.url).then (resp) =>
      $ = cheerio.load(resp.body)
      console.log(episode.url)
      @providers[episode.searchProvider].episode($, resp.body)

module.exports = Scraper
