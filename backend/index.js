import express from 'express';
import multer from 'multer';
import cors from 'cors';
import file_type from 'file-type';
import * as fs from 'fs';
import * as path from 'path';

const app = express();
app.use(cors())
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(multer().none());

const RELATIVE_IMG_ROOT = "public/img";
const RANDOM_WAIT_MAX_MS = 5000;

import { dirname } from 'path';
import { fileURLToPath } from 'url';
const __dirname = dirname(fileURLToPath(import.meta.url));

var isDark = true;

app.get("/list", async (req, res) => {
  let pathPrefix = "/";
  if (req.query["dark"] === "true") {
    pathPrefix = "/dark/";
  }

  let list = {
    "clouds": []
  };

  try {
    let imgs = await fs.promises.readdir(RELATIVE_IMG_ROOT + pathPrefix, { "withFileTypes": true });
    for (let i = 0; i < imgs.length; i++) {
      if (!imgs[i].isFile()) continue;
      let type = await file_type.fromFile(RELATIVE_IMG_ROOT + pathPrefix + imgs[i].name);
      if (type !== undefined && /^image/.test(type["mime"])) {
        list["clouds"].push({
          "url": 'img' + pathPrefix + imgs[i].name,
          "price": Math.random() * 100,
          "currency": "$",
          "rating": parseInt(Math.random() * 5),
          "title": "Cloud " + (i + 1)
        });
      }
    }
    res.send(list);
  } catch (e) {
    console.log(e);
    res.status(500).send("Unknown Error");
  }
});

app.get("/img/*", async (req, res) => {
  let randomWait = Math.random() * RANDOM_WAIT_MAX_MS;

  let options = {
    root: path.join(__dirname, 'public', 'img'),
    dotfiles: 'deny',
    headers: {
      'x-timestamp': Date.now(),
      'x-sent': true
    }
  }

  console.log("[INFO] Random wait is enabled. Waiting " + randomWait + "ms before sending file.");
  await sleep(randomWait);
  res.sendFile(req.params[0], options);
});

app.get("/prefs", async (req, res) => {
  if (req.query["set"]) {
    isDark = (req.query["set"] === 'true');
  }

  let randomWait = Math.random() * 400 + 800;
  console.log("[INFO] Waiting " + randomWait + "ms to send back dark pref (" + isDark + ").");
  await sleep(randomWait);
  res.send({
    "dark": isDark
  });
});

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

const PORT = process.env.PORT || 8080;
app.listen(PORT);
app.use(express.static("public"));
