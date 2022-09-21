**Русский**

На проекте было много страниц продуктов, которые влетели в индекс.
Нужно быо настроить 301 редирект для страниц продуктов, они же страницы с расширением .html и которые по get параметру page= отдавали 200 код ответа сервера.

```
RewriteEngine On
RewriteBase /

#redirects for page with .html and get parametr page=
RewriteCond %{QUERY_STRING} (?:^|&)page\=(.*)(?:$|&)
RewriteRule ^(.*).html$ https://site.com/$1.html? [L,R=301]
```

**English (Google Translate)**

There were many product pages on the project that flew into the index.
It was necessary to set up 301 redirects for product pages, they are pages with an extension.html and which by the get parameter page= gave 200 server response code.
```
RewriteEngine On
RewriteBase /

#redirects for page with .html and get parametr page=
RewriteCond %{QUERY_STRING} (?:^|&)page\=(.*)(?:$|&)
RewriteRule ^(.*).html$ https://site.com/$1.html? [L,R=301]
```