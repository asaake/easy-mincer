easy-mincer
===========

```
npm install -g easy-mincer
```

```
mkdir my-project
cd my-project
easy-mincer create

cd app/assets/javascripts
vi main.coffee # => class Main

easy-mincer start # => http://localhost:3000/main.coffee
```

```
easy-mincer create  # create init project
easy-mincer start   # start server
easy-mincer compile # compile src
```


```
# easy-mincer.json
{
  "targets": ["main.js"],     # compile target file name.
  "paths": [
    "app/assets/javascripts"  # mincer appendPath
  ]
}
```

* project-tree
  * app
    * assets
      * javascripts
      * stylesheets
      * templates
  * test
    * assets
      * javascripts
      * stylesheets
      * templates
  * dest # targets compile file
  * bower.json
  * easy-mincer.json # easy-mincer config file.
  * LICENSE
  * package.json
  * README.md

