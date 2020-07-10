<template>
  <div
    id="app"
    @dragover="dragOver"
    :class="dragging === true ? 'dragging' : null"
  >
    <router-view />
    <ModList :mods="mods" :type="String('mods')" />
    <ModList :mods="modsOverides" :type="String('mods_overrides')" />
    <div class="alert-alert-success" v-if="this.message.length > 0">
      {{ this.message }}
    </div>
    <DragAndDrop v-if="this.dragging" :filePath="this.dragFilePath" />
  </div>
</template>

<script lang="ts">
import Vue from "vue";
import router from "@/router";
import store from "@/store";
import fs from "fs";
import path from "path";
import extract from "extract-zip";
import { remote } from "electron";
import ModList from "@/components/ModList.vue";
import "../node_modules/bootstrap/dist/js/bootstrap";
import DragAndDrop from "@/components/DragAndDrop.vue";

export default Vue.extend({
  components: {
    ModList,
    DragAndDrop
  },
  store,
  router,
  data: () => {
    return {
      appName: "payday2-modloader" as string,
      configPath: "" as string,
      gamedir: "" as string,
      mods: [] as string[],
      modsOverides: [] as string[],
      modsFolder: "" as string,
      modsOveridesFolder: "" as string,
      filters: ["logs", "saves", "downloads"],
      dragging: false,
      dragFilePath: "",
      modType: "",
      message: ""
    };
  },
  async created() {
    this.getConfig();
    this.$on("add mod", async (data: any) => {
      this.dragFilePath = data.dragFilePath;
      this.dragging = data.dragging;
      this.modType = data.modType;
      const path =
        this.modType === "mod" ? this.modsFolder : this.modsOveridesFolder;
      try {
        await extract(this.dragFilePath, { dir: path });
      } catch (e) {
        console.error(e);
      }
      this.message = "Added mod";
      this.getMods();
    });
    this.$on("close-dragging", (data: any) => {
      this.dragging = data.dragging;
    });

    this.$on("delete mod", (data: any) => {
      this.deleteMod(data.mod, data.modType);
    });
  },
  methods: {
    dragOver(event: Event) {
      event.preventDefault();
      console.log("drag over");
      if (!this.dragging) {
        this.dragging = true;
      }
    },
    async getConfig(): Promise<void> {
      this.configPath = path.join(
        remote.app.getPath("userData"),
        "config.json"
      );
      if (!fs.existsSync(this.configPath)) {
        const path = await remote.dialog.showOpenDialog({
          properties: ["openDirectory"]
        });
        fs.writeFileSync(
          this.configPath,
          JSON.stringify({ gamedir: path.filePaths[0] })
        );
        this.gamedir = path.filePaths[0];
      } else {
        const { gamedir } = JSON.parse(
          fs.readFileSync(this.configPath, { encoding: "utf-8" })
        );
        this.gamedir = gamedir;
      }
      this.modsFolder = path.join(this.gamedir, "mods");
      this.modsOveridesFolder = path.join(
        this.gamedir,
        "assets",
        "mod_overrides"
      );
      this.getMods();
    },
    getMods(): void {
      console.log(this.modsFolder);
      try{
        this.mods = fs.readdirSync(this.modsFolder) as string[];
      } catch (e) {
        fs.mkdirSync(this.modsFolder);
      }
      try{
        this.modsOverides = fs.readdirSync(this.modsOveridesFolder) as string[];
      } catch (e) {
        fs.mkdirSync(this.modsOveridesFolder);
      }
      this.filters.forEach(filter => {
        if (this.mods.includes(filter)) {
          this.mods.splice(this.mods.indexOf(filter), 1);
        }
      });
    },
    deleteMod(mod: string, modType: string): void {
      const path = `${
        modType === "mod" ? this.modsFolder : this.modsOveridesFolder
      }\\${mod}`;
      try {
        fs.rmdirSync(path, { recursive: true });
      } catch (e) {
        console.error(e);
      }
      this.getMods();
    }
  }
});
</script>
<style lang="scss">
@import "../node_modules/bootstrap/scss/bootstrap.scss";
@import "../node_modules/@fortawesome/fontawesome-free/css/all.css";
body {
  overflow-x: hidden;
}
#app {
  overflow-x: hidden;
}
.dragging {
  overflow-y: hidden;
}
</style>
