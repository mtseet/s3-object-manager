<script setup>
import Main from './components/Main.vue'
import Login from './components/Login.vue'
</script>

<template>
  <div v-if="!hasCredentails">
  <Login @loginChanged="loginChanged" :s3Endpoint="s3Endpoint"/>
  </div>
  <div v-if="hasCredentails">
  <Main  @logout="logout" :s3Endpoint="s3Endpoint"/>  
  </div>
</template>

<style scoped>

</style>

<script>

export default {
  props: {
      s3Endpoint: { required: true, type: String },
  },
  data() {
    return {
      s3Endpoint: this.s3Endpoint,
      hasCredentails: false
    }
  },
  mounted(){

  },
  methods: {
    loginChanged(success) {
        
        this.hasCredentails = success;
    },
    logout(){
      window.$cookies.remove('access_key', "");
      window.$cookies.remove('secret_key', "");
      this.hasCredentails = false
    }
  }
}
</script>