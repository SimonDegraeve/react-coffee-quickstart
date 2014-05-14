path        = require("path")
url         = require("url")
express     = require("express")
browserify  = require("connect-browserify")
ReactAsync  = require("react-async")
nodejsx     = require("node-cjsx").transform()
App         = require("./client")
development = process.env.NODE_ENV isnt "production"


renderApp = (req, res, next) ->
  path = url.parse(req.url).pathname
  app = App(path: path)
  ReactAsync.renderComponentToStringWithAsyncState app, (err, markup) ->
    return next(err) if err
    res.send "<!doctype html>\n" + markup

api = express().get("/users/:username", (req, res) ->
  username = req.params.username
  res.send
    username: username
    name: username.charAt(0).toUpperCase() + username.slice(1)
)

app = express()

if development
  app.get "/assets/bundle.js", browserify("./client.coffee",
    debug: true
    watch: true
    extensions: [".cjsx", ".coffee", ".js", ".json"]
  )

app
  .use("/assets", express.static(path.join(__dirname, "assets")))
  .use("/api", api)
  .use(renderApp)
  .listen 3000, ->
    console.log "Point your browser at http://localhost:3000"
