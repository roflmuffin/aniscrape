Promise = require 'bluebird'
needle = Promise.promisifyAll(require 'needle')
cheerio = require 'cheerio'
_ = require 'lodash'
Bottleneck = require 'bottleneck'

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
    @limiter = new Bottleneck(0, 500)

  use: (provider) ->
    return new Promise (resolve, reject) =>
      if provider.length != undefined
        Promise.each provider, (item) =>
          if Validation.Logic.ValidateProvider(item)
            @providers[item.name] = item
            return Promise.resolve(item.initialize())
      else
        try
          if Validation.Logic.ValidateProvider(provider)
            @providers[provider.name] = provider
            return resolve(provider.initialize())
        catch error
          reject(error)

  search: (name, provider) ->
    @fetchSearchResult(name, @providers[provider])

  searchAll: (name) ->
    Promise.map Object.keys(@providers), (provider) =>
      @fetchSearchResult(name, @providers[provider])

  fetchSearchResult: (query, provider) ->
    @limiter.schedule(provider.methods.search, query).then (body) ->
      $ = cheerio.load(body)

      provider.methods.list($, body).then (list) ->

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
    provider = @providers[searchResult.searchProvider]
    needle.getAsync(searchResult.seriesUrl, provider.http_options).then (resp) =>
      $ = cheerio.load(resp.body)

      episodes = provider.methods.seriesList($, resp.body).then (episodes) ->
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
    provider = @providers[episode.searchProvider]
    needle.getAsync(episode.url, provider.http_options).then (resp) =>
      $ = cheerio.load(resp.body)
      provider.methods.episode($, resp.body)

module.exports = Scraper
