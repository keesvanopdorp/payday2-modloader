import { IConfig } from "@types";
import { createStore } from "vuex";

interface State {
  config: IConfig;
  applicationBasePath: string;
  configPath: string;
  sidebarExpand: boolean;
}

export default createStore<State>({
  state: {
    config: {
      gameDir: "",
    },
    applicationBasePath: "",
    configPath: "",
    sidebarExpand: true,
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
