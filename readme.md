# Aniscrape

## About

Aniscrape is an experimental scraping framework which supplies a 'provider' api to assist in scraping video & anime information from online anime sites.

## Install

```sh
npm install aniscrape
```

## Usage

#### Foreword
Please note that aniscrape is currently under heavy development and as a result the API is constantly changing and is by no means final. I don't claim to be an expert in module design so suggestions regarding class structure are welcome.

```js
var Aniscrape = require('aniscrape');
var animebam = require('aniscrape-animebam'); // Check source on GitHub for more info.

var scraper = new Aniscrape();
scraper.use(animebam)
.then(function() {
  scraper.search('Haikyuu', 'animebam').then(function (results) {
    console.log(results)
    scraper.fetchSeries(results[2]).then(function(anime) {
      console.log(anime)
      scraper.fetchVideo(anime.episodes[1]).then(function(video) {
        // Video is a list of direct video links and quality labels.
        console.log(video)
      })
    })
  })
})


// You can also do searchAll to search through all providers.
// When you call fetchSeries & fetchVideos, aniscrape will detect the provider automatically
// and use the correct methods to retrieve it.
scraper.searchAll('Haikyuu').then(function(results) {
  console.log(results); // Will return all results if more than one provider is supplied.
});
```

## Providers

Aniscrape uses a modular design whereby you simply provide the scraping structure of your website (urls, html class names etc.) in the form of a search provider module, and aniscrape will use that when providing search results, episode lists and more.

You can see the current structure of search providers in the [provider guide.](provider-guide.md)

### Available providers

There are currently two created providers for aniscrape as seen below. If you create one, please let me know and I will add it to the list.

- [animebam](https://github.com/roflmuffin/aniscrape-animebam)
- [KissAnime](https://github.com/roflmuffin/aniscrape-kissanime)

## Todo

#### Provider API

There are still more options I need to include for use in the provider API, such as:

- Support sites that have episode lists on a different page to their anime page (allow promise based episode returns)

#### Overall features that need to be included

Some must have features for the base scraper in general:

- Throttling and rate limiting requests. Currently requests are sent immediately, this is less than ideal especially if you want to bulk grab video URLs.

## Contributing

The project is currently in its infancy so I don't really have any contributor rules. The source is written in CoffeeScript and I would prefer it remain that way. CoffeeScript lends itself well to the key value based structure of the provider API as it exists currently.

Open to all issues and pull requests, submit away.

## License

MIT. See LICENSE.
