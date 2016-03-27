## Example

To view an example, you can see the provided animebam search provider located [here.](https://github.com/roflmuffin/aniscrape-animebam)

### Filters that must be provided
  - Search URL/Method & Method/Object to parse results
  - Anime Page Method/Object to parse episode list
  - Episode Page Methhod/Object to parse video links

## Search Object Structure
```js
{
  // This function must return search results based on query
  //
  // callback(null, body)
  page: function (query) {
    // Must return a promise that returns a body based on query
  },

  // You can also specify search as a string
  // We will just run a GET request on it and return the body
  page: 'http://animewebsite.com/list',

  // Another option is to supply the url and param name to perform a GET query
  // Below is the equivalent of http://animewebsite/search?name=AnimeName
  page: {url: 'http://animewebsite/search', param: 'name'}

  // This function must return a list of jQuery objects that represent a search result item
  //
  // $ = Cheerio page object
  // body = Raw page body
  // NOT IMPLEMENTED
  list: function ($, body) {
    return $(".row-item")
  },

  // You can also pass in a jQuery selector as a string
  list: '.row-item',   

  // Row is an object of Key Value function pairs that turn the jQuery row into data
  // Row must return name & url at the minimum but may contain extra data.
  //
  // el = Cheerio/jQuery element
  row: {
    name: function (el) {
      return el.find(".title").text()
    },
    url: function (el) {
      return el.attr('href').text()
    }
  }
}
```

## Anime Page Structure
```js
{
  // NOT IMPLEMENTED
  // This function must return a list of jQuery objects that represent a search result item
  //
  // $ = Cheerio page object
  // body = Raw page body
  // NOT IMPLEMENTED
  list: function ($, body) {
    return $(".row-item")
  },

  // You can also pass in a jQuery selector as a string
  list: '.row-item',

  // Almost identical to the search row parameter.
  // Key Value function pair that turns row items into usable objects
  row: {
    name: function (el) {
      return el.find(".name").text()
    },
    url: function (el) {
      return el.attr('href').text()
    },
    number: function (el) {
      return el.find('.episode-name').text().match(/(?=[^\s]*$)\d+/)[0]
    }
  }
}
```

## Episode Page Structure
```js
{
  // From this method you must return an array of objects {label: '', url: ''}
  // That describe video link qualities and url
  //
  // {label: '480p', url: 'http://video.com/file.mp4'}
  episode: function ($, body) {
    // Because episode pages vary greatly we request that
    // you parse the video urls manually.
  }
}
```
