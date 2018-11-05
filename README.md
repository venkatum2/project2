# AET Member Web Application
Below are instructions for getting started, debugging, testing and deploying the AET Member web application. 
## Getting Started
Install dependencies
```sh
$ npm install 
```
## Debug
Serve the Ionic application and debug in your default browser with:
```sh
$ ionic serve
```
This will enable live-reloading so you won't have to restart the service every time you make a change in the source code. 
## Build
Create a production build using Ionic's build script:
```sh
$ ionic build --prod
``` 
where `--prod` flags the build as production. This will created a library in the `~/www/` folder that contains necessary HTML, CSS and JS files to serve the application. 
## Deploy to Kubernetes
Set the shell variable for your Project ID so we don't have to re-type it with:
```sh
$ export PROJECT_ID="$(gcloud config get-value project -q)"
```
Once this is set, build the docker image using the following command:
```sh
$ docker build -t gcr.io/${PROJECT_ID}/aet-tmn-member-app:v1 .
```
This will create a new image from the `Dockerfile` at the project root and tag it with a name and a version. The `gcr.io` prefix refers to the Google Container Registry, where the image will be hosted. Confirm that the image was created with:
```sh
$ docker images
```
You should see the REPOSITORY, TAG, IMAGE ID, CREATED and SIZE properties of the new image. 
To run the docker image locally use the following command:
```sh
$ docker run --rm -p 8081:80 gcr.io/${PROJECT_ID}/aet-tmn-member-app:v1
```
This will expose the application on port 8081 of your localhost. 
After you confirm that the application is running successfully, login to the kubernetes service with:
```sh
$ gcloud auth configure-docker
```
This will authenticate your local machine to the GCP Container Registry for your project. Now, use the Docker command line to push this image to GCP:
```sh
$ docker push gcr.io/${PROJECT_ID}/aet-tmn-member-app:v1
```
More detailed information on deployments and updates can be found [here](https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app). Two shell scripts have also been included to orchestrate the image build (`$ bash docker-build.sh`) and the command to run locally (`$ bash docker-start.sh`). 
## Test
The packages [here](https://github.com/ionic-team/ionic-unit-testing-example) have been included in this application. Please reference these until additional documentation is added to this README. 
## Notes
The source tree contains two Firebase files (`firebase.json` & `.firebaserc`). These will be removed from this repository once we confirm that Firebase will not be used for deployment. 
