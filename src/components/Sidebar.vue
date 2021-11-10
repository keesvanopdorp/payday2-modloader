<template>
  <div class="sidebar">
    <h1>sidebar {{ sidebarExpand }}</h1>
    <button class="btn btn-primary" v-on:click="sidebarExpand = !sidebarExpand">
      test
    </button>
    <div class="d-flex flex-column my-5" id="sidebar-nav">
      <router-link to="/"> Mods </router-link>
      <router-link to="/"> Mods overrides </router-link>
      <router-link to="/"> settings </router-link>
    </div>
  </div>
</template>

<script lang="ts">
import store from "@/store";
import { Vue } from "vue-class-component";

export default class Sidebar extends Vue {
  get sidebarExpand(): boolean {
    return store.getters.sidebarExpand;
  }

  set sidebarExpand(value: boolean) {
    store.commit("setSidebarExpand", value);
  }
}
</script>

<style lang="scss" scoped>
#sidebar-nav a {
  text-decoration: none;
  color: #fff;
  font-size: 1.6rem;
}
</style>
