Promise = require 'bluebird'
needle = Promise.promisifyAll(require 'needle')
cheerio = require 'cheerio'
_ = require 'lodash'

animebam = require('./exampleplugin.coffee')
moetube = require('./moetube.coffee')

needle.defaults({
  follow_max: 10
})

class SearchResult
  constructor: (object) ->
    {@seriesName, @seriesUrl, @searchProvider, @isSpecial = false} = object

class Episode
  constructor: (object) ->
    {@number, @title, @url} = object

class Scraper
  constructor: (@plugin) ->

  search: (query) ->
    Promise.resolve(@plugin.search.page(query)).then (body) =>
      $ = cheerio.load(body)

      list = $(@plugin.search.list)

      list = list.map (i, el) =>
        return new SearchResult({
          seriesName: @plugin.search.row.name($(el))
          seriesUrl: @plugin.search.row.url($(el))
          searchProvider: @plugin.name
        })
      .get()

      list = _.filter list, (item) ->
        return item.seriesName.toUpperCase().indexOf(query.toUpperCase()) > -1

  fetchSeries: (searchResult) ->
    needle.getAsync(searchResult.seriesUrl).then (resp) =>
      $ = cheerio.load(resp.body)

      episodes = $(@plugin.series.list)

      episodes = episodes.map (i, el) =>
        return new Episode({
          title: @plugin.series.row.name($(el))
          url: @plugin.series.row.url($(el))
          number: @plugin.series.row.number($(el))
        })
      .get()

  fetchVideo: (episode) ->
    needle.getAsync(episode.url).then (resp) =>
      $ = cheerio.load(resp.body)

      @plugin.episode($, resp.body)


s = new Scraper(animebam)
s.search('Haikyuu').then (data) ->
  s.fetchSeries(data[0]).then (episodes) ->
    console.log episodes
    s.fetchVideo(episodes[0]).then (data) ->
      console.log data
  console.log data
# s.use animebam
# s.use moetube

# class Scraper
#   constructor: (@plugin) ->

#   search: (query) ->
#     Promise.resolve(@plugin.search.page(query)).then (body) =>
#       $ = cheerio.load(body)

#       list = $(@plugin.search.list)

#       list = list.map (i, el) =>
#         finalObj = {}
#         for k,v of @plugin.search.row
#           finalObj[k] = v($(el))
#         # return finalObj
#         return new SearchResult({
#           seriesName: @plugin.search.row.name($(el))
#           seriesUrl: @plugin.search.row.url($(el))
#           searchProvider: @plugin.name
#         })
#       .get()



# console.log s

# class Scraper
#   constructor: ->
#     @_loadedPlugins = []

#   use: (plugin) ->
#     @_loadedPlugins.push plugin

#   search: (query) ->
#     Promise.map @_loadedPlugins, (plugin) ->
#       Promise.resolve(plugin.search.page(query)).then (body) ->
#         $ = cheerio.load(body)

#         list = $(plugin.search.list)

#         list = list.map (i, el) ->
#           finalObj = {}
#           for k,v of plugin.search.row
#             finalObj[k] = v($(this))
#           return finalObj
#         .get()

#         list = _.filter list, (item) ->
#           return item.name.toUpperCase().indexOf(query.toUpperCase()) > -1

#         return {
#           scraper: plugin.name
#           results: list
#         }
#     .then (results) ->
#       console.log results



# s.search 'Haikyuu'

#   console.log 'Animebam initialized.'

# prom.then (value) ->
#   console.log value

# search = (name, filter) ->
#   if !filter? && !filter.page?
#     return

#   pageRetrieved = (err, body) ->
#     $ = cheerio.load(body)

#     list = $(filter.list)

#     list = list.map (i, el) ->
#       finalObj = {}
#       for k,v of filter.row
#         finalObj[k] = v($(this))
#       return finalObj
#     .get()

#     list = _.filter list, (item) ->
#       return item.name.toUpperCase().indexOf(name.toUpperCase()) > -1
#     console.log list

#   if typeof filter.page == 'function'
#     filter.page name, pageRetrieved
#   else if typeof filter.page == 'string'
#     needle.get filter.page, (err, resp) ->
#       pageRetrieved(err, resp.body)


# search('Haikyuu', animebam.search)

# searchObject =
#   search: 'http://www.animebam.net/series'
#   list: '.anm_det_pop'
#   row:
#     name: (el) ->
#       return el.text()
#     url: (el) ->
#       return el.attr('href')

# animeObject =
#   list: '.newmanga li'
#   row:
#     name: (el) ->
#       el.find(".anititle").text()
#     url: (el) ->
#       el.find("a").attr("href")

# useSearch = (name) ->
#   needle.getAsync(searchObject.search).then (resp) ->
#     $ = cheerio.load(resp.body)

#     list = $(searchObject.list)

#     list = list.map (i, el) ->
#       finalObj = {}
#       for k,v of searchObject.row
#         finalObj[k] = v($(this))
#       return finalObj
#     .get()

#     list = _.filter list, (item) ->
#       return item.name.toUpperCase().indexOf(name.toUpperCase()) > -1
#     console.log list

# acceptEpisode = (input) ->
#   if typeof input == 'function'
#     console.log 'Accepting Function'
#   else if typeof input == 'object'
#     if input.list? && input.row?
#       console.log 'Accepted Object'
#     else
#       throw new Error('Invalid filter specified for plugin')
#   else if typeof input == 'undefined'
#     throw new Error('No filter specified for plugin')
#   else
#     throw new Error('Unknown error occurred instantiating plugin')

# acceptEpisode
#   list: '.newmanga li'
#   row:
#     number: (el) ->
#       el.find(".anm_det_pop").text().match(/\s(\d+)/)[0].trim()
#     name: (el) ->
#       el.find(".anititle").text()
#     url: (el) ->
#       el.find("a").attr("href")


# episodeList =
#   list: '.newmanga li'
#   episode:
#     number: (el) ->
#       el.find(".anm_det_pop").text().match(/\s(\d+)/)[0].trim()
#     name: (el) ->
#       el.find(".anititle").text()
#     url: (el) ->
#       el.find("a").attr("href")

# animeUrl = 'http://www.animebam.net/series/haikyuu-second-season'

# needle.getAsync(animeUrl).then (resp) ->
#   $ = cheerio.load(resp.body)

#   list = $(episodeList.list)

#   list = list.map (i, el) ->
#     finalObj = {}
#     for k,v of episodeList.episode
#       finalObj[k] = v($(this))
#     return finalObj
#   .get()

#   console.log list
# searchList =
#   list: '.mse'
#   row:
#     name: (el) ->
#       el.find("h2").text()
#     url: (el) ->
#       el.attr("href")

# animeUrl = 'http://www.animebam.net/search?search=Haikyuu'

# needle.getAsync(animeUrl).then (resp) ->
#   $ = cheerio.load(resp.body)

#   list = $(searchList.list)

#   list = list.map (i, el) ->
#     finalObj = {}
#     for k,v of searchList.row
#       finalObj[k] = v($(this))
#     return finalObj
#   .get()

#   console.log list

# searchAnime('Haikyuu').then (response) ->
#   console.log "Anime Name: #{response[2].name}"
#   getEpisodes(response[2].url).then (episodes) ->
#     console.log episodes[1]
#     getEpisode(episodes[1].url).then (episode) ->
#       console.log episode