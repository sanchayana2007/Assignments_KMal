# Assignments_KMal
This has the source code and read me for the assignmnets provided for kpmg malta . The section is divided into 3 sections for the 3 questiosn provided



GCP Architecture : 
A 3 tier environment is a common setup. Use a tool of your choosing/familiarity to create these resources. Please remember we will not be judging on the outcome but more on the approach, style and reproducibility.

The following is the diagram of  a 3 tier environment . This infrastructure is shown below . 

Presentation Tier : 
The Front End tier is made scalable by using Instance groups for running the front end. It has a Load balancer which will distribute the external  load based on the health of the instances provided 

Application Backend tier:
The Backend is made scalable by using Instance groups for running the front end. It has a Load balancer which will distribute the internal load based on the health of the instances , it can scale up and down . 

Data Tier:
The data tier will usually have a database which will be encrypted with a vendor  managed key. It stores the application and provides the output . I have provided a GCP PAAS (cloud sql for database )





There are several other pieces to make this system robust and complete like 
High Availability :
For High availability the architecture just needs to be replicated across 2 zones and global load balancer in the front . This makes a primary and a secondary backup . The database on the secondary is kept updated and can be used for read only .


Backup and recovery : 
 The DR and Back for compute resources that need to be created with persistent  by  creating  snapshots of persistent disks to protect against data loss due to user error.
User management :
Onboarding users on the cloud and setting their roles and permissions based on the organization . 
Security and caching :


A cloud CDN can be used to further applied users a better feel if using static files . For security we can google KMS store passwords , certificates and security token.  



Details of creating the Infrastructure using gcloud cli 



Download and install gcloud CLI in the local system

>> curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-407.0.0-linux-x86_64.tar.gz



Untar and install gcloud 



Initialize the gcloud 
>> gcloud init // Initialize, authorize, and configure the gcloud CLI.
>> gcloud auth login  // ** We need this account a login/passwd 


Create a Project and set a region for the project and Billing API Enable 










Create Admin User Service Account creation 
Go to the projects portal and create a service account and download the keys for the service account 





Activate the service account using the gcloud 
>> gcloud auth activate-service-account SERVICE_ACCOUNT@DOMAIN.COM --key-file=/path/key.json --project=PROJECT_ID
Attach Roles to the service account 

>> gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \ --member=serviceAccount:${GCP_SVC_ACC}  --role=roles/compute.admin --role=roles/storage..admin, --role= roles/cloud sql.admin,  
Create the network 
Virtual Private Cloud (VPC) network 


i)  Name to  network.
>> gcloud compute networks create Threetiernetwoek \
    --subnet-mode=custom \
    --bgp-routing-mode=Dynamic \
    --mtu=MTU




Ii ) For Subnet creation mode, . (Auto mode networks create subnets in each region automatically)
>> gcloud compute networks subnets create PrivateSubnet \
    --network= Threetiernetwoek \ 
    --range=10.0.0.0/8\
    --region=us-central1a
>> gcloud compute networks subnets create PublicSubnet \
    --network= Threetiernetwoek \ 
    --range=192.168.2.10/8\
    --region=us-central1a
iii) Add the Routes 
gcloud compute routes create pub_pvt \
    --destination-range= 192.168.2.10/8\
    --network=PrivateSubnet \
  
gcloud compute routes create pub_pvt \
    --destination-range= 10.0.0.0/8\
    --network=PublicSubnet \


iii) For VPC Firewall rules, check all available rules. (These are the same standard firewall rules that the default network had)
Ingress : Allow: 0.0.0.0/3000
Egress : Allow 0.0.0.0/0
.
>> gcloud compute firewall-rules create "Public-http-rule" --allow=http:3000 --source-ranges="192.168.2.10/8" --description="Narrowing TCP traffic"

>> gcloud compute firewall-rules create "Private-http-rule" --allow=http:3000 --source-ranges="10.0.0.0/8" --description="Narrowing TCP traffic"



Create the Compute instance templates for the front end 
> gcloud compute instance-templates create FE_instance_templ \
    --machine-type=e2-standard-4 \
    --image-family=debian-10 \
    --image-project=debian-cloud \
    --boot-disk-size=50GB
    – network = PublicSubnet





> gcloud compute instance-templates create BE_instance_templ \
    --machine-type=e2-med-64 \
    --image-family=debian-10 \
    --image-project=debian-cloud \
    --boot-disk-size=200GB
    – network = PrivateSubnet



Create instance groups for frontend and backend
For the frond end 

> gcloud compute instance-groups managed create frontend-managed-instance-group --zone us-central1-a --template FE_instance_templ  --size 10 --health-check=  http-basic-check 

Instance group, define an HTTP service and map a port name to the relevant port. The load balancing service forwards traffic to the named port.


> gcloud compute instance-groups set-named-ports frontend-managed-instance-group \
    --named-ports http:80 \
    --zone us-central1




For Baceknd Managed instance groups 


> gcloud compute instance-groups managed create backendend-managed-instance-group --zone us-central1-a --template BE_instance_templ  --size 10 --health-check= http-basic-check 



> gcloud compute instance-groups set-named-ports frontend-managed-instance-group \
    --named-ports http:80 \
    --zone us-central1a-b




Create External Load Balancers and set the backend targets as the FE instance groups in public network 


> gcloud compute health-checks create http http-basic-check \
      --port 80

> gcloud compute backend-services create web-backend-service \
      --load-balancing-scheme=EXTERNAL \
      --protocol=HTTP \
      --port-name=http \
      --health-checks=http-basic-check \
      --global
 

Add your instance group as the backend to the backend service.

>  gcloud compute backend-services add-backend web-backend-service \
      --instance-group=backendend-managed-instance-group \
      --instance-group-zone=us-central1a \
      --global


For HTTP, create a URL map to route the incoming requests to the default backend service.

 gcloud compute url-maps create web-map-http \
      --default-service web-backend-service

Setting up an HTTP frontend
> For HTTP, create a target HTTP proxy to route requests to your URL map.
 gcloud compute target-http-proxies create http-lb-proxy \
      --url-map=web-map-http

For HTTP, create a global forwarding rule to route incoming requests to the proxy
> gcloud compute forwarding-rules create http-content-rule \
      --load-balancing-scheme=EXTERNAL \
      --address=lb-ipv4-1 \
      --global \
      --target-http-proxy=http-lb-proxy \
      --ports=80






Create internal load balancer and associated backend targets for 

HEALTH CHECKS
> gcloud compute health-checks create http l7-ilb-basic-check \
   --region=us-cental-1a\
   --use-serving-port

ATTACH BACKEND


>gcloud compute backend-services create l7-ilb-backend-service \
  --load-balancing-scheme=INTERNAL_MANAGED \
  --protocol=HTTP \
  --health-checks=l7-ilb-basic-check \
  --health-checks-region=us-central1 \
  --region=us-central1

Set up the service with the instance group
gcloud compute backend-services add-backend backendend-managed-instance-group \
  --balancing-mode=UTILIZATION \
  --instance-group=backendend-managed-instance-group \
  --instance-group-zone=us-central1-a \
  --region=us-west1




Create the database :

The gcloud sql instance thats been create dwhich will be only accesed by our Backend instances 
gcloud sql instances create prod-instance --database-version=SQLSERVER_2017_EXPRESS --cpu=2 --memory=3840MiB --zone=us-central1-a --root-password=password123
--authorized-networks=10.0.0.0/8










+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Q2:   METADATA FOR A EC2 INSTAVE IN JSON

The instance metadata needs to be fetched from the instance and a the metadataservice is running ('http://169.254.169.254/latest/meta-data/')  which provides the all metadata and we use it in json format . The code provided just use the above uri and gets the instance metadata .



The code is run 
> python3 metadata.py


Here we have shown the meta data for 
> ami-id
> public-hostname

We can get the metadata for all the values 



+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Q3: STRING FIND VALUE FOR COMBINED KEYS 

For {"a":{"b":{"c":{"d":"e"}}}} for a 

key of a/b/c/d/ Val = e
Key b/c/d/     Val = e

Solution: 
We can consider this structure as tree 
A →b →c →d –e



Wherefor a key  we can get the last node/nodes as val 
We use DFS
As we have DFS key = A–B  then DFS will spill values from B to end node that is E
So we get C D E as the value for key . 

Implementation:
This is implemented in a clever way with string modification and keeping the string in a map of the key 
a





