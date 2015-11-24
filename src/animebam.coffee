needle.defaults(follow_max: 5)

epUrl = 'http://www.animebam.net/haikyuu-second-season-episode-8'
searchUrl = 'http://www.animebam.net/search'

baseUrl = "http://www.animebam.net"

getEpisode = (epUrl) ->
  needle.getAsync(epUrl).then (resp) ->
    $ = cheerio.load(resp.body)
    iframe = $("iframe.embed-responsive-item")
    iframeSrc = "http://animebam.net#{iframe.attr('src')}"

    needle.getAsync(iframeSrc).then (resp) ->
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

searchAnime = (name) ->
  needle.getAsync("#{searchUrl}?search=#{name}").then (resp) ->
    $ = cheerio.load(resp.body)
    results = $(".mse")
    
    return results.map (i, el) ->
      return {
        name: $(el).find("h2").text()
        url: "#{baseUrl}#{$(el).attr('href')}"
      }
    .get()

getEpisodes = (url) ->
  needle.getAsync(url).then (resp) ->
    $ = cheerio.load(resp.body)
    results = $(".newmanga li").has('i.btn-xs')

    return results.map (i, el) ->
      return {
        number: $(this).find(".anm_det_pop").text().match(/\s(\d+)/)[0].trim()
        name: $(this).find(".anititle").text()
        url: "#{baseUrl}#{$(this).find("a").attr('href')}"
      }
    .get()
