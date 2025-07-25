<script setup>
import Button from 'primevue/button';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import ColumnGroup from 'primevue/columngroup';   // optional
import Row from 'primevue/row';                   // optional
import FileUpload from 'primevue/fileupload';
import Listbox from 'primevue/listbox';
import InputText from 'primevue/inputtext';
import Menu from 'primevue/menu';
import Menubar from 'primevue/menubar';
import Avatar from 'primevue/avatar';
import Badge from 'primevue/badge';
import Checkbox from 'primevue/checkbox';
import ConfirmDialog from 'primevue/confirmdialog';
import Toast from 'primevue/toast';
import ProgressBar from 'primevue/progressbar';

import { useConfirm } from "primevue/useconfirm";
import { useToast } from 'primevue/usetoast';

</script>

<template>
    <Menubar :model="menuBarItems">
      <template #start>
          <img src="/favicon.ico" style="width:32px;height:32px"><h3 style="display:inline">S3 Object Manager</h3>
      </template>
      <template #item="{ item, props, hasSubmenu, root }">
          <a v-ripple class="flex items-center" v-bind="props.action">
              <span>{{ item.label }}</span>
              <Badge v-if="item.badge" :class="{ 'ml-auto': !root, 'ml-2': root }" :value="item.badge" />
              <span v-if="item.shortcut" class="ml-auto border border-surface rounded bg-emphasis text-muted-color text-xs p-1">{{ item.shortcut }}</span>
              <i v-if="hasSubmenu" :class="['pi pi-angle-down ml-auto', { 'pi-angle-down': root, 'pi-angle-right': !root }]"></i>
          </a>
      </template>
      <template #end>
          <div class="flex items-center gap-2">
              
              <Avatar image="/avatars/memo_1.png" shape="circle" @click="logoutToggleMenu"/>
              
          </div>
      </template>
  </Menubar>
  
  <Menu ref="logoutMenu" id="overlay_menu_2" :model="logoutMenuItems" :popup="true" />

  <div class="container">
    <div class="sidebar">
      <h3>Buckets</h3>
      <IconField>
          <InputIcon>
              <i class="pi pi-search" />
          </InputIcon> &nbsp;
          <InputText v-model="bucketFilter" placeholder="Bucket Search" />
      </IconField>&nbsp;
      <div style="height: 180px; overflow: auto"><br/>
      <div v-for="bucket in buckets">
        <span v-if="bucketFilter.trim().length>0 && bucket.Name.includes(bucketFilter)">
        <a href="#" @click="setAndListObjecst(bucket)">{{bucket.Name}}</a>
        <br/><br/>
        </span>
        <span v-if="bucketFilter.trim().length<1">
        <a v-if="bucketFilter.trim().length<1" href="#" @click="setAndListObjecst(bucket)">{{bucket.Name}}</a>   
         <br/><br/>     
        </span>
      </div>
      </div>
      <br/>
      <InputText type="text" placeholder="bucket" v-model="newBucketName" />
      <Button label="Create" @click="createBucket()"/>

      <h4>Uploads</h4>

      <div style="width: 300px">
      <FileUpload ref="fileUpload" name="files[]" :customUpload="true" @uploader="uploadObject"  :multiple="true" :maxFileSize="1000000000" >
        <template #empty>
        Drag and drop files here ...        
        </template>
      </FileUpload>
      <progress id="progress" value="0" max="100"></progress>
      <InputText type="text" placeholder="Directory" v-model="uploadDirectory" />
      </div>
    </div>
    <div class="main">
        
        Bucket objects for <h4 style="display: inline;" v-if="selectedBucket"> {{selectedBucket.Name}}</h4>
        <!-- created <span v-if="selectedBucket">{{selectedBucket.CreationDate.toLocaleString()}}</span> -->
        
        <br/> <br/>
        
        <DataTable v-model:filters="objectFilters" :value="objects" paginator :rows="5" :rowsPerPageOptions="[5, 10, 20, 50]" tableStyle="min-width: 50rem">
          <template #header>
              <div class="flex justify-between">
                  <IconField>
                      <InputIcon>
                          <i class="pi pi-search" />
                      </InputIcon> &nbsp;
                      <InputText v-model="objectFilters['global'].value" placeholder="Object Search" />
                  </IconField>&nbsp;
                  <Button type="button" severity="secondary"  icon="pi pi-refresh" @click="listObjects" />&nbsp;
                  <Button icon="pi pi-download" @click="downloadObjects()"/>&nbsp;
                  <Button type="button" severity="secondary"  icon="pi pi-ellipsis-v" @click="bucketToggleMenu" aria-haspopup="true" aria-controls="overlay_menu" />
                  <Menu ref="bucketMenu" id="overlay_menu" :model="bucketMenuItems" :popup="true" />&nbsp;
                  <Button icon="pi pi-trash" @click="deleteObjectConfirmation()"/>
              </div>
          </template>
          <template #empty> No objects found. </template>
          <template #loading> Loading objects. Please wait. </template>
          <Column field="Key" header="Name" style="width: 25%">
          <template #body="slotProps">
              <Checkbox binary  @change="objectSelected" :value="slotProps.data.Key"/> {{slotProps.data.Key}}
          </template>
          </Column>
          <Column field="Size" header="Size" style="width: 25%"></Column>
          <Column field="LastModified" header="Updated Date" style="width: 25%">         
          <template #body="slotProps">
              {{slotProps.data.LastModified.toLocaleString()}}
          </template>
          </Column>
          <Column field="StorageClass" header="Storage Class" style="width: 25%"></Column>
          <Column field="ETag" header="ETag" style="width: 25%"></Column>
          <Column field="" header="" style="width: 25%">
          <template #body="slotProps">
              <Button icon="pi pi-copy" severity="secondary" @click="showPreSignedUrl(slotProps.data.Key)"/>
          </template>
          </Column>

          
        </DataTable>
        <ConfirmDialog></ConfirmDialog>
        
    </div>
  </div>
  <Toast />

</template>

<style scoped>
  .container {
    display: grid;
    grid-template-columns: 1fr; /* default 1 column on small screens */
    gap: 1rem;
  }

  @media (min-width: 600px) {
    .container {
      grid-template-columns: 20% 80%; /* two columns on wider screens */
    }
  }

  .sidebar {
    padding: 1rem;
  }

  .main {
    padding: 1rem;
  }

  progress {
    width: 100%;
    height: 15px;
    appearance: none;
  }

  /* Chrome/Safari */
  progress::-webkit-progress-bar {
    background-color: var(--p-button-primary-background);
    border-radius: 10px;
  }

  progress::-webkit-progress-value {
    background-color: var(--p-button-primary-background); 
    border-radius: 10px;
  }

  /* Firefox */
  progress::-moz-progress-bar {
    background-color: var(--p-button-primary-background);
    border-radius: 10px;
  }

  

</style>

<script>

import {
  paginateListBuckets,
  paginateListObjectsV2,
  S3Client,
  S3ServiceException,
  CreateBucketCommand,
  PutObjectCommand,
  ListObjectsCommand,
  CopyObjectCommand,
  GetObjectCommand,
  DeleteObjectsCommand,
  DeleteObjectCommand,
  DeleteBucketCommand,
  waitUntilObjectNotExists,
  BucketAlreadyExists,
  BucketAlreadyOwnedByYou,
  waitUntilBucketExists,
  NoSuchKey
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { Upload } from "@aws-sdk/lib-storage";
import { XhrHttpHandler } from "@aws-sdk/xhr-http-handler";

export default {
  props: {
    s3Endpoint: { required: true, type: String },
  },
  data() {
    return {
      s3Client: undefined,
      s3Endpoint: this.s3Endpoint,
      objects: [],
      selectedBucket:"",
      buckets:[],
      uploadDirectory:"",
      newBucketName: "",
      selectedObjects:[],
      deleteConfirmDialog:undefined,
      bucketMenuItems: [{
          label: 'Delete bucket',
          icon: 'pi pi-trash',
          command: () => { this.deleteBucketConfirmation() },
          disabled: false,
          visible: true
        }
      ],
      logoutMenuItems:[
        {
          label: 'Logout',
          icon: 'pi pi-sign-out',
          command: () => { this.$emit('logout')}
        }
      
      ],
      objectFilters: {
        'global': { value: null }
      },
      bucketFilter:"",
      menuBarItems :[]
    }
  },
  mounted(){
      this.toast = useToast();
      this.deleteConfirmDialog = useConfirm();
      this.s3Client = new S3Client({region: 'us-west-2',
        credentials: {
              accessKeyId: "userkey",
              secretAccessKey: "password@user"
            },
            endpoint: this.s3Endpoint,
            forcePathStyle: true 
        });
      this.listBuckets()
      
  },
  methods: {
    async showToast(title,msg,severity){
      this.toast.add({
                    severity: severity,      // success, info, warn, error
                    summary: title,
                    detail: msg,
                    life: 3000                // duration in ms
                })
    },
    async bucketToggleMenu(event) {
      this.$refs.bucketMenu.toggle(event);
    },
    async logoutToggleMenu(event) {
      this.$refs.logoutMenu.toggle(event);
    },    
    async createBucket(){
          const client = this.s3Client
          const bucketName = this.newBucketName
          try {
            const { Location } = await client.send(
              new CreateBucketCommand({
                // The name of the bucket. Bucket names are unique and have several other constraints.
                // See https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
                Bucket: bucketName,
              }),
            );
            await waitUntilBucketExists({ client }, { Bucket: bucketName });
            console.log(`Bucket created with location ${Location}`);
            this.listBuckets()
            this.newBucketName=""
            this.showToast("Info",`Bucket ${bucketName} created!`,'success')
          } catch (caught) {
            if (caught instanceof BucketAlreadyExists) {
              console.error(
                `The bucket "${bucketName}" already exists in another AWS account. Bucket names must be globally unique.`,
              );
              this.showToast("Info",`${bucketName} already exists in another account!`,'error')
            }
            // WARNING: If you try to create a bucket in the North Virginia region,
            // and you already own a bucket in that region with the same name, this
            // error will not be thrown. Instead, the call will return successfully
            // and the ACL on that bucket will be reset.
            else if (caught instanceof BucketAlreadyOwnedByYou) {
              console.error(
                `The bucket "${bucketName}" already exists in this AWS account.`,
              );
               this.showToast("Info",`${bucketName} already exists!`,'error')
            } else {
              this.showToast("Info",`Error creating ${bucketName}!`,'error')
              throw caught;
               
            }
          }

    },
    async deleteBucketConfirmation(){
        var deleteBucket = this.deleteBucket
        var bucketName = this.selectedBucket.Name
        this.deleteConfirmDialog.require({
          message: 'Are you sure you want to delete the selected bucket?',
          header: 'Confirmation',
          icon: 'pi pi-exclamation-triangle',
          acceptLabel: 'Yes',
          rejectLabel: 'No',
          accept: () => {
            deleteBucket(bucketName)
          },
          reject: () => {
            
          },
          modal:true
        });
    },
    async deleteBucket(bucketName){
        
        const client = this.s3Client
        const command = new DeleteBucketCommand({
          Bucket: bucketName,
        });

        try {
          await client.send(command);
          console.log("Bucket was deleted.");
          this.listBuckets()
          this.showToast("Info",`${bucketName} successfully deleted!`,'success')
        } catch (caught) {
          if (
            caught instanceof S3ServiceException &&
            caught.name === "NoSuchBucket"
          ) {
            console.error(
              `Error from S3 while deleting bucket. The bucket doesn't exist.`,
            );
            this.showToast("Info",`The bucket ${bucketName} does not exist!`,'error')
          } else if (caught instanceof S3ServiceException) {
            console.error(
              `Error from S3 while deleting the bucket. ${caught.name}: ${caught.message}`,
            );
            this.showToast("Info",`Error deleting ${bucketName} ${caught.name}: ${caught.message}!`,'error')
          } else {
            this.showToast("Info",`Error deleting ${bucketName}!`,'error')
            throw caught;
            
          }
        }
    },
    async listBuckets(){
        this.buckets = []        
        /** @type {?import('@aws-sdk/client-s3').Owner} */
        let Owner = null;

        /** @type {import('@aws-sdk/client-s3').Bucket[]} */
        const Buckets = [];

        try {
          const client = this.s3Client
          const paginator = paginateListBuckets({client }, {});

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
          console.log(`${Buckets.map((b) => ` • ${b.Name}`).join("\n")}`);
          this.buckets = Buckets;

          if(this.buckets.length > 0) {
            this.selectedBucket = this.buckets[0]
            await this.listObjects()
          }
          
        } catch (caught) {
          if (caught instanceof S3ServiceException) {
            console.error(
              `Error from S3 while listing buckets.  ${caught.name}: ${caught.message}`,
            );
            this.showToast("Info",`Error listing ${bucketName} ${caught.name}: ${caught.message}!`,'error')
          } else {
            this.showToast("Info",`Error listing ${bucketName}!`,'error')
            throw caught;
          }
        }

    },
    async setAndListObjecst(selectedBucket){
      this.selectedBucket = selectedBucket
      this.listObjects()
    },
    async listObjects(){
 
        this.selectedObjects=[]

        this.objects = []
        /** @type {string[][]} */
        const objects = [];
        try {
          const client = this.s3Client
          const pageSize = 1000;
          const paginator = paginateListObjectsV2(
            { client, /* Max items per page */ pageSize: Number.parseInt(pageSize) },
            { Bucket: this.selectedBucket.Name},
          );

          for await (const page of paginator) {
            if (!page.Contents)
               return
            objects.push(...page.Contents);
          }
          objects.forEach(o => {
            o.ETag = o.ETag.replaceAll('"','')
            //console.log(o);
          });
          this.objects = objects;
        } catch (caught) {
          if (
            caught instanceof S3ServiceException &&
            caught.name === "NoSuchBucket"
          ) {
            console.error(
              `Error from S3 while listing objects for "${this.selectedBucket.Name}". The bucket doesn't exist.`,
            );
            this.showToast("Info",`Error listing objects in ${bucketName}, bucket does not exist!`,'error')
          } else if (caught instanceof S3ServiceException) {
            console.error(
              `Error from S3 while listing objects for "${this.selectedBucket.Name}".  ${caught.name}: ${caught.message}`,
            );
            this.showToast("Info",`Error listing objects in ${bucketName}, ${caught.name}: ${caught.message}!`,'error')
          } else {
            this.showToast("Info",`Error listing objects in ${bucketName}!`,'error')
            throw caught;
          }
        }
    },
    async uploadObject(event){
        var noerror=true
        this.uploadDirectory=this.uploadDirectory.trim()
        if(this.uploadDirectory.length>0 && !this.uploadDirectory.endsWith('/')){
          this.uploadDirectory+="/"
        }        

        for (const file of event.files) {
        
            document.getElementById('progress').value=0

            const key = file.name
            const client = this.s3Client
            
            const parallelUploads3 = new Upload({
                client: this.s3Client,
                params: {
                  Bucket: this.selectedBucket.Name,
                  Key: this.uploadDirectory+key,
                  Body: file,
                },
              });

            try {
              
              parallelUploads3.on("httpUploadProgress", (progress) => {
                    const percentage = (progress.loaded / progress.total) * 100;
                    console.log(`Upload Progress: ${percentage.toFixed(0)}%`);
                    document.getElementById('progress').value=parseInt(percentage)

              });

              await parallelUploads3.done();

              console.log("Upload completed");  
              document.getElementById('progress').value=0

              
            } catch (caught) {
              noerror = false
              if (
                caught instanceof S3ServiceException &&
                caught.name === "EntityTooLarge"
              ) {
                console.error(
                  `Error from S3 while uploading object to ${this.selectedBucket.Name}. \
          The object was too large. To upload objects larger than 5GB, use the S3 console (160GB max) \
          or the multipart upload API (5TB max).`,
                );
                this.showToast("Info",`File upload object ${key}: object too large!`,'error')
              } else if (caught instanceof S3ServiceException) {
                console.error(
                  `Error from S3 while uploading object to ${this.selectedBucket.Name}.  ${caught.name}: ${caught.message}`,
                );
                this.showToast("Info",`File upload object ${key}: ${caught.name}: ${caught.message}!`,'error')
              } else {
                this.showToast("Info",`File upload object ${key}!`,'error')
                throw caught;
              }
            }
        }

        this.$refs.fileUpload.clear();
        this.$refs.fileUpload.uploadedFileCount = 0;
        this.uploadDirectory=""
        this.listObjects()

        if(noerror) this.showToast("Info","Objects uploaded successfully!",'success')

    },
    async deleteObjectConfirmation(){
        if(this.selectedObjects.length<1)
          return
        var deleteObjects = this.deleteObjects
        this.deleteConfirmDialog.require({
          message: 'Are you sure you want to delete the selected objects?',
          header: 'Confirmation',
          icon: 'pi pi-exclamation-triangle',
          acceptLabel: 'Yes',
          rejectLabel: 'No',
          accept: () => {
            deleteObjects()          },
          reject: () => {
            
          },
          modal:true
        });
    },
    async deleteObjects(){
       
        if(this.selectedObjects.length<1)
          return
        var noerror=true
        for(var i=0;i<this.selectedObjects.length;i++){
           
            const key = this.selectedObjects[i]
            const client = this.s3Client
            const bucketName = this.selectedBucket.Name
            try {
              await client.send(
                new DeleteObjectCommand({
                  Bucket: this.selectedBucket.Name,
                  Key: key,
                }),
              );
              await waitUntilObjectNotExists(
                { client },
                { Bucket: this.selectedBucket.Name, Key: key },
              );
              // A successful delete, or a delete for a non-existent object, both return
              // a 204 response code.
              console.log(
                `The object "${key}" from bucket "${bucketName}" was deleted, or it didn't exist.`,
              );

            } catch (caught) {
              noerror=false
              if (
                caught instanceof S3ServiceException &&
                caught.name === "NoSuchBucket"
              ) {
                console.error(
                  `Error from S3 while deleting object from ${bucketName}. The bucket doesn't exist.`,
                );
                this.showToast("Info",`Error deleting object ${key}!, the bucket does not exist!`,'error')
              } else if (caught instanceof S3ServiceException) {
                console.error(
                  `Error from S3 while deleting object from ${bucketName}.  ${caught.name}: ${caught.message}`,
                );
                this.showToast("Info",`Error deleting object ${key}!, ${caught.name}: ${caught.message}!`,'error')
              } else {
                this.showToast("Info",`Error deleting object ${key}!`,'error')
                throw caught;
              }
            }
        }
        this.listObjects()
        if(noerror) this.showToast("Info","Objects deleted successfully!",'success')
    },
    async downloadObjects(){
      if(this.selectedObjects.length<1)
          return
      var noerror = true
      for(var i=0;i<this.selectedObjects.length;i++){
            const key = this.selectedObjects[i]
            const client = this.s3Client
            const bucketName = this.selectedBucket.Name
            try {
              const response = await client.send(
                new GetObjectCommand({
                  Bucket: bucketName,
                  Key: key,
                }),
              );
            
              const stream = response.Body;
              const blob = await new Response(stream).blob();
                
              // Create an object URL for the Blob
              const url = window.URL.createObjectURL(blob);

              // Create a temporary anchor and click it to trigger download
              const a = document.createElement("a");
              a.href = url;
              a.download = key; // you can set the default name for the downloaded file
              document.body.appendChild(a);
              a.click();

              // Clean up
              a.remove();
              window.URL.revokeObjectURL(url);


            } catch (caught) {
              if (caught instanceof NoSuchKey) {
                console.error(
                  `Error from S3 while getting object "${key}" from "${bucketName}". No such key exists.`,
                );
                if(noerror) this.showToast("Info",`Error downloading ${key}, object does not exist!`,'error')
              } else if (caught instanceof S3ServiceException) {
                console.error(
                  `Error from S3 while getting object from ${bucketName}.  ${caught.name}: ${caught.message}`,
                );
                if(noerror) this.showToast("Info",`Error downloading ${key}, ${caught.name}: ${caught.message}!`,'error')
              } else {
                if(noerror) this.showToast("Info",`Error downloading ${key}!`,'error')
                throw caught;
              }
          }      
      }
      this.listObjects()
      if(noerror) this.showToast("Info","Objects downloaded successfully!",'success')
    },
    async objectSelected(event){
        const key = event.currentTarget.value
        if(!event.currentTarget.checked){
          this.selectedObjects=this.selectedObjects.filter(function (item) {
                  return item!=key
              });
        }
        else
         this.selectedObjects.push(key)

        console.log("Selected Objects")
        console.log("------------")
        for(var i=0;i<this.selectedObjects.length;i++)
          console.log(this.selectedObjects[i]) 
    },
    async generatePresignedUrl(bucketName, objectKey, expiresInSeconds = 60) {
      // Create the command to get the object
      const command = new GetObjectCommand({
        Bucket: bucketName,
        Key: objectKey,
      });

      // Generate the presigned URL with expiration (default 1 hour)
      const url = await getSignedUrl(this.s3Client, command, { expiresIn: expiresInSeconds });
      return url;
    },
    async showPreSignedUrl(key){
      const url = await this.generatePresignedUrl(this.selectedBucket.Name, key)
      alert(url)
    }
  }
}
</script>