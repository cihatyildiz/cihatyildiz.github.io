---
title: Understanding HTTP Security Headers
author: Cihat Yildiz
date: 2019-12-14 20:55:00 +0800
categories: [http headers, Notes]
tags: [http, web security]
pin: false
---

HTTP Security headers are security mechanisms that you can use to protect your web application. Those headers provide extra protection layers. This is a fundamental part of web application security. You can easily configure your web application and implement required security header information for your application. After the implementation, these security headers protect your application against the type of attacks such as XSS, code injection, clickjacking, etc.

Basically, when a browser requests a URL from a web server, the server responds with the content along with HTTP headers. Security headers in this response tell the browser how to manage the content of the webpage content. We explored HTTP security headers below.

## Content Security Policy

With this header configuration, you can specify which content should be loaded in your application. Basically, this is a whitelisting configuration for your web application.

If you are using a browser that supports Content Security Policy, such as Chrome or Firefox, your browser will read the CSP information from the response and know which sources are trusted or not.

Content-security-policy can prevent attacks such as:

* XSS – Cross-Site Scripting
* Clickjacking
* Protocol downgrading

The below URLs shows more detailed information about CSP.

* [https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
* [https://content-security-policy.com/](https://content-security-policy.com/)

[![CSP](https://img.youtube.com/vi/d0D3d0ZM-rI/0.jpg)](https://www.youtube.com/watch?v=d0D3d0ZM-rI)


## X-XSS-Protection

‘X-XSS-Protection’ header is a feature of modern browsers that allows websites to control for XSS attacks. This is a kind of audit process for your application.

If your application is not configured to return an ‘X-XSS-Protection’ header we can say that the pages on this website could be at risk of an XSS attack.

This header is enabled by default on the modern web browsers.

## X-Frame-Options

The X-Frame-Options HTTP header is a policy for modern browsers. With this security header, you can specify whether the browser will render the data in frame or iframe.

This security header helps to prevent clickjacking attacks, which ensures that their content is not embedded into other pages or frames.

## X-Content-Type-Options

X-Content-Type-Options is a security header that protects MIME type sniffing vulnerabilities. When a website allows users to upload content, the user can hide a particular filetype as something else. The application would be vulnerable to an XSS attack if you don’t have this setting in your server.

With this security header, you can disable the MIME sniffing. This helps prevent those type of attacks

## Access-Control-Allow-Origin

Access-Control-Allow-Origin response header deals with resource sharing. The header will instruct the browser whether the response can be shared or not.

## Strict-Transport-Security

Strict-Transport-Security header prevents web browsers from accessing webs in stateless HTTP connections. The header will instruct the browser to access web pages using HTTPS, instead of using HTTP.

## Conclusion

In this post, I have tried to point out some security headers that we need to implement on our web applications. These headers instruct your browsers on how to behave with a particular web application.

But, It doesn’t mean that those features will protect everything in your website. These are additional security layer on the client-side. Some headers not well designed protection mechanisms. There are also some attacks that try to bypass those features.

There is also an OWASP Project to describe HTTP response headers:
* [OWASP Security Header Project](https://www.owasp.org/index.php/OWASP_Secure_Headers_Project)

[![CSP](https://img.youtube.com/vi/GUo82P52TA8/0.jpg)](https://www.youtube.com/watch?v=GUo82P52TA8)

## References

* [https://www.netsparker.com/whitepaper-http-security-headers/](https://www.netsparker.com/whitepaper-http-security-headers/)
* [https://medium.com/@Johne_Jacob/7-security-response-headers-every-security-tester-should-know-77576ffdfc0f](https://medium.com/@Johne_Jacob/7-security-response-headers-every-security-tester-should-know-77576ffdfc0f)
* [https://www.thesslstore.com/blog/http-security-headers/](https://www.thesslstore.com/blog/http-security-headers/)
