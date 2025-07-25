import './assets/main.css'

import { createApp } from 'vue'
import App from './App.vue'
import PrimeVue from 'primevue/config';
import Aura from '@primeuix/themes/aura';
import 'primeicons/primeicons.css'
import { definePreset } from '@primeuix/themes';
import ConfirmationService from 'primevue/confirmationservice';
import ToastService from 'primevue/toastservice';
import { VueCookies} from 'vue-cookies';

const MyPreset = definePreset(Aura, {
    //Your customizations, see the following sections for examples
    semantic: {
        primary: {
            50: '{indigo.50}',
            100: '{indigo.100}',
            200: '{indigo.200}',
            300: '{indigo.300}',
            400: '{indigo.400}',
            500: '{indigo.500}',
            600: '{indigo.600}',
            700: '{indigo.700}',
            800: '{indigo.800}',
            900: '{indigo.900}',
            950: '{indigo.950}'
        }
    }
});

const s3Endpoint = import.meta.env.VITE_S3_ENDPOINT;
if(s3Endpoint=="")
    console.log("Using aws for endpoint!") 
else if(!s3Endpoint)
    console.log("S3 Endpoint not defined")

const app = createApp(App,{s3Endpoint:s3Endpoint})
app.use(PrimeVue, {
    theme: {
        preset: MyPreset
    }
});
app.use(VueCookies)
app.use(ConfirmationService);
app.use(ToastService);
app.mount('#app')
