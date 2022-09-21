**Русский**

На проекте было много страниц продуктов и главной страницы, которые влетели в индекс.
Нужно быо настроить 301 редирект для страниц продуктов, они же страницы с расширением .html и которые по get параметру page= отдавали 200 код ответа сервера.
Нужно быо настроить 301 редирект для главной и по get параметру page=, который отдавал 200 код ответа сервера.

```
RewriteEngine On
RewriteBase /

#redirects for page with .html and get parametr page=
RewriteCond %{QUERY_STRING} (?:^|&)page\=(.*)(?:$|&)
RewriteRule ^(.*).html$ https://site.com/$1.html? [L,R=301]

#redirects for home page and get parametr page=
RewriteCond %{QUERY_STRING} (?:^|&)page\=(.*)(?:$|&)
RewriteRule ^$ https://monamourplus.ru/? [L,R=301]
```

**English (Google Translate)**

The project had many product pages and the main page that flew into the index.
It was necessary to set up 301 redirects for product pages, they are pages with an extension.html and which by the get parameter page= gave 200 server response code.
It would be necessary to configure 301 redirects for the main page and by the get parameter page=, which gave 200 the server response code.

```
RewriteEngine On
RewriteBase /

#redirects for page with .html and get parametr page=
RewriteCond %{QUERY_STRING} (?:^|&)page\=(.*)(?:$|&)
RewriteRule ^(.*).html$ https://site.com/$1.html? [L,R=301]

#redirects for home page and get parametr page=
RewriteCond %{QUERY_STRING} (?:^|&)page\=(.*)(?:$|&)
RewriteRule ^$ https://monamourplus.ru/? [L,R=301]
```