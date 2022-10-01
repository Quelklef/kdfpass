const { app, BrowserWindow } = require('electron')

global.global = global;

app.whenReady().then(() => {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    frame: false,
    alwaysOnTop: true,
    transparent: true,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      enableRemoteModule: true,
    },
  })
  win.loadFile('index.html');
  win.webContents.openDevTools();
  win.center();
});
