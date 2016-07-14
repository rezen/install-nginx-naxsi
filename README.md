# install-nginx-naxsi
A work in progress! Still working on getting the configs down. Disclaimers aside, `install_naxsi.sh` does work well and has been tested significantly. The part that 
isn't quite down are the nginx configs.

### Naxsi
1. Learning mode
  * Use it to help Naxsi build better rules
  * Make normal requests against naxsi
  * Ideally setup in a sandboxxed environment that won't be attacked to skew learning results
2. Enforcing mode
  * Bad requests are redirect to a endpoint you configure
  

## Resources
##### Naxsi
- https://github.com/nbs-system/naxsi-rules
- https://www.scalescale.com/tips/nginx/naxsi-nginx-security-module/
- https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-naxsi-on-ubuntu-14-04
- https://github.com/scollazo/docker-naxsi-waf-with-ui
- http://atomic111.github.io/blog/create-a-naxsi-waf-for-owncloud
- https://bobcares.com/blog/how-we-blocked-zero-day-malware-attacks-on-websites-using-naxsi-firewall/
- http://bitsandpieces.it/nginx-by-examples-naxsi-waf
- https://github.com/nbs-system/naxsi-rules
- http://www.slideshare.net/wallarm/how-to-secure-your-web-applications-with-nginx
- http://www.greenacorn-websolutions.com/nginx/securing-your-app-with-nginx-naxsi.php
- http://gradew.net/2016/01/04/naxsi/

##### Securing nginx
- https://www.nginx.com/blog/mitigating-ddos-attacks-with-nginx-and-nginx-plus/
- http://www.tecmint.com/nginx-web-server-security-hardening-and-performance-tips/

##### Configuring nginx
- https://github.com/nbs-system/naxsi/wiki/basicsetup
- https://github.com/h5bp/server-configs-nginx/blob/master/nginx.conf
- http://nginx.org/en/docs/dirindex.html
- https://github.com/agile6v/awesome-nginx
- https://github.com/nginx-boilerplate/nginx-boilerplate
- https://github.com/mariusv/nginx-badbot-blocker/blob/master/blacklist.conf
- https://github.com/oohnoitz/nginx-blacklist
- https://github.com/Stevie-Ray/apache-nginx-referral-spam-blacklist
- https://gist.github.com/ipmb/472da2a9071dd87e24d3

##### Other
- https://2015.appsec.eu/wp-content/uploads/2015/09/owasp-appseceu2015-koechlin.pdf
- http://www.senginx.org/en/index.php/Main_Page

#### Credits
- https://github.com/nginx-boilerplate/nginx-boilerplate
- https://github.com/h5bp/server-configs-nginx