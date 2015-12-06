Promise = require 'bluebird'
needle = Promise.promisifyAll(require 'needle')
cheerio = require 'cheerio'

module.exports =
  name: 'animebam'
  # baseurl: 'http://animebam.net/'

  initialize: ->
    console.log "[#{@name}] loaded successfully."

  search:
    page: (query) ->
      # needle.getAsync("http://animebam.net/search?search=#{query}").get('body')
    page: {url: 'http://animebam.net/search', param: 'search', type: 'get'}
    # page: 'http://www.animebam.net/series'


    list: '.mse'
    row:
      name: (el) ->
        el.find("h2").text()
      url: (el) ->
        "http://animebam.net" + el.attr('href')

  series:
    list: '.newmanga li'
    row:
      name: (el) ->
        el.find(".anititle").text()
      url: (el) ->
        "http://animebam.net" + el.find("a").attr("href")
      number: (el) ->
        el.find('.anm_det_pop').text().match(/(?=[^\s]*$)\d+/)[0]

  episode: ($, body) ->
    url = "http://animebam.net" + $("iframe.embed-responsive-item").attr('src')
    needle.getAsync(url).then (resp) ->
      $ = cheerio.load(resp.body)
      episodes = eval($("script:contains('videoSources')").html().match(/\[.+\]/)[0])

      options =
        follow_max: 0
        headers:
          'Referer': 'http://animebam.net/'
          
      Promise.map episodes, (video) ->
        needle.headAsync(video.file, options).then (resp) ->
          return {
            label: video.label
            url: resp.headers.location
          }

