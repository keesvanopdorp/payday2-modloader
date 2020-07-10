<template>
  <div
    class="d-flex justify-content-center align-items-center flex-column"
    id="drag-and-drop"
    v-on:drop="drop"
    @dragover="dragOver"
    @drop="drop"
    @dragenter="dragEnter"
    @dragleave="dragLeave"
  >
    <div class="alert alert-danger w-100" v-if="this.error.length > 0">
      {{ this.error }}
      <button
        type="button"
        class="close"
        data-dismiss="alert"
        aria-label="Close"
      >
        <span aria-hidden="true">&times;</span>
      </button>
    </div>
    <h1 class="text-white text-center">{{ this.dragFilePath }}</h1>
    <div v-if="dragFilePath && !error">
      <label for="type-selector" class="text-white">type of mod: </label>
      <select
        class="form-control w-100"
        name="type-selector"
        id="type-selector"
        v-model="modType"
      >
        <option disabled selected="selected">choose a mod type</option>
        <option value="mod">mod</option>
        <option value="mod_override">mod_override</option>
      </select>
      <button
        type="button"
        @click="submit"
        :disabled="modType.length === 0"
        class="btn btn-success"
      >
        Add mod
      </button>
    </div>
    <i
      class="fas fa-times text-white"
      id="close-dragging"
      @click="closeDragging"
    ></i>
  </div>
</template>

<script lang="ts">
import Vue from "vue";
import path from "path";
export default Vue.extend({
  data: () => {
    return {
      dragFilePath: "",
      allowed: [".zip"],
      notSupported: [".rar", ".7z"],
      error: "",
      modType: ""
    };
  },
  methods: {
    dragOver(event: Event) {
      event.preventDefault();
    },
    drop(event: any) {
      event.preventDefault();
      event.stopPropagation();
      console.log(event);
      for (const f of event.dataTransfer.files) {
        // Using the path attribute to get absolute file path
        console.log("File Path of dragged files: ", f.path);
        this.dragFilePath = f.path;
      }
      const fileExtenstion = path.extname(this.dragFilePath);
      console.log(fileExtenstion);
      console.log(this.allowed.includes(fileExtenstion));
      if (!this.allowed.includes(fileExtenstion)) {
        if (this.notSupported.includes(fileExtenstion)) {
          this.error = `${this.notSupported.toString()} are currently not supported`;
        } else {
          this.error = `filetype not allowed only ${this.allowed.toString()}`;
        }
      } else {
        this.error = "";
      }
    },
    dragEnter(event: Event) {
      event.preventDefault();
    },
    dragLeave(event: Event) {
      event.preventDefault();
    },
    submit() {
      this.$parent.$emit("add mod", {
        dragging: false,
        dragFilePath: this.dragFilePath,
        modType: this.modType
      });
    },
    closeDragging() {
      this.$parent.$emit("close-dragging", {
        dragging: false
      });
    }
  }
});
</script>

<style scoped>
#drag-and-drop {
  position: absolute;
  top: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.7);
}

.alert {
  position: absolute;
  top: 0;
  z-index: 10;
}

#close-dragging {
  position: absolute;
  top: 1.75rem;
  right: 3rem;
  font-size: 2rem;
  z-index: 1;
}
</style>
