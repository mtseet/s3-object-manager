<script setup>
import InputText from 'primevue/inputtext';
import Button from 'primevue/button';
import Password from 'primevue/password';
import Select from 'primevue/select';
import Toast from 'primevue/toast';
import { useToast } from 'primevue/usetoast';
import { VueCookies} from 'vue-cookies';

</script>

<template>

    <div class="center-box">
        <div class="center-container">    
            <h3>S3 Object Manager Login</h3>
        
            <div class="input-group">
                <InputText type="text" required placeholder="access key" v-model="accessKey" />
            </div><br/>
            <div class="input-group">
                <label for="secret_key" class="form-label">Secret Key</label><br/>
                <Password v-model="secretKey" required :feedback="false" />
            </div><br/>
            <div class="input-group">
                <label for="region" class="form-label">Region</label><br/>
                <Select v-model="selectedRegion" :options="regions" required optionLabel="name" placeholder="Select a Region" class="w-full md:w-56" />
            </div><br/>
            <Button label="Login" @click="login()"/>
         </div>   
    </div>
    <Toast />

</template>

<style scoped>
.center-box {
  position: fixed;              /* or absolute */
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%); /* perfectly center */

  width: 400px;                 /* or any width */
  padding: 1.5rem;

  border: 1px solid #ccc;
  border-radius: 8px;

  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  background-color: #fff;
}

.center-container {
  margin-left:20%;
}

.input-group{
    line-height: 1.5; /* 1.5 × font size */
}

</style>

<script>

import {
  paginateListBuckets,
  S3Client,
  S3ServiceException
} from "@aws-sdk/client-s3";


export default {
  props: {
        s3Endpoint: { required: true, type: String }
  },
  data() {
    return {
        accessKey:"",
        secretKey: "",
        selectedRegion: {},
        endpoint:this.s3Endpoint,
        regions:[                              
                    { name: 'Local my-region', value: 'my-region' },
                    { name: 'US East (N. Virginia) us-east-1', value: 'us-east-1' },
                    { name: 'US East (Ohio) us-east-2', value: 'us-east-2' },
                    { name: 'US West (N. California) us-west-1', value: 'us-west-1' },
                    { name: 'US West (Oregon) us-west-2', value: 'us-west-2' },
                    { name: 'Africa (Cape Town) af-south-1', value: 'af-south-1' },
                    { name: 'Asia Pacific (Hong Kong) ap-east-1', value: 'ap-east-1' },
                    { name: 'Asia Pacific (Mumbai) ap-south-1', value: 'ap-south-1' },
                    { name: 'Asia Pacific (Osaka) ap-northeast-3', value: 'ap-northeast-3' },
                    { name: 'Asia Pacific (Seoul) ap-northeast-2', value: 'ap-northeast-2' },
                    { name: 'Asia Pacific (Singapore) ap-southeast-1', value: 'ap-southeast-1' },
                    { name: 'Asia Pacific (Sydney) ap-southeast-2', value: 'ap-southeast-2' },
                    { name: 'Asia Pacific (Tokyo) ap-northeast-1', value: 'ap-northeast-1' },
                    { name: 'Canada (Central) ca-central-1', value: 'ca-central-1' },
                    { name: 'Europe (Frankfurt) eu-central-1', value: 'eu-central-1' },
                    { name: 'Europe (Ireland) eu-west-1', value: 'eu-west-1' },
                    { name: 'Europe (London) eu-west-2', value: 'eu-west-2' },
                    { name: 'Europe (Milan) eu-south-1', value: 'eu-south-1' },
                    { name: 'Europe (Paris) eu-west-3', value: 'eu-west-3' },
                    { name: 'Europe (Stockholm) eu-north-1', value: 'eu-north-1' },
                    { name: 'Middle East (Bahrain) me-south-1', value: 'me-south-1' },
                    { name: 'South America (São Paulo) sa-east-1', value: 'sa-east-1' },
                    { name: 'AWS GovCloud (US-East) us-gov-east-1', value: 'us-gov-east-1' },
                    { name: 'AWS GovCloud (US) us-gov-west-1', value: 'us-gov-west-1' } 
        ],
        toast: undefined
    }
  },
  mounted(){
    this.toast = useToast();

    this.accessKey = window.$cookies.get('access_key');
    this.secretKey = window.$cookies.get('secret_key');
    this.selectedRegion = { name:window.$cookies.get('region-name'), value:window.$cookies.get('region')};

    this.credentialsWork(true)
       
  },
  methods: {
    async credentialsWork(notify){

        if(this.selectedRegion.name==null || this.selectedRegion.name=="null" || this.selectedRegion.value==null || this.selectedRegion.value=="null")
        {    
            this.$emit('loginChanged', false)
           
            return false
        }

        var client = undefined
        
        if(this.endpoint==""){
            client = new S3Client({region: this.selectedRegion.value,
                credentials: {
                    accessKeyId: this.accessKey,
                    secretAccessKey: this.secretKey
                    }
                });
        }else{
            client = new S3Client({region: this.selectedRegion.value,
                credentials: {
                    accessKeyId: this.accessKey,
                    secretAccessKey: this.secretKey
                    },
                    endpoint: this.endpoint,
                    forcePathStyle: true 
                });
        }

        const v = await this.listBuckets(client)
        if(notify) this.$emit('loginChanged', v)
      
        return v;
    },
    async login(){
        
        try{

            const v = await this.credentialsWork(false)
            if(!v)
            {
                this.toast.add({
                    severity: 'error',      // success, info, warn, error
                    summary: 'Autentication Error',
                    detail: 'Check your credentials or endpoint!',
                    life: 3000                // duration in ms
                })
            }else{

                const parsedUrl = new URL(this.s3Endpoint);
                const domain = parsedUrl.host.split(":")[0];

                window.$cookies.set('access_key', this.accessKey, 
                    '1d',           
                    '/', 
                    domain,
                    true,              
                    'None'
                );

                window.$cookies.set('secret_key', this.secretKey,
                    '1d',           
                    '/', 
                    domain,
                    true,              
                    'None'
                );

                window.$cookies.set('region', this.selectedRegion.value, 
                    '30d',           
                    '/', 
                    domain,
                    true,              
                    'None'     
                );

                window.$cookies.set('region-name', this.selectedRegion.name, 
                    '30d',           
                    '/', 
                    domain,
                    true,              
                    'None'     
                );    

                this.$emit('loginChanged', true)
            }
        }catch (e){
            this.toast.add({
                    severity: 'error',      // success, info, warn, error
                    summary: 'Autentication Error',
                    detail: "Please supply all credential details",
                    life: 3000                // duration in ms
                })
        }

    },
    async listBuckets(client){
        
        /** @type {?import('@aws-sdk/client-s3').Owner} */
        let Owner = null;

        /** @type {import('@aws-sdk/client-s3').Bucket[]} */
        const Buckets = [];

        try {
            const paginator = paginateListBuckets({ client }, {});

            for await (const page of paginator) {
            if (!Owner) {
                Owner = page.Owner;
            }

            Buckets.push(...page.Buckets);
            }

            console.log(
            `${Owner.DisplayName} owns ${Buckets.length} bucket${
                Buckets.length === 1 ? "" : "s"
            }:`,
            );
            return true
        } catch (caught) {
            if (caught instanceof S3ServiceException) {
            console.error(
                `Error from S3 while listing buckets.  ${caught.name}: ${caught.message}`,
            );
            } else {
           
            }
        }
        return false
    }
  }
}
</script>