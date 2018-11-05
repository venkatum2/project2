pipeline {
    agent {
        label "jenkins-nodejs"
    }
    environment {
      ORG               = 'mw-devops'
      APP_NAME          = 'tmn-member-app'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    }

    stages {
      stage('CI Build PR and Push Snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          dir ('./member-app') {
            container('nodejs') {
              sh "npm install"
              sh "CI=true DISPLAY=:99 npm test"
              sh "ionic build"
              sh 'export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml'
              sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"

            }
          }

          dir ('./member-app/charts/preview') {
           container('nodejs') {
             sh "printenv"
             sh "make preview"
             sh "jx preview --app $APP_NAME --dir ../../.. --namespace $PREVIEW_NAMESPACE --tls-acme true"
           }
          }
        }
      }
      stage('Build Release') {
        when {
          branch 'develop'
        }
        steps {
          container('nodejs') {
           // ensure we're not on a detached head
            sh "git checkout develop"
            sh "git config --global credential.helper store"

            sh "jx step git credentials"
            // so we can retrieve the version in later steps
            sh "jx step next-version -b --use-git-tag-only"

          }
          dir ('./member-app/charts/tmn-member-app') {
            container('nodejs') {
              //pushes tag to remote repo
              sh "make tag"
            }
          }
          dir ('./member-app') {
            container('nodejs') {
              sh "npm install"
              sh "CI=true DISPLAY=:99 npm test"
              sh "npm install -g ionic"
              script{
                if (env.BRANCH_NAME == 'master') {
                  sh 'ionic build -prod'
                } else {
                  sh 'ionic build'
                }
              }

              sh 'export VERSION=`cat ../VERSION` && skaffold build -f skaffold.yaml'
              sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat ../VERSION)"
            }
          }
        }
      }
      stage('Auto Promote Develop') {
        when {
          branch 'develop'
        }
        steps {
          dir ('./member-app/charts/tmn-member-app') {
            container('nodejs') {
              sh 'jx step changelog --version v\$(cat ../../../VERSION)'
              // release the helm chart

              sh 'jx step helm release'
              // promote through all 'Auto' promotion Environments
              sh 'jx promote -b --all-auto --timeout 1h --version \$(cat ../../../VERSION)'
            }
          }
        }
      }
    }
    post {
        always {
            cleanWs()
        }
    }
  }
