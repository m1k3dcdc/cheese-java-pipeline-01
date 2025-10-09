#source ./setenv.sh
# ##### Variable section - START
SCRIPT=deploy.sh
PLATFORM_OPTION=$1
AWS_ACCESS_KEY=$2
AWS_SECRET_KEY=$3
DEPLOY_FUNCTION=
# ##### Variable section - END

# ***** Function section - START
deployToRaspberry()
{
	## Deploy Windfire Restaurants backend component to remote Raspberry box
    echo ${cyn}Deploy Windfire Restaurants backend component to Raspberry Pi ...${end}
    export ANSIBLE_CONFIG=$PWD/deployment/raspberry/ansible.cfg
    ansible-playbook deployment/raspberry/deploy.yaml 
    echo ${cyn}Done${end}
    echo
}

deployToAWS()
{
    if [ "$AWS_ACCESS_KEY" == "" ]; then
        printInsertAWS_KEY
    fi
    if [ "$AWS_SECRET_KEY" == "" ]; then
        printInsertAWS_SECRET
    fi
    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
	## Deploy Windfire Restaurants backend component to AWS
    echo ${cyn}Deploy Windfire Restaurants backend component to AWS ...${end}
    ## Dynamically create Ansible configuration files for AWS deployment
    ANSIBLE_CONFIG_FILE=ansible-aws.cfg
    echo ${cyn}Invoking ansible-config.sh to dynamically create configuration files for Ansible ...${end}
    deployment/aws/ansible-config.sh $ANSIBLE_CONFIG_FILE $PLATFORM_OPTION
    export ANSIBLE_CONFIG=$PWD/deployment/aws/$ANSIBLE_CONFIG_FILE
    echo
    ## Run Ansible playbook for AWS deployment
    ansible-playbook -i deployment/aws/windfire.aws_ec2.yaml deployment/aws/deploy.yaml
    echo ${cyn}Done${end}
    echo
}

deployToOpenShift()
{
	## Deploy Windfire Restaurants backend component to Red Hat OpenShift using Template
    echo ${cyn}Deploy Cheese component to Red Hat OpenShift using Template ...${end}
    deployscripts/oc-deploy.sh
    echo ${cyn}Done${end}
    echo
}

runOpenShiftPipeline()
{
	## Deploy Windfire Restaurants backend component to Red Hat OpenShift using OpenShift pipeline
    echo ${cyn}Deploy Windfire Restaurants backend component to Red Hat OpenShift using OpenShift Pipeline ...${end}
    deployment/openshift/tekton/run-pipeline.sh
    echo ${cyn}Done${end}
    echo
}

deploy()
{
    #rm -rf $PWD/app/node_modules
    if [ -z $PLATFORM_OPTION ]; then 
        printSelectPlatform
    fi
    $DEPLOY_FUNCTION
}

printInsertAWS_KEY()
{
	echo ${grn}Insert AWS Key : ${end}
	read AWS_ACCESS_KEY
}

printInsertAWS_SECRET()
{
	echo ${grn}Insert AWS Secret : ${end}
	read AWS_SECRET_KEY
}

printSelectPlatform()
{
	echo ${grn}Select deployment platform : ${end}
    echo "${grn}1. Raspberry${end}"
    echo "${grn}2. AWS Single Zone${end}"
    echo "${grn}3. AWS Multi Zone${end}"
    echo "${grn}4. OpenShift (using Template)${end}"
    echo "${grn}5. OpenShift (using OpenShift Pipelines)${end}"
	read PLATFORM_OPTION
	setDeployFunction
}

setDeployFunction()
{
	case $PLATFORM_OPTION in
		1)  DEPLOY_FUNCTION="deployToRaspberry"
			;;
        2)  DEPLOY_FUNCTION="deployToAWS"
            ;;
        3)  DEPLOY_FUNCTION="deployToAWS"
            ;;
        4)  DEPLOY_FUNCTION="deployToOpenShift"
            ;;
        5)  DEPLOY_FUNCTION="runOpenShiftPipeline"
            ;;
		*) 	printf "\n${red}No valid option selected${end}\n"
			printSelectPlatform
			;;
	esac
}
# ***** Function section - END

# ##############################################
# #################### MAIN ####################
# ##############################################
# ************ START evaluate args ************"
if [ "$1" != "" ]; then
    setDeployFunction
fi
# ************** END evaluate args **************"
RUN_FUNCTION=deploy
$RUN_FUNCTION