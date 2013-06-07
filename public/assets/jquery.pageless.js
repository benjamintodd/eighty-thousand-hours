// =======================================================================
// PageLess - endless page
//
// Pageless is a jQuery plugin.
// As you scroll down you see more results coming back at you automatically.
// It provides an automatic pagination in an accessible way : if javascript 
// is disabled your standard pagination is supposed to work.
//
// Licensed under the MIT:
// http://www.opensource.org/licenses/mit-license.php
//
// Parameters:
//    currentPage: current page (params[:page])
//    distance: distance to the end of page in px when ajax query is fired
//    loader: selector of the loader div (ajax activity indicator)
//    loaderHtml: html code of the div if loader not used
//    loaderImage: image inside the loader
//    loaderMsg: displayed ajax message
//    pagination: selector of the paginator divs. 
//                if javascript is disabled paginator is provided
//    params: paramaters for the ajax query, you can pass auth_token here
//    totalPages: total number of pages
//    url: URL used to request more data
//
// Callback Parameters:
//    scrape: A function to modify the incoming data.
//    complete: A function to call when a new page has been loaded (optional)
//    end: A function to call when the last page has been loaded (optional)
//
// Usage:
//   $('#results').pageless({ totalPages: 10
//                          , url: '/articles/'
//                          , loaderMsg: 'Loading more results'
//                          });
//
// Requires: jquery
//
// Author: Jean-Sébastien Ney (jeansebastien.ney@gmail.com)
//
// Contributors:
//   Alexander Lang (langalex)
//   Lukas Rieder (Overbryd)
//
// Thanks to:
//  * codemonky.com/post/34940898
//  * www.unspace.ca/discover/pageless/
//  * famspam.com/facebox
// =======================================================================
(function(e){var t=!1,n=!t,r,i=t,s,o={container:window,currentPage:1,distance:100,pagination:".pagination",params:{},url:location.href,loaderImage:"/images/load.gif"},u=o.container;e.pageless=function(t){e.isFunction(t)?o.call():f(t)};var a=function(){return o.loaderHtml||'<div id="pageless-loader" style="display:none;text-align:center;width:100%;">  <div class="msg" style="color:#e9e9e9;font-size:2em"></div>  <img src="'+o.loaderImage+'" alt="loading more results" style="margin:10px auto" /></div>'},f=function(t){if(o.inited)return;o.inited=n,t&&e.extend(o,t),o.pagination&&e(o.pagination).remove(),p()};e.fn.pageless=function(t){var n=e(this),i=e(t.loader,n);f(t),r=n,t.loader&&i.length?s=i:(s=e(a()),n.append(s),t.loaderHtml||e("#pageless-loader .msg").html(t.loaderMsg))};var l=function(e){(i=e)?s&&s.fadeIn("normal"):s&&s.fadeOut("normal")},c=function(){return u===window?e(document).height()-e(u).scrollTop()-e(u).height():e(u)[0].scrollHeight-e(u).scrollTop()-e(u).height()},h=function(){e(u).unbind(".pageless")},p=function(){e(u).bind("scroll.pageless",d).trigger("scroll.pageless")},d=function(){if(o.totalPages<=o.currentPage){h(),o.end&&o.end.call();return}!i&&c()<o.distance&&(l(n),o.currentPage++,e.extend(o.params,{page:o.currentPage}),e.get(o.url,o.params,function(n){e.isFunction(o.scrape)?o.scrape(n):n,s?s.before(n):r.append(n),l(t),o.complete&&o.complete.call()}))}})(jQuery);