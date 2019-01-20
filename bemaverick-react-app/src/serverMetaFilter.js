// React SSR renders out <meta tags with URL-encoded values.
// That's bad if you need query parameters in your URLs.
// Before: <meta property="og:image"
// content="https://makelight-prismic-images.imgix.net/7f97d951970bbb15a8b3744e4c69499ffe969d66_img_1010.jpg?w=1200&amp;h=630&amp;fit=crop&amp;crop=entropy&amp;auto=format&amp;ixlib=js-1.1.1" class="next-head"/>
// (Notice the &amp;s in the URL)
//
// After: <meta property="og:image"
// content="https://makelight-prismic-images.imgix.net/cfb3a074bfcab5793eded64ef077dd6260d6d89b_img_0578.jpg?w=1200&h=630&fit=crop&crop=entropy&auto=format&ixlib=js-1.1.1" class="next-head"/>
// (Notice &amp; is now correctly &
//
// Use a custom Express server and add this middleware at the top of the middleware stack

// Gist & https://gist.github.com/stefl/1f8c246dd7ca9cb332ae41f68e80088d

const interceptor = require("express-interceptor");
const Entities = require("html-entities").AllHtmlEntities;
const entities = new Entities();

const serverMetaFilter = interceptor(function(req, res) {
  // console.log(res);
  return {
    isInterceptable: function(rq, rs) {
      // Only alter HTML
      // console.log("is interceptable", res.get("Content-Type"));
      return /text\/html/.test(res.get("Content-Type"));
    },
    intercept: function(body, send) {
      // Regex matches anything with a content="" attribute. Adjust this for your own needs.
      send(
        body.toString().replace(/content="([^"]+)"/g, function(match, content) {
          // console.log("🧀  replace", content);
          return `content="${entities.decode(content)}"`;
        })
      );
    }
  };
});

module.exports = serverMetaFilter;
