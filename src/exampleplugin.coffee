needle = require 'needle'

module.exports =
  name: 'animebam'

  initialize: ->
    console.log "[#{@name}] loaded successfully."

  search:
    page: (query, callback) ->
      needle.get "http://animebam.net/search?search=#{query}", (err, resp) ->
        callback err, resp.body

    list: '.mse'
    row:
      name: (el) ->
        return el.find("h2").text()
      url: (el) ->
        return el.attr('href')

  anime:
    list: '.newmanga li'
    row:
      name: (el) ->
        el.find(".anititle").text()
      url: (el) ->
        el.find("a").attr("href")

  episode: ($, body) ->
    return [{name: '480', url: 'Unknown'}]

