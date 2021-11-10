import { IConfig } from "@types";
import { createStore } from "vuex";

interface State {
  config: IConfig;
  applicationBasePath: string;
  configPath: string;
  sidebarExpand: boolean;
  modsFolder: string;
  modOverridesFolder: string;
  mods: string[];
}

export default createStore<State>({
  state: {
    config: {
      gameDir: "",
    },
    applicationBasePath: "",
    configPath: "",
    sidebarExpand: true,
    modsFolder: "",
    modOverridesFolder: "",
    mods: [],
  },
  mutations: {
    setGameDir: (state: State, gameDir: string) => {
      state.config.gameDir = gameDir;
    },
    setApplicationBasePath: (state: State, basePath: string) => {
      state.applicationBasePath = basePath;
    },
    setConfigPath: (state: State, path: string) => {
      state.configPath = path;
    },
    setConfig: (state: State, config: IConfig) => {
      state.config = config;
    },
    setSidebarExpand: (state: State, value: boolean) => {
      state.sidebarExpand = value;
    },
    setModFolder: (state: State, modFolder: string) => {
      state.modsFolder = modFolder;
    },
    setModOverridesFolder: (state: State, modFolder: string) => {
      state.modOverridesFolder = modFolder;
    },
    setMods: (state: State, mods: string[]) => {
      state.mods = mods;
    },
  },
  actions: {},
  modules: {},
  getters: {
    getConfig: (state): IConfig => {
      return state.config;
    },
    sidebarExpand: (state): boolean => {
      return state.sidebarExpand;
    },
  },
});
