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
scraper.use(animebam);

scraper.search('Haikyuu', 'animebam').then(function (results) {
  scraper.fetchSeries(results[0]).then(function(anime) {
    scraper.fetchVideo(anime.episodes[0]).then(function(video) {
      // Video is a list of direct video links and quality labels.
    })
  });
})
```

## Providers

Aniscrape uses a modular design whereby you simply provide the scraping structure of your website (urls, html class names etc.) in the form of a search provider module, and aniscrape will use that when providing search results, episode lists and more.

You can see the current structure of search providers in the [provider guide.](provider-guide.md)