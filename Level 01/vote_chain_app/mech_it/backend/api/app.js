const express = require("express");
const bodyParser = require("body-parser");
const routes = require("./api/routes");

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use("/api", routes);

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
