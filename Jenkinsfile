//def templatePath = 'https://github.com/m1k3dcdc/cheese-java-pipeline-01/blob/main/deployscripts/cheese-java-pipeline-template.yaml'
def templatePath = './deployscripts/cheese-java-pipeline-template.yaml'
def templateName = 'cheese-java-pipeline-template'
def APPName = 'cheese-java-pipeline'
pipeline {
  agent any

  options {
    timeout(time: 10, unit: 'MINUTES') 
  }
  
  stages {
    stage('preamble') {
        steps {
            script {
                echo "STAGE: preamble"
                openshift.withCluster() {
                    openshift.withProject() {
                        echo "Using project: ${openshift.project()}"

                        // Create a Selector capable of selecting all service accounts in mycluster's default project
                        def saSelector = openshift.selector( 'serviceaccount' )                    
                        // Prints `oc describe serviceaccount` to Jenkins console
                        saSelector.describe()                    
                        // Selectors also allow you to easily iterate through all objects they currently select.
                        saSelector.withEach { // The closure body will be executed once for each selected object.
                            // The 'it' variable will be bound to a Selector which selects a single
                            // object which is the focus of the iteration.
                            echo "Service account: ${it.name()} is defined in ${openshift.project()}"
                        }                    
                        // Prints a list of current service accounts to the console
                        echo "There are ${saSelector.count()} service accounts in project ${openshift.project()}"
                        echo "They are named: ${saSelector.names()}"
                    }
                }
            }
        }
    }
    stage('cleanup') {
      steps {
        script {
            echo "STAGE: cleanup"
            openshift.withCluster() {
                openshift.withProject() {
                  //openshift.selector("all", [ template : templateName ]).delete() 
                  //openshift.selector( 'dc', [ environment:'qe' ] ).delete()
                  if (openshift.selector("is", APPName).exists()) { 
                    openshift.selector("is", APPName).delete()
                  }
                  if (openshift.selector("bc", APPName).exists()) { 
                    openshift.selector("bc", APPName).delete()
                  }
                  if (openshift.selector("deploy", APPName).exists()) { 
                    openshift.selector("deploy", APPName).delete()
                  }                  
                  if (openshift.selector("svc", APPName).exists()) { 
                    openshift.selector("svc", APPName).delete()
                  }
                  if (openshift.selector("route", APPName).exists()) { 
                    openshift.selector("route", APPName).delete()
                  }
                }
            }
        }
      }
    }
    stage('create') {
      steps {
        script {
            echo "STAGE: create"
            openshift.withCluster() {
                openshift.withProject() {
                  openshift.newApp(templatePath) 
                }
            }
        }
      }
    }
    stage('build') {
      steps {
        script {
            echo "STAGE: build"
            openshift.withCluster() {
                openshift.withProject() {
                  echo "*** Start Build"

                  def buildConfigExists = openshift.selector("bc", APPName).exists()
                    
                  echo "### BuildConfig: " + APPName + " exists, start new build ..."
                  if (!buildConfigExists) {
                        echo "### newBuild " + APPName
                        openshift.newBuild("--name=${APPName}", "--image=docker.io/m1k3pjem/hello-java-spring-boot", "--binary")
                  }    
                  def startBuildLog = openshift.selector("bc", APPName).startBuild("--from-dir=.")
                  startBuildLog.logs('-f')
                
                  if (!openshift.selector("route", APPName).exists()) {
                      echo "### Route " + APPName + " does not exist, exposing service ..." 
                      def service = openshift.selector("service", APPName)
                      service.expose()
                  } else {
                      echo "### Route " + APPName + " exist" 
                  }
                  
                  //def buildSelector = openshift.selector("bc", APPName).startBuild()
                  //buildSelector.logs('-f')
                  /*
                  def builds = openshift.selector("bc", APPName).related('builds')
                  echo "*** BUILS related"
                  timeout(5) { 
                    builds.untilEach(1) {
                      return (it.object().status.phase == "Complete")
                    }
                  }*/
                }
            }
        }
      }
    } 
   /* stage('deploy') {
      steps {
        script {
            echo "STAGE: deploy"
            openshift.withCluster() {
                openshift.withProject() {
                  def rm = openshift.selector("deploy", APPName).rollout()
                  timeout(5) { 
                    openshift.selector("deploy", APPName).related('pods').untilEach(1) {
                      return (it.object().status.phase == "Running")
                    }
                  }
                }
            }
        }
      }
    } */
  /*  stage('tag') {
      steps {
        script {
            echo "STAGE: tag"
            openshift.withCluster() {
                openshift.withProject() {
                  openshift.tag("${APPName}:latest", "${APPName}-staging:latest") 
                }
            }
        }
      }
    } */
  }
}
