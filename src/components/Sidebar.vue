<template>
  <div class="sidebar">
    <h1>sidebar {{ sidebarExpand }}</h1>
    <button class="btn btn-primary" v-on:click="sidebarExpand = !sidebarExpand">
      test
    </button>
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
