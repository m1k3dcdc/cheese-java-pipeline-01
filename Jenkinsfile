pipeline {
    options {
        // set a timeout of 60 minutes for this pipeline
        timeout(time: 10, unit: 'MINUTES')
    }

    environment {
        APP_NAME = "cheese-java-pipeline-01"
        BUILDCONFIG_NAME = "cheese-java-pipeline-01-bc"
        DEV_PROJECT = "mavc23-dev"
        APP_GIT_URL = "https://github.com/m1k3dcdc/hello-java-spring-boot.git"
    }
    
    agent any

    stages {
        stage('Deploy to DEV environment') {
            steps {
                echo '###### Deploy to DEV environment ######'
                script {
                    openshift.withCluster() {
                        openshift.withProject("$DEV_PROJECT") {
                            echo "Using project: ${openshift.project()}"
                            // If BuildConfig already exists, start a new build to update the application
                            if (openshift.selector("bc", BUILDCONFIG_NAME).exists()) {
                                echo "BuildConfig " + BUILDCONFIG_NAME + " exists, start new build to update app ..."
                                // Start new build (it corresponds to oc start-build <buildconfig>)
                                def bc = openshift.selector("bc", "${BUILDCONFIG_NAME}")
                                bc.startBuild()
                            } else {
                                // If BuildConfig does not exist, create
                                echo "- BuildConfig " + BUILDCONFIG_NAME + " does not exist, creating from BuildConfig.yaml ..."
                                //oc set triggers bc/cheese-java-pipeline --from-github
                                //openshift.newApp('deployscripts/BuildConfig.yaml')
                                openshift.newBuild("--name=${BUILDCONFIG_NAME}", "--image=docker.io/m1k3pjem/hello-java-spring-boot", "--binary")
                                //sh "oc create -f deployscripts/BuildConfig.yaml -n ${DEV_PROJECT}"
                                //openshift.selector("bc", "${BUILDCONFIG_NAME}").startBuild("--from-dir=.", "--follow")
                                def bc = openshift.selector("bc", "${BUILDCONFIG_NAME}")
                                bc.startBuild()
                                //sh "oc start-build ${BUILDCONFIG_NAME} --follow"                                
                            }
                            /*
                            // If a Route does not exist, expose the Service and create the Route
                            if (!openshift.selector("route", APP_NAME).exists()) {
                                echo "Route " + APP_NAME + " does not exist, exposing service ..." 
                                //def service = openshift.selector("service", APP_NAME)
                                //service.expose()
                            } else {
                                def route = openshift.selector("route", APP_NAME)
                                echo "Test application with "
                                def result = route.describe()   
                            }    */
                        } // withProject
                    } // withCluster
                } // script
            } // steps
        } // stage

        stage('Deploy') {
          steps {
            echo 'Deploying....'
            script {
              openshift.withCluster() {
                openshift.withProject("$DEV_PROJECT") {
    
                  def deployment = openshift.selector("dc", "${APP_NAME}")
    
                  if (!deployment.exists()) {
                    //openshift.newApp('hello-java-spring-boot', "--as-deployment-config").narrow('svc').expose()
                    sh "oc apply -f ./deploy.yml -n ${DEV_PROJECT}"
                  }
    
                }    // withProject
              }    // withCluster
            }    // script
          }    // steps
        } // stage
    }
}
