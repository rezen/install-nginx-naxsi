# Examples
The examples are exaggerated to for the sake of simplicity. 
Try each example without naxsi running & then with naxsi blocking

#### Sql Injection
You can use any number of username/password combinations to 
very that there is no access without good creds. Verify 
the good cred get you in, as well as the injection.

- `sql.php`

**Good creds**
  - username: `jdoe`
  - password: `password`

**Injection**
  - username: `' OR 1=1 --`
  - password: 


#### File Inclusion
- `inclusion.php?file=text.txt`
- `inclusion.php?file=README.md`
- `inclusion.php?file=../../../../etc/nginx/nginx.conf`

#### XSS
- `xss.php?username=Bob`
- `xss.php?username=<script>alert('doh');</script>`