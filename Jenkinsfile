def templatePath = 'https://github.com/m1k3dcdc/cheese-java-pipeline-01/blob/main/deployscripts/cheese-java-pipeline-template.yaml'
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
                  openshift.selector("all", [ template : templateName ]).delete() 
                  //openshift.selector( 'dc', [ environment:'qe' ] ).delete()
                  if (openshift.selector("bc", APPName).exists()) { 
                    openshift.selector("bc", APPName).delete()
                  } 
                  if (openshift.selector("dc", APPName).exists()) { 
                    openshift.selector("dc", APPName).delete()
                  }
                  if (openshift.selector("secrets", APPName).exists()) { 
                    openshift.selector("secrets", APPName).delete()
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
  /*  stage('build') {
      steps {
        script {
            echo "STAGE: build"
            openshift.withCluster() {
                openshift.withProject() {
                  def builds = openshift.selector("bc", templateName).related('builds')
                  timeout(5) { 
                    builds.untilEach(1) {
                      return (it.object().status.phase == "Complete")
                    }
                  }
                }
            }
        }
      }
    } */
   /* stage('deploy') {
      steps {
        script {
            echo "STAGE: deploy"
            openshift.withCluster() {
                openshift.withProject() {
                  def rm = openshift.selector("dc", templateName).rollout()
                  timeout(5) { 
                    openshift.selector("dc", templateName).related('pods').untilEach(1) {
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
                  openshift.tag("${templateName}:latest", "${templateName}-staging:latest") 
                }
            }
        }
      }
    } */
  }
}
