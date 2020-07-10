<template>
  <div class="bg-dark text-white">
    <h1 class="text-center">
      {{ this.type }} (total: {{ this.filteredMods.length }}
      {{ this.filteredMods.length >= 2 ? "mods" : "mod" }})
    </h1>
    <div class="d-flex justify-content-evenly">
      <label for="search">search</label>
      <input
        type="text"
        id="search"
        name="search"
        v-model="filter"
        class="form-control w-75"
      />
    </div>
    <div class="mx-auto card bg-dark" id="mod-list">
      <ul class="row">
        <li v-for="mod in filteredMods" :key="mod" class="my-3 col-4">
          <div class="dropdown d-inline">
            <button
              class="btn btn-success dropdown-toggle"
              type="button"
              id="dropdownMenuButton"
              data-toggle="dropdown"
              aria-expanded="false"
            >
              Enabled
            </button>
            <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton">
              <li>
                <button
                  class="btn-danger btn-block btn"
                  data-target="#delete-modal"
                  @click="selectedMod = mod"
                  data-toggle="modal"
                >
                  Delete mod
                </button>
              </li>
              <li><a class="dropdown-item" href="#">Another action</a></li>
              <li><a class="dropdown-item" href="#">Something else here</a></li>
            </ul>
          </div>
          <span class="ml-5">
            {{ mod }}
          </span>
        </li>
      </ul>
    </div>
    <div
      id="delete-modal"
      class="modal"
      ref="modal"
      tabindex="-1"
      data-keyboard="false"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header text-dark">
            Are you sure?
          </div>
          <div class="modal-body">
            <p class="text-dark">
              Are you sure you want to delete the mod. press escape or close to
              cancel this action
            </p>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              data-dismiss="modal"
            >
              Close
            </button>
            <button
              type="button"
              class="btn btn-danger"
              data-dismiss="modal"
              @click="
                $parent.$emit('delete mod', { mod: selectedMod, modType: type })
              "
            >
              Yes i'm sure
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script lang="ts">
import Vue, { PropType } from "vue";
export default Vue.extend({
  props: {
    mods: {
      default: [],
      type: Array as PropType<string[]>
    },
    type: {
      type: String
    }
  },
  data: () => {
    return {
      filter: "",
      selectedMod: ""
    };
  },
  computed: {
    filteredMods(): string[] {
      const regex = new RegExp(this.filter, "gi");
      return this.mods.filter(m => m.match(regex));
    }
  },
  created() {
    console.log(`hello from ${this.type}`);
    console.log(this);
  }
});
</script>
<style lang="scss">
#mod-list {
  max-width: 98vw;
}

li {
  list-style: none;
}
.dropdown-menu {
  padding: 0px !important;
}
</style>
