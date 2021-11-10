<template>
  <div
    v-on:drop="drop"
    @dragover="dragOver"
    @drop="drop"
    @dragenter="dragEnter"
    @dragleave="dragLeave"
    :class="dragging ? 'dragging' : null"
  >
    <div
      :class="`drag-and-drop ${dragging ? 'd-block' : 'd-none'}`"
      @drop="drop"
      v-on:drop="drop"
    >
      <input type="file" />
    </div>
    <div class="row">
      <div :class="`col-${sidebarExpand ? 2 : 1}`">
        <Sidebar />
      </div>
      <div class="col">
        <h2 v-for="mod in store.state.mods" :key="mod">{{ mod }}</h2>
        <router-view />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Options, Vue } from "vue-class-component";
import Sidebar from "@/components/Sidebar.vue";
import store from "@/store";
import { app, dialog } from "@electron/remote";
import {
  existsSync,
  writeFileSync,
  readFileSync,
  readdirSync,
} from "original-fs";
import { IConfig } from "./types";
import { Archive } from "libarchive.js";
import path from "path";

Archive.init({
  workerUrl: "libarchive.js/dist/worker-bundle.js",
});

@Options({
  components: { Sidebar },
})
export default class App extends Vue {
  public config: IConfig | Record<string, never> = {};
  public configPath = "";
  public dragging = false;
  public store = store;

  async mounted(): Promise<void> {
    console.log(store.state.config.gameDir);
    this.config = store.state.config;
    this.config = store.state.config;
    store.commit("setApplicationBasePath", app.getPath("userData"));
    this.configPath = path.join(store.state.applicationBasePath, "config.json");

    store.commit("setConfigPath", this.configPath);
    await this.getConfig();
    this.loadMods();
  }

  async getConfig(): Promise<void> {
    if (!existsSync(this.configPath)) {
      // not exists
      const fileObject = await dialog.showOpenDialog({
        message: "Please select the Payday 2 installation directory",
        properties: ["openDirectory"],
      });
      if (!fileObject.canceled) {
        // dialog is not canceled
        const path = fileObject.filePaths[0];
        this.config = {
          gameDir: path,
        };
        writeFileSync(this.configPath, JSON.stringify(this.config, null, "\t"));
        this.readConfig();
      } else {
        // diaglog is canceled
        this.getConfig();
      }
    } else {
      // exists
      this.readConfig();
    }
  }

  readConfig(): void {
    this.config = JSON.parse(
      readFileSync(this.configPath, { encoding: "utf8" })
    );
    store.commit("setConfig", this.config);
    console.log(store.state.config.gameDir);
    store.commit("setModFolder", path.join(store.state.config.gameDir, "mods"));
    store.commit(
      "setModOverridesFolder",
      path.join(store.state.config.gameDir, "assets", "mod_overrides")
    );
  }

  loadMods(): void {
    console.log(readdirSync(store.state.modsFolder));
    store.commit(
      "setMods",
      readdirSync(store.state.modsFolder, { withFileTypes: true })
        .filter((dirent) => dirent.isDirectory())
        .map((dirent) => dirent.name)
    );
  }

  dragOver(event: Event): void {
    console.log("drag over");

    event.preventDefault();
    event.stopImmediatePropagation();
    if (!this.dragging) {
      this.dragging = true;
    }
  }

  dragEnd(event: Event): void {
    console.log("drag end");
    event.preventDefault();
    event.stopImmediatePropagation();
    if (this.dragging) {
      this.dragging = false;
    }
  }

  dragEnter(event: Event): void {
    console.log("drag enter");
    event.preventDefault();
    event.stopImmediatePropagation();
  }

  dragLeave(event: Event): void {
    console.log("drag leave");
    // event.preventDefault();
    // event.stopImmediatePropagation();
  }

  drop(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    console.log(event);
    console.log(event.target);
  }

  get sidebarExpand(): boolean {
    return store.getters.sidebarExpand;
  }
}
</script>

<style lang="scss">
@import "node_modules/bootstrap/scss/bootstrap.scss";

body {
  overflow-x: hidden;
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  overflow-x: hidden;
}

.sidebar {
  width: 100%;
  height: 100vh;
  background-color: $secondary;
  color: $white;
}

.drag-and-drop {
  position: absolute;
  top: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.7);
}

.dragging {
  overflow-y: hidden;
}
</style>
